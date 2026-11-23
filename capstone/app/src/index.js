'use strict';

const express = require('express');
const client = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || '1.0.0';
const NODE_ENV = process.env.NODE_ENV || 'development';

// Prometheus metrics
const register = new client.Registry();
client.collectDefaultMetrics({ register });

const httpRequestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total HTTP requests',
  labelNames: ['method', 'route', 'status'],
  registers: [register],
});

const httpDurationHistogram = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 2],
  registers: [register],
});

// Middleware
app.use(express.json());
app.use((req, res, next) => {
  const end = httpDurationHistogram.startTimer({ method: req.method, route: req.path });
  res.on('finish', () => {
    httpRequestCounter.inc({ method: req.method, route: req.path, status: res.statusCode });
    end();
  });
  next();
});

// Routes
app.get('/', (req, res) => {
  res.json({
    app: 'DevOps Capstone App',
    version: APP_VERSION,
    environment: NODE_ENV,
    message: 'End-to-end DevOps automation platform',
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    version: APP_VERSION,
    environment: NODE_ENV,
    uptime: Math.floor(process.uptime()),
    timestamp: new Date().toISOString(),
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    version: APP_VERSION,
    environment: NODE_ENV,
    nodeVersion: process.version,
    platform: process.platform,
    memory: process.memoryUsage(),
  });
});

app.get('/api/status', (req, res) => {
  res.json({ status: 'running', version: APP_VERSION });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.use((req, res) => {
  res.status(404).json({ error: 'Not Found', path: req.path });
});

// Start server (not during tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`DevOps Capstone App v${APP_VERSION} running on port ${PORT}`);
    console.log(`Environment: ${NODE_ENV}`);
  });
}

module.exports = app;
