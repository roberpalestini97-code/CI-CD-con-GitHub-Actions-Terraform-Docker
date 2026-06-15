const { createApp } = require('./app');

const port = Number(process.env.PORT) || 3000;
const server = createApp();

server.listen(port, '0.0.0.0', () => {
  console.log(`Servidor escuchando en http://0.0.0.0:${port}`);
});
