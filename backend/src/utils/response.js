/**
 * Standardized API response utilities
 */

function success(res, data = null, statusCode = 200) {
  return res.status(statusCode).json({
    success: true,
    data,
  });
}

function error(res, message, code = 'INTERNAL_ERROR', statusCode = 500, details = []) {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      details,
    },
  });
}

module.exports = {
  success,
  error,
};
