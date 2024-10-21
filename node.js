const express = require('express')
const app = express()

app.get('/', function (req, res) {
  res.send('Hey World')
})

app.listen(80)