# 42 School Style Guide - C Memory Visualizer

## 42 Philosophy Integration

### Core Principles
1. **Peer-to-peer learning** - No hand-holding, discovery-based
2. **Gamification** - XP, achievements, leaderboards
3. **Minimalist terminal aesthetic** - Dark, clean, hacker vibe
4. **Self-sufficiency** - Comprehensive man pages, no tutorials
5. **Rigor** - Norminette-style code standards

---

## VISUAL DESIGN (42 AESTHETIC)

### Color Palette (Dark Terminal Theme)
```css
:root {
  /* Primary - 42 brand colors */
  --color-42-cyan: #00BABC;        /* Primary accent */
  --color-42-dark: #0E0E0E;        /* Main background */
  --color-42-darker: #000000;      /* Panels */
  --color-42-gray: #1A1A1A;        /* Secondary bg */

  /* Terminal colors */
  --color-text: #FFFFFF;           /* Primary text */
  --color-text-dim: #808080;       /* Secondary text */
  --color-success: #00FF00;        /* Valid memory */
  --color-error: #FF0000;          /* Errors */
  --color-warning: #FFFF00;        /* Warnings */
  --color-info: #00BABC;           /* Info/highlights */

  /* Memory states */
  --color-allocated: #00FF41;      /* Matrix green */
  --color-freed: #FF0055;          /* Cyberpunk red */
  --color-uninitialized: #FFD700;  /* Warning gold */
  --color-current-line: #00BABC33; /* Cyan with alpha */
}
```

### Typography
```css
/* Monospace everywhere - terminal aesthetic */
font-family: 'JetBrains Mono', 'Fira Code', 'Monaco', 'Courier New', monospace;

/* Sizes */
--font-code: 14px;
--font-ui: 13px;
--font-heading: 16px;
--font-small: 12px;

/* Enable ligatures for => -> >= etc */
font-feature-settings: "liga" 1, "calt" 1;
```

### UI Components (Terminal Style)

#### Window Borders (ASCII-like)
```
┌─────────────────────────────────────────────┐
│ main()                          [0x7FFF000] │
├─────────────────────────────────────────────┤
│ int x = 42;    [0x7FFF1000] = 0x0000002A   │
│ int *p = &x;   [0x7FFF1004] = 0x7FFF1000   │
└─────────────────────────────────────────────┘
```

#### Buttons (Terminal Style)
```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ [>>] RUN │  │ [>] STEP │  │ [X] STOP │
└──────────┘  └──────────┘  └──────────┘
```

#### Status Bar (42 Style)
```
[●] RUNNING | Line: 42/100 | Stack: 2 frames | Heap: 3 blocks | Errors: 0
```

---

## LAYOUT (42 TERMINAL INTERFACE)

### Full Layout
```
┌────────────────────────────────────────────────────────────────────┐
│ C-MEM-VIZ v1.0.0                    login: jdoe      XP: 1337/2000 │
├────────────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────┐ ┌────────────────────────────────┐  │
│ │ // CODE                  │ │ [STACK] [HEAP] [GRAPH] [LOG]   │  │
│ │ ======================== │ │ ============================== │  │
│ │                          │ │                                │  │
│ │   1  #include <stdlib.h> │ │ STACK FRAME: main()            │  │
│ │ ►42  int x = 42;        │ │ ┌────────────────────────────┐ │  │
│ │  43  int *p = &x;        │ │ │ x     42    [0x7FFF_1000]  │ │  │
│ │  44  *p = 21;            │ │ │ p     ───►  [0x7FFF_1004]  │ │  │
│ │  45  return (0);         │ │ └────────────────────────────┘ │  │
│ │                          │ │                                │  │
│ │ [!] 0 errors | 0 leaks  │ │ HEAP: 0 allocations            │  │
│ │                          │ │                                │  │
│ └──────────────────────────┘ └────────────────────────────────┘  │
├────────────────────────────────────────────────────────────────────┤
│ [>>] run  [>] step  [<] back  [X] reset     ──●──────  500ms      │
└────────────────────────────────────────────────────────────────────┘
│ > Ready. Type 'help' for commands.                                 │
└────────────────────────────────────────────────────────────────────┘
```

