# C Memory Visualizer - 42 Network Edition

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

An interactive web-based tool for visualizing C memory management, designed for 42 school students learning pointers, malloc/free, and memory errors.

## 🎯 Features

- **Step-by-step Execution**: Execute C code line by line
- **Memory Visualization**: See stack frames, heap allocations, and pointer relationships in real-time
- **Error Detection**: Automatically catches:
  - Use-after-free
  - Out-of-bounds access
  - Null pointer dereference
  - Double free
  - Memory leaks
- **42 School Aesthetic**: Dark terminal theme with cyan accents
- **Interactive Examples**: Pre-loaded examples from basic pointers to common bugs

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
# Navigate to the project directory
cd c-memory-visualizer

# Install dependencies
npm install

# Start development server
npm run dev
```

Open `http://localhost:3000` in your browser.

## 📦 Deployment

### Deploy to Vercel (Recommended)

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy:
```bash
npm run build
vercel --prod
```

Or connect your GitHub repo to Vercel for automatic deployments.

### Deploy to Netlify

1. Build the project:
```bash
npm run build
```

2. Deploy the `dist` folder to Netlify:
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --prod --dir=dist
```

Or drag and drop the `dist` folder to Netlify's web interface.

### Deploy to GitHub Pages

1. Install gh-pages:
```bash
npm install -g gh-pages
```

2. Add to `package.json`:
```json
{
  "scripts": {
    "deploy": "npm run build && gh-pages -d dist"
  }
}
```

3. Deploy:
```bash
npm run deploy
```

## 🎓 Usage

### Loading Code

1. **Use Examples**: Click any example button to load pre-written C code
2. **Paste Code**: Paste your C code in the text area and click "Load Code"

### Execution Controls

- **Step**: Execute one line at a time
- **Run**: Execute until completion or error
- **Pause**: Pause during execution
- **Back**: Step backward (undo)
- **Reset**: Return to initial state

### Viewing Memory

- **Stack Tab**: View function call stack and local variables
- **Heap Tab**: View malloc'd blocks and their status
- **Log Tab**: See execution events (malloc, free, assignments)

## 📚 Supported C Syntax

### Variables
```c
int x = 42;
int *p = &x;
int arr[5];
```

### Pointers
```c
int *p = &x;
*p = 21;
```

### Dynamic Memory
```c
int *p = malloc(sizeof(int) * 10);
p[0] = 42;
free(p);
```

### Control Flow
```c
if (x > 0) { }
while (i < 10) { }
for (int i = 0; i < 5; i++) { }
```

### Limitations

This is an **educational simulator**, not a full C compiler. Not supported:
- Structs/unions
- Function pointers
- Preprocessor directives (#include, #define)
- Standard library (except malloc/free)
- Multi-file programs
- Recursion (initially)

## 🏗️ Architecture

```
React 18 + TypeScript
├── Parser (Custom C parser)
├── Interpreter (Step-by-step executor)
├── Store (Zustand state management)
└── UI Components (Stack/Heap/Log views)
```

**Key Design Decision**: Client-side only - no backend required!

## 🎨 Customization

### Changing Theme Colors

Edit `tailwind.config.js`:

```javascript
colors: {
  '42-cyan': '#00BABC',    // Primary accent
  '42-dark': '#0E0E0E',    // Background
  '42-darker': '#000000',  // Panels
  '42-gray': '#1A1A1A',    // Borders
}
```

### Adding More Examples

Edit `src/components/CodeEditor.tsx` and add to the `EXAMPLES` array:

```typescript
{
  name: 'your_example',
  title: 'Example Title',
  code: `int main(void) { ... }`
}
```

## 🐛 Troubleshooting

### "Module not found" errors
```bash
rm -rf node_modules package-lock.json
npm install
```

### Build fails
```bash
npm run build -- --verbose
```

### Styles not loading
```bash
# Rebuild Tailwind
npx tailwindcss -i ./src/index.css -o ./dist/output.css --watch
```

## 📖 Documentation

See the `docs/` directory for detailed design documents:

- `C_MEMORY_VISUALIZER_DESIGN.md` - Architecture and technical design
- `42_SCHOOL_STYLE_GUIDE.md` - 42-specific features and styling
- `IMPLEMENTATION_QUICKSTART.md` - Development guide

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Credits

Built for 42 Network students learning C memory management.

Inspired by:
- Valgrind
- GDB
- Python Tutor

## 📞 Support

- GitHub Issues: Report bugs or request features
- 42 Slack: #c-memory-viz channel

---

**Made with ☕ for 42 Network**

*"See your pointers. Master your memory. Become 42."*
