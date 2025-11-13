import { Token } from '@CryptoSwap/sdk'
import { Pool } from '@CryptoSwap/widgets-internal'
import StakeModal from '../../Modals/StakeModal'

export default Pool.withStakeActions<Token>(StakeModal)
