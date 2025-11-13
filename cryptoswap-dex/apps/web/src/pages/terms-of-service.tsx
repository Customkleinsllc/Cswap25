import { useRouter } from 'next/router'
import { useEffect } from 'react'

// Redirect to our custom terms of service
const TermsOfService = () => {
  const router = useRouter()
  
  useEffect(() => {
    router.push('/legal/terms-of-service.md')
  }, [router])
  
  return null
}

TermsOfService.chains = []

export default TermsOfService

