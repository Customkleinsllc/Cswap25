import React, { useState } from 'react'
import AdminDashboard from './components/AdminDashboard'
import PoolList from './components/PoolList'

const ChainSelector: React.FC<{ selected: string; onChange: (c: string) => void }> = ({ selected, onChange }) => (
  <select value={selected} onChange={(e) => onChange(e.target.value)}>
    <option value="avalanche">Avalanche</option>
    <option value="sei">SEI</option>
  </select>
)

const App: React.FC = () => {
  const [chain, setChain] = useState('avalanche')
  const [tokenIn, setTokenIn] = useState('AVAX')
  const [tokenOut, setTokenOut] = useState('SEI')
  const [amountIn, setAmountIn] = useState('1')
  const [result, setResult] = useState<string>('')

  const swap = async () => {
    setResult('')
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
      setResult(`tx: ${data.txHash}, amountOut: ${data.amountOut}`)
    } catch (e: any) {
      setResult(e.name === 'AbortError' ? 'Swap timeout' : e.message)
    }
  }

  return (
    <div style={{ padding: 20, fontFamily: 'sans-serif' }}>
      <h1>CSwap DEX</h1>
      <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
        <ChainSelector selected={chain} onChange={setChain} />
        <input value={tokenIn} onChange={(e) => setTokenIn(e.target.value)} placeholder="tokenIn" />
        <span>→</span>
        <input value={tokenOut} onChange={(e) => setTokenOut(e.target.value)} placeholder="tokenOut" />
        <input value={amountIn} onChange={(e) => setAmountIn(e.target.value)} placeholder="amount" />
        <button onClick={swap}>Swap</button>
      </div>
      {result && <pre style={{ padding: 10, backgroundColor: '#f3f4f6', borderRadius: 5 }}>{result}</pre>}
      
      <hr style={{ margin: '30px 0' }} />
      
      <PoolList />
      
      <hr style={{ margin: '30px 0' }} />
      
      <h2>Admin Dashboard</h2>
      <AdminDashboard />
    </div>
  )
}

export default App