---

## 42-SPECIFIC FEATURES

### 1. Achievement System (Gamification)
```javascript
const ACHIEVEMENTS = {
  'first_malloc': {
    title: '🏆 Dynamic Allocator',
    description: 'Successfully malloc and free your first block',
    xp: 50
  },
  'catch_uaf': {
    title: '🔍 Bug Hunter',
    description: 'Detected a use-after-free error',
    xp: 100
  },
  'zero_leaks': {
    title: '💚 Memory Master',
    description: 'Completed program with zero memory leaks',
    xp: 200
  },
  'norminette_style': {
    title: '📏 Norm Compliant',
    description: 'Code follows Norminette conventions',
    xp: 25
  },
  'pointer_wizard': {
    title: '🧙 Pointer Wizard',
    description: 'Successfully used pointer arithmetic 10 times',
    xp: 150
  }
};
```

### 2. Norminette Integration
- Check code style (42 chars per line, function length, etc.)
- Show warnings for non-compliant code
- Optional: enforce Norminette rules

### 3. Peer Review Mode
- Share session URL with peers
- Comment on specific lines
- "Request peer review" button

### 4. Man Page Style Help
```
NAME
     c-mem-viz - C memory visualizer for 42 students

SYNOPSIS
     Load C snippet and step through execution to visualize memory

DESCRIPTION
     The c-mem-viz tool simulates C code execution and displays:

     - Stack frames and local variables
     - Heap allocations (malloc/free)
     - Pointer relationships
     - Memory errors (UAF, OOB, leaks)

CONTROLS
     >>      Run until completion or error
     >       Execute next line (step)
     <       Step backward (undo last step)
     X       Reset to initial state

MEMORY STATES
     [0x...]     Memory address (hexadecimal)
     ───►        Pointer reference
     [FREED]     Invalid/freed memory
     [???]       Uninitialized memory

ERRORS
     UAF         Use-after-free
     OOB         Out-of-bounds access
     SEGV        Null pointer dereference
     LEAK        Memory not freed at exit

EXAMPLES
     Example 1: Basic pointer
         int x = 42;
         int *p = &x;
         *p = 21;

     Example 2: Dynamic allocation
         int *arr = malloc(sizeof(int) * 5);
         arr[0] = 42;
         free(arr);

AUTHOR
     Built for 42 Network students

SEE ALSO
     malloc(3), free(3), valgrind(1)
```

### 5. Command-Line Interface (Optional)
```
> load examples/malloc_basic.c
Loaded 15 lines

> run
Step 1/15: int x = 42;
Step 2/15: int *p = malloc(sizeof(int));
...
[!] Error at line 8: Use-after-free

> inspect p
Variable: p
Type: int*
Value: 0x0040_00A0
Target: [FREED at line 7]
Status: ⚠️  INVALID POINTER

> help malloc
MALLOC(3)
  Allocates memory on the heap.
  Returns pointer to block or NULL on failure.
  Must be freed with free() to avoid leaks.
```

---

## CODE EXAMPLES (42 PEDAGOGY)

### Starter Pack (Progressive Difficulty)

#### Level 0: Hello Pointers
```c
// 00_hello_ptr.c - Your first pointer
int main(void)
{
    int x;
    int *p;

    x = 42;
    p = &x;
    *p = 21;
    return (0);
}
```

#### Level 1: Malloc Basics
```c
// 01_malloc.c - Dynamic allocation
#include <stdlib.h>

int main(void)
{
    int *p;

    p = malloc(sizeof(int));
    if (!p)
        return (1);
    *p = 42;
    free(p);
    return (0);
}
```

