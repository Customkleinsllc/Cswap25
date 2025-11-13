import { Pool } from '@CryptoSwap/widgets-internal'
import { Coin } from '@CryptoSwap/aptos-swap-sdk'
import CakeCollectModal from './CakeCollectModal'
import CakeStakeModal from './CakeStakeModal'

const HarvestActions = Pool.withCollectModalCardAction(CakeCollectModal)
const StakeActions = Pool.withStakeActions(CakeStakeModal)

export default Pool.withCardActions<Coin>(HarvestActions, StakeActions)


