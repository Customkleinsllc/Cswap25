import { Router } from 'express'
import { TimeoutError } from '../utils/errors'
import { AvalancheService } from '../services/avalanche'
import { SeiService } from '../services/sei'
import { logger } from '../utils/logger'

export const swapRouter = Router()
const avalancheService = new AvalancheService()
const seiService = new SeiService()

// POST /api/swap - execute swap
swapRouter.post('/', async (req, res) => {
  try {
    const { tokenIn, tokenOut, amountIn, chain, recipient } = req.body || {}
    if (!tokenIn || !tokenOut || !amountIn || !chain) {
      return res.status(400).json({ error: 'tokenIn, tokenOut, amountIn, chain required' })
    }

    logger.info('Swap request received', { tokenIn, tokenOut, amountIn, chain, recipient })

    let result
    if (chain === 'avalanche' || chain === 'avax') {
      result = await avalancheService.executeSwap(
        tokenIn,
        tokenOut,
        amountIn,
        recipient || '0x0000000000000000000000000000000000000000'
      )
    } else if (chain === 'sei') {
      result = await seiService.executeSwap(
        tokenIn,
        tokenOut,
        amountIn,
        recipient || 'sei1test'
      )
    } else {
      return res.status(400).json({ error: `Unsupported chain: ${chain}` })
    }

    res.json({ ...result, chain })
  } catch (e: any) {
    logger.error('Swap failed:', e)
    res.status(e instanceof TimeoutError ? 408 : 500).json({ error: e.message })
  }
})





