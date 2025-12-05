import { ASTNode } from '../types';

/**
 * Simple C Parser for Educational Purposes
 * Supports: int declarations, pointers, arrays, malloc, free, assignments, if, while
 */

export class CParser {
  private tokens: string[] = [];
  private position = 0;
  private currentLine = 1;

  parse(code: string): ASTNode[] {
    // Remove comments
    code = this.removeComments(code);

    // Simple tokenization
    this.tokens = this.tokenize(code);
    this.position = 0;

    const statements: ASTNode[] = [];

    while (this.position < this.tokens.length) {
      const stmt = this.parseStatement();
      if (stmt) {
        statements.push(stmt);
      }
    }

    return statements;
  }

  private removeComments(code: string): string {
    // Remove single-line comments
    code = code.replace(/\/\/.*$/gm, '');
    // Remove multi-line comments
    code = code.replace(/\/\*[\s\S]*?\*\//g, '');
    return code;
  }

  private tokenize(code: string): string[] {
    const tokens: string[] = [];
    let current = '';
    let line = 1;

    for (let i = 0; i < code.length; i++) {
      const char = code[i];

      if (char === '\n') {
        if (current.trim()) tokens.push(current.trim());
        current = '';
        line++;
        continue;
      }

      if (char === ' ' || char === '\t') {
        if (current.trim()) tokens.push(current.trim());
        current = '';
        continue;
      }

      if ('(){}[];,*&=+-<>!'.includes(char)) {
        if (current.trim()) tokens.push(current.trim());
        tokens.push(char);
        current = '';
        continue;
      }

      current += char;
    }

    if (current.trim()) tokens.push(current.trim());

    return tokens;
  }

  private parseStatement(): ASTNode | null {
    if (this.position >= this.tokens.length) return null;

    const token = this.tokens[this.position];

    // Function definition
    if (token === 'int' && this.peek(2) === '(') {
      return this.parseFunctionDefinition();
    }

    // Variable declaration
    if (token === 'int' || token === 'char') {
      return this.parseDeclaration();
    }

    // Control flow
    if (token === 'if') {
      return this.parseIf();
    }

    if (token === 'while') {
      return this.parseWhile();
    }

    if (token === 'for') {
      return this.parseFor();
    }

    if (token === 'return') {
      return this.parseReturn();
    }

    if (token === '{') {
      return this.parseBlock();
    }

    if (token === '}') {
      this.position++;
      return null;
    }

    // Assignment or function call
    if (this.isIdentifier(token)) {
      return this.parseAssignmentOrCall();
    }

    this.position++;
    return null;
  }

  private parseFunctionDefinition(): ASTNode {
    const returnType = this.consume(); // int, void, etc.
    const name = this.consume(); // function name
    this.consume(); // (

    // Skip parameters for now
    while (this.current() !== ')') {
      this.position++;
    }
    this.consume(); // )

    const body = this.parseBlock();

    return {
      type: 'function_definition',
      value: { returnType, name },
      children: body ? [body] : [],
      line: this.currentLine
    };
  }

  private parseDeclaration(): ASTNode {
    const baseType = this.consume(); // int, char
    let isPointer = false;
    let isArray = false;
    let arraySize = 0;

    // Check for pointer
    if (this.current() === '*') {
      isPointer = true;
      this.consume();
    }

    const name = this.consume(); // variable name

    // Check for array
    if (this.current() === '[') {
      isArray = true;
      this.consume(); // [
      if (this.current() !== ']') {
        arraySize = parseInt(this.consume());
      }
      this.consume(); // ]
    }

    let initializer: ASTNode | null = null;

    // Check for initialization
    if (this.current() === '=') {
      this.consume(); // =
      initializer = this.parseExpression();
    }

    this.consume(); // ;

    return {
      type: 'declaration',
      value: { baseType, name, isPointer, isArray, arraySize },
      children: initializer ? [initializer] : [],
      line: this.currentLine
    };
  }

  private parseAssignmentOrCall(): ASTNode {
    const name = this.consume();

    // Array access: arr[i]
    if (this.current() === '[') {
      this.consume(); // [
      const index = this.parseExpression();
      this.consume(); // ]

      if (this.current() === '=') {
        this.consume(); // =
        const value = this.parseExpression();
        this.consume(); // ;

        return {
          type: 'array_assignment',
          value: { name },
          children: [index, value],
          line: this.currentLine
        };
      }
    }

    // Pointer dereference: *ptr = value
    if (name === '*') {
      const ptrName = this.consume();
      this.consume(); // =
      const value = this.parseExpression();
      this.consume(); // ;

      return {
        type: 'pointer_assignment',
        value: { name: ptrName },
        children: [value],
        line: this.currentLine
      };
    }

    // Function call: malloc(10)
    if (this.current() === '(') {
      this.consume(); // (
      const args: ASTNode[] = [];

      while (this.current() !== ')') {
        args.push(this.parseExpression());
        if (this.current() === ',') this.consume();
      }

      this.consume(); // )
      this.consume(); // ;

      return {
        type: 'function_call',
        value: { name },
        children: args,
        line: this.currentLine
      };
    }

    // Regular assignment: x = 5
    if (this.current() === '=') {
      this.consume(); // =
      const value = this.parseExpression();
      this.consume(); // ;

      return {
        type: 'assignment',
        value: { name },
        children: [value],
        line: this.currentLine
      };
    }

    this.consume(); // ;
    return {
      type: 'expression_statement',
      value: { name },
      line: this.currentLine
    };
  }

  private parseExpression(): ASTNode {
    // Handle malloc
    if (this.current() === 'malloc') {
      this.consume(); // malloc
      this.consume(); // (
      const size = this.parseExpression();
      this.consume(); // )

      return {
        type: 'malloc',
        children: [size],
        line: this.currentLine
      };
    }

    // Handle sizeof
    if (this.current() === 'sizeof') {
      this.consume(); // sizeof
      this.consume(); // (
      const type = this.consume();
      this.consume(); // )

      return {
        type: 'sizeof',
        value: { type },
        line: this.currentLine
      };
    }

    // Handle address-of: &x
    if (this.current() === '&') {
      this.consume(); // &
      const name = this.consume();

      return {
        type: 'address_of',
        value: { name },
        line: this.currentLine
      };
    }

    // Handle dereference: *ptr
    if (this.current() === '*') {
      this.consume(); // *
      const name = this.consume();

      return {
        type: 'dereference',
        value: { name },
        line: this.currentLine
      };
    }

    // Handle array access: arr[i]
    const first = this.current();
    if (this.isIdentifier(first) && this.peek() === '[') {
      const name = this.consume();
      this.consume(); // [
      const index = this.parseExpression();
      this.consume(); // ]

      return {
        type: 'array_access',
        value: { name },
        children: [index],
        line: this.currentLine
      };
    }

    // Simple binary operation
    const left = this.parsePrimary();

    if (this.position < this.tokens.length && '+-*/<>='.includes(this.current())) {
      const operator = this.consume();
      const right = this.parseExpression();

      return {
        type: 'binary_op',
        value: { operator },
        children: [left, right],
        line: this.currentLine
      };
    }

    return left;
  }

  private parsePrimary(): ASTNode {
    const token = this.consume();

    // Number literal
    if (/^\d+$/.test(token)) {
      return {
        type: 'number_literal',
        value: parseInt(token),
        line: this.currentLine
      };
    }

    // Identifier
    if (this.isIdentifier(token)) {
      return {
        type: 'identifier',
        value: token,
        line: this.currentLine
      };
    }

    // Parenthesized expression
    if (token === '(') {
      const expr = this.parseExpression();
      this.consume(); // )
      return expr;
    }

    return {
      type: 'unknown',
      value: token,
      line: this.currentLine
    };
  }

  private parseBlock(): ASTNode {
    this.consume(); // {
    const statements: ASTNode[] = [];

    while (this.current() !== '}' && this.position < this.tokens.length) {
      const stmt = this.parseStatement();
      if (stmt) {
        statements.push(stmt);
      }
    }

    this.consume(); // }

    return {
      type: 'block',
      children: statements,
      line: this.currentLine
    };
  }

  private parseIf(): ASTNode {
    this.consume(); // if
    this.consume(); // (
    const condition = this.parseExpression();
    this.consume(); // )

    const thenBlock = this.parseStatement();
    let elseBlock: ASTNode | null = null;

    if (this.current() === 'else') {
      this.consume(); // else
      elseBlock = this.parseStatement();
    }

    return {
      type: 'if_statement',
      children: elseBlock ? [condition, thenBlock, elseBlock] : [condition, thenBlock],
      line: this.currentLine
    };
  }

  private parseWhile(): ASTNode {
    this.consume(); // while
    this.consume(); // (
    const condition = this.parseExpression();
    this.consume(); // )

    const body = this.parseStatement();

    return {
      type: 'while_statement',
      children: [condition, body!],
      line: this.currentLine
    };
  }

  private parseFor(): ASTNode {
    this.consume(); // for
    this.consume(); // (

    // Init
    const init = this.parseStatement();

    // Condition
    const condition = this.parseExpression();
    this.consume(); // ;

    // Update
    const update = this.parseAssignmentOrCall();
    this.consume(); // )

    const body = this.parseStatement();

    return {
      type: 'for_statement',
      children: [init!, condition, update, body!],
      line: this.currentLine
    };
  }

  private parseReturn(): ASTNode {
    this.consume(); // return

    let value: ASTNode | null = null;
    if (this.current() !== ';') {
      value = this.parseExpression();
    }

    this.consume(); // ;

    return {
      type: 'return_statement',
      children: value ? [value] : [],
      line: this.currentLine
    };
  }

  private isIdentifier(token: string): boolean {
    return /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(token);
  }

  private current(): string {
    return this.tokens[this.position] || '';
  }

  private peek(offset: number = 1): string {
    return this.tokens[this.position + offset] || '';
  }

  private consume(): string {
    return this.tokens[this.position++] || '';
  }
}
