const express = require('express')
const app = express()

app.get('/', function (req, res) {
  res.send('Hell World')
})

app.listen(80)