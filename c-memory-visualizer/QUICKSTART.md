# Quick Start Guide - Deploy in 5 Minutes! 🚀

## You Don't Have Terminal Access? No Problem!

This guide is for you if you want to deploy WITHOUT using the terminal.

---

## Step 1: Download the Project

If you haven't already, download this entire `c-memory-visualizer` folder to your local machine.

---

## Step 2: Install Node.js (if not installed)

1. Go to https://nodejs.org/
2. Download and install the **LTS version**
3. Verify installation: Open Command Prompt/Terminal and type:
   ```
   node --version
   ```

---

## Step 3: Install Dependencies

### Windows:
1. Open the `c-memory-visualizer` folder
2. Hold **Shift** + **Right-click** in the folder
3. Select "Open PowerShell window here" or "Open command window here"
4. Type:
   ```
   npm install
   ```
5. Wait for installation to complete (2-3 minutes)

### Mac:
1. Open Terminal
2. Drag the `c-memory-visualizer` folder into Terminal
3. Type:
   ```
   npm install
   ```

---

## Step 4: Test Locally (Optional)

```
npm run dev
```

Open browser to http://localhost:3000

Press `Ctrl+C` to stop.

---

## Step 5: Deploy to Vercel (EASIEST METHOD)

### Method A: Vercel Dashboard (No Command Line!)

1. Go to https://vercel.com/signup
2. Sign up with GitHub (or email)
3. Click **"New Project"**
4. Click **"Import Git Repository"**
5. If you haven't pushed to Git yet:
   - Create a GitHub account at https://github.com
   - Create a new repository
   - Upload the `c-memory-visualizer` folder to that repo
6. In Vercel, select your repository
7. Configure:
   - **Framework Preset**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
8. Click **Deploy**
9. Wait 2-3 minutes
10. **DONE!** Your app is live! 🎉

Your URL will be: `https://c-memory-visualizer-xxxxxx.vercel.app`

---

## Alternative: Deploy to Netlify

### Drag & Drop Method (NO CODE!)

1. First, build the project:
   - Windows: Double-click `build.bat` (see below)
   - Mac: Run `npm run build` in Terminal

2. Go to https://app.netlify.com/drop

3. Drag the `dist` folder from your project into the browser

4. **DONE!** Your site is live!

---

## Create Easy Build Script

### For Windows: `build.bat`

Create a file named `build.bat` in the `c-memory-visualizer` folder:

```batch
@echo off
echo Building C Memory Visualizer...
call npm install
call npm run build
echo.
echo Build complete! The 'dist' folder is ready.
echo You can now upload it to Netlify or any hosting service.
pause
```

Double-click this file to build.

### For Mac: `build.sh`

Create a file named `build.sh`:

```bash
#!/bin/bash
echo "Building C Memory Visualizer..."
npm install
npm run build
echo ""
echo "Build complete! The 'dist' folder is ready."
```

Run: `chmod +x build.sh && ./build.sh`

---

## Without Git? Use Vercel CLI

1. Install Vercel CLI:
   ```
   npm install -g vercel
   ```

2. Login:
   ```
   vercel login
   ```

3. Deploy:
   ```
   vercel
   ```

4. For production:
   ```
   vercel --prod
   ```

---

## Troubleshooting

### "npm: command not found"
- Node.js not installed. Go to Step 2.

### "Permission denied"
- Windows: Run PowerShell as Administrator
- Mac: Try `sudo npm install`

### Build fails
- Delete `node_modules` folder
- Delete `package-lock.json`
- Run `npm install` again

### Blank page after deploy
- Check if `dist` folder was uploaded
- Verify base path in `vite.config.ts`

---

## Free Hosting Options Summary

| Platform | Difficulty | Time | Custom Domain |
|----------|-----------|------|---------------|
| **Vercel** (Recommended) | ⭐ Easy | 3 min | ✅ Yes |
| **Netlify** (Drag & Drop) | ⭐ Easy | 2 min | ✅ Yes |
| GitHub Pages | ⭐⭐ Medium | 10 min | ✅ Yes |
| Cloudflare Pages | ⭐⭐ Medium | 5 min | ✅ Yes |

---

## After Deployment

1. Test your live site
2. Share the URL!
3. (Optional) Connect custom domain

---

## Need Help?

- Check `DEPLOYMENT.md` for detailed guides
- Check `README.md` for usage instructions
- File an issue on GitHub

---

**Congratulations! Your C Memory Visualizer is now live! 🎊**

Share it with your fellow 42 students!
