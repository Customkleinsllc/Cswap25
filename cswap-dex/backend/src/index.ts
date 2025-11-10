import app from './app.js'

const port = parseInt(process.env.PORT || '8000', 10)

// Ensure we're not already listening
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`Backend listening on 0.0.0.0:${port}`)
})

process.on('unhandledRejection', (err) => {
  console.error('UnhandledRejection', err)
})

process.on('uncaughtException', (err) => {
  console.error('UncaughtException', err)
  server.close(() => process.exit(1))
})





