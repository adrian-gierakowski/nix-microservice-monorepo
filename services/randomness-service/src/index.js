const http = require('http')

const host = process.env.HOST ?? '0.0.0.0'
const port = Number(process.env.PORT)
const min = Number(process.env.RANDOM_GENERATOR_MIN ?? 0)
const max = Number(process.env.RANDOM_GENERATOR_MAX ?? 1000)

console.log(`starting with config`, { host, port, min, max })

const sockets = new Set();

const requestListener = (req, res) => {
  const body = Math.floor(Math.random() * (max - min) + min).toFixed()
  console.log('sending response', body)
  res.writeHead(200)
  res.end(body)
}

const server = http.createServer(requestListener)

server.on('connection', (socket) => {
  sockets.add(socket)
  sockets.add(socket)

  socket.once('close', () => {
    console.log('deleting socket')
    sockets.delete(socket)
  })
})

server.listen(port, host, () => {
  console.log(`Server is running on http://${host}:${port}`)
})

const singlas = ['SIGINT', 'SIGTERM']

singlas.forEach(signal => {
  process.once(signal, () => {
    for (const socket of sockets) {
      socket.destroy()
    }
    console.log(`${signal} received, stopping...`)
    server.close()
  })
})
