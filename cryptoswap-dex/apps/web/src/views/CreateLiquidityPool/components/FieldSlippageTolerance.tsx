import { useTranslation } from '@CryptoSwap/localization'
import { Box, BoxProps, FlexGap, Text } from '@CryptoSwap/uikit'
import { LiquiditySlippageButton } from 'views/Swap/components/SlippageButton'

export type FieldSlippageToleranceProps = BoxProps

export const FieldSlippageTolerance: React.FC<FieldSlippageToleranceProps> = ({ ...boxProps }) => {
  const { t } = useTranslation()

  return (
    <Box {...boxProps}>
      <FlexGap justifyContent="space-between" alignItems="center" gap="8px">
        <Text>{t('Slippage Tolerance')}</Text>
        <LiquiditySlippageButton />
      </FlexGap>
    </Box>
  )
}
