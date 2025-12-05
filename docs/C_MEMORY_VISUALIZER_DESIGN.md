# C Memory & Algorithm Visualizer - Complete Design Document

## Executive Summary

A web-based educational tool that simulates C code execution and visualizes memory management in real-time. Target audience: beginners learning C (e.g., 42 school students).

**Key Principle**: This is NOT a full C compiler/interpreter. It's a restricted simulator focusing on memory visualization.

---

## 1. ARCHITECTURE PROPOSAL

### 1.1 Recommended Approach: **Client-Side JavaScript Engine**

**Rationale:**
- Zero backend infrastructure costs
- Instant feedback (no network latency)
- Easy deployment (static hosting)
- No security concerns (sandboxed by default)
- Offline capability
- Perfect for educational use

**Architecture Overview:**
```
┌─────────────────────────────────────────────────────────┐
│                    Browser (Client)                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Parser     │→ │ Interpreter  │→ │ Visualizer   │ │
│  │ (tree-sitter)│  │   Engine     │  │    (React)   │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         ↓                  ↓                  ↓         │
│  ┌──────────────────────────────────────────────────┐  │
│  │          Unified State Management (Zustand)       │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 1.2 Alternative: Backend Sandbox (Not Recommended for MVP)

**When to Consider:**
- If you need actual GCC compilation
- If supporting full C standard library
- If you want to run real executables

**Why Not for MVP:**
- Overhead of maintaining sandboxed containers (Docker/WASM)
- Network latency hurts UX
- Security complexity (code injection risks)
- Infrastructure costs

**Verdict**: Start with client-side. Add backend only if needed later.

---

## 2. SYSTEM COMPONENTS

### 2.1 Parser Layer

**Purpose**: Convert C source to Abstract Syntax Tree (AST)

**Technology**: `tree-sitter-c` (battle-tested, incremental parsing)

**Supported Subset**:
```c
// Variable declarations
int x = 5;
int *ptr = &x;
int arr[10];

// Control flow
if (condition) { }
while (condition) { }
for (int i = 0; i < n; i++) { }

// Memory operations
int *p = malloc(sizeof(int) * 10);
free(p);

// Functions (limited)
int add(int a, int b) { return a + b; }
```

**NOT Supported in MVP**:
- Structs/unions
- Preprocessor directives (#define, #include)
- Function pointers
- Recursion (initially)
- Standard library (except malloc/free)

### 2.2 Interpreter Engine

**Core Responsibilities**:
1. Maintain execution state (PC, stack, heap)
2. Execute one statement at a time
3. Detect memory errors
4. Emit events for visualization

**Key Data Structures**:

```javascript
// Execution State
class ExecutionState {
  programCounter: number;        // Current line number
  callStack: StackFrame[];       // Function call stack
  heap: HeapManager;             // Dynamic memory
  globalScope: Scope;            // Global variables
  errors: Error[];               // Runtime errors
  log: Event[];                  // Execution log
}

// Stack Frame
class StackFrame {
  functionName: string;
  variables: Map<string, Variable>;
  returnAddress: number;
  framePointer: number;
}

// Variable
class Variable {
  name: string;
  type: CType;                   // int, int*, int[], etc.
  value: number | PointerValue;
  address: number;               // Simulated memory address
  size: number;                  // Bytes
}

// Heap Block
class HeapBlock {
  id: string;                    // Unique block ID
  address: number;               // Start address
  size: number;                  // Allocated bytes
  status: 'allocated' | 'freed'; // Current state
  allocatedAt: number;           // Line number
  freedAt?: number;              // Line number
}

// Pointer Value
class PointerValue {
  targetBlock: string | null;    // NULL or block ID
  offset: number;                // Offset within block
}
```

### 2.3 Memory Model

**Address Space Simulation**:
```
High Address
┌─────────────────┐
│   STACK         │ ← Grows downward (simulated 0x7FFF_FFFF)
│                 │
├─────────────────┤
│   (unused)      │
│                 │
├─────────────────┤
│   HEAP          │ ← Grows upward (simulated 0x0040_0000)
│                 │
├─────────────────┤
│   GLOBALS       │ ← Fixed (0x0020_0000)
└─────────────────┘
Low Address
```

**Address Allocation**:
- Globals: 0x0020_0000 + offset
- Heap: 0x0040_0000 + offset (per malloc)
- Stack: 0x7FFF_FFFF - offset (per frame)

**Pointer Representation**:
```javascript
// Instead of raw numbers, track semantic references
{
  type: 'heap_pointer',
  block: 'heap_0x004000A0',
  offset: 12  // arr[3] where sizeof(int) = 4
}
```

### 2.4 Error Detection System

**Runtime Checks**:

```javascript
// 1. Out-of-Bounds Access
function checkArrayAccess(array, index) {
  if (index < 0 || index >= array.length) {
    throw new MemoryError('OOB', `Index ${index} out of bounds [0, ${array.length})`);
  }
}

