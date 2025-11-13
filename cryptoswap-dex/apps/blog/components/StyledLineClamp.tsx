import { styled } from 'styled-components'
import { Text } from '@CryptoSwap/uikit'

export const StyledLineClamp = styled(Text)<{ line?: number }>`
  display: -webkit-box;
  white-space: initial;
  -webkit-line-clamp: ${({ line }) => line ?? 1};
  -webkit-box-orient: vertical;
`
