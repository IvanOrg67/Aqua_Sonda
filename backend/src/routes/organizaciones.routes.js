'use strict';

const repo = require('../repositories/organizaciones.repo');
const { clampInt } = require('../utils/clamp');

module.exports = async function (fastify) {
  const auth = {};

  fastify.post('/organizaciones', {
    ...auth,
    schema: {
      body: {
        type: 'object',
        required: ['nombre'],
        additionalProperties: false,
        properties: {
          nombre: { type: 'string', minLength: 1, maxLength: 160 },
          razon_social: { type: 'string', maxLength: 255 },
          rfc: { type: 'string', maxLength: 20 },
          correo: { type: 'string', maxLength: 255 },
          telefono: { type: 'string', maxLength: 20 },
          descripcion: { type: 'string' },
          id_estado: { type: 'integer', minimum: 1 },
          id_municipio: { type: 'integer', minimum: 1 },
          estado: { type: 'string', enum: ['activa', 'inactiva'] },
        },
      },
    },
  }, async (req, reply) => {
    const created = await repo.createOrganizacion(req.body);
    reply.status(201).send(created);
  });

  fastify.get('/organizaciones', {
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
    return repo.listOrganizaciones({ limit, offset });
  });

  fastify.get('/organizaciones/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req) => {
    const row = await repo.getOrganizacion(req.params.id);
    if (!row) throw fastify.httpErrors.notFound('Organización no encontrada');
    return row;
  });

  fastify.put('/organizaciones/:id', {
    ...auth,
    schema: {
      params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } },
      body: {
        type: 'object',
        additionalProperties: false,
        properties: {
          nombre: { type: 'string', minLength: 1, maxLength: 160 },
          razon_social: { type: 'string', maxLength: 255 },
          rfc: { type: 'string', maxLength: 20 },
          correo: { type: 'string', maxLength: 255 },
          telefono: { type: 'string', maxLength: 20 },
          descripcion: { type: 'string' },
          id_estado: { type: 'integer', minimum: 1 },
          id_municipio: { type: 'integer', minimum: 1 },
          estado: { type: 'string', enum: ['activa', 'inactiva'] },
        },
      },
    },
  }, async (req) => {
    const existing = await repo.getOrganizacion(req.params.id);
    if (!existing) throw fastify.httpErrors.notFound('Organización no encontrada');

    const updated = await repo.updateOrganizacion(req.params.id, req.body);
    if (!updated) throw fastify.httpErrors.badRequest('No hay datos para actualizar');
    return updated;
  });

  fastify.delete('/organizaciones/:id', {
    ...auth,
    schema: { params: { type: 'object', required: ['id'], properties: { id: { type: 'integer', minimum: 1 } } } },
  }, async (req, reply) => {
    const affected = await repo.deleteOrganizacion(req.params.id);
    if (!affected) throw fastify.httpErrors.notFound('Organización no encontrada');
    reply.status(204).send();
  });
};
