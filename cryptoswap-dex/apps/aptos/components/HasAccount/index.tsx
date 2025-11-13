import { useAccount } from '@CryptoSwap/awgmi'
import { useIsMounted } from '@CryptoSwap/hooks'

export default function HasAccount({ fallbackComp, children }) {
  const { account } = useAccount()
  const isMounted = useIsMounted()

  return isMounted && account ? <>{children}</> : fallbackComp
}


