import { useToast } from '@CryptoSwap/uikit'
import { Pool } from '@CryptoSwap/widgets-internal'

import { Coin } from '@CryptoSwap/aptos-swap-sdk'
import { TransactionResponse } from '@CryptoSwap/awgmi/dist/core'
import { useTranslation } from '@CryptoSwap/localization'
import { BIG_ZERO } from '@CryptoSwap/utils/bigNumber'
import { ToastDescriptionWithTx } from 'components/Toast'
import useActiveWeb3React from 'hooks/useActiveWeb3React'
import useCatchTxError from 'hooks/useCatchTxError'
import { useCallback } from 'react'
import { logGTMPoolStakeEvent } from 'utils/customGTMEventTracking'

const StakeModalContainer = ({
  pool,
  isRemovingStake,
  onDismiss,
  stakingTokenBalance,
  stakingTokenPrice,
  onUnstake,
  onStake,
  onDone,
}: Pool.StakeModalPropsType<Coin> & {
  onDone: () => void
  onStake: (_amount: string) => Promise<TransactionResponse>
  onUnstake: (_amount: string) => Promise<TransactionResponse>
}) => {
  const { t } = useTranslation()
  const { account = '' } = useActiveWeb3React()

  const {
    earningToken,
    stakingToken,
    earningTokenPrice = 0,
    apr = 0,
    userData,
    stakingLimit = BIG_ZERO,
    enableEmergencyWithdraw = false,
  } = pool
  const { toastSuccess } = useToast()
  const { fetchWithCatchTxError, loading: pendingTx } = useCatchTxError()

  const handleConfirmClick = useCallback(
    async (stakeAmount: string) => {
      const receipt = await fetchWithCatchTxError(() => {
        if (isRemovingStake) {
          return onUnstake(stakeAmount)
        }
        return onStake(stakeAmount)
      })

      if (receipt?.status) {
        if (isRemovingStake) {
          logGTMPoolStakeEvent('unstake', stakingToken?.symbol, stakeAmount)

          toastSuccess(
            `${t('Unstaked.status')}!`,
            <ToastDescriptionWithTx txHash={receipt.transactionHash}>
              {t('Your %symbol% earnings have also been harvested to your wallet!', {
                symbol: earningToken?.symbol,
              })}
            </ToastDescriptionWithTx>,
          )
        } else {
          logGTMPoolStakeEvent('stake', stakingToken?.symbol, stakeAmount)

          toastSuccess(
            `${t('Staked')}!`,
            <ToastDescriptionWithTx txHash={receipt.transactionHash}>
              {t('Your %symbol% funds have been staked in the pool!', {
                symbol: stakingToken?.symbol,
              })}
            </ToastDescriptionWithTx>,
          )
        }

        onDone?.()
        onDismiss?.()
      }
    },
    [
      fetchWithCatchTxError,
      isRemovingStake,
      onStake,
      onUnstake,
      onDone,
      onDismiss,
      toastSuccess,
      t,
      earningToken?.symbol,
      stakingToken?.symbol,
    ],
  )

  return (
    <Pool.StakeModal
      enableEmergencyWithdraw={enableEmergencyWithdraw}
      stakingLimit={stakingLimit}
      stakingTokenPrice={stakingTokenPrice}
      earningTokenPrice={earningTokenPrice}
      stakingTokenDecimals={stakingToken.decimals}
      earningTokenSymbol={earningToken.symbol}
      stakingTokenSymbol={stakingToken.symbol}
      stakingTokenAddress={stakingToken.address}
      stakingTokenBalance={stakingTokenBalance}
      apr={apr}
      userDataStakedBalance={userData?.stakedBalance ? userData.stakedBalance : BIG_ZERO}
      userDataStakingTokenBalance={userData?.stakingTokenBalance ? userData.stakingTokenBalance : BIG_ZERO}
      onDismiss={onDismiss}
      pendingTx={pendingTx}
      account={account}
      handleConfirmClick={handleConfirmClick}
      isRemovingStake={isRemovingStake}
      imageUrl="https://tokens.CryptoSwap.finance/images/aptos/"
    />
  )
}

export default StakeModalContainer


