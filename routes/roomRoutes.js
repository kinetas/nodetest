// routes/roomRoutes.js
const express = require('express');
const router = express.Router();
const roomController = require('../controllers/roomController');

router.get('/', roomController.getRooms);
router.post('/', roomController.addRoom);
router.delete('/:u2_id', roomController.deleteRoom);

module.exports = router;