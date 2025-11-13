import { CardProps } from '@CryptoSwap/uikit'
import { NftLocation, NftToken } from 'hooks/useProfile/nft/types'

export interface CollectibleCardProps extends CardProps {
  nft: NftToken
  nftLocation?: NftLocation
  currentAskPrice?: number
  isUserNft?: boolean
}
