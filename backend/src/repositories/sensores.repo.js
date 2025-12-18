'use strict';

const { pool } = require('../config/database');

// Catálogo de sensores
async function createCatalogoSensor(data) {
  const [res] = await pool.execute(
    `INSERT INTO catalogo_sensores (sensor, descripcion, modelo, marca, rango_medicion, unidad_medida)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [
      data.sensor,
      data.descripcion,
      data.modelo ?? null,
      data.marca ?? null,
      data.rango_medicion ?? null,
      data.unidad_medida ?? null,
    ]
  );

  const [rows] = await pool.execute(
    'SELECT * FROM catalogo_sensores WHERE id_sensor = ?',
    [res.insertId]
  );
  return rows[0];
}

async function listCatalogoSensores({ limit, offset }) {
  const [rows] = await pool.execute(
    `SELECT * FROM catalogo_sensores ORDER BY id_sensor DESC LIMIT ? OFFSET ?`,
    [limit, offset]
  );
  return rows;
}

async function getCatalogoSensor(id) {
  const [rows] = await pool.execute(
    'SELECT * FROM catalogo_sensores WHERE id_sensor = ?',
    [id]
  );
  return rows[0] || null;
}

async function updateCatalogoSensor(id, patch) {
  const fields = [];
  const values = [];

  for (const [k, v] of Object.entries(patch)) {
    if (v !== undefined) {
      fields.push(`${k} = ?`);
      values.push(v);
    }
  }
  if (!fields.length) return null;

  values.push(id);
  await pool.execute(
    `UPDATE catalogo_sensores SET ${fields.join(', ')} WHERE id_sensor = ?`,
    values
  );

  return getCatalogoSensor(id);
}

async function deleteCatalogoSensor(id) {
  const [res] = await pool.execute(
    'DELETE FROM catalogo_sensores WHERE id_sensor = ?',
    [id]
  );
  return res.affectedRows;
}

// Sensores instalados
async function createSensorInstalado(data) {
  const [res] = await pool.execute(
    `INSERT INTO sensor_instalado (id_instalacion, id_sensor, fecha_instalada, descripcion, id_lectura)
     VALUES (?, ?, ?, ?, ?)`,
    [
      data.id_instalacion,
      data.id_sensor,
      data.fecha_instalada,
      data.descripcion,
      data.id_lectura ?? null,
    ]
  );

  const [rows] = await pool.execute(
    `SELECT si.*, cs.sensor, cs.unidad_medida
     FROM sensor_instalado si
     JOIN catalogo_sensores cs ON cs.id_sensor = si.id_sensor
     WHERE si.id_sensor_instalado = ?`,
    [res.insertId]
  );
  return rows[0];
}

async function listSensoresInstalados({ limit, offset, id_instalacion }) {
  let sql = `SELECT si.*, cs.sensor, cs.unidad_medida
             FROM sensor_instalado si
             JOIN catalogo_sensores cs ON cs.id_sensor = si.id_sensor`;
  const params = [];

  if (id_instalacion) {
    sql += ' WHERE si.id_instalacion = ?';
    params.push(id_instalacion);
  }

  sql += ' ORDER BY si.id_sensor_instalado DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function getSensorInstalado(id) {
  const [rows] = await pool.execute(
    `SELECT si.*, cs.sensor, cs.unidad_medida
     FROM sensor_instalado si
     JOIN catalogo_sensores cs ON cs.id_sensor = si.id_sensor
     WHERE si.id_sensor_instalado = ?`,
    [id]
  );
  return rows[0] || null;
}

async function updateSensorInstalado(id, patch) {
  const fields = [];
  const values = [];

  for (const [k, v] of Object.entries(patch)) {
    if (v !== undefined) {
      fields.push(`${k} = ?`);
      values.push(v);
    }
  }
  if (!fields.length) return null;

  values.push(id);
  await pool.execute(
    `UPDATE sensor_instalado SET ${fields.join(', ')} WHERE id_sensor_instalado = ?`,
    values
  );

  return getSensorInstalado(id);
}

async function deleteSensorInstalado(id) {
  const [res] = await pool.execute(
    'DELETE FROM sensor_instalado WHERE id_sensor_instalado = ?',
    [id]
  );
  return res.affectedRows;
}

module.exports = {
  createCatalogoSensor,
  listCatalogoSensores,
  getCatalogoSensor,
  updateCatalogoSensor,
  deleteCatalogoSensor,
  createSensorInstalado,
  listSensoresInstalados,
  getSensorInstalado,
  updateSensorInstalado,
  deleteSensorInstalado,
};
