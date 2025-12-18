'use strict';

const fp = require('fastify-plugin');

module.exports = fp(async function base(fastify) {
  await fastify.register(require('@fastify/cors'), {
    origin: process.env.CORS_ORIGIN || true,
  });

  await fastify.register(require('@fastify/rate-limit'), {
    max: 300,
    timeWindow: '1 minute',
  });

  await fastify.register(require('@fastify/sensible'));

  // Opcional: headers de seguridad
  if (process.env.NODE_ENV === 'production') {
    await fastify.register(require('@fastify/helmet'));
  }

  // Error handler uniforme
  fastify.setErrorHandler((err, req, reply) => {
    req.log.error({ err }, 'request failed');

    const status = err.statusCode && err.statusCode >= 400 ? err.statusCode : 500;

    // Mensaje 500 (genérico) para no filtrar detalles internos
    const message =
      status === 500
        ? 'Error al conectar con la base de datos'
        : (err.message || 'Error');

    reply.status(status).send({ error: message });
  });
});