#### Level 2: Arrays
```c
// 02_arrays.c - Array allocation
#include <stdlib.h>

int main(void)
{
    int *arr;
    int i;

    arr = malloc(sizeof(int) * 5);
    i = 0;
    while (i < 5)
    {
        arr[i] = i * 10;
        i++;
    }
    free(arr);
    return (0);
}
```

#### Level 3: Catch the Bug
```c
// 03_bug_hunt.c - Find the error!
#include <stdlib.h>

int main(void)
{
    int *p;

    p = malloc(sizeof(int));
    *p = 42;
    free(p);
    *p = 21;  // ⚠️  Bug here!
    return (0);
}
```

#### Level 4: Memory Leak
```c
// 04_leak.c - Don't leak memory!
#include <stdlib.h>

int main(void)
{
    int *p1;
    int *p2;

    p1 = malloc(sizeof(int) * 10);
    p2 = malloc(sizeof(int) * 20);
    free(p1);
    // Oops, forgot to free p2!
    return (0);
}
```

#### Level 5: ft_split Challenge
```c
// 05_ft_split.c - Libft function visualization
#include <stdlib.h>

char **ft_split(char const *s, char c)
{
    char **result;
    int count;

    count = count_words(s, c);
    result = malloc(sizeof(char *) * (count + 1));
    // ... split logic
    return (result);
}

int main(void)
{
    char **words;

    words = ft_split("Hello 42 world", ' ');
    // Visualize the 2D array allocation
    free_split(words);
    return (0);
}
```

---

## XP & PROGRESSION SYSTEM

### XP Sources
```javascript
const XP_REWARDS = {
  'run_code': 5,              // Base XP per run
  'find_error': 20,           // Catch a memory error
  'fix_error': 50,            // Fix and re-run successfully
  'zero_leaks': 100,          // Clean execution
  'complete_level': 200,      // Finish example level
  'peer_review': 30,          // Review peer's code
  'share_solution': 15,       // Share working solution
};

const LEVELS = {
  1: { xp: 0,     title: 'Padawan' },
  2: { xp: 500,   title: 'Cadet' },
  3: { xp: 1500,  title: 'Developer' },
  4: { xp: 3000,  title: 'Engineer' },
  5: { xp: 5000,  title: 'Architect' },
  6: { xp: 10000, title: 'Memory Master' },
};
```

### Leaderboard (42 Intra Style)
```
┌─────────────────────────────────────────────┐
│ GLOBAL LEADERBOARD                          │
├──────┬───────────┬──────────┬───────────────┤
│ Rank │ Login     │ XP       │ Level         │
├──────┼───────────┼──────────┼───────────────┤
│  1   │ jdoe      │ 15,420   │ Memory Master │
│  2   │ asmith    │ 12,100   │ Architect     │
│  3   │ bwilson   │ 9,850    │ Architect     │
│ ...  │ ...       │ ...      │ ...           │
│ 42   │ YOU       │ 3,200    │ Engineer      │
└──────┴───────────┴──────────┴───────────────┘
```

---

## ERROR MESSAGES (42 TONE)

### Use-After-Free
```
┌────────────────────────────────────────────┐
│ ⚠️  SEGMENTATION FAULT (core dumped)       │
├────────────────────────────────────────────┤
│ Line 42: *p = 21;                          │
│                                            │
│ Error: Use-after-free                      │
│ You're dereferencing a freed pointer.     │
│                                            │
│ Hint: Check line 40 - you freed this      │
│ memory. Once freed, don't touch it again. │
│                                            │
│ man free(3) for more info                 │
└────────────────────────────────────────────┘
```

### Memory Leak
```
┌────────────────────────────────────────────┐
│ ⚠️  MEMORY LEAK DETECTED                   │
├────────────────────────────────────────────┤
│ 2 blocks still allocated at exit:         │
│                                            │
│ • 0x0040_00A0 (40 bytes) - line 12        │
│ • 0x0040_0100 (16 bytes) - line 23        │
│                                            │
│ You must free() all malloc'd memory.      │
│                                            │
│ Run valgrind to check: valgrind ./a.out   │
└────────────────────────────────────────────┘
```

