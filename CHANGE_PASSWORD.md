# 🔑 How to Change Your Password

## Quick Steps

### 1. Generate Your Password Hash

Open terminal and run:
```bash
python3 -c "import hashlib; print(hashlib.sha256('YourNewPassword'.encode()).hexdigest())"
```

**Replace `YourNewPassword` with your actual password!**

Example:
```bash
python3 -c "import hashlib; print(hashlib.sha256('MySuper$ecretP@ss2024'.encode()).hexdigest())"
```

This will output something like:
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2
```

**Copy this hash!**

---

### 2. Set in Render Dashboard

1. Go to: **https://dashboard.render.com**
2. Click on your service: **"hlr"** or **"excel-comparator"**
3. Click the **"Environment"** tab (left sidebar)
4. Click **"Add Environment Variable"**
5. Fill in:
   - **Key:** `APP_PASSWORD_HASH`
   - **Value:** (paste your hash from step 1)
6. Click **"Save Changes"**

Render will automatically redeploy with your new password!

---

### 3. Wait & Test

- **Wait:** 2-3 minutes for redeploy
- **Visit:** https://hlr.onrender.com
- **Login with:** Your new password!

---

## ✅ Done!

Password is now changed and the default password is removed from the login page.

**Old password (won't work anymore):** SecurePass123!
**New password:** Whatever you set!

---

## 💡 Password Tips

**Good passwords:**
- At least 12 characters
- Mix of uppercase, lowercase, numbers, symbols
- Examples:
  - `Compar3Excel$2024!`
  - `MyT3am@SecureP@ss`
  - `Xlsx!Compare#99`

**Bad passwords:**
- `password123`
- `admin`
- `12345678`

---

## 🔐 Share Password Securely

**DO:**
- Share via password manager (1Password, LastPass)
- Share in person
- Use encrypted messaging (Signal, WhatsApp)

**DON'T:**
- Put in email
- Post in Slack/Teams
- Write in shared docs

---

## Questions?

Just message me if you need help!
