const express = require('express');
const router = express.Router();
const { logUserAction } = require('../controllers/loggingController');
const loginRequired = require('../middleware/loginRequired');

router.post('/log-action', loginRequired, logUserAction);
module.exports = router;