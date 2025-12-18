const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/sucursales - Crear sucursal
  fastify.post('/sucursales', async (request, reply) => {
    const { id_organizacion, nombre_sucursal, estado } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO organizacion_sucursal (id_organizacion, nombre_sucursal, estado) VALUES (?, ?, ?)',
        [id_organizacion, nombre_sucursal, estado || 'activa']
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear sucursal:', error);
      return reply.code(500).send({ error: 'Error al crear sucursal' });
    }
  });

  // GET /api/sucursales - Obtener todas las sucursales
  fastify.get('/sucursales', async (request, reply) => {
    try {
      const [sucursales] = await pool.query(`
        SELECT os.*, o.nombre as organizacion_nombre
        FROM organizacion_sucursal os
        LEFT JOIN organizacion o ON os.id_organizacion = o.id_organizacion
      `);
      
      return sucursales;
    } catch (error) {
      console.error('Error al obtener sucursales:', error);
      return reply.code(500).send({ error: 'Error al obtener sucursales' });
    }
  });

  // GET /api/sucursales/:id - Obtener sucursal por ID
  fastify.get('/sucursales/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sucursal no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener sucursal:', error);
      return reply.code(500).send({ error: 'Error al obtener sucursal' });
    }
  });

  // PUT /api/sucursales/:id - Actualizar sucursal
  fastify.put('/sucursales/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre_sucursal, estado } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (nombre_sucursal !== undefined) {
        updates.push('nombre_sucursal = ?');
        values.push(nombre_sucursal);
      }
      if (estado !== undefined) {
        updates.push('estado = ?');
        values.push(estado);
      }
      
      if (updates.length === 0) {
        return reply.code(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE organizacion_sucursal SET ${updates.join(', ')} WHERE id_organizacion_sucursal = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sucursal no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar sucursal:', error);
      return reply.code(500).send({ error: 'Error al actualizar sucursal' });
    }
  });

  // DELETE /api/sucursales/:id - Eliminar sucursal
  fastify.delete('/sucursales/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM organizacion_sucursal WHERE id_organizacion_sucursal = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Sucursal no encontrada' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar sucursal:', error);
      return reply.code(500).send({ error: 'Error al eliminar sucursal' });
    }
  });
}

module.exports = routes;
