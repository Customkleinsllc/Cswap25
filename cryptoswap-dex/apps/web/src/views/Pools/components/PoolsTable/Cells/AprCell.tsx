import { Text, useMatchBreakpoints } from '@CryptoSwap/uikit'
import { BIG_ZERO } from '@CryptoSwap/utils/bigNumber'
import { Pool } from '@CryptoSwap/widgets-internal'

import { useTranslation } from '@CryptoSwap/localization'
import { Token } from '@CryptoSwap/sdk'
import BigNumber from 'bignumber.js'

import Apr from '../../Apr'

interface AprCellProps {
  pool: Pool.DeserializedPool<Token>
}

const AprCell: React.FC<React.PropsWithChildren<AprCellProps>> = ({ pool }) => {
  const { t } = useTranslation()
  const { isMobile } = useMatchBreakpoints()
  const { userData } = pool
  const stakedBalance = userData?.stakedBalance ? new BigNumber(userData.stakedBalance) : BIG_ZERO

  return (
    <Pool.BaseCell role="cell" flex={['1 0 50px', '1 0 50px', '2 0 150px', '2 0 150px', '1 0 190px']}>
      <Pool.CellContent>
        <Text fontSize="12px" color="textSubtle" textAlign="left">
          {t('APR')}
        </Text>
        <Apr pool={pool} stakedBalance={stakedBalance} showIcon={!isMobile} />
      </Pool.CellContent>
    </Pool.BaseCell>
  )
}

export default AprCell
