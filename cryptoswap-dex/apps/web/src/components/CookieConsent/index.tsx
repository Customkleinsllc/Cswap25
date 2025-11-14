import { useState, useEffect } from 'react'
import styled from 'styled-components'
import { Button, Text, Flex, Link } from '@CryptoSwap/uikit'

const CookieConsentContainer = styled.div<{ $show: boolean }>`
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: ${({ theme }) => theme.colors.backgroundAlt};
  border-top: 1px solid ${({ theme }) => theme.colors.cardBorder};
  padding: 20px;
  z-index: 1000;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.1);
  transform: translateY(${({ $show }) => ($show ? '0' : '100%')});
  transition: transform 0.3s ease-in-out;

  ${({ theme }) => theme.mediaQueries.md} {
    padding: 24px 32px;
  }
`

const ContentWrapper = styled(Flex)`
  max-width: 1200px;
  margin: 0 auto;
  flex-direction: column;
  gap: 16px;

  ${({ theme }) => theme.mediaQueries.md} {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
`

const TextContent = styled.div`
  flex: 1;
`

const ButtonGroup = styled(Flex)`
  gap: 12px;
  flex-direction: column;

  ${({ theme }) => theme.mediaQueries.sm} {
    flex-direction: row;
  }
`

const COOKIE_CONSENT_KEY = 'cryptoswap_cookie_consent'
const COOKIE_PREFERENCES_KEY = 'cryptoswap_cookie_preferences'

export interface CookiePreferences {
  necessary: boolean // Always true
  analytics: boolean
  functional: boolean
}

const defaultPreferences: CookiePreferences = {
  necessary: true,
  analytics: false,
  functional: false,
}

export const CookieConsent = () => {
  const [show, setShow] = useState(false)
  const [showPreferences, setShowPreferences] = useState(false)

  useEffect(() => {
    // Check if user has already accepted/declined cookies
    const consent = localStorage.getItem(COOKIE_CONSENT_KEY)
    if (!consent) {
      // Show banner after a short delay for better UX
      const timer = setTimeout(() => setShow(true), 1000)
      return () => clearTimeout(timer)
    }
  }, [])

  const handleAcceptAll = () => {
    const preferences: CookiePreferences = {
      necessary: true,
      analytics: true,
      functional: true,
    }
    saveCookiePreferences(preferences)
    setShow(false)
  }

  const handleDeclineAll = () => {
    saveCookiePreferences(defaultPreferences)
    setShow(false)
  }

  const handleCustomize = () => {
    setShowPreferences(true)
  }

  const saveCookiePreferences = (preferences: CookiePreferences) => {
    localStorage.setItem(COOKIE_CONSENT_KEY, 'true')
    localStorage.setItem(COOKIE_PREFERENCES_KEY, JSON.stringify(preferences))

    // Trigger event for analytics initialization
    window.dispatchEvent(
      new CustomEvent('cookiePreferencesUpdated', {
        detail: preferences,
      }),
    )
  }

  if (!show) return null

  if (showPreferences) {
    return <CookiePreferencesModal onClose={() => setShowPreferences(false)} onSave={(prefs) => {
      saveCookiePreferences(prefs)
      setShow(false)
      setShowPreferences(false)
    }} />
  }

  return (
    <CookieConsentContainer $show={show}>
      <ContentWrapper>
        <TextContent>
          <Text bold mb="8px">
            🍪 We use cookies
          </Text>
          <Text fontSize="14px" color="textSubtle">
            We use essential cookies to make our site work. With your consent, we may also use non-essential cookies to
            improve user experience and analyze website traffic. By clicking "Accept All", you agree to our website's
            cookie use as described in our{' '}
            <Link href="/legal/privacy-policy" external>
              Privacy Policy
            </Link>
            .
          </Text>
        </TextContent>
        <ButtonGroup>
          <Button variant="text" onClick={handleDeclineAll} scale="sm">
            Decline
          </Button>
          <Button variant="secondary" onClick={handleCustomize} scale="sm">
            Customize
          </Button>
          <Button onClick={handleAcceptAll} scale="sm">
            Accept All
          </Button>
        </ButtonGroup>
      </ContentWrapper>
    </CookieConsentContainer>
  )
}

const ModalOverlay = styled.div`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1001;
  padding: 16px;
`

const ModalContent = styled.div`
  background: ${({ theme }) => theme.colors.background};
  border-radius: 24px;
  padding: 32px;
  max-width: 600px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
`

