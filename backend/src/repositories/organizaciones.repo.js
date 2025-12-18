'use strict';

const { pool } = require('../config/database');

async function createOrganizacion(data) {
  const [res] = await pool.execute(
    `INSERT INTO organizacion (nombre, razon_social, rfc, correo, telefono, descripcion, id_estado, id_municipio, estado)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.nombre,
      data.razon_social ?? null,
      data.rfc ?? null,
      data.correo ?? null,
      data.telefono ?? null,
      data.descripcion ?? null,
      data.id_estado ?? null,
      data.id_municipio ?? null,
      data.estado ?? 'activa',
    ]
  );

  const [rows] = await pool.execute(
    'SELECT * FROM organizacion WHERE id_organizacion = ?',
    [res.insertId]
  );
  return rows[0];
}

async function listOrganizaciones({ limit, offset }) {
  const [rows] = await pool.execute(
    `SELECT * FROM organizacion ORDER BY id_organizacion DESC LIMIT ? OFFSET ?`,
    [limit, offset]
  );
  return rows;
}

async function getOrganizacion(id) {
  const [rows] = await pool.execute(
    'SELECT * FROM organizacion WHERE id_organizacion = ?',
    [id]
  );
  return rows[0] || null;
}

async function updateOrganizacion(id, patch) {
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
    `UPDATE organizacion SET ${fields.join(', ')} WHERE id_organizacion = ?`,
    values
  );

  return getOrganizacion(id);
}

async function deleteOrganizacion(id) {
  const [res] = await pool.execute(
    'DELETE FROM organizacion WHERE id_organizacion = ?',
    [id]
  );
  return res.affectedRows;
}

module.exports = {
  createOrganizacion,
  listOrganizaciones,
  getOrganizacion,
  updateOrganizacion,
  deleteOrganizacion,
};
