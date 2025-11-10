import React, { useState } from 'react'
import AdminDashboard from './components/AdminDashboard'
import PoolList from './components/PoolList'

const App: React.FC = () => {
  const [chain, setChain] = useState('avalanche')
  const [tokenIn, setTokenIn] = useState('AVAX')
  const [tokenOut, setTokenOut] = useState('SEI')
  const [amountIn, setAmountIn] = useState('1')
  const [result, setResult] = useState<string>('')
  const [isSwapping, setIsSwapping] = useState(false)

  const swap = async () => {
    setResult('')
    setIsSwapping(true)
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 15000)
    try {
      const res = await fetch('/api/swap', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ tokenIn, tokenOut, amountIn, chain }),
        signal: controller.signal
      })
      clearTimeout(timeoutId)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Swap failed')
      setResult(`✅ Success! TX: ${data.txHash}\nAmount Out: ${data.amountOut}`)
    } catch (e: any) {
      setResult(`❌ ${e.name === 'AbortError' ? 'Swap timeout' : e.message}`)
    } finally {
      setIsSwapping(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-dark-900 via-dark-800 to-dark-900">
      {/* Animated Background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-1/2 -left-1/2 w-full h-full bg-gradient-to-br from-primary-500/10 to-transparent rounded-full blur-3xl animate-pulse-slow"></div>
        <div className="absolute -bottom-1/2 -right-1/2 w-full h-full bg-gradient-to-tl from-blue-500/10 to-transparent rounded-full blur-3xl animate-pulse-slow"></div>
      </div>

      {/* Header */}
      <header className="relative z-10 border-b border-dark-700/50 backdrop-blur-xl bg-dark-900/50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-12 h-12 bg-gradient-to-br from-primary-500 to-blue-600 rounded-xl flex items-center justify-center shadow-lg shadow-primary-500/50">
                <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <div>
                <h1 className="text-3xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-primary-400 to-blue-400">
                  CSwap DEX
                </h1>
                <p className="text-sm text-dark-400">Cross-Chain Decentralized Exchange</p>
              </div>
            </div>
            <button className="px-6 py-2.5 bg-gradient-to-r from-primary-600 to-blue-600 text-white rounded-lg font-medium hover:from-primary-500 hover:to-blue-500 transition-all duration-200 shadow-lg shadow-primary-500/30">
              Connect Wallet
            </button>
          </div>
        </div>
      </header>

      <main className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Swap Interface */}
        <div className="max-w-2xl mx-auto mb-12">
          <div className="bg-dark-800/50 backdrop-blur-xl rounded-2xl border border-dark-700/50 p-8 shadow-2xl">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-white">Swap Tokens</h2>
              <select
                value={chain}
                onChange={(e) => setChain(e.target.value)}
                className="px-4 py-2 bg-dark-700/50 border border-dark-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-primary-500 transition-all"
              >
                <option value="avalanche">Avalanche</option>
                <option value="sei">SEI</option>
              </select>
            </div>

            {/* From Token */}
            <div className="space-y-4">
              <div className="p-4 bg-dark-700/30 rounded-xl border border-dark-600/50">
                <label className="text-sm text-dark-300 block mb-2">From</label>
                <div className="flex items-center space-x-4">
                  <input
                    type="text"
                    value={tokenIn}
                    onChange={(e) => setTokenIn(e.target.value)}
                    placeholder="Token"
                    className="flex-1 bg-transparent text-2xl font-bold text-white placeholder-dark-500 focus:outline-none"
                  />
                  <input
                    type="number"
                    value={amountIn}
                    onChange={(e) => setAmountIn(e.target.value)}
                    placeholder="0.0"
                    className="w-32 bg-transparent text-2xl font-bold text-white text-right placeholder-dark-500 focus:outline-none"
                  />
                </div>
              </div>

              {/* Swap Arrow */}
              <div className="flex justify-center">
                <button className="p-3 bg-dark-700 rounded-xl border border-dark-600 hover:bg-dark-600 transition-all transform hover:scale-110 active:scale-95">
                  <svg className="w-6 h-6 text-primary-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" />
                  </svg>
                </button>
              </div>

              {/* To Token */}
              <div className="p-4 bg-dark-700/30 rounded-xl border border-dark-600/50">
                <label className="text-sm text-dark-300 block mb-2">To</label>
                <div className="flex items-center space-x-4">
                  <input
                    type="text"
                    value={tokenOut}
                    onChange={(e) => setTokenOut(e.target.value)}
                    placeholder="Token"
                    className="flex-1 bg-transparent text-2xl font-bold text-white placeholder-dark-500 focus:outline-none"
                  />
                  <div className="w-32 text-2xl font-bold text-dark-400 text-right">~0.0</div>
                </div>
              </div>
            </div>

            {/* Swap Button */}
            <button
              onClick={swap}
              disabled={isSwapping}
              className="w-full mt-6 py-4 bg-gradient-to-r from-primary-600 to-blue-600 text-white rounded-xl font-bold text-lg hover:from-primary-500 hover:to-blue-500 disabled:from-dark-600 disabled:to-dark-600 disabled:cursor-not-allowed transition-all duration-200 shadow-lg shadow-primary-500/30"
            >
              {isSwapping ? (
                <span className="flex items-center justify-center">
                  <svg className="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Swapping...
                </span>
              ) : (
                'Swap'
              )}
            </button>

            {/* Result Message */}
            {result && (
              <div className={`mt-4 p-4 rounded-xl ${result.startsWith('✅') ? 'bg-green-500/10 border border-green-500/50 text-green-400' : 'bg-red-500/10 border border-red-500/50 text-red-400'}`}>
                <pre className="text-sm whitespace-pre-wrap font-mono">{result}</pre>
              </div>
            )}
          </div>
        </div>

        {/* Liquidity Pools */}
        <div className="mb-12">
          <div className="bg-dark-800/50 backdrop-blur-xl rounded-2xl border border-dark-700/50 p-8 shadow-2xl">
            <h2 className="text-2xl font-bold text-white mb-6">Liquidity Pools</h2>
            <PoolList />
          </div>
        </div>

        {/* Admin Dashboard */}
        <div>
          <div className="bg-dark-800/50 backdrop-blur-xl rounded-2xl border border-dark-700/50 p-8 shadow-2xl">
            <h2 className="text-2xl font-bold text-white mb-6">Admin Dashboard</h2>
            <AdminDashboard />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="relative z-10 border-t border-dark-700/50 backdrop-blur-xl bg-dark-900/50 mt-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="text-center text-dark-400 text-sm">
            <p>© 2025 CSwap DEX. Enterprise-Grade Decentralized Exchange.</p>
            <p className="mt-2">Built with React, TypeScript, Vite & Tailwind CSS</p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default App
