const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/tipos-rol - Crear tipo de rol
  fastify.post('/tipos-rol', async (request, reply) => {
    const { nombre } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO tipo_rol (nombre) VALUES (?)',
        [nombre]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM tipo_rol WHERE id_rol = ?',
        [result.insertId]
      );
      
      return reply.status(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear tipo de rol:', error);
      return reply.status(500).send({ error: 'Error al crear tipo de rol' });
    }
  });

  // GET /api/tipos-rol - Obtener todos los tipos de rol
  fastify.get('/tipos-rol', async (request, reply) => {
    try {
      const [rows] = await pool.query('SELECT * FROM tipo_rol ORDER BY nombre');
      return rows;
    } catch (error) {
      console.error('Error al obtener tipos de rol:', error);
      return reply.status(500).send({ error: 'Error al obtener tipos de rol' });
    }
  });

  // GET /api/tipos-rol/:id - Obtener tipo de rol por ID
  fastify.get('/tipos-rol/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM tipo_rol WHERE id_rol = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Tipo de rol no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener tipo de rol:', error);
      return reply.status(500).send({ error: 'Error al obtener tipo de rol' });
    }
  });

  // PUT /api/tipos-rol/:id - Actualizar tipo de rol
  fastify.put('/tipos-rol/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre } = request.body;
    
    try {
      if (nombre === undefined) {
        return reply.status(400).send({ error: 'El nombre es requerido' });
      }
      
      await pool.query(
        'UPDATE tipo_rol SET nombre = ? WHERE id_rol = ?',
        [nombre, id]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM tipo_rol WHERE id_rol = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Tipo de rol no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar tipo de rol:', error);
      return reply.status(500).send({ error: 'Error al actualizar tipo de rol' });
    }
  });

  // DELETE /api/tipos-rol/:id - Eliminar tipo de rol
  fastify.delete('/tipos-rol/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM tipo_rol WHERE id_rol = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Tipo de rol no encontrado' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar tipo de rol:', error);
      return reply.status(500).send({ error: 'Error al eliminar tipo de rol' });
    }
  });
}

module.exports = routes;
