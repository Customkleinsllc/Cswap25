import { Protocol } from '@CryptoSwap/farms'
import { useTranslation } from '@CryptoSwap/localization'
import { AutoColumn } from '@CryptoSwap/uikit'
import { useChainIdByQuery } from 'state/info/hooks'
import { useRouterQuery } from 'views/PoolDetail/hooks/useRouterQuery'
import { LocalLoader } from 'views/V3Info/components/Loader'
import { usePoolTransactions } from '../../hooks/usePoolTransactions'
import { TransactionsTable } from './TransactionsTable'

type TransactionProps = {
  protocol?: Protocol
}

export const Transactions: React.FC<TransactionProps> = ({ protocol }) => {
  const { t } = useTranslation()
  const { id: address } = useRouterQuery()
  const chainId = useChainIdByQuery()
  const { data: transactions } = usePoolTransactions(address, protocol, chainId)
  return (
    <AutoColumn>
      {transactions ? <TransactionsTable transactions={transactions} /> : <LocalLoader fill={false} />}
    </AutoColumn>
  )
}
