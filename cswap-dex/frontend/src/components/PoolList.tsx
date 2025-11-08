import React, { useState, useEffect } from 'react'

interface Pool {
  id: string
  chain: string
  tvl: string
  fee: string
  volume24h: string
}

const PoolList: React.FC = () => {
  const [pools, setPools] = useState<Pool[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [selectedChain, setSelectedChain] = useState<string>('')

  const loadPools = async (chain?: string) => {
    setLoading(true)
    setError('')
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), 5000)
    try {
      const url = chain ? `/api/pools?chain=${chain}` : '/api/pools'
      const res = await fetch(url, { signal: controller.signal })
      clearTimeout(timeoutId)
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Failed to load pools')
      setPools(data.pools || [])
    } catch (e: any) {
      setError(e.name === 'AbortError' ? 'Load timeout' : e.message)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadPools(selectedChain || undefined)
  }, [selectedChain])

  return (
    <div style={{ marginTop: 20 }}>
      <h3>Liquidity Pools</h3>
      
      <div style={{ display: 'flex', gap: 10, marginBottom: 15 }}>
        <select
          value={selectedChain}
          onChange={(e) => setSelectedChain(e.target.value)}
          style={{ padding: 5 }}
        >
          <option value="">All Chains</option>
          <option value="avalanche">Avalanche</option>
          <option value="sei">SEI</option>
        </select>
        <button onClick={() => loadPools(selectedChain || undefined)} disabled={loading}>
          Refresh
        </button>
      </div>

      {error && <div style={{ color: 'red', marginBottom: 10 }}>{error}</div>}

      {loading && <div>Loading pools...</div>}

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: 15 }}>
        {pools.map((pool) => (
          <div
            key={pool.id}
            style={{
              padding: 15,
              backgroundColor: '#f3f4f6',
              borderRadius: 8,
              border: '1px solid #e5e7eb'
            }}
          >
            <div style={{ fontWeight: 'bold', marginBottom: 10 }}>{pool.id}</div>
            <div style={{ fontSize: 12, color: '#6b7280', marginBottom: 5 }}>
              Chain: <span style={{ textTransform: 'capitalize' }}>{pool.chain}</span>
            </div>
            <div style={{ fontSize: 12, color: '#6b7280', marginBottom: 5 }}>
              TVL: ${parseFloat(pool.tvl).toLocaleString()}
            </div>
            <div style={{ fontSize: 12, color: '#6b7280', marginBottom: 5 }}>
              24h Volume: ${parseFloat(pool.volume24h).toLocaleString()}
            </div>
            <div style={{ fontSize: 12, color: '#6b7280' }}>
              Fee: {pool.fee}
            </div>
          </div>
        ))}
      </div>

      {pools.length === 0 && !loading && <div>No pools found</div>}
    </div>
  )
}

export default PoolList

