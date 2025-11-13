import { useMemo } from 'react'
import { footerLinks } from '@CryptoSwap/uikit'
import Footer from '@CryptoSwap/uikit/components/Footer'
import { languageList, useTranslation } from '@CryptoSwap/localization'
import { useTheme } from 'next-themes'
import { ChainId } from '@CryptoSwap/chains'
import { useCakePrice } from 'hooks/useCakePrice'

const FooterPage = () => {
  const { setTheme, resolvedTheme } = useTheme()
  const { currentLanguage, setLanguage, t } = useTranslation()
  const { data: cakePrice } = useCakePrice()

  const isDark = resolvedTheme === 'dark'

  const toggleTheme = useMemo(() => {
    return () => setTheme(isDark ? 'light' : 'dark')
  }, [setTheme, isDark])

  const getFooterLinks = useMemo(() => {
    return footerLinks(t)
  }, [t])

  return (
    <Footer
      chainId={ChainId.BSC}
      items={getFooterLinks}
      isDark={isDark}
      toggleTheme={toggleTheme}
      langs={languageList}
      setLang={setLanguage}
      currentLang={currentLanguage.code}
      cakePriceUsd={cakePrice ? Number(cakePrice) : undefined}
      buyCakeLabel={t('Buy CAKE')}
      buyCakeLink="https://pancakeswap.finance/swap?outputCurrency=0x0e09fabb73bd3ade0a17ecc321fd13a19e81ce82&chainId=56"
    />
  )
}

export default FooterPage
