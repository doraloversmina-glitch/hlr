# Deployment Guide

## Prerequisites

Before deploying, ensure you have:
- Node.js 18+ installed
- Project built successfully (`npm run build`)

## Option 1: Vercel (Recommended - Easiest)

### Method A: Vercel CLI

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel
```

Follow the prompts:
- Set up and deploy? **Y**
- Which scope? Select your account
- Link to existing project? **N**
- What's your project's name? **c-memory-visualizer**
- In which directory is your code located? **/**
- Want to override settings? **N**

For production:
```bash
vercel --prod
```

### Method B: Vercel Dashboard

1. Go to https://vercel.com/new
2. Import your Git repository
3. Configure:
   - Framework Preset: **Vite**
   - Build Command: `npm run build`
   - Output Directory: `dist`
4. Click **Deploy**

**Your app will be live at**: `https://c-memory-visualizer.vercel.app`

---

## Option 2: Netlify

### Method A: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Build the project
npm run build

# Deploy to draft URL
netlify deploy

# When ready, deploy to production
netlify deploy --prod
```

### Method B: Netlify Dashboard

1. Go to https://app.netlify.com/drop
2. Drag and drop the `dist` folder
3. Done! Your site is live.

### Method C: Connect Git Repository

1. Go to https://app.netlify.com/start
2. Connect your Git provider (GitHub/GitLab)
3. Select repository: `c-memory-visualizer`
4. Build settings:
   - Build command: `npm run build`
   - Publish directory: `dist`
5. Click **Deploy site**

**Your app will be live at**: `https://random-name-12345.netlify.app`

You can customize the domain in Site settings → Domain management.

---

## Option 3: GitHub Pages

### Setup

1. Add homepage to `package.json`:
```json
{
  "homepage": "https://yourusername.github.io/c-memory-visualizer"
}
```

2. Install gh-pages:
```bash
npm install --save-dev gh-pages
```

3. Add deploy script to `package.json`:
```json
{
  "scripts": {
    "predeploy": "npm run build",
    "deploy": "gh-pages -d dist"
  }
}
```

4. Update `vite.config.ts`:
```typescript
export default defineConfig({
  plugins: [react()],
  base: '/c-memory-visualizer/', // Add this
})
```

### Deploy

```bash
npm run deploy
```

Enable GitHub Pages:
1. Go to your repo → Settings → Pages
2. Source: **gh-pages** branch
3. Click Save

**Your app will be live at**: `https://yourusername.github.io/c-memory-visualizer`

---

## Option 4: Cloudflare Pages

1. Go to https://dash.cloudflare.com/
2. Navigate to **Pages** → **Create a project**
3. Connect your Git repository
4. Build settings:
   - Build command: `npm run build`
   - Build output directory: `dist`
5. Click **Save and Deploy**

**Your app will be live at**: `https://c-memory-visualizer.pages.dev`

---

## Option 5: Render

1. Go to https://dashboard.render.com/
2. Click **New** → **Static Site**
3. Connect your repository
4. Settings:
   - Build Command: `npm run build`
   - Publish Directory: `dist`
5. Click **Create Static Site**

**Your app will be live at**: `https://c-memory-visualizer.onrender.com`

---

## Option 6: Self-Hosted (Your Own Server)

### Using Nginx

1. Build the project:
```bash
npm run build
```

2. Copy `dist` folder to server:
```bash
scp -r dist/* user@yourserver.com:/var/www/c-memory-visualizer/
```

3. Nginx config (`/etc/nginx/sites-available/c-memory-visualizer`):
```nginx
server {
    listen 80;
    server_name cmemviz.yourserver.com;

    root /var/www/c-memory-visualizer;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Gzip compression
    gzip on;
    gzip_types text/css application/javascript application/json;
}
```

4. Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/c-memory-visualizer /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

### Using Apache

1. Copy dist to server
2. Apache config:
```apache
<VirtualHost *:80>
    ServerName cmemviz.yourserver.com
    DocumentRoot /var/www/c-memory-visualizer

    <Directory /var/www/c-memory-visualizer>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted

        # Rewrite for SPA
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>
</VirtualHost>
```

---

## Environment Variables

This project doesn't require environment variables. All configuration is client-side.

---

## Custom Domain

### Vercel
1. Go to Project Settings → Domains
2. Add your domain
3. Update DNS records as instructed

### Netlify
1. Go to Site settings → Domain management
2. Add custom domain
3. Update DNS records

---

## SSL/HTTPS

All modern platforms (Vercel, Netlify, Cloudflare) provide **automatic HTTPS** with free SSL certificates.

For self-hosted:
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d cmemviz.yourserver.com
```

---

## Performance Optimization

Already included in build:
- Minified JS/CSS
- Tree-shaking
- Code splitting
- Gzip compression

To verify:
```bash
npm run build
ls -lh dist/assets/  # Check file sizes
```

---

## Monitoring

### Vercel Analytics
Enable in dashboard → Analytics

### Google Analytics
Add to `index.html`:
```html
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
```

---

## Troubleshooting

### "Blank page" after deploy
- Check browser console for errors
- Verify base path in `vite.config.ts`
- Ensure `dist` folder uploaded correctly

### "404 on refresh"
- Configure server for SPA routing (see above)

### "Styles not loading"
- Check if Tailwind CSS built correctly
- Verify `postcss.config.js` exists

---

## Quick Deploy Checklist

- [ ] Code committed to Git
- [ ] `npm run build` succeeds locally
- [ ] No console errors in built version
- [ ] Choose deployment platform
- [ ] Configure build settings
- [ ] Deploy!
- [ ] Test on deployed URL
- [ ] (Optional) Configure custom domain

---

**Recommended for beginners**: Start with **Vercel** or **Netlify** - both offer:
- Free tier
- Automatic HTTPS
- Global CDN
- CI/CD from Git
- Zero configuration

Good luck! 🚀
