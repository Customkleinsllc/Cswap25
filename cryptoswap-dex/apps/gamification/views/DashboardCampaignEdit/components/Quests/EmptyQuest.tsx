import { useTranslation } from '@CryptoSwap/localization'
import { Flex } from '@CryptoSwap/uikit'
import { styled } from 'styled-components'

const EmptyQuestContainer = styled(Flex)`
  height: 120px;
  align-items: center;
  justify-content: center;
  border-radius: 16px;
  color: ${({ theme }) => (theme.isDark ? `${theme.colors.input}` : `${theme.colors.inputSecondary}`)};
  border: 2px dashed ${({ theme }) => (theme.isDark ? `${theme.colors.input}` : `${theme.colors.inputSecondary}`)};
`

export const EmptyQuest = () => {
  const { t } = useTranslation()

  return <EmptyQuestContainer>{t('No quests assigned yet')}</EmptyQuestContainer>
}
