import { Pool } from '@CryptoSwap/widgets-internal'
import { Coin } from '@CryptoSwap/aptos-swap-sdk'
import StakeActions from './StakeActions'
import HarvestActions from './HarvestActions'

export default Pool.withCardActions<Coin>(HarvestActions, StakeActions)


