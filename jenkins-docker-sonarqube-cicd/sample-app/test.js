const app = require('./app');

if (!app) {
  console.error('Application failed to load');
  process.exit(1);
}

console.log('Application module loaded successfully');
process.exit(0);
