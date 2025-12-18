'use strict';

const repo = require('../repositories/sensores.repo');
const { clampInt } = require('../utils/clamp');

module.exports = async function (fastify) {
  const auth = {};

  // CATÁLOGO DE SENSORES

  fastify.post('/catalogo-sensores', {
    ...auth,
    schema: {
      body: {
        type: 'object',
        required: ['sensor', 'descripcion'],
        additionalProperties: false,
        properties: {
          sensor: { type: 'string', minLength: 1, maxLength: 45 },
          descripcion: { type: 'string', minLength: 1, maxLength: 500 },
          modelo: { type: 'string', maxLength: 45 },
          marca: { type: 'string', maxLength: 45 },
          rango_medicion: { type: 'string', maxLength: 45 },
          unidad_medida: { type: 'string', maxLength: 45 },
        },
      },
    },
  }, async (req, reply) => {
    const created = await repo.createCatalogoSensor(req.body);
    reply.status(201).send(created);
  });

  fastify.get('/catalogo-sensores', {
    ...auth,
    schema: {
      querystring: {
        type: 'object',
        additionalProperties: false,
        properties: {
          limit: { type: 'integer', minimum: 1, maximum: 200, default: 50 },
          offset: { type: 'integer', minimum: 0, default: 0 },
        },
      },
    },
  }, async (req) => {
    const limit = clampInt(req.query.limit, 50, 1, 200);
    const offset = clampInt(req.query.offset, 0, 0, 1_000_000);
    return repo.listCatalogoSensores({ limit, offset });
  });

  fastify.get('/catalogo-sensores/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req) => {
    const row = await repo.getCatalogoSensor(req.params.id);
    if (!row) throw fastify.httpErrors.notFound('Sensor no encontrado en catálogo');
    return row;
  });

  fastify.put('/catalogo-sensores/:id', {
    ...auth,
    schema: {
      params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } },
      body: {
        type: 'object',
        additionalProperties: false,
        properties: {
          sensor: { type: 'string', minLength: 1, maxLength: 45 },
          descripcion: { type: 'string', minLength: 1, maxLength: 500 },
          modelo: { type: 'string', maxLength: 45 },
          marca: { type: 'string', maxLength: 45 },
          rango_medicion: { type: 'string', maxLength: 45 },
          unidad_medida: { type: 'string', maxLength: 45 },
        },
      },
    },
  }, async (req) => {
    const existing = await repo.getCatalogoSensor(req.params.id);
    if (!existing) throw fastify.httpErrors.notFound('Sensor no encontrado en catálogo');

    const updated = await repo.updateCatalogoSensor(req.params.id, req.body);
    if (!updated) throw fastify.httpErrors.badRequest('No hay datos para actualizar');
    return updated;
  });

  fastify.delete('/catalogo-sensores/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req, reply) => {
    const affected = await repo.deleteCatalogoSensor(req.params.id);
    if (!affected) throw fastify.httpErrors.notFound('Sensor no encontrado en catálogo');
    reply.status(204).send();
  });

  // SENSORES INSTALADOS

  fastify.post('/sensores-instalados', {
    ...auth,
    schema: {
      body: {
        type: 'object',
        required: ['id_instalacion', 'id_sensor', 'fecha_instalada', 'descripcion'],
        additionalProperties: false,
        properties: {
          id_instalacion: { type: 'integer', minimum: 1 },
          id_sensor: { type: 'integer', minimum: 1 },
          fecha_instalada: { type: 'string', format: 'date' },
          descripcion: { type: 'string', minLength: 1, maxLength: 50 },
          id_lectura: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req, reply) => {
    const created = await repo.createSensorInstalado(req.body);
    reply.status(201).send(created);
  });

  fastify.get('/sensores-instalados', {
    ...auth,
    schema: {
      querystring: {
        type: 'object',
        additionalProperties: false,
        properties: {
          limit: { type: 'integer', minimum: 1, maximum: 200, default: 50 },
          offset: { type: 'integer', minimum: 0, default: 0 },
          id_instalacion: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req) => {
    const limit = clampInt(req.query.limit, 50, 1, 200);
    const offset = clampInt(req.query.offset, 0, 0, 1_000_000);
    return repo.listSensoresInstalados({ limit, offset, id_instalacion: req.query.id_instalacion });
  });

  fastify.get('/sensores-instalados/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req) => {
    const row = await repo.getSensorInstalado(req.params.id);
    if (!row) throw fastify.httpErrors.notFound('Sensor instalado no encontrado');
    return row;
  });

  fastify.put('/sensores-instalados/:id', {
    ...auth,
    schema: {
      params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } },
      body: {
        type: 'object',
        additionalProperties: false,
        properties: {
          id_instalacion: { type: 'integer', minimum: 1 },
          id_sensor: { type: 'integer', minimum: 1 },
          fecha_instalada: { type: 'string', format: 'date' },
          descripcion: { type: 'string', minLength: 1, maxLength: 50 },
          id_lectura: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req) => {
    const existing = await repo.getSensorInstalado(req.params.id);
    if (!existing) throw fastify.httpErrors.notFound('Sensor instalado no encontrado');

    const updated = await repo.updateSensorInstalado(req.params.id, req.body);
    if (!updated) throw fastify.httpErrors.badRequest('No hay datos para actualizar');
    return updated;
  });

  fastify.delete('/sensores-instalados/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req, reply) => {
    const affected = await repo.deleteSensorInstalado(req.params.id);
    if (!affected) throw fastify.httpErrors.notFound('Sensor instalado no encontrado');
    reply.status(204).send();
  });
};
