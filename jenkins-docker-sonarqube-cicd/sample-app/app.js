const express = require('express');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Container CI/CD service is running',
    version: '1.0.0',
    runtime: 'Docker',
    pipeline: 'Jenkins',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'container-cicd-node-service'
  });
});

if (require.main === module) {
  app.listen(port, () => {
    console.log(`Service running on port ${port}`);
  });
}

module.exports = app;
