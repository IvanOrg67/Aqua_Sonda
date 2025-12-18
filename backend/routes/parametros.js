const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/parametros - Crear parámetro
  fastify.post('/parametros', async (request, reply) => {
    const { nombre_parametro, unidad_medida } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO parametros (nombre_parametro, unidad_medida) VALUES (?, ?)',
        [nombre_parametro, unidad_medida]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM parametros WHERE id_parametro = ?',
        [result.insertId]
      );
      
      return reply.status(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear parámetro:', error);
      return reply.status(500).send({ error: 'Error al crear parámetro' });
    }
  });

  // GET /api/parametros - Obtener todos los parámetros
  fastify.get('/parametros', async (request, reply) => {
    try {
      const [rows] = await pool.query('SELECT * FROM parametros ORDER BY nombre_parametro');
      return rows;
    } catch (error) {
      console.error('Error al obtener parámetros:', error);
      return reply.status(500).send({ error: 'Error al obtener parámetros' });
    }
  });

  // GET /api/parametros/:id - Obtener parámetro por ID
  fastify.get('/parametros/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM parametros WHERE id_parametro = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Parámetro no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener parámetro:', error);
      return reply.status(500).send({ error: 'Error al obtener parámetro' });
    }
  });

  // PUT /api/parametros/:id - Actualizar parámetro
  fastify.put('/parametros/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre_parametro, unidad_medida } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (nombre_parametro !== undefined) {
        updates.push('nombre_parametro = ?');
        values.push(nombre_parametro);
      }
      if (unidad_medida !== undefined) {
        updates.push('unidad_medida = ?');
        values.push(unidad_medida);
      }
      
      if (updates.length === 0) {
        return reply.status(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE parametros SET ${updates.join(', ')} WHERE id_parametro = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM parametros WHERE id_parametro = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Parámetro no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar parámetro:', error);
      return reply.status(500).send({ error: 'Error al actualizar parámetro' });
    }
  });

  // DELETE /api/parametros/:id - Eliminar parámetro
  fastify.delete('/parametros/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM parametros WHERE id_parametro = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Parámetro no encontrado' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar parámetro:', error);
      return reply.status(500).send({ error: 'Error al eliminar parámetro' });
    }
  });
}

module.exports = routes;
