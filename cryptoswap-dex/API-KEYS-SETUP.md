# API Keys Setup Guide

## Summary

**Email Used:** admin@customkleins.llc  
**Credentials File:** See `CREDENTIALS.txt` (do NOT commit!)

### ✅ Completed
- 1inch Business: Magic link sent to email
- Reown (WalletConnect): Account created (password in CREDENTIALS.txt)
- Documentation created with all setup instructions

### ⏳ Awaiting Your Action
1. **Check email** for 1inch magic link → Click it → Get API key
2. **Complete Cloudflare verifications** for Reown and Infura signups
3. **Create .env.local** with all API keys (template below)

### Alternative Option
For quick testing, you can use **public RPC endpoints** (no signup needed) - see below.

---

## Quick Start (No API Keys Needed)

If you want to test immediately without waiting for API signups, use this `.env.local`:

```env
# Public RPCs (free, no signup, but rate-limited)
NEXT_PUBLIC_RPC_ETHEREUM=https://eth.llamarpc.com
NEXT_PUBLIC_RPC_POLYGON=https://polygon-rpc.com
NEXT_PUBLIC_RPC_ARBITRUM=https://arb1.arbitrum.io/rpc
NEXT_PUBLIC_RPC_AVALANCHE=https://api.avax.network/ext/bc/C/rpc
NEXT_PUBLIC_RPC_BSC=https://bsc-dataseed.binance.org

# Your revenue wallet
NEXT_PUBLIC_REVENUE_WALLET_EVM=0xYourWalletAddress

# Platform fee (0.05% = 5 basis points)
NEXT_PUBLIC_PLATFORM_FEE_BPS=5

# Optional: For better functionality, add when available
# NEXT_PUBLIC_1INCH_API_KEY=
# NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=
```

Then run: `pnpm dev` to start testing!

---

## 1inch Business API ✉️ **EMAIL SENT**

**Status:** Magic link sent to admin@customkleins.llc  
**Action Required:**
1. Check your email inbox for "1inch Business" magic link
2. Click the link to complete sign-up
3. Once logged in, navigate to: https://business.1inch.com/portal/
4. Go to "API Keys" section
5. Create a new API key for "CryptoSwap DEX"
6. Copy the key (format: starts with letters/numbers)

**Where to add the key:**
```env
# In cryptoswap-dex/.env.local
NEXT_PUBLIC_1INCH_API_KEY=your_key_here
```

**Pricing:** Free tier includes:
- 1 request/second
- Swap API access
- All supported chains
- Sufficient for development and initial launch

---

## Infura RPC Provider ⏸️ **BLOCKED BY CLOUDFLARE**

**Website:** https://developer.metamask.io/  
**Status:** Requires manual signup (Cloudflare protection)  
**Sign-up Method:** Email or GitHub  
**What you'll get:**
- Project ID (used as API key)
- Free tier: 100,000 requests/day
- Supports: Ethereum, Polygon, Arbitrum

**Manual Steps Required:**
1. Open https://developer.metamask.io/register in your browser
2. Complete Cloudflare human verification
3. Sign up with admin@customkleins.llc
4. Verify email
5. Create new project: "CryptoSwap"
6. Copy Project ID from project settings

**Where to add:**
```env
NEXT_PUBLIC_INFURA_KEY=your_project_id_here

# RPC URLs will be automatically constructed:
# https://mainnet.infura.io/v3/YOUR_PROJECT_ID
# https://polygon-mainnet.infura.io/v3/YOUR_PROJECT_ID
# https://arbitrum-mainnet.infura.io/v3/YOUR_PROJECT_ID
```

**Alternative:** Use public RPC endpoints (less reliable):
```env
# Free public RPCs (no API key needed, but rate-limited):
# Ethereum: https://eth.llamarpc.com
# Polygon: https://polygon-rpc.com
# Arbitrum: https://arb1.arbitrum.io/rpc
# Avalanche: https://api.avax.network/ext/bc/C/rpc
# BSC: https://bsc-dataseed.binance.org
```

---

## Reown (WalletConnect) Project ⏸️ **BLOCKED BY CLOUDFLARE**

**Website:** https://dashboard.reown.com/ (formerly cloud.walletconnect.com)  
**Status:** Account created, waiting for Cloudflare verification  
**Created Credentials:**
- Email: admin@customkleins.llc
- Password: `CryptoSwap2025!Secure#DEX`

**What you'll get:**
- Project ID
- Free tier: Unlimited for non-commercial
- Required for wallet connections

