const fastify = require('fastify')({ logger: false });
const cors = require('@fastify/cors');
const websocket = require('@fastify/websocket');
const rateLimit = require('@fastify/rate-limit');
const { testConnection } = require('./config/database');
require('dotenv').config();

const PORT = process.env.PORT || 3300;
const HOST = process.env.HOST || '0.0.0.0';

// Registrar plugins
async function start() {
  try {
    // CORS
    await fastify.register(cors, {
      origin: true
    });

    // Rate limiting
    await fastify.register(rateLimit, {
      max: 300,
      timeWindow: '1 minute'
    });

    // WebSocket
    await fastify.register(websocket);

    // Logging middleware
    fastify.addHook('onRequest', async (request, reply) => {
      console.log(`${request.method} ${request.url}`);
    });

    // Health check
    fastify.get('/health', async (request, reply) => {
      return {
        status: 'ok',
        time: new Date().toISOString()
      };
    });

    // WebSocket - Lecturas en tiempo real
    fastify.register(async function (fastify) {
      fastify.get('/ws/lecturas', { websocket: true }, (connection, req) => {
        const { sensorInstaladoId, instalacionId } = req.query;

        if (!sensorInstaladoId && !instalacionId) {
          connection.socket.send(JSON.stringify({
            type: 'error',
            message: 'Debe enviar sensorInstaladoId o instalacionId'
          }));
          connection.socket.close();
          return;
        }

        console.log(`WebSocket conectado - Sensor: ${sensorInstaladoId}, Instalación: ${instalacionId}`);

        // Almacenar el filtro en el socket
        connection.socket.sensorInstaladoId = sensorInstaladoId;
        connection.socket.instalacionId = instalacionId;

        connection.socket.on('close', () => {
          console.log('WebSocket desconectado');
        });
      });
    });

    // Rutas API
    await fastify.register(require('./routes/organizaciones'), { prefix: '/api' });
    await fastify.register(require('./routes/sucursales'), { prefix: '/api' });
    await fastify.register(require('./routes/instalaciones'), { prefix: '/api' });
    await fastify.register(require('./routes/sensores'), { prefix: '/api' });
    await fastify.register(require('./routes/lecturas'), { prefix: '/api' });
    await fastify.register(require('./routes/usuarios'), { prefix: '/api' });
    await fastify.register(require('./routes/alertas'), { prefix: '/api' });
    await fastify.register(require('./routes/parametros'), { prefix: '/api' });
    await fastify.register(require('./routes/especies'), { prefix: '/api' });
    await fastify.register(require('./routes/procesos'), { prefix: '/api' });
    await fastify.register(require('./routes/tipos-rol'), { prefix: '/api' });

    // Test de conexión a la base de datos
    await testConnection();

    // Iniciar servidor
    await fastify.listen({ port: PORT, host: HOST });
    console.log(`🚀 Servidor AQUA SONDA corriendo en http://${HOST}:${PORT}`);
    console.log(`📊 Base de datos: MySQL`);
    console.log(`🔌 WebSocket: ws://${HOST}:${PORT}/ws/lecturas`);
    console.log(`📝 Health check: http://${HOST}:${PORT}/health`);

  } catch (err) {
    console.error('Error al iniciar el servidor:', err);
    process.exit(1);
  }
}

// Manejo de señales de cierre
const signals = ['SIGINT', 'SIGTERM'];
signals.forEach(signal => {
  process.on(signal, async () => {
    console.log(`\nRecibida señal ${signal}, cerrando servidor...`);
    await fastify.close();
    process.exit(0);
  });
});

start();

module.exports = fastify;
