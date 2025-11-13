import { ContextApi } from '@CryptoSwap/localization'
import { FooterLinkType } from '@CryptoSwap/uikit'

export const footerLinks: (t: ContextApi['t']) => FooterLinkType[] = (t) => [
  {
    label: t('Ecosystem'),
    items: [
      {
        label: t('Trade'),
        href: '/swap',
      },
      {
        label: t('Earn.verb'),
        href: '/farms',
      },
      {
        label: t('Game'),
        href: 'https://CryptoSwap.games/',
      },
      {
        label: t('Play'),
        href: 'https://CryptoSwap.finance/prediction',
      },
      {
        label: t('Merchandise'),
        href: 'https://merch.CryptoSwap.finance/',
      },
    ],
  },
  {
    label: 'Business',
    items: [
      {
        label: t('CAKE Incentives'),
        href: 'https://docs.CryptoSwap.finance/ecosystem-and-partnerships/business-partnerships/syrup-pools-and-farms',
      },
      {
        label: t('Staking Pools'),
        href: 'https://CryptoSwap.finance/pools',
      },
      {
        label: t('Token Launches'),
        href: 'https://docs.CryptoSwap.finance/ecosystem-and-partnerships/business-partnerships/initial-farm-offerings-ifos',
      },
      {
        label: t('Brand Assets'),
        href: 'https://docs.CryptoSwap.finance/ecosystem-and-partnerships/brand',
      },
    ],
  },
  {
    label: t('Developers'),
    items: [
      {
        label: t('Contributing'),
        href: 'https://docs.CryptoSwap.finance/developers/contributing',
      },
      {
        label: t('Github'),
        href: 'https://github.com/CryptoSwap',
      },
      {
        label: t('Bug Bounty'),
        href: 'https://docs.CryptoSwap.finance/developers/bug-bounty',
      },
    ],
  },
  {
    label: t('Support'),
    items: [
      {
        label: t('Get Help'),
        href: 'https://docs.CryptoSwap.finance/contact-us/customer-support',
      },
      {
        label: t('Troubleshooting'),
        href: 'https://docs.CryptoSwap.finance/readme/help/troubleshooting',
      },
      {
        label: t('Documentation'),
        href: 'https://docs.CryptoSwap.finance/',
      },
      {
        label: t('Audits'),
        href: 'https://docs.CryptoSwap.finance/readme/audits',
      },
      {
        label: t('Legacy products'),
        href: 'https://docs.CryptoSwap.finance/products/legacy-products',
      },
    ],
  },
  {
    label: t('About'),
    items: [
      {
        label: t('Tokenomics'),
        href: 'https://docs.CryptoSwap.finance/governance-and-tokenomics/cake-tokenomics',
      },
      {
        label: t('CAKE Burn Dashboard'),
        href: 'https://CryptoSwap.finance/burn-dashboard',
      },
      {
        label: t('Blog'),
        href: 'https://blog.CryptoSwap.finance/',
      },
      {
        label: t('Careers'),
        href: 'https://docs.CryptoSwap.finance/team/become-a-chef',
      },
      {
        label: t('Terms Of Service'),
        href: 'https://CryptoSwap.finance/terms-of-service',
      },
    ],
  },
]


