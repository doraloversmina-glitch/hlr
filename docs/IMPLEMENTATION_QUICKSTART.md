# C Memory Visualizer - Implementation Quickstart

## Project Setup (5 minutes)

### 1. Create New Project
```bash
# Create Vite + React + TypeScript project
npm create vite@latest c-memory-visualizer -- --template react-ts
cd c-memory-visualizer
```

### 2. Install Dependencies
```bash
# Core
npm install zustand

# UI
npm install @radix-ui/react-tabs @radix-ui/react-slider
npm install tailwindcss postcss autoprefixer
npm install lucide-react  # Icons

# Code Editor
npm install @codemirror/state @codemirror/view
npm install @codemirror/lang-cpp
npm install @codemirror/theme-one-dark

# Parser
npm install web-tree-sitter

# Visualization
npm install d3 @types/d3

# Dev
npm install -D @types/node
```

### 3. Initialize TailwindCSS
```bash
npx tailwindcss init -p
```

Update `tailwind.config.js`:
```javascript
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        '42-cyan': '#00BABC',
        '42-dark': '#0E0E0E',
        '42-darker': '#000000',
        '42-gray': '#1A1A1A',
      },
      fontFamily: {
        mono: ['JetBrains Mono', 'Fira Code', 'monospace'],
      },
    },
  },
  plugins: [],
};
```

### 4. Project Structure
```bash
mkdir -p src/{components,engine,store,utils,types}
mkdir -p public/examples
```

---

## File: src/index.css (42 Theme)

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  * {
    @apply border-42-gray;
  }

  body {
    @apply bg-42-dark text-white font-mono;
    font-size: 14px;
    line-height: 1.5;
  }

  /* Custom scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  ::-webkit-scrollbar-track {
    @apply bg-42-darker;
  }

  ::-webkit-scrollbar-thumb {
    @apply bg-42-gray hover:bg-42-cyan;
    border-radius: 4px;
  }
}

@layer components {
  /* Terminal box */
  .terminal-box {
    @apply bg-42-darker border border-42-gray rounded;
    box-shadow: 0 0 10px rgba(0, 186, 188, 0.1);
  }

  /* Current line highlight */
  .code-line-current {
    @apply bg-42-cyan bg-opacity-10 border-l-2 border-42-cyan;
  }

  /* Memory block */
  .memory-block {
    @apply terminal-box p-2 font-mono text-xs;
  }

  .memory-block-allocated {
    @apply border-green-500 bg-green-500 bg-opacity-5;
  }

  .memory-block-freed {
    @apply border-red-500 bg-red-500 bg-opacity-5 line-through;
  }

  /* Button */
  .btn {
    @apply px-3 py-1 bg-42-gray hover:bg-42-cyan hover:text-black
           border border-42-gray transition-colors duration-200
           font-mono text-sm;
  }

  .btn-primary {
    @apply bg-42-cyan text-black hover:bg-opacity-80;
  }
}

/* Animations */
@keyframes pulse-border {
  0%, 100% {
    border-color: rgb(0, 186, 188);
  }
  50% {
    border-color: rgb(0, 255, 65);
  }
}

.animate-malloc {
  animation: pulse-border 0.3s ease-in-out;
}
```

---

## File: src/types/index.ts

```typescript
// Memory Types
export type MemoryAddress = string; // "0x7FFF_1000"

export interface PointerValue {
  targetBlock: string | null; // Block ID or null
  offset: number;
}

export type VariableValue = number | PointerValue;

export interface Variable {
  name: string;
  type: CType;
  value: VariableValue;
  address: MemoryAddress;
  size: number;
}

export interface CType {
  kind: 'int' | 'char' | 'pointer' | 'array';
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
  data: number[];
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
}

// Events & Errors
export type ErrorType = 'OOB' | 'UAF' | 'NULL_DEREF' | 'DOUBLE_FREE' | 'LEAK';

export interface MemoryError {
  type: ErrorType;
  message: string;
  line: number;
  details?: string;
}

