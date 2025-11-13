import { useTranslation } from '@CryptoSwap/localization'
import { Button, ButtonProps } from '@CryptoSwap/uikit'
import { useState } from 'react'
import { SwitchToBnbChainModal } from './SwitchToBnbCahinModal'

export const SyncButton: React.FC<ButtonProps> = (props) => {
  const { t } = useTranslation()
  const [isOpen, setIsOpen] = useState(false)
  return (
    <>
      <Button width="50%" onClick={() => setIsOpen(true)} {...props}>
        {t('Sync')}
      </Button>
      <SwitchToBnbChainModal
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        onDismiss={() => {
          setIsOpen(false)
        }}
      />
    </>
  )
}