// 2. Use-After-Free
function checkPointerValid(ptr) {
  if (ptr.targetBlock && heap.get(ptr.targetBlock).status === 'freed') {
    throw new MemoryError('UAF', `Accessing freed block ${ptr.targetBlock}`);
  }
}

// 3. Null Dereference
function checkNullDeref(ptr) {
  if (ptr.targetBlock === null) {
    throw new MemoryError('NULL_DEREF', 'Dereferencing NULL pointer');
  }
}

// 4. Double Free
function checkDoubleFree(ptr) {
  const block = heap.get(ptr.targetBlock);
  if (block.status === 'freed') {
    throw new MemoryError('DOUBLE_FREE', `Block ${ptr.targetBlock} already freed`);
  }
}

// 5. Memory Leaks (at program end)
function checkLeaks() {
  const leaks = heap.blocks.filter(b => b.status === 'allocated');
  if (leaks.length > 0) {
    return new MemoryWarning('LEAK', `${leaks.length} blocks not freed`);
  }
}
```

---

## 3. UI/UX DESIGN

### 3.1 Layout

```
┌──────────────────────────────────────────────────────────────┐
│ C Memory Visualizer                          [?] [Settings]  │
├────────────────────────┬─────────────────────────────────────┤
│                        │  ┌────────────────────────────────┐ │
│  CODE EDITOR           │  │ VISUALIZATION TABS             │ │
│                        │  ├────┬────┬────────┬──────────┐  │ │
│  1  int main() {       │  │ 📚 │ 🧱 │ 🔗     │ 📋      │  │ │
│  2►   int x = 10;     │  │Stack│Heap│Pointers│  Log    │  │ │
│  3    int *p = &x;     │  └────┴────┴────────┴──────────┘  │ │
│  4    *p = 20;         │                                    │ │
│  5    return 0;        │  ┌──────────────────────────────┐ │ │
│  6  }                  │  │ Stack Frame: main()          │ │ │
│                        │  ├──────────────────────────────┤ │ │
│                        │  │ x: 20    [0x7FFF_1000]       │ │ │
│                        │  │ p: ──┐   [0x7FFF_1004]       │ │ │
│                        │  │       └──→ 0x7FFF_1000       │ │ │
│  [Errors/Warnings]     │  └──────────────────────────────┘ │ │
│  ✓ No errors           │                                    │ │
│                        │                                    │ │
├────────────────────────┴─────────────────────────────────────┤
│ [◀◀ Reset] [◀ Step Back] [▶ Step] [▶▶ Run] [⏸ Pause]       │
│ Speed: [────●─────] Delay: 500ms                            │
└──────────────────────────────────────────────────────────────┘
```

### 3.2 Visualization Panels

#### 3.2.1 Stack View
```
┌─────────────────────────────────────┐
│ Call Stack (grows ↓)                │
├─────────────────────────────────────┤
│ Frame: main()          [0x7FFF_F000]│
│ ┌─────────────────────────────────┐ │
│ │ int x = 20      [0x7FFF_1000]   │ │
│ │ int* p = 0x...  [0x7FFF_1004] ──┼─┼──→ points to x
│ └─────────────────────────────────┘ │
│                                     │
│ Frame: foo(int a)      [0x7FFF_E000]│
│ ┌─────────────────────────────────┐ │
│ │ int a = 5       [0x7FFF_E000]   │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### 3.2.2 Heap View
```
┌─────────────────────────────────────┐
│ Heap (grows ↑)                      │
├─────────────────────────────────────┤
│ ✓ 0x0040_00A0  [20 bytes]  VALID    │
│   malloc() at line 3                │
│   [0][1][2][3][4]                   │
│   5  0  0  0  0                     │
│                                     │
│ ✗ 0x0040_0050  [16 bytes]  FREED    │
│   freed at line 7                   │
│   [INVALID MEMORY]                  │
└─────────────────────────────────────┘
```

