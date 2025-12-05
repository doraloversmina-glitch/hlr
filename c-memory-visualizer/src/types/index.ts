// Memory Types
export type MemoryAddress = string; // "0x7FFF_1000"

export interface PointerValue {
  targetBlock: string | null; // Block ID or null
  offset: number;
}

export type VariableValue = number | PointerValue | number[];

export interface Variable {
  name: string;
  type: CType;
  value: VariableValue;
  address: MemoryAddress;
  size: number;
  isPointer: boolean;
  isArray: boolean;
}

export interface CType {
  kind: 'int' | 'char' | 'pointer' | 'array' | 'void';
  size: number;
  baseType?: CType;
  length?: number; // For arrays
}

// Execution State
export interface StackFrame {
  functionName: string;
  variables: Map<string, Variable>;
  returnAddress: number;
  framePointer: MemoryAddress;
}

export interface HeapBlock {
  id: string;
  address: MemoryAddress;
  size: number;
  status: 'allocated' | 'freed';
  data: (number | null)[];
  allocatedAt: number;
  freedAt?: number;
}

export interface ExecutionState {
  programCounter: number;
  callStack: StackFrame[];
  heap: Map<string, HeapBlock>;
  globalScope: Map<string, Variable>;
  errors: MemoryError[];
  log: ExecutionEvent[];
  isRunning: boolean;
  isHalted: boolean;
  currentLine: number;
  code: string;
  lines: string[];
}

// Events & Errors
export type ErrorType = 'OOB' | 'UAF' | 'NULL_DEREF' | 'DOUBLE_FREE' | 'LEAK' | 'SYNTAX';

export interface MemoryError {
  type: ErrorType;
  message: string;
  line: number;
  details?: string;
}

export interface ExecutionEvent {
  line: number;
  type: 'malloc' | 'free' | 'assignment' | 'declaration' | 'function_call' | 'error' | 'info';
  message: string;
  timestamp: number;
}

// 42 Specific
export interface Achievement {
  id: string;
  title: string;
  description: string;
  xp: number;
  icon: string;
  unlocked: boolean;
}

export interface UserProgress {
  xp: number;
  level: number;
  achievements: Achievement[];
  completedExamples: string[];
}

// Parser Types
export interface ASTNode {
  type: string;
  value?: any;
  children?: ASTNode[];
  line?: number;
}
