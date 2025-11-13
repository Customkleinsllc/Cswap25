import { useTranslation } from '@CryptoSwap/localization'
import { Button } from '@CryptoSwap/uikit'
import { ErrorMessage } from './ErrorMessage'

export const ErrorContent = ({ onRetry, message }: { onRetry: () => void; message: string }) => {
  const { t } = useTranslation()
  return (
    <>
      <ErrorMessage message={message} />
      <Button variant="subtle" onClick={onRetry}>
        {t('Retry')}
      </Button>
    </>
  )
}
