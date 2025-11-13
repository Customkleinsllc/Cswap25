import { ASSET_CDN } from 'config/constants/endpoints'
import { DefaultSeoProps } from 'next-seo'

export const SEO: DefaultSeoProps = {
  titleTemplate: '%s | CryptoSwap',
  defaultTitle: 'CryptoSwap',
  description: 'Best prices across all DEXes - Complete DeFi aggregator for swaps, yield farming, and staking',
  twitter: {
    cardType: 'summary_large_image',
    handle: '@CryptoSwap',
    site: '@CryptoSwap',
  },
  openGraph: {
    title: "CryptoSwap - Your Complete DeFi Aggregator",
    description: 'Best prices across all DEXes - Complete DeFi aggregator for swaps, yield farming, and staking',
    images: [{ url: `${ASSET_CDN}/web/og/v2/hero.jpg` }],
  },
}
