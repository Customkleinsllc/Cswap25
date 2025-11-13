# Vercel Deployment Guide for CryptoSwap

Complete step-by-step guide to deploy CryptoSwap to Vercel in under 10 minutes.

---

## 🚀 Why Vercel?

- ✅ **Free tier** - Perfect for starting out
- ✅ **Automatic HTTPS** - SSL included
- ✅ **Global CDN** - Fast worldwide
- ✅ **Git integration** - Deploy on push
- ✅ **Zero config** - Works with Next.js out of the box
- ✅ **Preview deployments** - Test before production

---

## 📋 Prerequisites

Before deploying, make sure you have:

- [x] GitHub account
- [x] CryptoSwap code pushed to GitHub
- [x] Revenue wallet address
- [x] API keys obtained (1inch, WalletConnect, Infura)
- [x] pnpm install completed successfully
- [x] Local testing done (pnpm dev works)

---

## 🔐 Step 1: Sign Up for Vercel

### 1.1 Create Account

1. Go to **https://vercel.com/signup**
2. Click **"Continue with GitHub"** (recommended)
3. Authorize Vercel to access your GitHub
4. Complete signup

**OR use email:**
- Email: **admin@customkleins.llc**
- Verify email
- Connect GitHub later

### 1.2 Install Vercel CLI (Optional)

```bash
npm install -g vercel
vercel login
```

---

## 📂 Step 2: Prepare GitHub Repository

### 2.1 Push Code to GitHub

If not already done:

```bash
cd "C:\Users\CryptoSwap\Desktop\Cswap Web UNI\cryptoswap-dex"

# Initialize git (if not already done)
git remote add origin https://github.com/YOUR_USERNAME/cryptoswap-dex.git

# Push code
git add .
git commit -m "feat: ready for Vercel deployment"
git push -u origin main
```

### 2.2 Verify .gitignore

Make sure these are in `.gitignore`:
```
.env.local
.env*.local
CREDENTIALS.txt
node_modules
.next
```

**IMPORTANT:** Never commit `.env.local` or `CREDENTIALS.txt`!

---

## 🚀 Step 3: Deploy to Vercel

### Option A: Deploy via Vercel Dashboard (Easiest)

#### 3.1 Import Project

1. Go to **https://vercel.com/dashboard**
2. Click **"Add New..."** → **"Project"**
3. Click **"Import"** next to your `cryptoswap-dex` repo
4. If not visible, click **"Adjust GitHub App Permissions"**

#### 3.2 Configure Project

**Framework Preset:** Next.js (auto-detected)

**Root Directory:** `./` (leave as is)

**Build Settings:**
- Build Command: `pnpm build`
- Output Directory: `.next` (default)
- Install Command: `pnpm install`

**Node Version:** 18.x or 20.x

#### 3.3 Add Environment Variables

Click **"Environment Variables"** and add:

```
NEXT_PUBLIC_REVENUE_WALLET_EVM=0xYourActualWalletAddress
NEXT_PUBLIC_PLATFORM_FEE_BPS=5
NEXT_PUBLIC_1INCH_API_KEY=your_1inch_key
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_id
NEXT_PUBLIC_INFURA_KEY=your_infura_key
NEXT_PUBLIC_RPC_ETHEREUM=https://eth.llamarpc.com
NEXT_PUBLIC_RPC_POLYGON=https://polygon-rpc.com
NEXT_PUBLIC_RPC_ARBITRUM=https://arb1.arbitrum.io/rpc
NEXT_PUBLIC_RPC_AVALANCHE=https://api.avax.network/ext/bc/C/rpc
NEXT_PUBLIC_RPC_BSC=https://bsc-dataseed.binance.org
NEXT_PUBLIC_RPC_SEI=https://evm-rpc.sei-apis.com
NEXT_PUBLIC_SUPPORTED_CHAINS=1,56,137,42161,43114,1329
NEXT_PUBLIC_DEFAULT_CHAIN_ID=1
NEXT_PUBLIC_SITE_URL=https://cryptoswap.com
NEXT_PUBLIC_TESTNET_MODE=false
NEXT_PUBLIC_DEBUG=false
NEXT_PUBLIC_ENABLE_SWAP=true
NEXT_PUBLIC_ENABLE_LIQUIDITY=true
NEXT_PUBLIC_ENABLE_FARMS=true
NEXT_PUBLIC_ENABLE_STAKING=true
NEXT_PUBLIC_ENABLE_BRIDGE=true
NEXT_PUBLIC_ENABLE_ANALYTICS=true
```

**Pro Tip:** Copy-paste from your `.env.local` file!

#### 3.4 Deploy!

1. Click **"Deploy"**
2. Wait 5-10 minutes for build
3. 🎉 Your site is live!

**Your URL:** `https://cryptoswap-dex.vercel.app` (or similar)

---

### Option B: Deploy via CLI