#### 3.2.3 Pointer Graph
```
┌─────────────────────────────────────┐
│ Pointer Relationships               │
├─────────────────────────────────────┤
│                                     │
│  [main::p] ──────┐                  │
│                  ↓                  │
│            [main::x]                │
│                                     │
│  [main::arr] ────┐                  │
│                  ↓                  │
│            [Heap 0x0040_00A0]       │
│                                     │
│  [main::null_ptr] ──→ NULL          │
└─────────────────────────────────────┘
```

#### 3.2.4 Execution Log
```
┌─────────────────────────────────────┐
│ Event Log                           │
├─────────────────────────────────────┤
│ L1  Started main()                  │
│ L2  Declared int x = 10             │
│ L3  🔴 MALLOC: 20 bytes at 0x0040.. │
│ L4  Assigned arr[0] = 5             │
│ L5  🔴 FREE: 0x0040_00A0            │
│ L6  ⚠️  NULL DEREF at line 6!       │
└─────────────────────────────────────┘
```

### 3.3 Interaction Features

**Hover Effects**:
- Hover variable in code → highlight in stack/heap
- Hover memory block → show allocation site in code
- Hover pointer → draw arrow to target

**Color Coding**:
- 🟢 Green: Valid allocated memory
- 🔴 Red: Freed/invalid memory
- 🟡 Yellow: Uninitialized memory
- 🔵 Blue: Current execution line
- 🟠 Orange: Error location

**Animations** (subtle, < 300ms):
- Malloc: fade-in new block
- Free: fade-to-red + strikethrough
- Variable assignment: brief highlight
- Function call: stack frame push animation

---

## 4. STEP-BY-STEP EXECUTION EXAMPLE

### Example Code:
```c
int main() {
  int x = 10;
  int *p = malloc(sizeof(int));
  *p = x;
  free(p);
  *p = 99;  // Error: use-after-free
  return 0;
}
```

### Execution Trace:

**Step 0: Initial State**
```
PC: 1
Stack: [main frame (empty)]
Heap: []
Errors: []
```

**Step 1: Line 2 - `int x = 10;`**
```
PC: 2
Stack: [
  main: { x: {value: 10, addr: 0x7FFF_1000} }
]
Heap: []
Log: "Declared int x = 10"
```

**Step 2: Line 3 - `int *p = malloc(sizeof(int));`**
```
PC: 3
Stack: [
  main: {
    x: {value: 10, addr: 0x7FFF_1000},
    p: {value: {block: 'heap_0x0040_00A0', offset: 0}, addr: 0x7FFF_1004}
  }
]
Heap: [
  {id: 'heap_0x0040_00A0', size: 4, status: 'allocated', allocatedAt: 3}
]
Log: "MALLOC: 4 bytes at 0x0040_00A0"
```

**Step 3: Line 4 - `*p = x;`**
```
PC: 4
Stack: [same as step 2]
Heap: [
  {id: 'heap_0x0040_00A0', size: 4, status: 'allocated', data: [10]}
]
Log: "Dereferenced p, wrote 10 to heap"
```

**Step 4: Line 5 - `free(p);`**
```
PC: 5
Heap: [
  {id: 'heap_0x0040_00A0', size: 4, status: 'freed', freedAt: 5}
]
Log: "FREE: 0x0040_00A0"
Visual: Block turns red in heap view
```

**Step 5: Line 6 - `*p = 99;` ❌**
```
PC: 6
Error: {
  type: 'USE_AFTER_FREE',
  message: 'Attempting to write to freed memory at 0x0040_00A0',
  line: 6
}
Execution: HALTED
Visual: Red highlight on line 6, error tooltip, heap block flashes red
```

---

## 5. INTERNAL DATA STRUCTURES (Detailed)

### 5.1 AST Representation (tree-sitter output)
```javascript
{
  type: 'translation_unit',
  children: [
    {
      type: 'function_definition',
      declarator: { name: 'main' },
      body: {
        type: 'compound_statement',
        children: [
          {
            type: 'declaration',
            declarator: { name: 'x' },
            type: 'int',
            initializer: { type: 'number_literal', value: 10 }
          },
          // ...
        ]
      }
    }
  ]
}
```

