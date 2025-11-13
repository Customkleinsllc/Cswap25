import { Token } from '@CryptoSwap/swap-sdk-core'
import { Pool } from '@CryptoSwap/widgets-internal'
import StakeModal from './StakeModal'

export default Pool.withStakeActions<Token>(StakeModal)