```bash
cd cryptoswap-dex

# Login
vercel login

# Deploy (first time)
vercel

# Follow prompts:
# - Link to existing project? No
# - Project name? cryptoswap-dex
# - Directory? ./
# - Override settings? No

# Add environment variables
vercel env add NEXT_PUBLIC_REVENUE_WALLET_EVM production
vercel env add NEXT_PUBLIC_1INCH_API_KEY production
# ... add all others

# Deploy to production
vercel --prod
```

---

## 🌐 Step 4: Configure Custom Domain

### 4.1 Add Domain in Vercel

1. Go to your project dashboard
2. Click **"Settings"** → **"Domains"**
3. Click **"Add"**
4. Enter: `cryptoswap.com`
5. Click **"Add"**

### 4.2 Configure DNS

Vercel will show you DNS records to add. Go to your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.):

**Add A Record:**
```
Type: A
Name: @
Value: 76.76.21.21 (Vercel's IP)
TTL: 3600
```

**Add CNAME for www:**
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
TTL: 3600
```

### 4.3 Wait for Verification

- DNS propagation: 1-48 hours (usually 1-6 hours)
- Vercel will automatically provision SSL
- Check status in Vercel dashboard

### 4.4 Set as Primary Domain

Once verified:
1. Go to Domains settings
2. Click three dots next to `cryptoswap.com`
3. Click **"Set as Primary Domain"**

---

## 🔄 Step 5: Set Up Automatic Deployments

### 5.1 Enable Git Integration

Vercel automatically deploys when you push to GitHub!

**How it works:**
- Push to `main` → Deploys to production
- Push to other branches → Creates preview deployment
- Pull requests → Automatic preview links

### 5.2 Protect Production Branch

In GitHub:
1. Go to repo **Settings** → **Branches**
2. Add branch protection rule for `main`:
   - Require pull request reviews
   - Require status checks to pass
   - Include administrators

---

## 🧪 Step 6: Test Your Deployment

### 6.1 Basic Tests

Visit your site and check:
- [ ] Site loads properly
- [ ] All pages accessible
- [ ] Wallet connection works
- [ ] Swap interface loads
- [ ] Chain switching works
- [ ] Images load correctly
- [ ] No console errors (F12)

### 6.2 Test Swap Flow

1. Connect MetaMask
2. Switch to different chains
3. Try a small swap on each chain
4. Verify fee calculation correct
5. Check transaction completes
6. Verify fee went to revenue wallet

### 6.3 Performance Check

1. Go to **https://pagespeed.web.dev/**
2. Enter your URL
3. Check scores:
   - Performance: >85
   - Accessibility: >90
   - Best Practices: >90
   - SEO: >90

---

## 📊 Step 7: Monitor Your Deployment

### 7.1 Vercel Analytics

1. Go to project → **"Analytics"**
2. View:
   - Real-time visitors
   - Page views
   - Top pages
   - Geographic distribution
   - Core Web Vitals

### 7.2 Deployment Logs

1. Go to **"Deployments"**
2. Click any deployment
3. View:
   - Build logs
   - Function logs
   - Runtime logs

### 7.3 Set Up Alerts

1. Project **Settings** → **"Notifications"**
2. Enable:
   - Failed deployments
   - Performance degradation
   - Error rate increase
3. Add email: **admin@customkleins.llc**

---

## 🔒 Step 8: Security Hardening

### 8.1 Environment Variable Security

✅ **Already Configured in vercel.json:**
- Security headers (X-Frame-Options, CSP, etc.)
- HTTPS enforcement
- XSS protection

### 8.2 Additional Settings

1. **Settings** → **"Security"**
2. Enable:
   - [x] Secure cookies
   - [x] HTTPS redirect
   - [x] HSTS
   - [x] CORS restrictions

### 8.3 API Key Rotation

**Every 90 days:**
1. Generate new API keys
2. Update in Vercel dashboard
3. Redeploy

---

## 🚨 Troubleshooting

### Build Fails

**Error:** `pnpm: command not found`
```
Solution: Vercel auto-detects package manager. 
If fails, add to vercel.json:
"installCommand": "npm install -g pnpm && pnpm install"
```

**Error:** `Module not found`
```
Solution: Clear build cache
1. Go to Settings → General
2. Scroll to "Build & Development Settings"
3. Clear cache and redeploy
```

**Error:** `Out of memory`
```
Solution: Upgrade to Pro plan ($20/month) for more memory
Or optimize bundle size
```

### Site Not Loading

**Issue:** `ERR_NAME_NOT_RESOLVED`
```
Solution: DNS not propagated yet
- Wait 1-6 hours
- Check DNS: https://dnschecker.org/
- Verify DNS records match Vercel's requirements
```

**Issue:** `This site can't provide a secure connection`
```
Solution: SSL not provisioned yet
- Wait 10-30 minutes after DNS verification
- Check Vercel domain status
```

### Runtime Errors

**Check logs:**
1. Vercel Dashboard → Deployments
2. Click deployment → "Functions"
3. View real-time logs

**Common issues:**
- Missing environment variables
- Wrong API keys
- RPC provider limits reached

---

## 💰 Vercel Pricing

### Free Tier (Hobby)
- **Cost:** $0/month
- **Includes:**
  - Unlimited deployments
  - 100GB bandwidth/month
  - 100 hours compute/month
  - Automatic HTTPS
  - Preview deployments
  
