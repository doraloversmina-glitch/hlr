import {
  ExecutionState,
  StackFrame,
  Variable,
  HeapBlock,
  MemoryError,
  ExecutionEvent,
  PointerValue,
  CType,
  ASTNode
} from '../types';

export class Interpreter {
  private state: ExecutionState;
  private nextStackAddress = 0x7FFF_F000;
  private nextHeapAddress = 0x0040_0000;
  private heapBlockCounter = 0;

  constructor(code: string) {
    this.state = {
      programCounter: 0,
      callStack: [],
      heap: new Map(),
      globalScope: new Map(),
      errors: [],
      log: [],
      isRunning: false,
      isHalted: false,
      currentLine: 1,
      code,
      lines: code.split('\n')
    };
  }

  getState(): ExecutionState {
    return this.state;
  }

  initializeMain() {
    const mainFrame: StackFrame = {
      functionName: 'main',
      variables: new Map(),
      returnAddress: 0,
      framePointer: this.formatAddress(this.nextStackAddress)
    };

    this.nextStackAddress -= 0x1000;
    this.state.callStack.push(mainFrame);
    this.addLog(1, 'info', 'Started main()');
  }

  executeStatement(node: ASTNode): void {
    if (this.state.isHalted) return;

    this.state.currentLine = node.line || this.state.currentLine;

    try {
      switch (node.type) {
        case 'declaration':
          this.executeDeclaration(node);
          break;

        case 'assignment':
          this.executeAssignment(node);
          break;

        case 'pointer_assignment':
          this.executePointerAssignment(node);
          break;

        case 'array_assignment':
          this.executeArrayAssignment(node);
          break;

        case 'function_call':
          this.executeFunctionCall(node);
          break;

        case 'block':
          if (node.children) {
            node.children.forEach(child => this.executeStatement(child));
          }
          break;

        case 'if_statement':
          this.executeIf(node);
          break;

        case 'while_statement':
          this.executeWhile(node);
          break;

        case 'for_statement':
          this.executeFor(node);
          break;

        case 'return_statement':
          this.state.isHalted = true;
          this.addLog(node.line!, 'info', 'Program completed');
          break;

        case 'function_definition':
          if (node.children && node.children[0]) {
            this.executeStatement(node.children[0]);
          }
          break;

        default:
          break;
      }
    } catch (error: any) {
      this.addError(node.line!, 'SYNTAX', error.message);
      this.state.isHalted = true;
    }
  }

  private executeDeclaration(node: ASTNode): void {
    const { baseType, name, isPointer, isArray, arraySize } = node.value;
    const frame = this.getCurrentFrame();

    let type: CType;
    let value: any;
    let size: number;

    if (isArray) {
      size = (baseType === 'int' ? 4 : 1) * (arraySize || 0);
      type = {
        kind: 'array',
        size,
        baseType: { kind: baseType, size: baseType === 'int' ? 4 : 1 },
        length: arraySize
      };
      value = new Array(arraySize).fill(0);
    } else if (isPointer) {
      size = 8; // Pointer size
      type = {
        kind: 'pointer',
        size,
        baseType: { kind: baseType, size: baseType === 'int' ? 4 : 1 }
      };
      value = { targetBlock: null, offset: 0 } as PointerValue;
    } else {
      size = baseType === 'int' ? 4 : 1;
      type = { kind: baseType, size };
      value = 0;
    }

    // Check for initialization
    if (node.children && node.children.length > 0) {
      value = this.evaluateExpression(node.children[0]);
    }

    const address = this.formatAddress(this.nextStackAddress);
    this.nextStackAddress -= size;

    const variable: Variable = {
      name,
      type,
      value,
      address,
      size,
      isPointer,
      isArray
    };

    frame.variables.set(name, variable);

    this.addLog(
      node.line!,
      'declaration',
      `Declared ${baseType}${isPointer ? '*' : ''}${isArray ? '[]' : ''} ${name} = ${this.valueToString(value)}`
    );
  }

  private executeAssignment(node: ASTNode): void {
    const { name } = node.value;
    const frame = this.getCurrentFrame();
    const variable = frame.variables.get(name);

    if (!variable) {
      throw new Error(`Variable ${name} not declared`);
    }

    const newValue = this.evaluateExpression(node.children![0]);
    variable.value = newValue;

    this.addLog(
      node.line!,
      'assignment',
      `${name} = ${this.valueToString(newValue)}`
    );
  }

