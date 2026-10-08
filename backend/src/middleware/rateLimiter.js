/**
 * In-memory sliding-window rate limiter for production safety.
 * Zero external dependencies; protects authentication endpoints against brute force.
 */

function createRateLimiter({ windowMs = 15 * 60 * 1000, max = 30, message = 'Too many requests, please try again later.' } = {}) {
  const requests = new Map();

  // Periodic cleanup of stale timestamps
  const cleanupTimer = setInterval(() => {
    const now = Date.now();
    for (const [key, timestamps] of requests.entries()) {
      const valid = timestamps.filter(t => now - t < windowMs);
      if (valid.length === 0) {
        requests.delete(key);
      } else {
        requests.set(key, valid);
      }
    }
  }, windowMs);

  if (cleanupTimer.unref) {
    cleanupTimer.unref();
  }

  return (req, res, next) => {
    // Skip in test environment to avoid flaky test suites
    if (process.env.NODE_ENV === 'test') {
      return next();
    }

    const key = req.ip || req.headers['x-forwarded-for'] || req.connection?.remoteAddress || 'unknown';
    const now = Date.now();
    const timestamps = (requests.get(key) || []).filter(t => now - t < windowMs);

    if (timestamps.length >= max) {
      return res.status(429).json({
        success: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message,
        },
      });
    }

    timestamps.push(now);
    requests.set(key, timestamps);
    next();
  };
}

const authRateLimiter = createRateLimiter({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: 'Too many authentication attempts from this IP address. Please wait 15 minutes before retrying.',
});

module.exports = {
  createRateLimiter,
  authRateLimiter,
};