### 5.2 Runtime Type System
```javascript
class CType {
  static INT = new CType('int', 4);
  static CHAR = new CType('char', 1);
  static POINTER = (baseType) => new CType('pointer', 8, baseType);
  static ARRAY = (baseType, size) => new CType('array', baseType.size * size, baseType, size);

  constructor(kind, size, baseType = null, length = null) {
    this.kind = kind;      // 'int', 'pointer', 'array'
    this.size = size;      // Total bytes
    this.baseType = baseType;
    this.length = length;  // For arrays
  }
}
```

### 5.3 Heap Manager
```javascript
class HeapManager {
  constructor() {
    this.blocks = new Map();
    this.nextAddress = 0x00400000;
  }

  malloc(size, lineNumber) {
    const address = this.nextAddress;
    const id = `heap_${address.toString(16)}`;
    this.blocks.set(id, {
      id,
      address,
      size,
      status: 'allocated',
      data: new Array(size).fill(0),
      allocatedAt: lineNumber
    });
    this.nextAddress += size + 16; // Add padding for metadata
    return { block: id, offset: 0 };
  }

  free(ptr, lineNumber) {
    const block = this.blocks.get(ptr.block);
    if (!block) throw new Error('Invalid pointer');
    if (block.status === 'freed') throw new Error('Double free');

    block.status = 'freed';
    block.freedAt = lineNumber;
  }

  write(ptr, value) {
    const block = this.blocks.get(ptr.block);
    if (block.status === 'freed') throw new Error('Use-after-free');
    block.data[ptr.offset] = value;
  }

  read(ptr) {
    const block = this.blocks.get(ptr.block);
    if (block.status === 'freed') throw new Error('Use-after-free');
    return block.data[ptr.offset];
  }
}
```

### 5.4 Interpreter Core Loop
```javascript
class Interpreter {
  execute(ast) {
    this.state = new ExecutionState();
    this.state.callStack.push(new StackFrame('main'));

    while (!this.state.halted && this.state.programCounter < ast.body.length) {
      const stmt = ast.body[this.state.programCounter];

      try {
        this.executeStatement(stmt);
        this.state.programCounter++;
        this.emitEvent('step', this.state);
      } catch (error) {
        this.state.errors.push(error);
        this.state.halted = true;
        this.emitEvent('error', error);
      }
    }

    // Check for leaks
    const leaks = this.state.heap.checkLeaks();
    if (leaks.length > 0) {
      this.emitEvent('warning', { type: 'MEMORY_LEAK', blocks: leaks });
    }
  }

  executeStatement(stmt) {
    switch (stmt.type) {
      case 'declaration':
        return this.executeDeclaration(stmt);
      case 'expression_statement':
        return this.executeExpression(stmt.expression);
      case 'if_statement':
        return this.executeIf(stmt);
      case 'while_statement':
        return this.executeWhile(stmt);
      // ...
    }
  }
}
```

---

## 6. DEVELOPMENT ROADMAP

### Phase 1: MVP (2-3 weeks)
**Goal**: Basic step-through with stack/heap visualization

**Deliverables**:
- ✅ Simple code editor (CodeMirror with C syntax highlighting)
- ✅ Parser integration (tree-sitter-c for basic subset)
- ✅ Interpreter for:
  - Variable declarations (int, int*, int[])
  - Arithmetic operations
  - malloc/free
  - Simple control flow (if/while)
- ✅ Stack view (single frame)
- ✅ Heap view (blocks with status)
- ✅ Basic error detection (null deref, use-after-free)
- ✅ Step/Run/Reset controls

**Tech Stack**:
- React 18 + TypeScript
- CodeMirror 6
- tree-sitter-c (WASM build)
- Zustand (state management)
- TailwindCSS + Shadcn/ui

### Phase 2: Enhanced Visualization (1-2 weeks)
**Goal**: Better UX and pointer graphs

**Deliverables**:
- ✅ Pointer graph view (D3.js or Cytoscape.js)
- ✅ Execution log panel
- ✅ Hover interactions (highlight relationships)
- ✅ Smooth animations
- ✅ Error tooltips and highlights
- ✅ Speed control slider
- ✅ Syntax error highlighting

### Phase 3: Advanced Features (2-3 weeks)
**Goal**: Support more C constructs

