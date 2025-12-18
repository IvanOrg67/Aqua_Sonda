'use strict';

const repo = require('../repositories/lecturas.repo');
const { clampInt } = require('../utils/clamp');
const { createLectura } = require('../services/lecturas.service');

module.exports = async function (fastify) {
  const auth = {};

  fastify.get('/lecturas', {
    ...auth,
    schema: {
      querystring: {
        type: 'object',
        required: ['sensorInstaladoId'],
        additionalProperties: false,
        properties: {
          sensorInstaladoId: { type: 'integer', minimum: 1 },
          from: { type: 'string', format: 'date-time' },
          to: { type: 'string', format: 'date-time' },
          limit: { type: 'integer', minimum: 1, maximum: 5000, default: 500 },
        },
      },
    },
  }, async (req) => {
    const limit = clampInt(req.query.limit, 500, 1, 5000);

    const rows = await repo.listLecturas({
      id_sensor_instalado: req.query.sensorInstaladoId,
      from: req.query.from,
      to: req.query.to,
      limit,
    });

    return rows.map(r => ({
      id_lectura: r.id_lectura,
      id_sensor_instalado: r.id_sensor_instalado,
      valor: Number(r.valor),
      tomada_en: new Date(r.tomada_en).toISOString(),
      fecha: String(r.fecha),
      hora: String(r.hora),
    }));
  });

  fastify.post('/lecturas', {
    ...auth,
    schema: {
      body: {
        type: 'object',
        required: ['id_sensor_instalado', 'valor'],
        additionalProperties: false,
        properties: {
          id_sensor_instalado: { type: 'integer', minimum: 1 },
          valor: { type: 'number' },
          timestamp: { type: 'string' },
        },
      },
    },
  }, async (req, reply) => {
    const created = await createLectura(fastify, req.body);
    reply.status(201).send(created);
  });
};
