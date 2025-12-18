const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/organizaciones - Crear organización
  fastify.post('/organizaciones', async (request, reply) => {
    const { nombre, estado } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO organizacion (nombre, estado) VALUES (?, ?)',
        [nombre, estado || 'activa']
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM organizacion WHERE id_organizacion = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear organización:', error);
      return reply.code(500).send({ error: 'Error al crear organización' });
    }
  });

  // GET /api/organizaciones - Obtener todas las organizaciones
  fastify.get('/organizaciones', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT o.*, 
          JSON_ARRAYAGG(
            JSON_OBJECT(
              'id_organizacion_sucursal', os.id_organizacion_sucursal,
              'nombre_sucursal', os.nombre_sucursal,
              'estado', os.estado
            )
          ) as organizacion_sucursal
        FROM organizacion o
        LEFT JOIN organizacion_sucursal os ON o.id_organizacion = os.id_organizacion
        GROUP BY o.id_organizacion
      `);
      
      return rows.map(row => ({
        ...row,
        organizacion_sucursal: row.organizacion_sucursal ? JSON.parse(row.organizacion_sucursal) : []
      }));
    } catch (error) {
      console.error('Error al obtener organizaciones:', error);
      return reply.code(500).send({ error: 'Error al obtener organizaciones' });
    }
  });

  // GET /api/organizaciones/:id - Obtener organización por ID
  fastify.get('/organizaciones/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(`
        SELECT o.*, 
          JSON_ARRAYAGG(
            JSON_OBJECT(
              'id_organizacion_sucursal', os.id_organizacion_sucursal,
              'nombre_sucursal', os.nombre_sucursal,
              'estado', os.estado
            )
          ) as organizacion_sucursal
        FROM organizacion o
        LEFT JOIN organizacion_sucursal os ON o.id_organizacion = os.id_organizacion
        WHERE o.id_organizacion = ?
        GROUP BY o.id_organizacion
      `, [id]);
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Organización no encontrada' });
      }
      
      const org = {
        ...rows[0],
        organizacion_sucursal: rows[0].organizacion_sucursal ? JSON.parse(rows[0].organizacion_sucursal) : []
      };
      
      return org;
    } catch (error) {
      console.error('Error al obtener organización:', error);
      return reply.code(500).send({ error: 'Error al obtener organización' });
    }
  });

  // PUT /api/organizaciones/:id - Actualizar organización
  fastify.put('/organizaciones/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre, estado } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (nombre !== undefined) {
        updates.push('nombre = ?');
        values.push(nombre);
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
        `UPDATE organizacion SET ${updates.join(', ')} WHERE id_organizacion = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM organizacion WHERE id_organizacion = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Organización no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar organización:', error);
      return reply.code(500).send({ error: 'Error al actualizar organización' });
    }
  });

  // DELETE /api/organizaciones/:id - Eliminar organización
  fastify.delete('/organizaciones/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM organizacion WHERE id_organizacion = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Organización no encontrada' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar organización:', error);
      return reply.code(500).send({ error: 'Error al eliminar organización' });
    }
  });
}

module.exports = routes;
