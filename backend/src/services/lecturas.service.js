'use strict';

const repo = require('../repositories/lecturas.repo');
const { toDatePartsUTC } = require('../utils/time');
const { broadcastLectura } = require('./lecturas.ws.service');

async function createLectura(fastify, { id_sensor_instalado, valor, timestamp }) {
  const ctx = await repo.getContextForWs(id_sensor_instalado);
  if (!ctx) throw fastify.httpErrors.notFound('Sensor instalado no encontrado');

  const date = timestamp ? new Date(timestamp) : new Date();
  if (Number.isNaN(date.getTime())) throw fastify.httpErrors.badRequest('timestamp inválido (usa ISO 8601)');

  const { fecha, hora } = toDatePartsUTC(date);

  const row = await repo.insertLectura({ id_sensor_instalado, valor, fecha, hora });

  await repo.setUltimaLecturaSensorInstalado({ id_sensor_instalado, id_lectura: row.id_lectura });

  const payload = {
    id_lectura: row.id_lectura,
    sensor_instalado_id: row.id_sensor_instalado,
    instalacion_id: ctx.id_instalacion,
    nombre_instalacion: ctx.nombre_instalacion,
    tipo_medida: ctx.tipo_medida,
    unidad: ctx.unidad,
    tomada_en: new Date(row.tomada_en).toISOString(),
    valor: Number(row.valor),
  };

  broadcastLectura(payload);

  return {
    id_lectura: payload.id_lectura,
    id_sensor_instalado: payload.sensor_instalado_id,
    valor: payload.valor,
    tomada_en: payload.tomada_en,
    fecha: String(row.fecha),
    hora: String(row.hora),
  };
}

module.exports = { createLectura };
