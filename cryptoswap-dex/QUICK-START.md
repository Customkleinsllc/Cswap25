# CryptoSwap DEX - Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Step 1: Install Dependencies (if not already running)

```bash
cd cryptoswap-dex
pnpm install
```

⏱️ This takes 5-10 minutes on first run.

---

### Step 2: Set Your Revenue Wallet

Open `.env.local` and replace the placeholder wallet:

```env
# Replace this!
NEXT_PUBLIC_REVENUE_WALLET_EVM=0x0000000000000000000000000000000000000000

# With your actual wallet address:
NEXT_PUBLIC_REVENUE_WALLET_EVM=0xYourActualWalletAddressHere
```

**Don't have a wallet?**
1. Install [MetaMask](https://metamask.io/)
2. Create a new wallet
3. Copy your wallet address (starts with `0x`)
4. Paste it into `.env.local`

---

### Step 3: Start Development Server

```bash
pnpm dev
```

The site will be available at: **http://localhost:3000**

---

### Step 4: Test the DEX

1. **Connect your wallet** (MetaMask)
2. **Switch to a supported chain** (Ethereum, BSC, Polygon, Arbitrum, Avalanche, or SEI)
3. **Try swapping tokens**
4. **Check that your fee is applied** (0.05% by default)

---

## ✅ What's Already Working

- ✅ Multi-chain support (6 chains)
- ✅ Swap interface
- ✅ Token lists configured
- ✅ Revenue wallet integration
- ✅ Public RPC endpoints (free)
- ✅ All PancakeSwap branding replaced with CryptoSwap

---

## ⏳ What Needs API Keys (Optional for Now)

You can add these later for better functionality:

### 1. 1inch API (for better swap rates)
- Get from: https://business.1inch.com/portal/
- Add to `.env.local`: `NEXT_PUBLIC_1INCH_API_KEY=your_key`

### 2. WalletConnect (for more wallet options)
- Get from: https://dashboard.reown.com/
- Add to `.env.local`: `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your_id`

### 3. Infura/Alchemy (for production reliability)
- Get from: https://developer.metamask.io/ or https://www.alchemy.com/
- Replace public RPCs with your endpoints

**Full guide:** See `API-KEYS-SETUP.md`

---

## 🔧 Common Issues

### "Revenue wallet not configured"
→ Update `NEXT_PUBLIC_REVENUE_WALLET_EVM` in `.env.local` with your real wallet address

### "Cannot connect wallet"
→ Make sure MetaMask is installed and you're on a supported chain

### "RPC error" or "Network timeout"
→ Public RPCs can be slow. Consider getting Infura/Alchemy keys for better reliability

### Port 3000 already in use
→ Kill the other process or change port: `pnpm dev --port 3001`

---

## 📊 Testing Fee Collection

1. **Get some testnet tokens**:
   - Ethereum Goerli: https://goerlifaucet.com/
   - Polygon Mumbai: https://faucet.polygon.technology/
   - BSC Testnet: https://testnet.binance.org/faucet-smart

2. **Switch .env.local to testnet mode**:
   ```env
   NEXT_PUBLIC_TESTNET_MODE=true
   ```

3. **Do a test swap** and verify fee shows correctly

4. **Check your revenue wallet** to confirm fees are collected

---

## 🚢 Ready for Production?

### Before deploying:

1. ✅ Get API keys (1inch, WalletConnect, Infura/Alchemy)
2. ✅ Test on all supported chains
3. ✅ Build production bundle: `pnpm build`
4. ✅ Set `NEXT_PUBLIC_TESTNET_MODE=false`
5. ✅ Update `NEXT_PUBLIC_SITE_URL=https://cryptoswap.com`
6. ✅ Deploy to Vercel/Netlify
7. ✅ Configure custom domain
8. ✅ Add monitoring (Sentry, analytics)
9. ✅ Create Terms of Service and Privacy Policy

**Full production checklist:** See `DEPLOYMENT-CHECKLIST.md` (coming soon)

---

## 📚 Documentation

- **API Setup**: `API-KEYS-SETUP.md`
- **Credentials**: `CREDENTIALS.txt` (keep secure!)
- **Implementation Guide**: `REAL-DEX-IMPLEMENTATION-GUIDE.md`
- **Session Summary**: `SESSION-SUMMARY.md`

---

## 🆘 Need Help?

1. Check documentation files above
2. Review console errors in browser (F12)
3. Check terminal output for build errors
4. Verify `.env.local` has correct values
5. Try `pnpm clean` and reinstall if issues persist

---

## 🎯 Next Steps

1. **Short term** (today):
   - Get your revenue wallet set up
   - Test swaps on testnet
   - Get API keys from services

2. **Medium term** (this week):
   - Deploy to staging environment
   - Test on all chains
   - Add monitoring

3. **Long term** (this month):
   - Get legal docs (Terms/Privacy)
   - Production deployment
   - Marketing & launch

---

**Last Updated:** 2025-11-11  
**Status:** Ready for local development testing

Need to update revenue wallet? → `.env.local`  
Need API keys? → `API-KEYS-SETUP.md`  
Having issues? → Check browser console and terminal
