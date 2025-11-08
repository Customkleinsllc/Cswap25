import app from './app.js'

const port = parseInt(process.env.PORT || '8000', 10)

const server = app.listen(port, () => {
  console.log(`Backend listening on port ${port}`)
})

process.on('unhandledRejection', (err) => {
  console.error('UnhandledRejection', err)
})

process.on('uncaughtException', (err) => {
  console.error('UncaughtException', err)
  server.close(() => process.exit(1))
})





