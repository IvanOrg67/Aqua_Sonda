const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/procesos - Crear proceso
  fastify.post('/procesos', async (request, reply) => {
    const { id_especie, fecha_inicio, fecha_final } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO procesos (id_especie, fecha_inicio, fecha_final) VALUES (?, ?, ?)',
        [id_especie, fecha_inicio, fecha_final]
      );
      
      const [rows] = await pool.query(`
        SELECT p.*, e.nombre as especie_nombre
        FROM procesos p
        LEFT JOIN especies e ON p.id_especie = e.id_especie
        WHERE p.id_proceso = ?
      `, [result.insertId]);
      
      // Formatear respuesta igual que la web (incluir especie como objeto)
      const proceso = rows[0];
      const procesoFormateado = {
        ...proceso,
        especie: proceso.especie_nombre ? {
          id_especie: proceso.id_especie,
          nombre: proceso.especie_nombre
        } : null
      };
      
      return reply.status(201).send(procesoFormateado);
    } catch (error) {
      console.error('Error al crear proceso:', error);
      return reply.status(500).send({ error: 'Error al crear proceso' });
    }
  });

  // GET /api/procesos - Obtener todos los procesos
  fastify.get('/procesos', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT p.*, e.nombre as especie_nombre
        FROM procesos p
        LEFT JOIN especies e ON p.id_especie = e.id_especie
        ORDER BY p.fecha_inicio DESC
      `);
      
      // Formatear respuestas igual que la web (incluir especie como objeto)
      const procesosFormateados = rows.map(proceso => ({
        ...proceso,
        especie: proceso.especie_nombre ? {
          id_especie: proceso.id_especie,
          nombre: proceso.especie_nombre
        } : null
      }));
      
      return reply.send(procesosFormateados);
    } catch (error) {
      console.error('Error al obtener procesos:', error);
      return reply.status(500).send({ error: 'Error al obtener procesos' });
    }
  });

  // GET /api/procesos/:id - Obtener proceso por ID
  fastify.get('/procesos/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(`
        SELECT p.*, e.nombre as especie_nombre
        FROM procesos p
        LEFT JOIN especies e ON p.id_especie = e.id_especie
        WHERE p.id_proceso = ?
      `, [id]);
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Proceso no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener proceso:', error);
      return reply.status(500).send({ error: 'Error al obtener proceso' });
    }
  });

  // PUT /api/procesos/:id - Actualizar proceso
  fastify.put('/procesos/:id', async (request, reply) => {
    const { id } = request.params;
    const { id_especie, fecha_inicio, fecha_final } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (id_especie !== undefined) {
        updates.push('id_especie = ?');
        values.push(id_especie);
      }
      if (fecha_inicio !== undefined) {
        updates.push('fecha_inicio = ?');
        values.push(fecha_inicio);
      }
      if (fecha_final !== undefined) {
        updates.push('fecha_final = ?');
        values.push(fecha_final);
      }
      
      if (updates.length === 0) {
        return reply.status(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE procesos SET ${updates.join(', ')} WHERE id_proceso = ?`,
        values
      );
      
      const [rows] = await pool.query(`
        SELECT p.*, e.nombre as especie_nombre
        FROM procesos p
        LEFT JOIN especies e ON p.id_especie = e.id_especie
        WHERE p.id_proceso = ?
      `, [id]);
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Proceso no encontrado' });
      }
      
      // Formatear respuesta igual que la web (incluir especie como objeto)
      const proceso = rows[0];
      const procesoFormateado = {
        ...proceso,
        especie: proceso.especie_nombre ? {
          id_especie: proceso.id_especie,
          nombre: proceso.especie_nombre
        } : null
      };
      
      return reply.send(procesoFormateado);
    } catch (error) {
      console.error('Error al actualizar proceso:', error);
      return reply.status(500).send({ error: 'Error al actualizar proceso' });
    }
  });

  // DELETE /api/procesos/:id - Eliminar proceso
  fastify.delete('/procesos/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM procesos WHERE id_proceso = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Proceso no encontrado' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar proceso:', error);
      return reply.status(500).send({ error: 'Error al eliminar proceso' });
    }
  });
}

module.exports = routes;