const CookieOption = styled.div`
  padding: 16px;
  border: 1px solid ${({ theme }) => theme.colors.cardBorder};
  border-radius: 12px;
  margin-bottom: 12px;
`

interface CookiePreferencesModalProps {
  onClose: () => void
  onSave: (preferences: CookiePreferences) => void
}

const CookiePreferencesModal: React.FC<CookiePreferencesModalProps> = ({ onClose, onSave }) => {
  const [preferences, setPreferences] = useState<CookiePreferences>(() => {
    const saved = localStorage.getItem(COOKIE_PREFERENCES_KEY)
    return saved ? JSON.parse(saved) : defaultPreferences
  })

  const togglePreference = (key: keyof CookiePreferences) => {
    if (key === 'necessary') return // Cannot disable necessary cookies
    setPreferences((prev) => ({ ...prev, [key]: !prev[key] }))
  }

  const handleSave = () => {
    onSave(preferences)
  }

  return (
    <ModalOverlay onClick={onClose}>
      <ModalContent onClick={(e) => e.stopPropagation()}>
        <Text fontSize="24px" bold mb="24px">
          Cookie Preferences
        </Text>

        <CookieOption>
          <Flex justifyContent="space-between" alignItems="flex-start" mb="8px">
            <Text bold>Essential Cookies</Text>
            <Text fontSize="12px" color="success">
              Always Active
            </Text>
          </Flex>
          <Text fontSize="14px" color="textSubtle">
            These cookies are necessary for the website to function and cannot be disabled. They include session
            management, wallet connection state, and user preferences.
          </Text>
        </CookieOption>

        <CookieOption>
          <Flex justifyContent="space-between" alignItems="center" mb="8px">
            <Text bold>Analytics Cookies</Text>
            <Button
              variant={preferences.analytics ? 'success' : 'secondary'}
              scale="xs"
              onClick={() => togglePreference('analytics')}
            >
              {preferences.analytics ? 'Enabled' : 'Disabled'}
            </Button>
          </Flex>
          <Text fontSize="14px" color="textSubtle">
            These cookies help us understand how visitors interact with our website by collecting and reporting
            information anonymously. This includes Google Analytics and similar services.
          </Text>
        </CookieOption>

        <CookieOption>
          <Flex justifyContent="space-between" alignItems="center" mb="8px">
            <Text bold>Functional Cookies</Text>
            <Button
              variant={preferences.functional ? 'success' : 'secondary'}
              scale="xs"
              onClick={() => togglePreference('functional')}
            >
              {preferences.functional ? 'Enabled' : 'Disabled'}
            </Button>
          </Flex>
          <Text fontSize="14px" color="textSubtle">
            These cookies enable enhanced functionality and personalization, such as theme preferences (light/dark mode),
            language settings, and recently viewed tokens.
          </Text>
        </CookieOption>

        <Text fontSize="14px" color="textSubtle" mb="24px" mt="16px">
          For more information about how we use cookies, please see our{' '}
          <Link href="/legal/privacy-policy" external>
            Privacy Policy
          </Link>
          .
        </Text>

        <Flex justifyContent="flex-end" style={{ gap: '12px' }}>
          <Button variant="secondary" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={handleSave}>Save Preferences</Button>
        </Flex>
      </ModalContent>
    </ModalOverlay>
  )
}

/**
 * Hook to check if user has consented to specific cookie types
 */
export const useCookieConsent = () => {
  const [preferences, setPreferences] = useState<CookiePreferences>(defaultPreferences)

  useEffect(() => {
    const loadPreferences = () => {
      const saved = localStorage.getItem(COOKIE_PREFERENCES_KEY)
      if (saved) {
        try {
          setPreferences(JSON.parse(saved))
        } catch (error) {
          console.error('Failed to parse cookie preferences:', error)
        }
      }
    }

    loadPreferences()

    // Listen for preference updates
    const handleUpdate = (event: CustomEvent<CookiePreferences>) => {
      setPreferences(event.detail)
    }

    window.addEventListener('cookiePreferencesUpdated', handleUpdate as EventListener)
    return () => {
      window.removeEventListener('cookiePreferencesUpdated', handleUpdate as EventListener)
    }
  }, [])

  const hasConsent = (type: keyof CookiePreferences): boolean => {
    return preferences[type]
  }

  return { preferences, hasConsent }
}

export default CookieConsent

