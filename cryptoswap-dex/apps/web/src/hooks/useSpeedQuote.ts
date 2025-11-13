import { useSpeedQuote as useSpeedQuoteState } from '@CryptoSwap/utils/user'
import { EXPERIMENTAL_FEATURES } from 'config/experimentalFeatures'
import { useExperimentalFeatureEnabled } from 'hooks/useExperimentalFeatureEnabled'

export const useSpeedQuote = () => {
  const featureEnabled = useExperimentalFeatureEnabled(EXPERIMENTAL_FEATURES.SpeedQuote)
  const [speedQuoteEnabled, setSpeedQuote] = useSpeedQuoteState()
  const enabled = Boolean(speedQuoteEnabled ?? featureEnabled)

  return [enabled, setSpeedQuote] as const
}
