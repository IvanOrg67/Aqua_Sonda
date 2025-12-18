'use strict';

const { registerClient } = require('../services/lecturas.ws.service');

module.exports = async function (fastify) {
  await fastify.register(require('@fastify/websocket'));

  fastify.get('/ws/lecturas', { websocket: true }, (connection, req) => {
    const q = req.query || {};

    const sensorInstaladoId = q.sensorInstaladoId ? Number(q.sensorInstaladoId) : null;
    const instalacionId = q.instalacionId ? Number(q.instalacionId) : null;

    if (!sensorInstaladoId && !instalacionId) {
      connection.socket.send(JSON.stringify({
        type: 'error',
        message: 'Debe enviar sensorInstaladoId o instalacionId',
      }));
      connection.socket.close();
      return;
    }

    registerClient(connection.socket, { sensorInstaladoId, instalacionId });
  });
};