**Manual Steps Required:**
1. Open https://dashboard.reown.com/sign-up in your browser
2. Complete Cloudflare Turnstile verification (checkbox)
3. Either:
   - a) If account creation completes, log in with credentials above
   - b) If it fails, try signing up again (may need different email)
4. Verify email if required
5. Create new project: "CryptoSwap DEX"
6. Select project type: "App"
7. Add your domain: cryptoswap.com
8. Copy Project ID from project dashboard

**Where to add:**
```env
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_project_id_here
```

**Important:** Keep the password safe! You'll need it to access the Reown dashboard.

---

## Optional Services (Can Add Later)

### CoinGecko API (Price Data)
- **Website:** https://www.coingecko.com/en/api
- **Free Tier:** 50 calls/minute (10,000/month)
- **Sign-up:** Email registration
- **Key Location:** `NEXT_PUBLIC_COINGECKO_API_KEY=xxx`

### Sentry (Error Tracking)
- **Website:** https://sentry.io/signup/
- **Free Tier:** 5K errors/month
- **Sign-up:** Email or GitHub
- **Key Location:** `SENTRY_DSN=https://xxx@sentry.io/xxx`

### Google Analytics
- **Website:** https://analytics.google.com/
- **Free:** Unlimited
- **Sign-up:** Google account
- **Key Location:** `NEXT_PUBLIC_GOOGLE_ANALYTICS=G-XXXXXXXXXX`

---

## Quick Complete Setup

Once you have all API keys, create `.env.local`:

```env
# Essential APIs
NEXT_PUBLIC_1INCH_API_KEY=your_1inch_key
NEXT_PUBLIC_INFURA_KEY=your_infura_project_id
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_walletconnect_project_id

# Your revenue wallet (replace with your actual address)
NEXT_PUBLIC_REVENUE_WALLET_EVM=0xYourWalletAddress

# Platform fee (0.05% default)
NEXT_PUBLIC_PLATFORM_FEE_BPS=5

# Optional - Add later
# NEXT_PUBLIC_COINGECKO_API_KEY=your_coingecko_key
# SENTRY_DSN=your_sentry_dsn
# NEXT_PUBLIC_GOOGLE_ANALYTICS=G-XXXXXXXXXX
```

---

## Testing Your Setup

After adding the API keys:

```bash
cd cryptoswap-dex

# Test that environment variables are loaded
pnpm dev

# Open http://localhost:3000
# Open browser console and check for any API errors
```

### Verification Checklist:
- [ ] 1inch API key retrieved from email magic link
- [ ] Infura project created and ID copied
- [ ] WalletConnect project created and ID copied
- [ ] `.env.local` file created with all keys
- [ ] Development server starts without API errors
- [ ] Can connect wallet (MetaMask)
- [ ] Can view token prices
- [ ] Can get swap quote

---

## Troubleshooting

### "1inch API error: Unauthorized"
- Check API key is correctly copied (no extra spaces)
- Verify key is active in 1inch portal
- Check you're using the correct endpoint (business.1inch.com)

### "Infura rate limit exceeded"
- Free tier limit reached (100K requests/day)
- Consider caching responses
- Upgrade to paid tier if needed ($50/month for 300K/day)

### "WalletConnect connection failed"
- Verify Project ID is correct
- Check domain is allowed in WalletConnect dashboard
- Clear browser cache and try again

---

## Cost Summary

**Current Setup (Free Tier):**
- 1inch: $0/month (1 req/sec)
- Infura: $0/month (100K req/day)
- WalletConnect: $0/month (unlimited)
- **Total: $0/month**

**When You Scale:**
- At ~1,000 daily users: Still free tier sufficient
- At ~10,000 daily users: May need Infura upgrade ($50/month)
- At ~100,000 daily users: Consider dedicated RPC ($200-500/month)

---

## Next Steps

1. ✅ Check email for 1inch magic link
2. ⏳ Complete 1inch sign-up and get API key
3. ⏳ Sign up for Infura and get Project ID
4. ⏳ Sign up for WalletConnect and get Project ID
5. ⏳ Create `.env.local` with all keys
6. ⏳ Test locally with `pnpm dev`
7. ⏳ Verify swap functionality works
8. ⏳ Deploy to production

**Estimated Time:** 15-30 minutes to complete all signups

---

**Last Updated:** 2025-11-11  
**Email Used:** admin@customkleins.llc  
**Status:** Awaiting email verifications