**Perfect for:** Launch and initial growth (up to 10K visitors/month)

### Pro Tier
- **Cost:** $20/month
- **Includes:**
  - Unlimited bandwidth
  - Unlimited compute
  - Team collaboration
  - Advanced analytics
  - Password protection
  - More build minutes

**Upgrade when:** >10K visitors/month or need advanced features

### Enterprise
- **Cost:** Custom
- **Includes:**
  - Dedicated support
  - SLA guarantees
  - Custom contracts
  - Advanced security

**Upgrade when:** Serious scale (100K+ users/month)

---

## 🎯 Post-Deployment Checklist

### Immediate (Day 1)
- [ ] Verify deployment successful
- [ ] Test all features work
- [ ] Check analytics tracking
- [ ] Monitor error logs
- [ ] Test from different devices
- [ ] Verify SSL certificate
- [ ] Check page speed

### Week 1
- [ ] Monitor uptime (should be 99.9%+)
- [ ] Review error logs daily
- [ ] Check API usage
- [ ] Monitor gas costs
- [ ] Review user feedback
- [ ] Fix critical bugs
- [ ] Optimize slow pages

### Ongoing
- [ ] Weekly analytics review
- [ ] Monthly security updates
- [ ] Quarterly dependency updates
- [ ] API key rotation (every 90 days)
- [ ] Performance optimization
- [ ] Feature updates based on feedback

---

## 🔄 Redeployment Process

### For Code Changes

```bash
# Make changes locally
git add .
git commit -m "feat: new feature"
git push

# Vercel automatically deploys!
```

### For Environment Variable Changes

1. Vercel Dashboard → Settings → Environment Variables
2. Edit variable
3. Click "Redeploy" at top
4. Select latest deployment
5. Click "Redeploy"

### For Emergency Rollback

1. Go to Deployments
2. Find last working deployment
3. Click three dots → "Promote to Production"
4. Instant rollback!

---

## 📱 Mobile Testing

### Test on Real Devices

**iOS:**
- Safari (primary)
- Chrome
- Trust Wallet browser
- MetaMask app

**Android:**
- Chrome (primary)
- Samsung Internet
- MetaMask app
- Trust Wallet browser

### Responsive Testing Tools

- Chrome DevTools (F12 → Toggle device toolbar)
- **https://responsively.app/** (test multiple devices)
- **https://www.browserstack.com/** (real device testing)

---

## 🌟 Vercel Pro Tips

### 1. Preview Deployments

Every git branch gets its own URL:
```
feature-branch → cryptoswap-dex-git-feature-branch.vercel.app
```

Use for:
- Testing features before merge
- Showing stakeholders progress
- A/B testing

### 2. Environment-Specific Variables

Set different values per environment:
- **Production:** Real API keys, real revenue wallet
- **Preview:** Testnet API keys, test wallet
- **Development:** Debug mode enabled

### 3. Deploy Hooks

Create webhook for external triggers:
1. Settings → Git → Deploy Hooks
2. Create hook
3. Get webhook URL
4. Use to trigger deploys from:
   - CI/CD pipelines
   - External services
   - Scheduled tasks

### 4. Edge Functions

For future optimization:
- Put API proxies on edge
- Reduce latency worldwide
- Cache expensive operations

---

## 📞 Support Resources

### Vercel Documentation
- Docs: **https://vercel.com/docs**
- Guides: **https://vercel.com/guides**
- API Ref: **https://vercel.com/docs/rest-api**

### Getting Help
- Discord: **https://vercel.com/discord**
- GitHub: **https://github.com/vercel/vercel**
- Email: **support@vercel.com**
- Twitter: **@vercel**

### Community
- Vercel Discord (10K+ members)
- r/vercel on Reddit
- Stack Overflow (#vercel)

---

## ✅ Deployment Success Criteria

Your deployment is successful when:

- [x] Site loads at your domain
- [x] HTTPS works (green padlock)
- [x] All pages accessible
- [x] Wallet connection works
- [x] Swaps execute successfully
- [x] Fees collect to revenue wallet
- [x] No console errors
- [x] Page load < 3 seconds
- [x] Mobile responsive
- [x] Works on all major browsers

---

## 🚀 You're Live!

**Congratulations!** 🎉

Your DEX aggregator is now live and accessible worldwide!

**What's Next:**
1. Start marketing (use MARKETING-LAUNCH-KIT.md)
2. Monitor analytics daily
3. Gather user feedback
4. Iterate and improve
5. Scale up!

**Remember:**
- Vercel auto-deploys on git push
- Free tier is plenty for starting out
- Upgrade when you need more resources
- Monitor, learn, optimize, repeat!

---

**Last Updated:** 2025-11-11  
**Status:** Ready to deploy!

**Quick Deploy:**
1. Sign up: https://vercel.com/signup
2. Import GitHub repo
3. Add environment variables
4. Click Deploy
5. Done! 🚀

---

**Need help?** Check the Troubleshooting section or contact Vercel support!



