const express = require('express');
const os = require('os');

const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from containerized application platform',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    hostname: os.hostname()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    version: '1.0.0'
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
