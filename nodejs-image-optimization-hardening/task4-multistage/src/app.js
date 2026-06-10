const express = require('express');
const compression = require('compression');

const app = express();
const port = process.env.PORT || 3000;

app.use(compression());

const getServerInfo = () => ({
  message: 'Multi-stage build demo',
  timestamp: new Date().toISOString(),
  environment: process.env.NODE_ENV || 'development',
  features: ['compression', 'transpilation', 'optimization']
});

app.get('/', (req, res) => {
  res.json(getServerInfo());
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Multi-stage demo app listening at http://0.0.0.0:${port}`);
});
