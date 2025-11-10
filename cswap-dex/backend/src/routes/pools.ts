import { Router } from 'express'
import { TimeoutError } from '../utils/errors'
import { AvalancheService } from '../services/avalanche'
import { SeiService } from '../services/sei'
import { logger } from '../utils/logger'

export const poolsRouter = Router()
const avalancheService = new AvalancheService()
const seiService = new SeiService()

// GET /api/pools - list pools
poolsRouter.get('/', async (req, res) => {
  try {
    const { chain } = req.query || {}
    
    const pools = []
    
    // Get pools from both chains or specific chain
    if (!chain || chain === 'avalanche' || chain === 'avax') {
      const avalanchePools = await Promise.race([
        Promise.resolve([
          { id: 'AVAX-USDC', chain: 'avalanche', tvl: '1500000', fee: '0.3%', volume24h: '500000' },
          { id: 'AVAX-SEI', chain: 'avalanche', tvl: '800000', fee: '0.3%', volume24h: '200000' }
        ]),
        new Promise<never>((_, reject) => 
          setTimeout(() => reject(new TimeoutError('Avalanche pools timeout')), 5000)
        )
      ])
      pools.push(...avalanchePools)
    }
    
    if (!chain || chain === 'sei') {
      const seiPools = await Promise.race([
        Promise.resolve([
          { id: 'SEI-USDC', chain: 'sei', tvl: '3000000', fee: '0.3%', volume24h: '1000000' },
          { id: 'SEI-AVAX', chain: 'sei', tvl: '1200000', fee: '0.3%', volume24h: '400000' }
        ]),
        new Promise<never>((_, reject) => 
          setTimeout(() => reject(new TimeoutError('SEI pools timeout')), 5000)
        )
      ])
      pools.push(...seiPools)
    }
    
    res.json({ pools, total: pools.length })
  } catch (e: any) {
    logger.error('Pools fetch failed:', e)
    res.status(e instanceof TimeoutError ? 408 : 500).json({ error: e.message })
  }
})

// GET /api/pools/:id - get pool details
poolsRouter.get('/:id', async (req, res) => {
  try {
    const { id } = req.params
    const { chain } = req.query || {}
    
    // Parse pool ID to determine chain
    const poolChain = chain as string || (id.includes('SEI') ? 'sei' : 'avalanche')
    
    let poolInfo
    if (poolChain === 'avalanche' || poolChain === 'avax') {
      poolInfo = await avalancheService.getPoolInfo(id)
    } else if (poolChain === 'sei') {
      poolInfo = await seiService.getPoolInfo(id)
    } else {
      return res.status(400).json({ error: `Unsupported chain: ${poolChain}` })
    }
    
    res.json({ id, chain: poolChain, ...poolInfo })
  } catch (e: any) {
    logger.error('Pool info fetch failed:', e)
    res.status(e instanceof TimeoutError ? 408 : 500).json({ error: e.message })
  }
})

// POST /api/pools - create pool
poolsRouter.post('/', async (req, res) => {
  try {
    const { tokenA, tokenB, fee, chain } = req.body || {}
    if (!tokenA || !tokenB || !chain) {
      return res.status(400).json({ error: 'tokenA, tokenB, and chain required' })
    }

    logger.info('Creating pool', { tokenA, tokenB, fee, chain })

    let result
    if (chain === 'avalanche' || chain === 'avax') {
      result = await avalancheService.createPool(tokenA, tokenB, fee || '0.3%')
    } else if (chain === 'sei') {
      result = await seiService.createPool(tokenA, tokenB, fee || '0.3%')
    } else {
      return res.status(400).json({ error: `Unsupported chain: ${chain}` })
    }

    res.status(201).json({
      id: `${tokenA}-${tokenB}`,
      chain,
      ...result,
      fee: fee || '0.3%'
    })
  } catch (e: any) {
    logger.error('Pool creation failed:', e)
    res.status(e instanceof TimeoutError ? 408 : 500).json({ error: e.message })
  }
})





