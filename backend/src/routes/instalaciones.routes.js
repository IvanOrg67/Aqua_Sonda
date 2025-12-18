'use strict';

const repo = require('../repositories/instalaciones.repo');
const { clampInt } = require('../utils/clamp');

module.exports = async function (fastify) {
  const auth = {};

  fastify.post('/instalaciones', {
    ...auth,
    schema: {
      body: {
        type: 'object',
        required: ['id_organizacion_sucursal', 'nombre_instalacion', 'fecha_instalacion'],
        additionalProperties: false,
        properties: {
          id_organizacion_sucursal: { type: 'integer', minimum: 1 },
          nombre_instalacion: { type: 'string', minLength: 1, maxLength: 150 },
          fecha_instalacion: { type: 'string', format: 'date' },
          estado_operativo: { type: 'string', enum: ['activo', 'inactivo'] },
          descripcion: { type: 'string' },
          tipo_uso: { type: 'string', enum: ['acuicultura', 'tratamiento', 'otros'] },
          id_proceso: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req, reply) => {
    const created = await repo.createInstalacion(req.body);
    reply.status(201).send(created);
  });

  fastify.get('/instalaciones', {
    ...auth,
    schema: {
      querystring: {
        type: 'object',
        additionalProperties: false,
        properties: {
          limit: { type: 'integer', minimum: 1, maximum: 200, default: 50 },
          offset: { type: 'integer', minimum: 0, default: 0 },
          id_organizacion_sucursal: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req) => {
    const limit = clampInt(req.query.limit, 50, 1, 200);
    const offset = clampInt(req.query.offset, 0, 0, 1_000_000);
    return repo.listInstalaciones({ limit, offset, id_organizacion_sucursal: req.query.id_organizacion_sucursal });
  });

  fastify.get('/instalaciones/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req) => {
    const row = await repo.getInstalacion(req.params.id);
    if (!row) throw fastify.httpErrors.notFound('Instalación no encontrada');
    return row;
  });

  fastify.put('/instalaciones/:id', {
    ...auth,
    schema: {
      params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } },
      body: {
        type: 'object',
        additionalProperties: false,
        properties: {
          id_organizacion_sucursal: { type: 'integer', minimum: 1 },
          nombre_instalacion: { type: 'string', minLength: 1, maxLength: 150 },
          fecha_instalacion: { type: 'string', format: 'date' },
          estado_operativo: { type: 'string', enum: ['activo', 'inactivo'] },
          descripcion: { type: 'string' },
          tipo_uso: { type: 'string', enum: ['acuicultura', 'tratamiento', 'otros'] },
          id_proceso: { type: 'integer', minimum: 1 },
        },
      },
    },
  }, async (req) => {
    const existing = await repo.getInstalacion(req.params.id);
    if (!existing) throw fastify.httpErrors.notFound('Instalación no encontrada');

    const updated = await repo.updateInstalacion(req.params.id, req.body);
    if (!updated) throw fastify.httpErrors.badRequest('No hay datos para actualizar');
    return updated;
  });

  fastify.delete('/instalaciones/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req, reply) => {
    const affected = await repo.deleteInstalacion(req.params.id);
    if (!affected) throw fastify.httpErrors.notFound('Instalación no encontrada');
    reply.status(204).send();
  });
};
