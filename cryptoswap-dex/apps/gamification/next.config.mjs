import { withWebSecurityHeaders } from '@CryptoSwap/next-config/withWebSecurityHeaders';
import smartRouterPkgs from '@CryptoSwap/smart-router/package.json' with { type: 'json' };
import { createVanillaExtractPlugin } from '@vanilla-extract/next-plugin';
import path from 'path';
import { fileURLToPath } from 'url';
import { RetryChunkLoadPlugin } from 'webpack-retry-chunk-load-plugin'

const withVanillaExtract = createVanillaExtractPlugin()

const __dirname = path.dirname(fileURLToPath(import.meta.url))

const workerDeps = Object.keys(smartRouterPkgs.dependencies)
  .map((d) => d.replace('@CryptoSwap/', 'packages/'))
  .concat(['/packages/smart-router/', '/packages/swap-sdk/'])

/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    tsconfigPath: 'tsconfig.json',
  },
  experimental: {
    scrollRestoration: true,
    fallbackNodePolyfills: false,
    optimizePackageImports: ['@CryptoSwap/widgets-internal', '@CryptoSwap/uikit'],
  },
  outputFileTracingRoot: path.join(__dirname, '../../'),
  outputFileTracingExcludes: {
    '*': [],
  },
  reactStrictMode: true,
  transpilePackages: [
    '@CryptoSwap/uikit',
    '@CryptoSwap/hooks',
    '@CryptoSwap/localization',
    '@CryptoSwap/utils',
    '@CryptoSwap/prediction',
    '@CryptoSwap/widgets-internal',
    '@CryptoSwap/sdk',
    '@CryptoSwap/ui-wallets',
    '@CryptoSwap/tokens',
    '@CryptoSwap/wagmi',
    '@CryptoSwap/ifos',
    '@CryptoSwap/v3-sdk',
    // https://github.com/TanStack/query/issues/6560#issuecomment-1975771676
    '@tanstack/query-core',
  ],
  images: {
    contentDispositionType: 'attachment',
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'assets.cryptoswap.com',
        pathname: '/web/**',
      },
    ],
  },
  compiler: {
    styledComponents: true,
  },
  async redirects() {
    return [
      {
        source: '/',
        destination: '/quests',
        permanent: false,
      },
    ]
  },
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'Cross-Origin-Opener-Policy',
            value: 'same-origin-allow-popups',
          },
          {
            key: 'Content-Security-Policy',
            value: `frame-ancestors 'self'`,
          },
        ],
      },
    ]
  },
  webpack: (webpackConfig, { isServer }) => {
    webpackConfig.plugins.push(
        new RetryChunkLoadPlugin({
          cacheBust: `function() {
          return 'cache-bust=' + Date.now();
        }`,
          retryDelay: `function(retryAttempt) {
          return 2 ** (retryAttempt - 1) * 500;
        }`,
          maxRetries: 5,
        }),
    )
    if (!isServer && webpackConfig.optimization.splitChunks) {
      // webpack doesn't understand worker deps on quote worker, so we need to manually add them
      // https://github.com/webpack/webpack/issues/16895
      // eslint-disable-next-line no-param-reassign
      webpackConfig.optimization.splitChunks.cacheGroups.workerChunks = {
        chunks: 'all',
        test(module) {
          const resource = module.nameForCondition?.() ?? ''
          return resource ? workerDeps.some((d) => resource.includes(d)) : false
        },
        priority: 31,
        name: 'worker-chunks',
        reuseExistingChunk: true,
      }
    }
    return webpackConfig
  },
}

export default withVanillaExtract(withWebSecurityHeaders(nextConfig))
