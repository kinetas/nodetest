const express = require('express')
const app = express()

app.get('/', function (req, res) {
  res.send('Hi World!!')
})

app.listen(80)