  private executePointerAssignment(node: ASTNode): void {
    const { name } = node.value;
    const frame = this.getCurrentFrame();
    const variable = frame.variables.get(name);

    if (!variable || !variable.isPointer) {
      throw new Error(`${name} is not a pointer`);
    }

    const ptrValue = variable.value as PointerValue;

    // Check for null dereference
    if (ptrValue.targetBlock === null) {
      this.addError(node.line!, 'NULL_DEREF', `Dereferencing NULL pointer ${name}`);
      this.state.isHalted = true;
      return;
    }

    // Check for use-after-free
    if (ptrValue.targetBlock.startsWith('heap_')) {
      const block = this.state.heap.get(ptrValue.targetBlock);
      if (block && block.status === 'freed') {
        this.addError(node.line!, 'UAF', `Use-after-free: pointer ${name} points to freed memory`);
        this.state.isHalted = true;
        return;
      }
    }

    const newValue = this.evaluateExpression(node.children![0]);

    // Write to heap or stack
    if (ptrValue.targetBlock.startsWith('heap_')) {
      const block = this.state.heap.get(ptrValue.targetBlock)!;
      const index = Math.floor(ptrValue.offset / 4);
      block.data[index] = newValue as number;
      this.addLog(node.line!, 'assignment', `*${name} = ${newValue} (heap write)`);
    } else {
      // Find the target variable and update it
      for (const [varName, varData] of frame.variables) {
        if (varData.address === ptrValue.targetBlock) {
          varData.value = newValue;
          this.addLog(node.line!, 'assignment', `*${name} = ${newValue} (${varName})`);
          break;
        }
      }
    }
  }

  private executeArrayAssignment(node: ASTNode): void {
    const { name } = node.value;
    const frame = this.getCurrentFrame();
    const variable = frame.variables.get(name);

    if (!variable || !variable.isArray) {
      throw new Error(`${name} is not an array`);
    }

    const index = this.evaluateExpression(node.children![0]) as number;
    const value = this.evaluateExpression(node.children![1]) as number;

    const arr = variable.value as number[];

    // Check bounds
    if (index < 0 || index >= arr.length) {
      this.addError(node.line!, 'OOB', `Array index ${index} out of bounds [0, ${arr.length})`);
      this.state.isHalted = true;
      return;
    }

    arr[index] = value;
    this.addLog(node.line!, 'assignment', `${name}[${index}] = ${value}`);
  }

  private executeFunctionCall(node: ASTNode): void {
    const { name } = node.value;

    if (name === 'malloc') {
      this.executeMalloc(node);
    } else if (name === 'free') {
      this.executeFree(node);
    }
  }

  private executeMalloc(node: ASTNode): void {
    const sizeExpr = node.children![0];
    const size = this.evaluateExpression(sizeExpr) as number;

    const blockId = `heap_${this.formatAddress(this.nextHeapAddress)}`;
    const address = this.formatAddress(this.nextHeapAddress);

    const block: HeapBlock = {
      id: blockId,
      address,
      size,
      status: 'allocated',
      data: new Array(Math.ceil(size / 4)).fill(0),
      allocatedAt: node.line!
    };

    this.state.heap.set(blockId, block);
    this.nextHeapAddress += size + 16; // Add padding

    this.addLog(node.line!, 'malloc', `malloc(${size}) → ${address}`);

    // Return pointer value (will be used in assignment)
    this.lastMallocResult = { targetBlock: blockId, offset: 0 };
  }

  private executeFree(node: ASTNode): void {
    const ptrExpr = node.children![0];
    const ptrValue = this.evaluateExpression(ptrExpr) as PointerValue;

    if (ptrValue.targetBlock === null) {
      this.addError(node.line!, 'NULL_DEREF', 'Attempting to free NULL pointer');
      this.state.isHalted = true;
      return;
    }

    const block = this.state.heap.get(ptrValue.targetBlock);

    if (!block) {
      this.addError(node.line!, 'SYNTAX', 'Invalid pointer passed to free()');
      this.state.isHalted = true;
      return;
    }

    if (block.status === 'freed') {
      this.addError(node.line!, 'DOUBLE_FREE', `Double free detected at ${block.address}`);
      this.state.isHalted = true;
      return;
    }

    block.status = 'freed';
    block.freedAt = node.line!;

    this.addLog(node.line!, 'free', `free(${block.address})`);
  }

  private executeIf(node: ASTNode): void {
    const condition = this.evaluateExpression(node.children![0]) as number;

    if (condition !== 0) {
      this.executeStatement(node.children![1]);
    } else if (node.children!.length > 2) {
      this.executeStatement(node.children![2]);
    }
  }