**Deliverables**:
- ✅ Multi-function support (call stack visualization)
- ✅ Arrays (multi-dimensional)
- ✅ Strings (char arrays)
- ✅ For loops
- ✅ Function parameters and return values
- ✅ Step-back (execution history)
- ✅ Breakpoints
- ✅ Watch expressions

### Phase 4: Polish & Deployment (1 week)
**Goal**: Production-ready

**Deliverables**:
- ✅ Example library (common algorithms)
- ✅ Code sharing (URL encoding)
- ✅ Export/import snippets
- ✅ Mobile-responsive layout
- ✅ Onboarding tutorial
- ✅ Documentation
- ✅ Deploy to Vercel/Netlify

### Phase 5: Future Enhancements
**Not MVP, but valuable**:
- Structs and unions
- Recursion visualization (call tree)
- Performance metrics (complexity analysis)
- Collaborative mode (share session)
- AI-powered error explanations
- Integration with actual GCC (backend option)
- VS Code extension

---

## 7. RECOMMENDED LIBRARIES & FRAMEWORKS

### 7.1 Frontend Framework
**React 18** (with TypeScript)
- **Why**: Component reusability, huge ecosystem, TypeScript support
- **Alternatives**: Vue 3 (simpler), Svelte (faster, smaller bundle)

### 7.2 Code Editor
**CodeMirror 6**
- **Why**: Modern, extensible, excellent C syntax support
- **Alternatives**: Monaco Editor (heavier, but VS Code quality)

### 7.3 Parser
**tree-sitter-c** (WASM build)
- **Why**: Production-grade, incremental parsing, used by GitHub/Atom
- **How**: `web-tree-sitter` npm package
- **Alternatives**: Write custom recursive-descent parser (more control, more work)

### 7.4 State Management
**Zustand**
- **Why**: Lightweight, no boilerplate, great with React
- **Alternatives**: Redux Toolkit (overkill), Jotai (atomic approach)

### 7.5 Visualization
**D3.js** (for pointer graphs)
- **Why**: Ultimate flexibility for custom visualizations
- **Alternatives**: Cytoscape.js (graph-focused), vis.js (easier API)

**React Flow** (optional, for call graphs)
- **Why**: Drag-and-drop node graphs, built for React

### 7.6 UI Components
**Shadcn/ui** + **TailwindCSS**
- **Why**: Beautiful, accessible, customizable components
- **Alternatives**: Chakra UI, MUI (heavier)

### 7.7 Animations
**Framer Motion**
- **Why**: Declarative animations in React, smooth transitions
- **Alternatives**: React Spring (physics-based), CSS animations

### 7.8 Testing
**Vitest** (unit tests) + **Playwright** (E2E)
- **Why**: Fast, modern, great TypeScript support

### 7.9 Build Tool
**Vite**
- **Why**: Blazing fast, great DX, native ESM support

### 7.10 Deployment
**Vercel** or **Netlify**
- **Why**: Zero-config, edge functions, CI/CD built-in

---

## 8. TECHNICAL CHALLENGES & SOLUTIONS

### Challenge 1: Tree-sitter WASM Performance
**Problem**: WASM initialization might be slow on first load
**Solution**:
- Lazy load tree-sitter (only when user pastes code)
- Cache WASM module in IndexedDB
- Show loading spinner during init

### Challenge 2: Memory Address Simulation
**Problem**: JavaScript doesn't have raw pointers
**Solution**:
- Use symbolic references (block ID + offset)
- Display hex addresses for UX, but internally use IDs
- Generate addresses deterministically (0x7FFF_XXXX for stack)

### Challenge 3: Pointer Arithmetic
**Problem**: Supporting `ptr + 5` without real addresses
**Solution**:
```javascript
function pointerAdd(ptr, offset, elementSize) {
  return {
    block: ptr.block,
    offset: ptr.offset + (offset * elementSize)
  };
}
```

### Challenge 4: Visualization Performance
**Problem**: Re-rendering entire memory on every step
**Solution**:
- Use React.memo for stack/heap components
- Only update changed parts (diff previous state)
- Virtual scrolling for large arrays/heap

### Challenge 5: C Syntax Ambiguities
**Problem**: Parsing complex declarations like `int *(*p)[10]`
**Solution**:
- Limit to simple subset initially
- Show clear error messages for unsupported syntax
- Suggest simpler alternatives

---

## 9. EXAMPLE FILE STRUCTURE

