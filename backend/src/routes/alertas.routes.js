// backend/src/routes/alertas.routes.js
'use strict';

const alertasRepo = require('../repositories/alertas.repo');

/**
 * Esquemas de validación
 */
const alertaSchema = {
  type: 'object',
  required: ['id_instalacion', 'id_sensor_instalado', 'descripcion', 'dato_puntual'],
  properties: {
    id_instalacion: { type: 'integer', minimum: 1 },
    id_sensor_instalado: { type: 'integer', minimum: 1 },
    descripcion: { type: 'string', minLength: 1, maxLength: 100 },
    dato_puntual: { type: 'number' },
  },
};

/**
 * @param {import('fastify').FastifyInstance} fastify
 */
async function alertasRoutes(fastify) {
  // GET /api/alertas?id_instalacion=X
  fastify.get('/', async (request, reply) => {
    const { id_instalacion } = request.query;
    const alertas = await alertasRepo.getAll(id_instalacion ? parseInt(id_instalacion) : undefined);
    return alertas;
  });

  // GET /api/alertas/:id
  fastify.get('/:id', async (request, reply) => {
    const { id } = request.params;
    const alerta = await alertasRepo.getById(parseInt(id));
    
    if (!alerta) {
      return reply.status(404).send({ error: 'Alerta no encontrada' });
    }
    
    return alerta;
  });

  // POST /api/alertas
  fastify.post('/', {
    schema: {
      body: alertaSchema,
    },
  }, async (request, reply) => {
    const alerta = await alertasRepo.create(request.body);
    return reply.status(201).send(alerta);
  });

  // DELETE /api/alertas/:id
  fastify.delete('/:id', async (request, reply) => {
    const { id } = request.params;
    const eliminada = await alertasRepo.deleteById(parseInt(id));
    
    if (!eliminada) {
      return reply.status(404).send({ error: 'Alerta no encontrada' });
    }
    
    return reply.status(204).send();
  });
}

module.exports = alertasRoutes;
