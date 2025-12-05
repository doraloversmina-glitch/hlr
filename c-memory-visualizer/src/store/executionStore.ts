import { create } from 'zustand';
import { ExecutionState, StackFrame } from '../types';
import { CParser } from '../engine/parser';
import { Interpreter } from '../engine/interpreter';

interface ExecutionStore extends ExecutionState {
  // Actions
  step: () => void;
  run: () => void;
  reset: () => void;
  pause: () => void;
  setCode: (code: string) => void;
  setSpeed: (speed: number) => void;

  // Runtime
  interpreter: Interpreter | null;
  parser: CParser;
  statements: any[];
  statementIndex: number;
  speed: number; // ms delay
  runInterval: any;

  // History for step-back
  history: ExecutionState[];
  stepBack: () => void;
}

export const useExecutionStore = create<ExecutionStore>((set, get) => ({
  // Initial state
  programCounter: 0,
  callStack: [],
  heap: new Map(),
  globalScope: new Map(),
  errors: [],
  log: [],
  isRunning: false,
  isHalted: false,
  currentLine: 1,
  code: '',
  lines: [],

  // Runtime
  interpreter: null,
  parser: new CParser(),
  statements: [],
  statementIndex: 0,
  speed: 500,
  runInterval: null,
  history: [],

  setCode: (code: string) => {
    try {
      const parser = new CParser();
      const statements = parser.parse(code);

      const interpreter = new Interpreter(code);
      interpreter.initializeMain();

      const state = interpreter.getState();

      set({
        code,
        lines: code.split('\n'),
        statements,
        statementIndex: 0,
        interpreter,
        programCounter: 0,
        callStack: state.callStack,
        heap: state.heap,
        globalScope: state.globalScope,
        errors: [],
        log: state.log,
        isRunning: false,
        isHalted: false,
        currentLine: 1,
        history: [],
      });
    } catch (error: any) {
      set({
        errors: [{
          type: 'SYNTAX',
          message: 'Parse error: ' + error.message,
          line: 1
        }],
        isHalted: true
      });
    }
  },

  step: () => {
    const state = get();
    if (state.isHalted || !state.interpreter) return;

    // Save history
    const currentState: ExecutionState = {
      programCounter: state.programCounter,
      callStack: structuredClone(state.callStack),
      heap: new Map(state.heap),
      globalScope: new Map(state.globalScope),
      errors: [...state.errors],
      log: [...state.log],
      isRunning: state.isRunning,
      isHalted: state.isHalted,
      currentLine: state.currentLine,
      code: state.code,
      lines: state.lines
    };

    const newHistory = [...state.history];
    if (newHistory.length >= 100) {
      newHistory.shift();
    }
    newHistory.push(currentState);

    // Execute next statement
    if (state.statementIndex < state.statements.length) {
      const stmt = state.statements[state.statementIndex];
      state.interpreter.executeStatement(stmt);

      const newState = state.interpreter.getState();

      set({
        statementIndex: state.statementIndex + 1,
        callStack: newState.callStack,
        heap: newState.heap,
        globalScope: newState.globalScope,
        errors: newState.errors,
        log: newState.log,
        isHalted: newState.isHalted,
        currentLine: newState.currentLine,
        history: newHistory
      });

      // Check for completion
      if (state.statementIndex + 1 >= state.statements.length) {
        state.interpreter.checkForLeaks();
        const finalState = state.interpreter.getState();

        set({
          isHalted: true,
          errors: finalState.errors,
          log: finalState.log
        });
      }

      // Stop if error
      if (newState.errors.length > 0) {
        get().pause();
      }
    } else {
      set({ isHalted: true });
      get().pause();
    }
  },

  run: () => {
    const state = get();
    if (state.isRunning) return;

    set({ isRunning: true });

    const interval = setInterval(() => {
      const currentState = get();
      if (currentState.isHalted || currentState.errors.length > 0) {
        get().pause();
        return;
      }
      get().step();
    }, state.speed);

    set({ runInterval: interval });
  },

  pause: () => {
    const state = get();
    if (state.runInterval) {
      clearInterval(state.runInterval);
    }
    set({ isRunning: false, runInterval: null });
  },

  reset: () => {
    const state = get();
    if (state.code) {
      get().setCode(state.code);
    }
    get().pause();
  },

  setSpeed: (speed: number) => {
    set({ speed });

    // Restart interval if running
    const state = get();
    if (state.isRunning) {
      get().pause();
      setTimeout(() => get().run(), 0);
    }
  },

  stepBack: () => {
    const state = get();
    if (state.history.length === 0) return;

    const previousState = state.history[state.history.length - 1];
    const newHistory = state.history.slice(0, -1);

    set({
      ...previousState,
      history: newHistory,
      statementIndex: Math.max(0, state.statementIndex - 1),
      isRunning: false
    });

    get().pause();
  },
}));
