const express = require('express')
const app = express()

app.get('/', function (req, res) {
  res.send('H1 World!!')
})

app.listen(3000)