  private executeWhile(node: ASTNode): void {
    let iterations = 0;
    const MAX_ITERATIONS = 1000;

    while (iterations < MAX_ITERATIONS) {
      const condition = this.evaluateExpression(node.children![0]) as number;
      if (condition === 0) break;

      this.executeStatement(node.children![1]);
      iterations++;
    }

    if (iterations >= MAX_ITERATIONS) {
      this.addError(node.line!, 'SYNTAX', 'Infinite loop detected');
      this.state.isHalted = true;
    }
  }

  private executeFor(node: ASTNode): void {
    // Init
    this.executeStatement(node.children![0]);

    let iterations = 0;
    const MAX_ITERATIONS = 1000;

    while (iterations < MAX_ITERATIONS) {
      // Condition
      const condition = this.evaluateExpression(node.children![1]) as number;
      if (condition === 0) break;

      // Body
      this.executeStatement(node.children![3]);

      // Update
      this.executeStatement(node.children![2]);

      iterations++;
    }

    if (iterations >= MAX_ITERATIONS) {
      this.addError(node.line!, 'SYNTAX', 'Infinite loop detected');
      this.state.isHalted = true;
    }
  }

  private lastMallocResult: PointerValue | null = null;

  private evaluateExpression(node: ASTNode): any {
    switch (node.type) {
      case 'number_literal':
        return node.value;

      case 'identifier': {
        const frame = this.getCurrentFrame();
        const variable = frame.variables.get(node.value);
        return variable ? variable.value : 0;
      }

      case 'address_of': {
        const frame = this.getCurrentFrame();
        const variable = frame.variables.get(node.value.name);
        if (!variable) throw new Error(`Variable ${node.value.name} not found`);

        return {
          targetBlock: variable.address,
          offset: 0
        } as PointerValue;
      }

      case 'dereference': {
        const frame = this.getCurrentFrame();
        const variable = frame.variables.get(node.value.name);
        if (!variable) throw new Error(`Variable ${node.value.name} not found`);

        const ptrValue = variable.value as PointerValue;
        if (ptrValue.targetBlock === null) {
          throw new Error('Null pointer dereference');
        }

        // Find target variable
        for (const [_, varData] of frame.variables) {
          if (varData.address === ptrValue.targetBlock) {
            return varData.value;
          }
        }

        return 0;
      }

      case 'array_access': {
        const frame = this.getCurrentFrame();
        const variable = frame.variables.get(node.value.name);
        if (!variable) throw new Error(`Variable ${node.value.name} not found`);

        const index = this.evaluateExpression(node.children![0]) as number;
        const arr = variable.value as number[];

        if (index < 0 || index >= arr.length) {
          throw new Error('Array index out of bounds');
        }

        return arr[index];
      }

      case 'malloc':
        // This was already executed, return the result
        return this.lastMallocResult;

      case 'sizeof': {
        const type = node.value.type;
        return type === 'int' ? 4 : 1;
      }

      case 'binary_op': {
        const left = this.evaluateExpression(node.children![0]) as number;
        const right = this.evaluateExpression(node.children![1]) as number;
        const op = node.value.operator;

        switch (op) {
          case '+': return left + right;
          case '-': return left - right;
          case '*': return left * right;
          case '/': return Math.floor(left / right);
          case '<': return left < right ? 1 : 0;
          case '>': return left > right ? 1 : 0;
          case '=': return left === right ? 1 : 0;
          default: return 0;
        }
      }

      default:
        return 0;
    }
  }

  private getCurrentFrame(): StackFrame {
    if (this.state.callStack.length === 0) {
      throw new Error('No active stack frame');
    }
    return this.state.callStack[this.state.callStack.length - 1];
  }

  private formatAddress(addr: number): string {
    return '0x' + addr.toString(16).toUpperCase().padStart(8, '0');
  }

  private valueToString(value: any): string {
    if (typeof value === 'number') return value.toString();
    if (Array.isArray(value)) return `[${value.join(', ')}]`;
    if (value && typeof value === 'object' && 'targetBlock' in value) {
      return value.targetBlock || 'NULL';
    }
    return String(value);
  }

  private addLog(line: number, type: ExecutionEvent['type'], message: string): void {
    this.state.log.push({
      line,
      type,
      message,
      timestamp: Date.now()
    });
  }

  private addError(line: number, type: MemoryError['type'], message: string): void {
    const error: MemoryError = {
      type,
      message,
      line
    };
    this.state.errors.push(error);
  }

  checkForLeaks(): void {
    const leaks: HeapBlock[] = [];

    for (const [_, block] of this.state.heap) {
      if (block.status === 'allocated') {
        leaks.push(block);
      }
    }

    if (leaks.length > 0) {
      this.addError(
        this.state.currentLine,
        'LEAK',
        `${leaks.length} memory leak(s) detected`
      );
    }
  }
}
