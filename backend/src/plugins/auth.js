'use strict';

const fp = require('fastify-plugin');

module.exports = fp(async function auth(fastify) {
  await fastify.register(require('@fastify/jwt'), {
    secret: process.env.JWT_SECRET,
  });

  fastify.decorate('authenticate', async (req, reply) => {
    try {
      await req.jwtVerify();
    } catch (e) {
      reply.status(401).send({ error: 'No autorizado' });
    }
  });
});
