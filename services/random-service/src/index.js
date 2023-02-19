const http = require('http')

const host = process.env.HOST ?? '0.0.0.0'
const port = Number(process.env.PORT)

const requestListener = function (req, res) {
  const body = Math.floor(Math.random() * 1000).toFixed()
  console.log('sending response', body)
  res.writeHead(200)
  res.end(body)
}

const server = http.createServer(requestListener)

server.listen(port, host, () => {
  console.log(`Server is running on http://${host}:${port}`)
})

const singlas = ['SIGINT', 'SIGTERM']

singlas.forEach(signal => {
  process.on(signal, () => {
    console.log(`${signal} received, stopping...`)
    server.close()
  })
})
