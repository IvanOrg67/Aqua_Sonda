const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/alertas - Crear alerta
  fastify.post('/alertas', async (request, reply) => {
    const { id_instalacion, id_sensor_instalado, descripcion, dato_puntual } = request.body;
    
    try {
      const [result] = await pool.query(
        `INSERT INTO alertas (id_instalacion, id_sensor_instalado, descripcion, dato_puntual) 
        VALUES (?, ?, ?, ?)`,
        [id_instalacion, id_sensor_instalado, descripcion, dato_puntual]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM alertas WHERE id_alertas = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear alerta:', error);
      return reply.code(500).send({ error: 'Error al crear alerta' });
    }
  });

  // GET /api/alertas - Obtener todas las alertas con filtros
  fastify.get('/alertas', async (request, reply) => {
    const { id_instalacion, id_sensor_instalado } = request.query;
    
    try {
      let query = `
        SELECT a.*, 
          i.nombre_instalacion,
          si.descripcion as sensor_descripcion
        FROM alertas a
        LEFT JOIN instalacion i ON a.id_instalacion = i.id_instalacion
        LEFT JOIN sensor_instalado si ON a.id_sensor_instalado = si.id_sensor_instalado
        WHERE 1=1
      `;
      const params = [];
      
      if (id_instalacion) {
        query += ' AND a.id_instalacion = ?';
        params.push(id_instalacion);
      }
      
      if (id_sensor_instalado) {
        query += ' AND a.id_sensor_instalado = ?';
        params.push(id_sensor_instalado);
      }
      
      query += ' ORDER BY a.id_alertas DESC';
      
      const [rows] = await pool.query(query, params);
      return rows;
    } catch (error) {
      console.error('Error al obtener alertas:', error);
      return reply.code(500).send({ error: 'Error al obtener alertas' });
    }
  });

  // GET /api/alertas/:id - Obtener alerta por ID
  fastify.get('/alertas/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM alertas WHERE id_alertas = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Alerta no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener alerta:', error);
      return reply.code(500).send({ error: 'Error al obtener alerta' });
    }
  });

  // PUT /api/alertas/:id - Actualizar alerta
  fastify.put('/alertas/:id', async (request, reply) => {
    const { id } = request.params;
    const { descripcion, dato_puntual } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (descripcion !== undefined) {
        updates.push('descripcion = ?');
        values.push(descripcion);
      }
      if (dato_puntual !== undefined) {
        updates.push('dato_puntual = ?');
        values.push(dato_puntual);
      }
      
      if (updates.length === 0) {
        return reply.code(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE alertas SET ${updates.join(', ')} WHERE id_alertas = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM alertas WHERE id_alertas = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Alerta no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar alerta:', error);
      return reply.code(500).send({ error: 'Error al actualizar alerta' });
    }
  });

  // DELETE /api/alertas/:id - Eliminar alerta
  fastify.delete('/alertas/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM alertas WHERE id_alertas = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Alerta no encontrada' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar alerta:', error);
      return reply.code(500).send({ error: 'Error al eliminar alerta' });
    }
  });
}

module.exports = routes;


// Obtener alertas por sensor
router.get('/sensor/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 50 } = req.query;
    
    const alertas = await from('alertas')
      .select('*')
      .eq('id_sensor_instalado', id)
      .orderBy('id_alertas', 'DESC')
      .limit(limit)
      .execute();

    res.json(alertas);
  } catch (error) {
    console.error('Error al obtener alertas:', error);
    res.status(500).json({ error: 'Error al obtener alertas' });
  }
});

// Crear alerta
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { id_instalacion, id_sensor_instalado, descripcion, dato_puntual } = req.body;

    const nuevaAlerta = await insert('alertas', {
      id_instalacion,
      id_sensor_instalado,
      descripcion,
      dato_puntual
    }).execute();

    res.status(201).json(nuevaAlerta);
  } catch (error) {
    console.error('Error al crear alerta:', error);
    res.status(500).json({ error: 'Error al crear alerta' });
  }
});

// Eliminar alerta
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('alertas')
      .eq('id_alertas', id)
      .execute();
    
    res.json({ message: 'Alerta eliminada' });
  } catch (error) {
    console.error('Error al eliminar alerta:', error);
    res.status(500).json({ error: 'Error al eliminar alerta' });
  }
});

module.exports = router;