export interface ExecutionEvent {
  line: number;
  type: 'malloc' | 'free' | 'assignment' | 'function_call' | 'error';
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
```

---

## File: src/store/executionStore.ts (Zustand)

```typescript
import { create } from 'zustand';
import { ExecutionState, HeapBlock, StackFrame } from '../types';

interface ExecutionStore extends ExecutionState {
  // Actions
  step: () => void;
  run: () => void;
  reset: () => void;
  stepBack: () => void;
  setCode: (code: string) => void;

  // History for step-back
  history: ExecutionState[];
  maxHistorySize: number;
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
  history: [],
  maxHistorySize: 100,

  // Actions
  setCode: (code: string) => {
    // Parse and initialize
    set({
      programCounter: 0,
      callStack: [{
        functionName: 'main',
        variables: new Map(),
        returnAddress: 0,
        framePointer: '0x7FFF_F000'
      }],
      heap: new Map(),
      errors: [],
      log: [],
      isRunning: false,
      isHalted: false,
      history: [],
    });
  },

  step: () => {
    const state = get();
    if (state.isHalted) return;

    // Save current state to history
    const currentState: ExecutionState = {
      programCounter: state.programCounter,
      callStack: structuredClone(state.callStack),
      heap: new Map(state.heap),
      globalScope: new Map(state.globalScope),
      errors: [...state.errors],
      log: [...state.log],
      isRunning: state.isRunning,
      isHalted: state.isHalted,
    };

    set({
      history: [...state.history.slice(-state.maxHistorySize + 1), currentState],
    });

    // Execute next statement (to be implemented)
    // This is where interpreter logic goes

    set({ programCounter: state.programCounter + 1 });
  },

  run: () => {
    set({ isRunning: true });
    // Run until error or completion
    const interval = setInterval(() => {
      const state = get();
      if (state.isHalted || state.errors.length > 0) {
        clearInterval(interval);
        set({ isRunning: false });
        return;
      }
      get().step();
    }, 500); // 500ms delay between steps
  },

  reset: () => {
    set({
      programCounter: 0,
      callStack: [{
        functionName: 'main',
        variables: new Map(),
        returnAddress: 0,
        framePointer: '0x7FFF_F000'
      }],
      heap: new Map(),
      errors: [],
      log: [],
      isRunning: false,
      isHalted: false,
      history: [],
    });
  },

  stepBack: () => {
    const state = get();
    if (state.history.length === 0) return;

    const previousState = state.history[state.history.length - 1];
    set({
      ...previousState,
      history: state.history.slice(0, -1),
    });
  },
}));
```

---

## File: src/components/Layout.tsx (42 Style)

```typescript
import React from 'react';
import { Play, Square, SkipForward, RotateCcw, ChevronLeft } from 'lucide-react';

