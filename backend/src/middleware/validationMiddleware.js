const { validationResult } = require('express-validator');
const { error } = require('../utils/response');

function validateRequest(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return error(
      res,
      'Validation failed for one or more fields',
      'VALIDATION_ERROR',
      400,
      errors.array().map(e => ({ field: e.path || e.param, message: e.msg }))
    );
  }
  next();
}

function errorHandler(err, req, res, next) {
  console.error('Unhandled Server Error:', err);
  const status = err.statusCode || 500;
  const message = process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message;
  return error(res, message, err.code || 'INTERNAL_ERROR', status);
}

module.exports = {
  validateRequest,
  errorHandler,
};
