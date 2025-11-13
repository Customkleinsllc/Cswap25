import { useMemo } from 'react'
import { GAMES_LIST, GameType } from '@CryptoSwap/games'

export const useGamesConfig = (): GameType[] => useMemo(() => GAMES_LIST, [])
