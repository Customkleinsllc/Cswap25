import { ChainId } from '@CryptoSwap/chains'

import { arbitrumTokens } from './constants/arb'
import { arbitrumGoerliTokens } from './constants/arbGoerli'
import { arbSepoliaTokens } from './constants/arbSepolia'
import { avalancheTokens } from './constants/avalanche'
import { avalancheFujiTokens } from './constants/avalancheFuji'
import { baseTokens } from './constants/base'
import { baseSepoliaTokens } from './constants/baseSepolia'
import { baseTestnetTokens } from './constants/baseTestnet'
import { bscTokens } from './constants/bsc'
import { bscTestnetTokens } from './constants/bscTestnet'
import { ethereumTokens } from './constants/eth'
import { goerliTestnetTokens } from './constants/goerli'
import { lineaTokens } from './constants/linea'
import { lineaTestnetTokens } from './constants/lineaTestnet'
import { monadTestnetTokens } from './constants/monadTestnet'
import { opBnbTokens } from './constants/opBNB'
import { opBnbTestnetTokens } from './constants/opBnbTestnet'
import { polygonTokens } from './constants/polygon'
import { polygonZkEvmTokens } from './constants/polygonZkEVM'
import { polygonZkEvmTestnetTokens } from './constants/polygonZkEVMTestnet'
import { scrollSepoliaTokens } from './constants/scrollSepolia'
import { seiTokens } from './constants/sei'
import { sepoliaTokens } from './constants/sepolia'
import { zksyncTokens } from './constants/zkSync'
import { zkSyncTestnetTokens } from './constants/zkSyncTestnet'

export const allTokens = {
  [ChainId.GOERLI]: goerliTestnetTokens,
  [ChainId.BSC]: bscTokens,
  [ChainId.BSC_TESTNET]: bscTestnetTokens,
  [ChainId.ETHEREUM]: ethereumTokens,
  [ChainId.ARBITRUM_ONE]: arbitrumTokens,
  [ChainId.POLYGON_ZKEVM]: polygonZkEvmTokens,
  [ChainId.POLYGON_ZKEVM_TESTNET]: polygonZkEvmTestnetTokens,
  [ChainId.ZKSYNC]: zksyncTokens,
  [ChainId.ZKSYNC_TESTNET]: zkSyncTestnetTokens,
  [ChainId.LINEA_TESTNET]: lineaTestnetTokens,
  [ChainId.LINEA]: lineaTokens,
  [ChainId.ARBITRUM_GOERLI]: arbitrumGoerliTokens,
  [ChainId.OPBNB]: opBnbTokens,
  [ChainId.OPBNB_TESTNET]: opBnbTestnetTokens,
  [ChainId.BASE]: baseTokens,
  [ChainId.BASE_TESTNET]: baseTestnetTokens,
  [ChainId.SCROLL_SEPOLIA]: scrollSepoliaTokens,
  [ChainId.SEPOLIA]: sepoliaTokens,
  [ChainId.ARBITRUM_SEPOLIA]: arbSepoliaTokens,
  [ChainId.BASE_SEPOLIA]: baseSepoliaTokens,
  [ChainId.MONAD_TESTNET]: monadTestnetTokens,
  [ChainId.POLYGON]: polygonTokens,
  [ChainId.AVALANCHE]: avalancheTokens,
  [ChainId.AVALANCHE_FUJI]: avalancheFujiTokens,
  [ChainId.SEI]: seiTokens,
}