```
c-memory-visualizer/
├── public/
│   ├── examples/
│   │   ├── 01-hello-pointers.c
│   │   ├── 02-malloc-free.c
│   │   ├── 03-arrays.c
│   │   ├── 04-use-after-free.c
│   │   └── 05-memory-leak.c
│   └── tree-sitter-c.wasm
├── src/
│   ├── components/
│   │   ├── CodeEditor.tsx
│   │   ├── ControlPanel.tsx
│   │   ├── StackView.tsx
│   │   ├── HeapView.tsx
│   │   ├── PointerGraph.tsx
│   │   ├── ExecutionLog.tsx
│   │   └── ErrorDisplay.tsx
│   ├── engine/
│   │   ├── parser.ts            // tree-sitter wrapper
│   │   ├── interpreter.ts       // Main execution engine
│   │   ├── memory.ts            // Stack/Heap/Variable classes
│   │   ├── types.ts             // CType system
│   │   ├── errors.ts            // Error detection
│   │   └── evaluator.ts         // Expression evaluation
│   ├── store/
│   │   └── executionStore.ts    // Zustand store
│   ├── utils/
│   │   ├── addressGenerator.ts
│   │   ├── codeFormatter.ts
│   │   └── eventEmitter.ts
│   ├── App.tsx
│   └── main.tsx
├── tests/
│   ├── interpreter.test.ts
│   ├── memory.test.ts
│   └── errors.test.ts
├── package.json
├── vite.config.ts
├── tsconfig.json
└── README.md
```

---

## 10. NEXT STEPS TO START DEVELOPMENT

### Week 1: Setup & Parser
1. Initialize Vite + React + TypeScript project
2. Install dependencies (tree-sitter, CodeMirror, etc.)
3. Create basic UI layout (split panes)
4. Integrate tree-sitter-c
5. Parse simple C snippets and log AST

### Week 2: Interpreter Core
1. Implement ExecutionState classes
2. Build statement executor (variables, assignments)
3. Add malloc/free support
4. Create basic stack view component

### Week 3: Visualization
1. Build heap view component
2. Add step controls (step, run, reset)
3. Implement error detection (null deref, UAF)
4. Create execution log panel

### Week 4: Polish MVP
1. Add syntax highlighting and error markers
2. Implement hover interactions
3. Add example snippets
4. Write documentation
5. Deploy to Vercel

---

## 11. SUCCESS METRICS

**For MVP Launch**:
- ✅ Supports 90% of beginner C patterns (variables, arrays, pointers, malloc/free)
- ✅ Catches all 5 core memory errors (OOB, UAF, double-free, null deref, leaks)
- ✅ Step execution < 100ms per step
- ✅ Works on mobile (responsive)
- ✅ Zero crashes on valid C subset

**For Product-Market Fit**:
- Teachers use it in C programming courses
- Students share on Reddit/Discord (r/learnprogramming)
- < 5% bounce rate (users try at least one example)
- Positive feedback on visualization clarity

---

## 12. SECURITY & SAFETY

**Client-Side is Safe**:
- No code execution on server
- Sandboxed JavaScript interpreter
- No file system access
- No network calls from user code

**Potential Abuse**:
- Infinite loops → Add execution step limit (10,000 steps)
- Memory bombs → Limit heap to 1 MB
- DOS via parsing → Limit code size to 10 KB

---

## 13. ACCESSIBILITY

**WCAG 2.1 AA Compliance**:
- Keyboard navigation (Tab, Arrow keys for stepping)
- Screen reader labels for all panels
- High contrast mode for visualizations
- Color-blind friendly palette (use patterns + colors)
- Font size controls

---

## CONCLUSION

This design provides a comprehensive blueprint for building a C Memory Visualizer that:
- ✅ Focuses on education (42 school audience)
- ✅ Uses modern web tech (React, TypeScript, WASM)
- ✅ Starts simple (MVP in 3-4 weeks)
- ✅ Scales gracefully (clear roadmap)
- ✅ Avoids over-engineering (client-side first)

**Recommended First Step**: Build a proof-of-concept interpreter that can execute:
```c
int x = 10;
int *p = &x;
*p = 20;
```
...and visualize the stack in a simple React component. Once that works, expand incrementally.

**Key Philosophy**: Ship early, iterate based on user feedback. Don't build structs support until users ask for it.
