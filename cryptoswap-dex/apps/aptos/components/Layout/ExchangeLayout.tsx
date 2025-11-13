import { useTranslation } from '@CryptoSwap/localization'
import { Image } from '@CryptoSwap/uikit'
import { Swap } from '@CryptoSwap/widgets-internal'

export const ExchangeLayout = ({ children }: React.PropsWithChildren) => {
  const { t } = useTranslation()
  return (
    <Swap.Page
      helpUrl="https://docs.CryptoSwap.finance/get-started-aptos"
      externalText={t('Bridge assets to Aptos Chain')}
      externalLinkUrl="https://bridge.CryptoSwap.finance/aptos"
      helpImage={<Image src="/help.png" width={178} height={243} alt="Aptos help" />}
    >
      {children}
    </Swap.Page>
  )
}


