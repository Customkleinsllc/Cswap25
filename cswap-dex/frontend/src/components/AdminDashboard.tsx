import React, { useState, useEffect } from 'react'

interface Stats {
  totalTVL: string
  totalVolume24h: string
  totalPools: number
  activeUsers: number
  chains: {
    avalanche: { tvl: string; volume24h: string; pools: number }
    sei: { tvl: string; volume24h: string; pools: number }
  }
}

interface Health {
  status: string
  services: {
    backend: { status: string; uptime: number }
    avalanche: { status: string; latency: string }
    sei: { status: string; latency: string }
  }
  circuitBreakers: {
    priceFeed: { state: string; failures: number }
    bridge: { state: string; failures: number }
  }
}

interface Transaction {
  id: string
  type: string
  chain: string
  tokenIn: string
  tokenOut: string
  amountIn: string
  amountOut: string
  txHash: string
  timestamp: string
}

const AdminDashboard: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'stats' | 'health' | 'transactions'>('stats')
  const [stats, setStats] = useState<Stats | null>(null)
  const [health, setHealth] = useState<Health | null>(null)
  const [transactions, setTransactions] = useState<Transaction[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  const fetchStats = async () => {
    setLoading(true)
    setError('')
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 5000)
    try {
      const res = await fetch('/api/admin/stats', { signal: controller.signal })
      clearTimeout(timeoutId)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load stats')
      setStats(data)
    } catch (e: any) {
      setError(e.name === 'AbortError' ? 'Request timeout' : e.message)
    } finally {
      setLoading(false)
    }
  }

  const fetchHealth = async () => {
    setLoading(true)
    setError('')
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 5000)
    try {
      const res = await fetch('/api/admin/health', { signal: controller.signal })
      clearTimeout(timeoutId)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load health')
      setHealth(data)
    } catch (e: any) {
      setError(e.name === 'AbortError' ? 'Request timeout' : e.message)
    } finally {
      setLoading(false)
    }
  }

  const fetchTransactions = async () => {
    setLoading(true)
    setError('')
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 5000)
    try {
      const res = await fetch('/api/admin/transactions', { signal: controller.signal })
      clearTimeout(timeoutId)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load transactions')
      setTransactions(data.transactions || [])
    } catch (e: any) {
      setError(e.name === 'AbortError' ? 'Request timeout' : e.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    if (activeTab === 'stats') fetchStats()
    else if (activeTab === 'health') fetchHealth()
    else if (activeTab === 'transactions') fetchTransactions()
  }, [activeTab])

  return (
    <div style={{ padding: 20, fontFamily: 'sans-serif' }}>
      <h2>Admin Dashboard</h2>
      
      <div style={{ display: 'flex', gap: 10, marginBottom: 20 }}>
        <button
          onClick={() => setActiveTab('stats')}
          style={{
            padding: '10px 20px',
            backgroundColor: activeTab === 'stats' ? '#2563eb' : '#6b7280',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          Statistics
        </button>
        <button
          onClick={() => setActiveTab('health')}
          style={{
            padding: '10px 20px',
            backgroundColor: activeTab === 'health' ? '#2563eb' : '#6b7280',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          Health
        </button>
        <button
          onClick={() => setActiveTab('transactions')}
          style={{
            padding: '10px 20px',
            backgroundColor: activeTab === 'transactions' ? '#2563eb' : '#6b7280',
            color: 'white',
            border: 'none',
            borderRadius: '5px',
            cursor: 'pointer'
          }}
        >
          Transactions
        </button>
      </div>

      {error && (
        <div style={{ padding: 10, backgroundColor: '#fee', color: '#c00', marginBottom: 20, borderRadius: 5 }}>
          Error: {error}
        </div>
      )}

      {loading && <div>Loading...</div>}

      {activeTab === 'stats' && stats && (
        <div>
          <h3>Platform Statistics</h3>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: 20 }}>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <div style={{ fontSize: 12, color: '#6b7280' }}>Total TVL</div>
              <div style={{ fontSize: 24, fontWeight: 'bold' }}>${parseFloat(stats.totalTVL).toLocaleString()}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <div style={{ fontSize: 12, color: '#6b7280' }}>24h Volume</div>
              <div style={{ fontSize: 24, fontWeight: 'bold' }}>${parseFloat(stats.totalVolume24h).toLocaleString()}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <div style={{ fontSize: 12, color: '#6b7280' }}>Total Pools</div>
              <div style={{ fontSize: 24, fontWeight: 'bold' }}>{stats.totalPools}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <div style={{ fontSize: 12, color: '#6b7280' }}>Active Users</div>
              <div style={{ fontSize: 24, fontWeight: 'bold' }}>{stats.activeUsers.toLocaleString()}</div>
            </div>
          </div>
          
          <h4 style={{ marginTop: 30 }}>Chain Statistics</h4>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20, marginTop: 15 }}>
            <div style={{ padding: 15, backgroundColor: '#fef3c7', borderRadius: 5 }}>
              <h5>Avalanche</h5>
              <div>TVL: ${parseFloat(stats.chains.avalanche.tvl).toLocaleString()}</div>
              <div>24h Volume: ${parseFloat(stats.chains.avalanche.volume24h).toLocaleString()}</div>
              <div>Pools: {stats.chains.avalanche.pools}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#dbeafe', borderRadius: 5 }}>
              <h5>SEI</h5>
              <div>TVL: ${parseFloat(stats.chains.sei.tvl).toLocaleString()}</div>
              <div>24h Volume: ${parseFloat(stats.chains.sei.volume24h).toLocaleString()}</div>
              <div>Pools: {stats.chains.sei.pools}</div>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'health' && health && (
        <div>
          <h3>System Health</h3>
          <div style={{ padding: 15, backgroundColor: health.status === 'healthy' ? '#d1fae5' : '#fee', borderRadius: 5, marginBottom: 20 }}>
            <strong>Status:</strong> {health.status.toUpperCase()}
          </div>
          
          <h4>Services</h4>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 15 }}>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <strong>Backend</strong>
              <div>Status: {health.services.backend.status}</div>
              <div>Uptime: {Math.floor(health.services.backend.uptime / 60)}m</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <strong>Avalanche</strong>
              <div>Status: {health.services.avalanche.status}</div>
              <div>Latency: {health.services.avalanche.latency}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <strong>SEI</strong>
              <div>Status: {health.services.sei.status}</div>
              <div>Latency: {health.services.sei.latency}</div>
            </div>
          </div>

          <h4 style={{ marginTop: 20 }}>Circuit Breakers</h4>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 15 }}>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <strong>Price Feed</strong>
              <div>State: {health.circuitBreakers.priceFeed.state}</div>
              <div>Failures: {health.circuitBreakers.priceFeed.failures}</div>
            </div>
            <div style={{ padding: 15, backgroundColor: '#f3f4f6', borderRadius: 5 }}>
              <strong>Bridge</strong>
              <div>State: {health.circuitBreakers.bridge.state}</div>
              <div>Failures: {health.circuitBreakers.bridge.failures}</div>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'transactions' && (
        <div>
          <h3>Recent Transactions</h3>
          <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: 15 }}>
            <thead>
              <tr style={{ backgroundColor: '#f3f4f6' }}>
                <th style={{ padding: 10, textAlign: 'left' }}>Type</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Chain</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Pair</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Amount In</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Amount Out</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Tx Hash</th>
                <th style={{ padding: 10, textAlign: 'left' }}>Time</th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((tx) => (
                <tr key={tx.id} style={{ borderBottom: '1px solid #e5e7eb' }}>
                  <td style={{ padding: 10 }}>{tx.type}</td>
                  <td style={{ padding: 10 }}>{tx.chain}</td>
                  <td style={{ padding: 10 }}>{tx.tokenIn}/{tx.tokenOut}</td>
                  <td style={{ padding: 10 }}>{tx.amountIn}</td>
                  <td style={{ padding: 10 }}>{tx.amountOut}</td>
                  <td style={{ padding: 10, fontFamily: 'monospace', fontSize: 12 }}>
                    {tx.txHash.slice(0, 10)}...
                  </td>
                  <td style={{ padding: 10, fontSize: 12 }}>
                    {new Date(tx.timestamp).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {transactions.length === 0 && !loading && <div>No transactions found</div>}
        </div>
      )}
    </div>
  )
}

export default AdminDashboard

