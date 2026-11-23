'use strict';

const request = require('supertest');
const app = require('../src/index');

describe('DevOps Capstone App', () => {
  describe('GET /', () => {
    test('returns app info with 200', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body.app).toBe('DevOps Capstone App');
      expect(res.body.version).toBeDefined();
    });
  });

  describe('GET /health', () => {
    test('returns healthy status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('healthy');
      expect(res.body.uptime).toBeGreaterThanOrEqual(0);
      expect(res.body.timestamp).toBeDefined();
    });
  });

  describe('GET /api/info', () => {
    test('returns application info', async () => {
      const res = await request(app).get('/api/info');
      expect(res.statusCode).toBe(200);
      expect(res.body.version).toBeDefined();
      expect(res.body.nodeVersion).toBeDefined();
    });
  });

  describe('GET /api/status', () => {
    test('returns running status', async () => {
      const res = await request(app).get('/api/status');
      expect(res.statusCode).toBe(200);
      expect(res.body.status).toBe('running');
    });
  });

  describe('GET /metrics', () => {
    test('returns Prometheus metrics', async () => {
      const res = await request(app).get('/metrics');
      expect(res.statusCode).toBe(200);
      expect(res.text).toContain('http_requests_total');
    });
  });

  describe('Unknown routes', () => {
    test('returns 404 for unknown path', async () => {
      const res = await request(app).get('/unknown-route');
      expect(res.statusCode).toBe(404);
      expect(res.body.error).toBe('Not Found');
    });
  });
});
