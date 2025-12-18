'use strict';

module.exports = async function (fastify) {
  fastify.get('/health', async () => ({
    status: 'ok',
    time: new Date().toISOString(),
  }));
};
