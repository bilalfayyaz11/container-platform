const express = require('express');
const os = require('os');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`
    <h1>Container Platform API</h1>
    <p>Status: Running on Azure Kubernetes Service</p>
    <p>Hostname: ${os.hostname()}</p>
    <p>Timestamp: ${new Date().toISOString()}</p>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    hostname: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
