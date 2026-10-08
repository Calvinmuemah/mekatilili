const express = require('express');
const { success } = require('../utils/response');

const router = express.Router();

router.get('/health', (req, res) => {
  return success(res, {
    status: 'ok',
    service: 'mekatilili-backend',
    timestamp: new Date().toISOString(),
  });
});

module.exports = router;
