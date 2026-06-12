const express = require('express');
const rateLimit = require('express-rate-limit');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const port = process.env.PORT || 3000;

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3002';
const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL || 'http://order-service:3003';

app.use((req, res, next) => {
  console.log(JSON.stringify({
    method: req.method,
    path: req.originalUrl,
    timestamp: new Date().toISOString()
  }));

  next();
});

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Rate limit exceeded',
    message: 'Maximum 100 requests allowed per 15-minute window'
  }
});

app.use(limiter);

app.get('/health', (req, res) => {
  res.status(200).json({
    service: 'api-gateway',
    status: 'healthy'
  });
});

function backendUnavailable(serviceName) {
  return (err, req, res, next) => {
    console.error(JSON.stringify({
      error: err.message,
      backend: serviceName,
      path: req.originalUrl,
      timestamp: new Date().toISOString()
    }));

    if (!res.headersSent) {
      res.status(503).json({
        error: 'Backend service unavailable',
        message: `${serviceName} is currently unreachable`
      });
    }
  };
}

app.use('/api/users', createProxyMiddleware({
  target: USER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api': ''
  },
  on: {
    error: backendUnavailable('user-service')
  }
}));

app.use('/api/products', createProxyMiddleware({
  target: PRODUCT_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api': ''
  },
  on: {
    error: backendUnavailable('product-service')
  }
}));

app.use('/api/orders', createProxyMiddleware({
  target: ORDER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api': ''
  },
  on: {
    error: backendUnavailable('order-service')
  }
}));

app.use((req, res) => {
  res.status(404).json({
    error: 'Route not found',
    message: `${req.method} ${req.originalUrl} is not handled by the API Gateway`
  });
});

app.listen(port, () => {
  console.log(`api-gateway listening on port ${port}`);
});
