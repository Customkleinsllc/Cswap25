import { useTranslation } from '@CryptoSwap/localization'
import { Flex, Spinner, Text } from '@CryptoSwap/uikit'

export const SpinnerWithLoadingText = () => {
  const { t } = useTranslation()

  return (
    <Flex flexDirection="column" alignItems="center" pb="20px">
      <Spinner size={100} />
      <Text textAlign="center" bold mt="8px">
        {t('Loading')}
      </Text>
    </Flex>
  )
}
