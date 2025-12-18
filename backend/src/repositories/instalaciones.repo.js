'use strict';

const { pool } = require('../config/database');

async function createInstalacion(data) {
  const [res] = await pool.execute(
    `INSERT INTO instalacion (id_organizacion_sucursal, nombre_instalacion, fecha_instalacion, estado_operativo, descripcion, tipo_uso, id_proceso)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
    [
      data.id_organizacion_sucursal,
      data.nombre_instalacion,
      data.fecha_instalacion,
      data.estado_operativo ?? 'activo',
      data.descripcion ?? null,
      data.tipo_uso ?? 'acuicultura',
      data.id_proceso ?? null,
    ]
  );

  const [rows] = await pool.execute(
    'SELECT * FROM instalacion WHERE id_instalacion = ?',
    [res.insertId]
  );
  return rows[0];
}

async function listInstalaciones({ limit, offset, id_organizacion_sucursal }) {
  let sql = 'SELECT * FROM instalacion';
  const params = [];

  if (id_organizacion_sucursal) {
    sql += ' WHERE id_organizacion_sucursal = ?';
    params.push(id_organizacion_sucursal);
  }

  sql += ' ORDER BY id_instalacion DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function getInstalacion(id) {
  const [rows] = await pool.execute(
    'SELECT * FROM instalacion WHERE id_instalacion = ?',
    [id]
  );
  return rows[0] || null;
}

async function updateInstalacion(id, patch) {
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
    `UPDATE instalacion SET ${fields.join(', ')} WHERE id_instalacion = ?`,
    values
  );

  return getInstalacion(id);
}

async function deleteInstalacion(id) {
  const [res] = await pool.execute(
    'DELETE FROM instalacion WHERE id_instalacion = ?',
    [id]
  );
  return res.affectedRows;
}

module.exports = {
  createInstalacion,
  listInstalaciones,
  getInstalacion,
  updateInstalacion,
  deleteInstalacion,
};
