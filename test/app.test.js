const { describe, it, before, after } = require('node:test');
const assert = require('node:assert/strict');
const http = require('node:http');
const { createApp } = require('../src/app');

function request(server, path) {
  return new Promise((resolve, reject) => {
    const { port } = server.address();
    http.get(`http://127.0.0.1:${port}${path}`, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        resolve({ statusCode: res.statusCode, body: JSON.parse(body) });
      });
    }).on('error', reject);
  });
}

describe('API', () => {
  let server;

  before(async () => {
    server = createApp({ appName: 'PIN Test App' });
    await new Promise((resolve, reject) => {
      server.once('error', reject);
      server.listen(0, '127.0.0.1', resolve);
    });
  });

  after(async () => {
    await new Promise((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  });

  it('responde en la ruta raíz', async () => {
    const response = await request(server, '/');
    assert.equal(response.statusCode, 200);
    assert.match(response.body.message, /PIN Proyecto 1/);
  });

  it('expone healthcheck', async () => {
    const response = await request(server, '/health');
    assert.equal(response.statusCode, 200);
    assert.equal(response.body.status, 'ok');
    assert.equal(typeof response.body.uptimeSeconds, 'number');
  });

  it('expone información de la app', async () => {
    const response = await request(server, '/api/info');
    assert.equal(response.statusCode, 200);
    assert.equal(response.body.appName, 'PIN Test App');
  });

  it('devuelve 404 para rutas desconocidas', async () => {
    const response = await request(server, '/no-existe');
    assert.equal(response.statusCode, 404);
    assert.equal(response.body.error, 'Not found');
  });
});
