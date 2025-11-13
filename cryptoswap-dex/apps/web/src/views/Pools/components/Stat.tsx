import { Flex, Text } from '@CryptoSwap/uikit'
import { Pool } from '@CryptoSwap/widgets-internal'

import { useTranslation } from '@CryptoSwap/localization'
import { Token } from '@CryptoSwap/sdk'
import BigNumber from 'bignumber.js'
import Apr from './Apr'

export const AprInfo: React.FC<
  React.PropsWithChildren<{ pool: Pool.DeserializedPool<Token>; stakedBalance: BigNumber }>
> = ({ pool, stakedBalance }) => {
  const { t } = useTranslation()
  return (
    <Flex justifyContent="space-between" alignItems="center">
      <Text small>{t('APR')}:</Text>
      <Apr pool={pool} showIcon stakedBalance={stakedBalance} performanceFee={0} fontSize="14px" />
    </Flex>
  )
}
