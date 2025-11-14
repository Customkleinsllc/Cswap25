import { ChainId } from '@CryptoSwap/chains'
// import { IfoChainId } from '@CryptoSwap/widgets-internal/ifo/constants'
import { atom, useAtom } from 'jotai'

// IFO feature disabled - using placeholder type
type IfoChainId = ChainId.BSC | ChainId.ARBITRUM_ONE | ChainId.ETHEREUM | ChainId.ZKSYNC

const txnByChainAtom = atom<Record<Exclude<IfoChainId, ChainId.BSC>, string>>({
  [ChainId.ARBITRUM_ONE]: '',
  [ChainId.ETHEREUM]: '',
  [ChainId.ZKSYNC]: '',
})

export const useTxnByChain = () => {
  return useAtom(txnByChainAtom)
}
