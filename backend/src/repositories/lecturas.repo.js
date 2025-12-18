'use strict';

const { pool } = require('../config/database');

async function insertLectura({ id_sensor_instalado, valor, fecha, hora }) {
  const [res] = await pool.execute(
    `INSERT INTO lectura (id_sensor_instalado, valor, fecha, hora)
     VALUES (?, ?, ?, ?)`,
    [id_sensor_instalado, valor, fecha, hora]
  );

  const [rows] = await pool.execute(
    `SELECT id_lectura, id_sensor_instalado, valor,
            TIMESTAMP(fecha, hora) AS tomada_en,
            fecha, hora
     FROM lectura
     WHERE id_lectura = ?`,
    [res.insertId]
  );

  return rows[0];
}

async function setUltimaLecturaSensorInstalado({ id_sensor_instalado, id_lectura }) {
  await pool.execute(
    `UPDATE sensor_instalado SET id_lectura = ? WHERE id_sensor_instalado = ?`,
    [id_lectura, id_sensor_instalado]
  );
}

async function listLecturas({ id_sensor_instalado, from, to, limit }) {
  const where = ['id_sensor_instalado = ?'];
  const params = [id_sensor_instalado];

  if (from) { where.push('TIMESTAMP(fecha, hora) >= ?'); params.push(from); }
  if (to) { where.push('TIMESTAMP(fecha, hora) <= ?'); params.push(to); }

  params.push(limit);

  const [rows] = await pool.execute(
    `SELECT id_lectura, id_sensor_instalado, valor,
            TIMESTAMP(fecha, hora) AS tomada_en,
            fecha, hora
     FROM lectura
     WHERE ${where.join(' AND ')}
     ORDER BY TIMESTAMP(fecha, hora) DESC
     LIMIT ?`,
    params
  );

  return rows;
}

async function getContextForWs(id_sensor_instalado) {
  const [rows] = await pool.execute(`
    SELECT
      si.id_sensor_instalado,
      si.id_instalacion,
      i.nombre_instalacion,
      cs.sensor AS tipo_medida,
      cs.unidad_medida AS unidad
    FROM sensor_instalado si
    JOIN instalacion i ON i.id_instalacion = si.id_instalacion
    JOIN catalogo_sensores cs ON cs.id_sensor = si.id_sensor
    WHERE si.id_sensor_instalado = ?
  `, [id_sensor_instalado]);

  return rows[0] || null;
}

module.exports = {
  insertLectura,
  setUltimaLecturaSensorInstalado,
  listLecturas,
  getContextForWs,
};