### Norminette Warning
```
┌────────────────────────────────────────────┐
│ 📏 NORMINETTE: Warning                     │
├────────────────────────────────────────────┤
│ Line 42: Line too long (87/80 chars)      │
│ Line 15: Function too many lines (30/25)  │
│                                            │
│ This won't stop execution, but Moulinette │
│ would not be happy. Fix before submitting!│
└────────────────────────────────────────────┘
```

---

## INTERACTIONS (42 UX)

### Keyboard Shortcuts (VIM-inspired)
```
NAVIGATION
  j/k       Scroll code up/down
  gg        Jump to top
  G         Jump to bottom
  /         Search in code

EXECUTION
  Space     Step forward
  Shift+Space  Run
  u         Undo (step back)
  r         Reset

PANELS
  1-4       Switch tabs (Stack/Heap/Graph/Log)
  Tab       Toggle focus code/viz

OTHER
  ?         Show help
  Esc       Clear errors
  :q        Close (easter egg)
```

### Mouse Interactions
- Click line number → set breakpoint
- Hover variable → highlight in memory
- Right-click variable → "Watch this"
- Double-click malloc → jump to corresponding free

---

## ANIMATIONS (SUBTLE, TERMINAL-LIKE)

### Execution Step
```
Before:   int x = 42;
          ^

After:    int x = 42;
                     ^

[Flash effect on changed memory cells - 200ms]
```

### Malloc Animation
```
Frame 1:  HEAP: [empty]
Frame 2:  HEAP: [▒▒▒▒▒▒▒▒] (allocating...)
Frame 3:  HEAP: [████████] (allocated!)

[Green border pulse - 300ms]
```

### Free Animation
```
Frame 1:  [████████] VALID
Frame 2:  [▓▓▓▓▓▓▓▓] (freeing...)
Frame 3:  [✗✗✗✗✗✗✗✗] FREED

[Red strikethrough animation - 300ms]
```

---

## RESPONSIVE DESIGN (42 WORKSTATIONS)

### Desktop (1920x1080 - iMac)
```
[CODE 50%] [VISUALIZATION 50%]
```

### Laptop (1440x900)
```
[CODE 45%] [VIZ 55%]
```

### Mobile (Vertical)
```
[CODE - Full width]
[Toggle: Show Memory ▼]
[VIZ - Collapsible]
```

---

## TECHNICAL STACK (42-APPROVED)

### Why Each Choice Fits 42:

**React** - Industry standard, part of 42 web curriculum
**TypeScript** - Type safety (like Norminette for JS)
**Vite** - Fast, modern, no Webpack complexity
**TailwindCSS** - Utility-first, terminal aesthetic
**tree-sitter** - Used by GitHub, professional-grade
**Zustand** - Minimal state management (no Redux bloat)

### Deployment
- **Vercel** - Free for open source, fast CDN
- **URL**: `mem.42.tools` or `c-viz.42project.dev`

---

## ACCESSIBILITY (42 INCLUSIVITY)

### Screen Reader Support
```html
<div role="region" aria-label="Stack memory visualization">
  <div role="list" aria-label="Stack frames">
    <div role="listitem" aria-label="Variable x: value 42, address 0x7FFF1000">
```

### Keyboard Navigation
- All features accessible without mouse
- Tab order: Code → Controls → Visualization → Log

### High Contrast Mode
```css
@media (prefers-contrast: high) {
  --color-allocated: #00FF00;  /* Pure green */
  --color-freed: #FF0000;      /* Pure red */
  --border-width: 2px;         /* Thicker borders */
}
```

---

## INTEGRATION WITH 42 INTRA

### OAuth Login (Optional)
```javascript
// Login with 42 account to save progress
const auth42 = new FtAuth({
  clientId: process.env.FT_CLIENT_ID,
  redirectUri: 'https://c-viz.42/callback'
});
```

