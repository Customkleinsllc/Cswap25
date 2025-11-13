/**
 * Revenue Configuration for CryptoSwap DEX
 * Handles platform fees and revenue wallet addresses
 */

/**
 * Platform fee in basis points (1 bp = 0.01%)
 * Examples:
 * - 5 = 0.05%
 * - 10 = 0.10%
 * - 30 = 0.30%
 */
export const PLATFORM_FEE_BPS = parseInt(process.env.NEXT_PUBLIC_PLATFORM_FEE_BPS || '5', 10)

/**
 * Revenue wallet address - receives all platform fees
 * This should be set in .env.local
 */
export const REVENUE_WALLET_EVM = process.env.NEXT_PUBLIC_REVENUE_WALLET_EVM || ''

/**
 * Validate revenue configuration
 */
export function validateRevenueConfig(): { valid: boolean; errors: string[] } {
  const errors: string[] = []

  if (!REVENUE_WALLET_EVM) {
    errors.push('REVENUE_WALLET_EVM is not set. Please set NEXT_PUBLIC_REVENUE_WALLET_EVM in .env.local')
  } else if (!REVENUE_WALLET_EVM.match(/^0x[a-fA-F0-9]{40}$/)) {
    errors.push('REVENUE_WALLET_EVM is not a valid Ethereum address')
  }

  if (PLATFORM_FEE_BPS < 0 || PLATFORM_FEE_BPS > 500) {
    errors.push('PLATFORM_FEE_BPS must be between 0 and 500 (0% to 5%)')
  }

  return {
    valid: errors.length === 0,
    errors,
  }
}

/**
 * Calculate platform fee amount from a trade amount
 * @param amount - Trade amount in token units
 * @returns Platform fee amount
 */
export function calculatePlatformFee(amount: bigint): bigint {
  return (amount * BigInt(PLATFORM_FEE_BPS)) / BigInt(10000)
}

/**
 * Calculate amount after deducting platform fee
 * @param amount - Original amount
 * @returns Amount after fee deduction
 */
export function calculateAmountAfterFee(amount: bigint): bigint {
  const fee = calculatePlatformFee(amount)
  return amount - fee
}

/**
 * Convert basis points to percentage string
 * @param bps - Basis points
 * @returns Formatted percentage (e.g., "0.05%")
 */
export function bpsToPercentage(bps: number): string {
  return `${(bps / 100).toFixed(2)}%`
}

/**
 * Get formatted platform fee for display
 */
export function getFormattedPlatformFee(): string {
  return bpsToPercentage(PLATFORM_FEE_BPS)
}

/**
 * Check if revenue wallet is configured
 */
export function isRevenueWalletConfigured(): boolean {
  return !!REVENUE_WALLET_EVM && REVENUE_WALLET_EVM.match(/^0x[a-fA-F0-9]{40}$/) !== null
}

/**
 * Fee tiers for different user types (future expansion)
 */
export interface FeeTier {
  name: string
  feeBps: number
  minVolume?: bigint // Minimum 30-day volume to qualify
  description: string
}

export const FEE_TIERS: FeeTier[] = [
  {
    name: 'Standard',
    feeBps: PLATFORM_FEE_BPS,
    description: 'Default fee for all users',
  },
  {
    name: 'VIP',
    feeBps: Math.max(1, Math.floor(PLATFORM_FEE_BPS * 0.5)), // 50% discount
    minVolume: BigInt('1000000000000000000000'), // $1000 in 18 decimals
    description: 'For users with $1,000+ monthly volume',
  },
  {
    name: 'Whale',
    feeBps: Math.max(1, Math.floor(PLATFORM_FEE_BPS * 0.3)), // 70% discount
    minVolume: BigInt('10000000000000000000000'), // $10,000 in 18 decimals
    description: 'For users with $10,000+ monthly volume',
  },
]

/**
 * Get fee tier for a user based on their volume
 * @param volume30d - User's 30-day trading volume
 * @returns Applicable fee tier
 */
export function getFeeTier(volume30d: bigint): FeeTier {
  // Start from highest tier and work down
  for (let i = FEE_TIERS.length - 1; i >= 0; i--) {
    const tier = FEE_TIERS[i]
    if (!tier.minVolume || volume30d >= tier.minVolume) {
      return tier
    }
  }
  return FEE_TIERS[0] // Default to standard tier
}

/**
 * Revenue analytics tracking (placeholder for future implementation)
 */
export interface RevenueMetrics {
  totalFeesCollected: bigint
  feesByChain: Record<number, bigint>
  feesByToken: Record<string, bigint>
  timestamp: number
}

/**
 * Log a fee collection event (for analytics)
 */
export function logFeeCollection(chainId: number, tokenAddress: string, amount: bigint): void {
  // In production, this would send to analytics service
  if (process.env.NODE_ENV === 'development') {
    console.log('[Fee Collection]', {
      chainId,
      token: tokenAddress,
      amount: amount.toString(),
      fee: getFormattedPlatformFee(),
      timestamp: new Date().toISOString(),
    })
  }
}

/**
 * Emergency: Disable fee collection (owner only in production)
 */
let feeCollectionEnabled = true

export function setFeeCollectionEnabled(enabled: boolean): void {
  feeCollectionEnabled = enabled
  console.warn(`Fee collection ${enabled ? 'ENABLED' : 'DISABLED'}`)
}

export function isFeeCollectionEnabled(): boolean {
  return feeCollectionEnabled
}

