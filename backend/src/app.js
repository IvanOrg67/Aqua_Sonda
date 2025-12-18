'use strict';

const fastify = require('fastify')({
  logger: {
    transport: {
      target: 'pino-pretty',
      options: { translateTime: 'SYS:standard' },
    },
  },
});

fastify.register(require('./plugins/base'));
fastify.register(require('./plugins/auth'));

// Routes
fastify.register(require('./routes/health.routes'));
fastify.register(require('./routes/auth.routes'), { prefix: '/api' });
fastify.register(require('../routes/usuarios'), { prefix: '/api' });
fastify.register(require('./routes/organizaciones.routes'), { prefix: '/api' });
fastify.register(require('./routes/sucursales.routes'), { prefix: '/api' });
fastify.register(require('./routes/instalaciones.routes'), { prefix: '/api' });
fastify.register(require('./routes/sensores.routes'), { prefix: '/api' });
fastify.register(require('./routes/lecturas.routes'), { prefix: '/api' });
fastify.register(require('./routes/alertas.routes'), { prefix: '/api/alertas' });
fastify.register(require('../routes/procesos'), { prefix: '/api' });
fastify.register(require('../routes/especies'), { prefix: '/api' });
fastify.register(require('../routes/parametros'), { prefix: '/api' });
fastify.register(require('../routes/tipos-rol'), { prefix: '/api' });

// WS
fastify.register(require('./routes/ws.routes'));

module.exports = fastify;