### Sync with Projects
```
PROJECT: libft
└── ft_split visualization
    ├── XP earned: 250
    ├── Bugs found: 2
    └── Peer reviews: 3

PROJECT: get_next_line
└── Buffer visualization
    ├── XP earned: 400
    └── Achievement: Zero Leaks 🏆
```

---

## BRANDING

### Logo (ASCII Art)
```
  ██████╗      ███╗   ███╗███████╗███╗   ███╗
 ██╔════╝      ████╗ ████║██╔════╝████╗ ████║
 ██║     █████╗██╔████╔██║█████╗  ██╔████╔██║
 ██║     ╚════╝██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║
 ╚██████╗      ██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║
  ╚═════╝      ╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝
                  Memory Visualizer v1.0
```

### Tagline
```
"See your pointers. Master your memory. Become 42."
```

---

## EXAMPLE SESSION (42 STUDENT FLOW)

### 1. Landing Page
```
┌────────────────────────────────────────────┐
│         Welcome to C-MEM-VIZ               │
│                                            │
│   Visualize memory. Catch bugs. Level up. │
│                                            │
│   [LOGIN WITH 42] [TRY AS GUEST]           │
│                                            │
│   Featured: ft_split visualization         │
│   Popular: Use-after-free challenge        │
└────────────────────────────────────────────┘
```

### 2. Load Example
```
> load example libft/ft_split
Loaded: ft_split.c (42 lines)

Tips:
• Use [>] to step through execution
• Watch how the 2D array is allocated
• Try to spot the memory leak!
```

### 3. Step Through
```
Line 12: result = malloc(sizeof(char *) * (count + 1));

HEAP:
┌──────────────────────────────────────┐
│ Block 0x0040_00A0 (32 bytes)         │
│ [ptr][ptr][ptr][ptr][NULL]           │
│ Allocated at line 12                 │
└──────────────────────────────────────┘

XP +5
```

### 4. Find Bug
```
⚠️  MEMORY LEAK DETECTED!

You forgot to free the individual strings!
See lines 15-18 where you malloc each word.

XP +20 (Bug Hunter achievement unlocked!)
```

### 5. Share & Review
```
Code fixed! All memory freed correctly.

XP +100 (Zero Leaks achievement!)
Total session XP: 125

[SHARE SOLUTION] [REQUEST PEER REVIEW] [NEXT LEVEL]
```

---

## FINAL TOUCHES (42 POLISH)

### Easter Eggs
```
:q          → "You're not in Vim, but I like your style."
norminette  → Run Norminette check on code
valgrind    → Show detailed leak report
man malloc  → Show malloc man page
cowsay      → ASCII cow says "Moo! Check your pointers!"
```

### Loading Messages
```
Loading tree-sitter...
Initializing malloc arena...
Spawning stack frames...
Preparing heap buckets...
Ready. May the pointers be with you.
```

### Footer
```
┌────────────────────────────────────────────┐
│ Made with ☕ for 42 Network                │
│ Open Source • GitHub • Discord             │
│ Report bugs: github.com/42/c-mem-viz       │
└────────────────────────────────────────────┘
```

---

## SUMMARY: 42 STYLE CHECKLIST

✅ Dark terminal aesthetic (black + cyan)
✅ Monospace fonts everywhere
✅ ASCII art borders and graphics
✅ Gamification (XP, achievements, leaderboards)
✅ Man page style documentation
✅ Norminette integration
✅ Peer review features
✅ Keyboard-first navigation
✅ Progressive difficulty examples
✅ No hand-holding (discovery-based learning)
✅ 42 Intra OAuth integration
✅ Easter eggs and terminal culture
✅ Clean, minimal, professional

---

**Philosophy**: "Don't tell them how to code. Show them their memory. Let them discover the bugs. Reward the learning."

This is the 42 way. 🚀