export const Layout: React.FC = () => {
  return (
    <div className="h-screen flex flex-col bg-42-dark text-white font-mono">
      {/* Header */}
      <header className="border-b border-42-gray p-3 flex items-center justify-between">
        <div className="flex items-center gap-4">
          <h1 className="text-42-cyan font-bold">C-MEM-VIZ v1.0.0</h1>
          <span className="text-gray-500 text-xs">42 Network</span>
        </div>
        <div className="flex items-center gap-4 text-xs">
          <span>login: <span className="text-42-cyan">guest</span></span>
          <span>XP: <span className="text-green-500">1337</span>/2000</span>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 flex overflow-hidden">
        {/* Left: Code Editor */}
        <div className="w-1/2 border-r border-42-gray flex flex-col">
          <div className="p-2 bg-42-darker border-b border-42-gray text-xs text-gray-400">
            CODE
          </div>
          <div className="flex-1 p-4">
            {/* CodeMirror goes here */}
            <pre className="text-sm">
              <code>
                {`  1  #include <stdlib.h>
  2
►42  int x = 42;
 43  int *p = &x;
 44  *p = 21;
 45  return (0);`}
              </code>
            </pre>
          </div>
          <div className="p-2 bg-42-darker border-t border-42-gray text-xs">
            <span className="text-green-500">✓</span> 0 errors | 0 leaks
          </div>
        </div>

        {/* Right: Visualization */}
        <div className="w-1/2 flex flex-col">
          <div className="p-2 bg-42-darker border-b border-42-gray flex gap-4 text-xs">
            <button className="text-42-cyan border-b-2 border-42-cyan pb-1">STACK</button>
            <button className="text-gray-400 hover:text-white pb-1">HEAP</button>
            <button className="text-gray-400 hover:text-white pb-1">GRAPH</button>
            <button className="text-gray-400 hover:text-white pb-1">LOG</button>
          </div>
          <div className="flex-1 p-4 overflow-auto">
            {/* Stack View */}
            <div className="terminal-box p-3">
              <div className="text-xs text-gray-400 mb-2">
                STACK FRAME: main() [0x7FFF_F000]
              </div>
              <div className="space-y-2 text-xs">
                <div className="flex items-center gap-2">
                  <span className="text-42-cyan">x</span>
                  <span className="text-gray-400">=</span>
                  <span className="text-green-400">42</span>
                  <span className="text-gray-600">[0x7FFF_1000]</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-42-cyan">p</span>
                  <span className="text-gray-400">=</span>
                  <span className="text-yellow-400">───►</span>
                  <span className="text-gray-600">[0x7FFF_1004]</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Controls */}
      <div className="border-t border-42-gray p-3 flex items-center justify-between">
        <div className="flex gap-2">
          <button className="btn flex items-center gap-1">
            <RotateCcw size={14} />
            reset
          </button>
          <button className="btn flex items-center gap-1">
            <ChevronLeft size={14} />
            back
          </button>
          <button className="btn btn-primary flex items-center gap-1">
            <SkipForward size={14} />
            step
          </button>
          <button className="btn flex items-center gap-1">
            <Play size={14} />
            run
          </button>
        </div>
        <div className="flex items-center gap-2 text-xs">
          <span className="text-gray-400">Speed:</span>
          <input
            type="range"
            min="100"
            max="2000"
            defaultValue="500"
            className="w-32"
          />
          <span className="text-gray-400">500ms</span>
        </div>
      </div>

      {/* Command Line (Easter Egg) */}
      <div className="bg-42-darker border-t border-42-gray p-2 text-xs text-gray-400">
        &gt; Ready. Type 'help' for commands.
      </div>
    </div>
  );
};
```

---

## File: src/App.tsx

```typescript
import { Layout } from './components/Layout';

function App() {
  return <Layout />;
}

export default App;
```

---

## File: public/examples/00_hello_ptr.c

```c
/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   00_hello_ptr.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: student <student@42.fr>                    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/01/01 00:00:00 by student           #+#    #+#             */
/*   Updated: 2025/01/01 00:00:00 by student          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

/*
** LEVEL 0: Hello Pointers
** Learn: Variable declaration, address-of operator, dereferencing
** Goal: Understand how pointers store memory addresses
*/

int	main(void)
{
	int		x;
	int		*p;

	x = 42;
	p = &x;
	*p = 21;
	return (0);
}
```

---

## First Sprint Tasks (Week 1)

### Day 1-2: Setup & UI Shell
- [x] Initialize project
- [ ] Create 42-themed CSS
- [ ] Build Layout component
- [ ] Add CodeMirror integration

### Day 3-4: Parser Integration
- [ ] Install tree-sitter WASM
- [ ] Parse simple C code
- [ ] Log AST to console
- [ ] Handle parse errors

### Day 5-7: Basic Interpreter
- [ ] Implement ExecutionState
- [ ] Execute variable declarations
- [ ] Execute assignments
- [ ] Display in Stack view

---

## Quick Test

```bash
npm run dev
```

Visit `http://localhost:5173` and you should see:
- 42-themed dark terminal interface
- Code editor placeholder
- Stack visualization panel
- Control buttons

---

## Next Steps

1. Implement CodeMirror editor
2. Add tree-sitter parsing
3. Build interpreter loop
4. Connect state to UI
5. Add error detection
6. Polish animations

**Total MVP time**: ~3-4 weeks for solo developer

**With team**: 2 weeks (1 frontend + 1 backend/interpreter)

---

## Resources

- tree-sitter: https://tree-sitter.github.io/tree-sitter/
- CodeMirror 6: https://codemirror.net/
- Zustand: https://github.com/pmndrs/zustand
- 42 Norm: https://github.com/42School/norminette
- D3.js: https://d3js.org/

---

**Ready to code? Let's build this! 🚀**
