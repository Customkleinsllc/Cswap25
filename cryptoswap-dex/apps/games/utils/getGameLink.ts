import { GameLinkType } from '@CryptoSwap/games'

export function getGameLink({
  gameId,
  gameLink,
  isMobile,
}: {
  gameId: string
  gameLink: GameLinkType
  isMobile?: boolean
}) {
  if (gameLink.signUpLink && !gameLink.playNowLink) {
    return gameLink.signUpLink
  }

  return isMobile || gameLink.external ? gameLink.playNowLink : `/project/${gameId}`
}
