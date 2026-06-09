const http = require('node:http');

function createApp(config = {}) {
  const appName = config.appName || process.env.APP_NAME || 'PIN Proyecto 1';
  const startTime = Date.now();

  return http.createServer((req, res) => {
    const { method, url } = req;

    if (method === 'GET' && url === '/') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        message: 'Bienvenido a la aplicación del PIN Proyecto 1',
        endpoints: ['/health', '/api/info'],
      }));
      return;
    }

    if (method === 'GET' && url === '/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        status: 'ok',
        uptimeSeconds: Math.floor((Date.now() - startTime) / 1000),
      }));
      return;
    }

    if (method === 'GET' && url === '/api/info') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        appName,
        version: process.env.npm_package_version || '1.0.0',
        environment: process.env.NODE_ENV || 'development',
      }));
      return;
    }

    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  });
}

module.exports = { createApp };
