'use strict';

const { pool } = require('../config/database');

async function createSucursal(data) {
  const [res] = await pool.execute(
    `INSERT INTO organizacion_sucursal (id_organizacion, nombre_sucursal, id_estado, id_municipio, localidad, calle, codigo_postal, telefono, correo, estado)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.id_organizacion,
      data.nombre_sucursal,
      data.id_estado ?? null,
      data.id_municipio ?? null,
      data.localidad ?? null,
      data.calle ?? null,
      data.codigo_postal ?? null,
      data.telefono ?? null,
      data.correo ?? null,
      data.estado ?? 'activa',
    ]
  );

  const [rows] = await pool.execute(
    'SELECT * FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
    [res.insertId]
  );
  return rows[0];
}

async function listSucursales({ limit, offset, id_organizacion }) {
  let sql = 'SELECT * FROM organizacion_sucursal';
  const params = [];

  if (id_organizacion) {
    sql += ' WHERE id_organizacion = ?';
    params.push(id_organizacion);
  }

  sql += ' ORDER BY id_organizacion_sucursal DESC LIMIT ? OFFSET ?';
  params.push(limit, offset);

  const [rows] = await pool.execute(sql, params);
  return rows;
}

async function getSucursal(id) {
  const [rows] = await pool.execute(
    'SELECT * FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
    [id]
  );
  return rows[0] || null;
}

async function updateSucursal(id, patch) {
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
    `UPDATE organizacion_sucursal SET ${fields.join(', ')} WHERE id_organizacion_sucursal = ?`,
    values
  );

  return getSucursal(id);
}

async function deleteSucursal(id) {
  const [res] = await pool.execute(
    'DELETE FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
    [id]
  );
  return res.affectedRows;
}

module.exports = {
  createSucursal,
  listSucursales,
  getSucursal,
  updateSucursal,
  deleteSucursal,
};
