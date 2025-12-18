// backend/src/repositories/alertas.repo.js
'use strict';

const { getPool } = require('../config/database');

/**
 * @typedef {Object} Alerta
 * @property {number} id_alertas
 * @property {number} id_instalacion
 * @property {number} id_sensor_instalado
 * @property {string} descripcion
 * @property {number} dato_puntual
 */

/**
 * Obtener todas las alertas (opcionalmente filtradas por instalación)
 * @param {number} [idInstalacion] - ID de la instalación
 * @returns {Promise<Alerta[]>}
 */
async function getAll(idInstalacion) {
  const pool = getPool();
  let query = `
    SELECT 
      a.id_alertas,
      a.id_instalacion,
      a.id_sensor_instalado,
      a.descripcion,
      a.dato_puntual,
      si.descripcion as nombre_sensor,
      cs.sensor,
      cs.unidad_medida
    FROM alertas a
    LEFT JOIN sensor_instalado si ON a.id_sensor_instalado = si.id_sensor_instalado
    LEFT JOIN catalogo_sensores cs ON si.id_sensor = cs.id_sensor
  `;
  
  const params = [];
  if (idInstalacion) {
    query += ' WHERE a.id_instalacion = ?';
    params.push(idInstalacion);
  }
  
  query += ' ORDER BY a.id_alertas DESC';
  
  const [rows] = await pool.execute(query, params);
  return rows;
}

/**
 * Obtener una alerta por ID
 * @param {number} id
 * @returns {Promise<Alerta|null>}
 */
async function getById(id) {
  const pool = getPool();
  const [rows] = await pool.execute(
    `SELECT 
      a.id_alertas,
      a.id_instalacion,
      a.id_sensor_instalado,
      a.descripcion,
      a.dato_puntual,
      si.descripcion as nombre_sensor,
      cs.sensor,
      cs.unidad_medida
    FROM alertas a
    LEFT JOIN sensor_instalado si ON a.id_sensor_instalado = si.id_sensor_instalado
    LEFT JOIN catalogo_sensores cs ON si.id_sensor = cs.id_sensor
    WHERE a.id_alertas = ?`,
    [id]
  );
  return rows[0] || null;
}

/**
 * Crear una nueva alerta
 * @param {Object} data
 * @param {number} data.id_instalacion
 * @param {number} data.id_sensor_instalado
 * @param {string} data.descripcion
 * @param {number} data.dato_puntual
 * @returns {Promise<Alerta>}
 */
async function create(data) {
  const pool = getPool();
  const { id_instalacion, id_sensor_instalado, descripcion, dato_puntual } = data;
  
  const [result] = await pool.execute(
    `INSERT INTO alertas (id_instalacion, id_sensor_instalado, descripcion, dato_puntual)
     VALUES (?, ?, ?, ?)`,
    [id_instalacion, id_sensor_instalado, descripcion, dato_puntual]
  );
  
  return getById(result.insertId);
}

/**
 * Eliminar una alerta
 * @param {number} id
 * @returns {Promise<boolean>}
 */
async function deleteById(id) {
  const pool = getPool();
  const [result] = await pool.execute(
    'DELETE FROM alertas WHERE id_alertas = ?',
    [id]
  );
  return result.affectedRows > 0;
}

module.exports = {
  getAll,
  getById,
  create,
  deleteById,
};
