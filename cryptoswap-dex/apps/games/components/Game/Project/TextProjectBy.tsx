import { styled } from 'styled-components'
import { Flex, Text } from '@CryptoSwap/uikit'
import { useTranslation } from '@CryptoSwap/localization'
import { GameType } from '@CryptoSwap/games'

const StyledProjectBy = styled(Flex)`
  display: none;

  ${({ theme }) => theme.mediaQueries.md} {
    display: flex;
    position: absolute;
    top: 0px;
    right: 0;
  }
`

interface TextProjectByProps {
  game: GameType
}

export const TextProjectBy: React.FC<React.PropsWithChildren<TextProjectByProps>> = ({ game }) => {
  const { t } = useTranslation()
  return (
    <StyledProjectBy px="24px">
      <Text fontSize="14px" color="textSubtle">
        {t('Published By')}
      </Text>
      <Text ml="4px" fontSize="14px" color="primary">
        {game.projectName}
      </Text>
    </StyledProjectBy>
  )
}
