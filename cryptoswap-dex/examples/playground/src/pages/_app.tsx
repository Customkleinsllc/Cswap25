import '@/styles/globals.css'
import '@CryptoSwap/uikit/styles'
import type { AppProps } from 'next/app'

export default function App({ Component, pageProps }: AppProps) {
  return <Component {...pageProps} />
}
