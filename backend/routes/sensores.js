const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // ===== CATÁLOGO DE SENSORES =====
  
  // POST /api/catalogo-sensores - Crear sensor en catálogo
  fastify.post('/catalogo-sensores', async (request, reply) => {
    const { sensor, descripcion, modelo, marca, rango_medicion, unidad_medida } = request.body;
    
    try {
      const [result] = await pool.query(
        `INSERT INTO catalogo_sensores (sensor, descripcion, modelo, marca, rango_medicion, unidad_medida) 
        VALUES (?, ?, ?, ?, ?, ?)`,
        [sensor, descripcion, modelo, marca, rango_medicion, unidad_medida]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM catalogo_sensores WHERE id_sensor = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear sensor en catálogo:', error);
      return reply.code(500).send({ error: 'Error al crear sensor en catálogo' });
    }
  });

  // GET /api/catalogo-sensores - Obtener todos los sensores del catálogo
  fastify.get('/catalogo-sensores', async (request, reply) => {
    try {
      const [rows] = await pool.query('SELECT * FROM catalogo_sensores ORDER BY sensor');
      return rows;
    } catch (error) {
      console.error('Error al obtener catálogo de sensores:', error);
      return reply.code(500).send({ error: 'Error al obtener catálogo de sensores' });
    }
  });

  // GET /api/catalogo-sensores/:id - Obtener sensor del catálogo por ID
  fastify.get('/catalogo-sensores/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM catalogo_sensores WHERE id_sensor = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sensor no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener sensor:', error);
      return reply.code(500).send({ error: 'Error al obtener sensor' });
    }
  });

  // PUT /api/catalogo-sensores/:id - Actualizar sensor del catálogo
  fastify.put('/catalogo-sensores/:id', async (request, reply) => {
    const { id } = request.params;
    const { sensor, descripcion, modelo, marca, rango_medicion, unidad_medida } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (sensor !== undefined) {
        updates.push('sensor = ?');
        values.push(sensor);
      }
      if (descripcion !== undefined) {
        updates.push('descripcion = ?');
        values.push(descripcion);
      }
      if (modelo !== undefined) {
        updates.push('modelo = ?');
        values.push(modelo);
      }
      if (marca !== undefined) {
        updates.push('marca = ?');
        values.push(marca);
      }
      if (rango_medicion !== undefined) {
        updates.push('rango_medicion = ?');
        values.push(rango_medicion);
      }
      if (unidad_medida !== undefined) {
        updates.push('unidad_medida = ?');
        values.push(unidad_medida);
      }
      
      if (updates.length === 0) {
        return reply.code(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE catalogo_sensores SET ${updates.join(', ')} WHERE id_sensor = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM catalogo_sensores WHERE id_sensor = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sensor no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar sensor:', error);
      return reply.code(500).send({ error: 'Error al actualizar sensor' });
    }
  });

  // DELETE /api/catalogo-sensores/:id - Eliminar sensor del catálogo
  fastify.delete('/catalogo-sensores/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM catalogo_sensores WHERE id_sensor = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Sensor no encontrado' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar sensor:', error);
      return reply.code(500).send({ error: 'Error al eliminar sensor' });
    }
  });

  // ===== SENSORES INSTALADOS =====
  
  // POST /api/sensores-instalados - Crear sensor instalado
  fastify.post('/sensores-instalados', async (request, reply) => {
    const { id_instalacion, id_sensor, fecha_instalada, descripcion } = request.body;
    
    try {
      const [result] = await pool.query(
        `INSERT INTO sensor_instalado (id_instalacion, id_sensor, fecha_instalada, descripcion) 
        VALUES (?, ?, ?, ?)`,
        [id_instalacion, id_sensor, fecha_instalada, descripcion]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM sensor_instalado WHERE id_sensor_instalado = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al instalar sensor:', error);
      return reply.code(500).send({ error: 'Error al instalar sensor' });
    }
  });

  // GET /api/sensores-instalados - Obtener todos los sensores instalados
  fastify.get('/sensores-instalados', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT si.*, 
          i.nombre_instalacion,
          cs.sensor, cs.descripcion as sensor_descripcion, cs.unidad_medida
        FROM sensor_instalado si
        LEFT JOIN instalacion i ON si.id_instalacion = i.id_instalacion
        LEFT JOIN catalogo_sensores cs ON si.id_sensor = cs.id_sensor
        ORDER BY si.id_sensor_instalado DESC
      `);
      
      return rows;
    } catch (error) {
      console.error('Error al obtener sensores instalados:', error);
      return reply.code(500).send({ error: 'Error al obtener sensores instalados' });
    }
  });

  // GET /api/sensores-instalados/:id - Obtener sensor instalado por ID
  fastify.get('/sensores-instalados/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(`
        SELECT si.*, 
          i.nombre_instalacion,
          cs.sensor, cs.descripcion as sensor_descripcion, cs.unidad_medida
        FROM sensor_instalado si
        LEFT JOIN instalacion i ON si.id_instalacion = i.id_instalacion
        LEFT JOIN catalogo_sensores cs ON si.id_sensor = cs.id_sensor
        WHERE si.id_sensor_instalado = ?
      `, [id]);
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sensor instalado no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener sensor instalado:', error);
      return reply.code(500).send({ error: 'Error al obtener sensor instalado' });
    }
  });

  // PUT /api/sensores-instalados/:id - Actualizar sensor instalado
  fastify.put('/sensores-instalados/:id', async (request, reply) => {
    const { id } = request.params;
    const { descripcion } = request.body;
    
    try {
      if (descripcion === undefined) {
        return reply.code(400).send({ error: 'No hay datos para actualizar' });
      }
      
      await pool.query(
        'UPDATE sensor_instalado SET descripcion = ? WHERE id_sensor_instalado = ?',
        [descripcion, id]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM sensor_instalado WHERE id_sensor_instalado = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Sensor instalado no encontrado' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar sensor instalado:', error);
      return reply.code(500).send({ error: 'Error al actualizar sensor instalado' });
    }
  });

  // DELETE /api/sensores-instalados/:id - Eliminar sensor instalado
  fastify.delete('/sensores-instalados/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM sensor_instalado WHERE id_sensor_instalado = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Sensor instalado no encontrado' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar sensor instalado:', error);
      return reply.code(500).send({ error: 'Error al eliminar sensor instalado' });
    }
  });
}

module.exports = routes;


// Obtener catálogo de sensores
router.get('/catalogo', authMiddleware, async (req, res) => {
  try {
    const sensores = await from('catalogo_sensores')
      .select(`
        id_sensor,
        sensor as nombre,
        unidad_medida as unidad,
        sensor as tipo_medida,
        rango_medicion
      `)
      .orderBy('sensor')
      .execute();

    res.json(sensores);
  } catch (error) {
    console.error('Error al obtener catálogo:', error);
    res.status(500).json({ error: 'Error al obtener catálogo de sensores' });
  }
});

// Crear tipo de sensor en catálogo
router.post('/catalogo', authMiddleware, async (req, res) => {
  try {
    const { nombre, unidad, descripcion, rango_min, rango_max } = req.body;

    const rango_medicion = (rango_min && rango_max) 
      ? `${rango_min} - ${rango_max}` 
      : null;

    const nuevoSensor = await insert('catalogo_sensores', {
      sensor: nombre,
      descripcion: descripcion || '',
      unidad_medida: unidad,
      rango_medicion
    }).execute();

    res.status(201).json(nuevoSensor);
  } catch (error) {
    console.error('Error al crear sensor en catálogo:', error);
    res.status(500).json({ error: 'Error al crear sensor' });
  }
});

// Desinstalar sensor
router.delete('/instalados/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('sensor_instalado')
      .eq('id_sensor_instalado', id)
      .execute();
    
    res.json({ message: 'Sensor desinstalado correctamente' });
  } catch (error) {
    console.error('Error al desinstalar sensor:', error);
    res.status(500).json({ error: 'Error al desinstalar sensor' });
  }
});

// Obtener lecturas de un sensor
router.get('/:id/lecturas', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 50 } = req.query;
    
    const lecturas = await from('lectura')
      .select('*')
      .eq('id_sensor_instalado', id)
      .orderBy('fecha', 'DESC')
      .limit(limit)
      .execute();

    res.json(lecturas);
  } catch (error) {
    console.error('Error al obtener lecturas:', error);
    res.status(500).json({ error: 'Error al obtener lecturas' });
  }
});

// Enviar lectura manual
router.post('/:id/lecturas', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { valor, timestamp } = req.body;

    const date = timestamp ? new Date(timestamp) : new Date();
    const fecha = date.toISOString().split('T')[0];
    const hora = date.toTimeString().split(' ')[0];

    const result = await db.query(`
      INSERT INTO lectura (
        id_sensor_instalado,
        valor,
        fecha,
        hora
      ) VALUES ($1, $2, $3, $4)
      RETURNING *
    `, [id, valor, fecha, hora]);

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error al enviar lectura:', error);
    res.status(500).json({ error: 'Error al registrar lectura' });
  }
});

module.exports = router;
