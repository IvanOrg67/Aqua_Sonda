const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/instalaciones - Crear instalación
  fastify.post('/instalaciones', async (request, reply) => {
    const {
      id_organizacion_sucursal,
      nombre_instalacion,
      fecha_instalacion,
      estado_operativo,
      descripcion,
      tipo_uso,
      id_proceso
    } = request.body;
    
    try {
      const [result] = await pool.query(
        `INSERT INTO instalacion 
        (id_organizacion_sucursal, nombre_instalacion, fecha_instalacion, estado_operativo, descripcion, tipo_uso, id_proceso) 
        VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [id_organizacion_sucursal, nombre_instalacion, fecha_instalacion, estado_operativo, descripcion, tipo_uso, id_proceso]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM instalacion WHERE id_instalacion = ?',
        [result.insertId]
      );
      
      return reply.code(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear instalación:', error);
      return reply.code(500).send({ error: 'Error al crear instalación' });
    }
  });

  // GET /api/instalaciones - Obtener todas las instalaciones
  fastify.get('/instalaciones', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT i.*, 
          os.nombre_sucursal,
          o.nombre as organizacion_nombre,
          (SELECT COUNT(*) FROM sensor_instalado si WHERE si.id_instalacion = i.id_instalacion) as total_sensores
        FROM instalacion i
        LEFT JOIN organizacion_sucursal os ON i.id_organizacion_sucursal = os.id_organizacion_sucursal
        LEFT JOIN organizacion o ON os.id_organizacion = o.id_organizacion
        ORDER BY i.id_instalacion DESC
      `);
      
      return rows;
    } catch (error) {
      console.error('Error al obtener instalaciones:', error);
      return reply.code(500).send({ error: 'Error al obtener instalaciones' });
    }
  });

  // GET /api/instalaciones/:id - Obtener instalación por ID con sensores
  fastify.get('/instalaciones/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [instalaciones] = await pool.query(
        'SELECT * FROM instalacion WHERE id_instalacion = ?',
        [id]
      );
      
      if (instalaciones.length === 0) {
        return reply.code(404).send({ error: 'Instalación no encontrada' });
      }
      
      const [sensores] = await pool.query(`
        SELECT si.*, cs.sensor, cs.descripcion as sensor_descripcion, cs.unidad_medida
        FROM sensor_instalado si
        LEFT JOIN catalogo_sensores cs ON si.id_sensor = cs.id_sensor
        WHERE si.id_instalacion = ?
      `, [id]);
      
      return {
        ...instalaciones[0],
        sensores
      };
    } catch (error) {
      console.error('Error al obtener instalación:', error);
      return reply.code(500).send({ error: 'Error al obtener instalación' });
    }
  });

  // PUT /api/instalaciones/:id - Actualizar instalación
  fastify.put('/instalaciones/:id', async (request, reply) => {
    const { id } = request.params;
    const {
      nombre_instalacion,
      estado_operativo,
      descripcion,
      tipo_uso
    } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (nombre_instalacion !== undefined) {
        updates.push('nombre_instalacion = ?');
        values.push(nombre_instalacion);
      }
      if (estado_operativo !== undefined) {
        updates.push('estado_operativo = ?');
        values.push(estado_operativo);
      }
      if (descripcion !== undefined) {
        updates.push('descripcion = ?');
        values.push(descripcion);
      }
      if (tipo_uso !== undefined) {
        updates.push('tipo_uso = ?');
        values.push(tipo_uso);
      }
      
      if (updates.length === 0) {
        return reply.code(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE instalacion SET ${updates.join(', ')} WHERE id_instalacion = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM instalacion WHERE id_instalacion = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.code(404).send({ error: 'Instalación no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar instalación:', error);
      return reply.code(500).send({ error: 'Error al actualizar instalación' });
    }
  });

  // DELETE /api/instalaciones/:id - Eliminar instalación
  fastify.delete('/instalaciones/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM instalacion WHERE id_instalacion = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.code(404).send({ error: 'Instalación no encontrada' });
      }
      
      return reply.code(204).send();
    } catch (error) {
      console.error('Error al eliminar instalación:', error);
      return reply.code(500).send({ error: 'Error al eliminar instalación' });
    }
  });
}

module.exports = routes;


// Listar sucursales (DEBE IR PRIMERO antes del /:id)
router.get('/sucursales', authMiddleware, async (req, res) => {
  try {
    const sucursales = await from('organizacion_sucursal')
      .select(`
        organizacion_sucursal.id_organizacion_sucursal,
        organizacion_sucursal.nombre_sucursal,
        organizacion.nombre as organizacion_nombre
      `)
      .leftJoin('organizacion', 'organizacion_sucursal.id_organizacion = organizacion.id_organizacion')
      .eq('organizacion_sucursal.estado', 'activa')
      .orderBy('organizacion.nombre')
      .execute();

    res.json(sucursales);
  } catch (error) {
    console.error('Error al listar sucursales:', error);
    res.status(500).json({ error: 'Error al obtener sucursales' });
  }
});

// Listar instalaciones
router.get('/', authMiddleware, async (req, res) => {
  try {
    const instalaciones = await from('instalacion')
      .select(`
        instalacion.id_instalacion,
        instalacion.id_organizacion_sucursal,
        instalacion.nombre_instalacion,
        instalacion.descripcion,
        instalacion.fecha_instalacion,
        organizacion_sucursal.nombre_sucursal,
        organizacion.nombre as organizacion_nombre
      `)
      .leftJoin('organizacion_sucursal', 'instalacion.id_organizacion_sucursal = organizacion_sucursal.id_organizacion_sucursal')
      .leftJoin('organizacion', 'organizacion_sucursal.id_organizacion = organizacion.id_organizacion')
      .orderBy('instalacion.id_instalacion', 'DESC')
      .execute();

    res.json(instalaciones);
  } catch (error) {
    console.error('Error al listar instalaciones:', error);
    res.status(500).json({ error: 'Error al obtener instalaciones' });
  }
});

// Obtener una instalación
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const instalacion = await from('instalacion')
      .select(`
        instalacion.*,
        organizacion_sucursal.nombre_sucursal,
        organizacion.nombre as organizacion_nombre
      `)
      .leftJoin('organizacion_sucursal', 'instalacion.id_organizacion_sucursal = organizacion_sucursal.id_organizacion_sucursal')
      .leftJoin('organizacion', 'organizacion_sucursal.id_organizacion = organizacion.id_organizacion')
      .eq('instalacion.id_instalacion', id)
      .single();

    if (!instalacion) {
      return res.status(404).json({ error: 'Instalación no encontrada' });
    }

    res.json(instalacion);
  } catch (error) {
    console.error('Error al obtener instalación:', error);
    res.status(500).json({ error: 'Error al obtener instalación' });
  }
});

// Crear instalación
router.post('/', authMiddleware, async (req, res) => {
  try {
    const {
      id_organizacion_sucursal = 1,
      nombre_instalacion,
      descripcion = ''
    } = req.body;

    const nuevaInstalacion = await insert('instalacion', {
      id_organizacion_sucursal,
      nombre_instalacion,
      fecha_instalacion: new Date().toISOString().split('T')[0],
      descripcion
    }).execute();

    res.status(201).json(nuevaInstalacion);
  } catch (error) {
    console.error('Error al crear instalación:', error);
    res.status(500).json({ error: 'Error al crear instalación' });
  }
});

// Eliminar instalación
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('instalacion')
      .eq('id_instalacion', id)
      .execute();
    
    res.json({ message: 'Instalación eliminada' });
  } catch (error) {
    console.error('Error al eliminar instalación:', error);
    res.status(500).json({ error: 'Error al eliminar instalación' });
  }
});

// Obtener sensores de una instalación
router.get('/:id/sensores', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const sensores = await from('sensor_instalado')
      .select(`
        sensor_instalado.id_sensor_instalado as id,
        sensor_instalado.descripcion,
        sensor_instalado.fecha_instalada as fecha_instalacion,
        catalogo_sensores.sensor as nombre_sensor,
        catalogo_sensores.sensor as tipo_sensor,
        catalogo_sensores.unidad_medida as unidad,
        'activo' as estado
      `)
      .innerJoin('catalogo_sensores', 'sensor_instalado.id_sensor = catalogo_sensores.id_sensor')
      .eq('sensor_instalado.id_instalacion', id)
      .orderBy('sensor_instalado.id_sensor_instalado', 'DESC')
      .execute();

    res.json(sensores);
  } catch (error) {
    console.error('Error al obtener sensores:', error);
    res.status(500).json({ error: 'Error al obtener sensores' });
  }
});

// Instalar sensor en instalación
router.post('/:id/sensores', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { id_sensor, alias, descripcion } = req.body;

    const nuevoSensor = await insert('sensor_instalado', {
      id_instalacion: id,
      id_sensor,
      fecha_instalada: new Date().toISOString().split('T')[0],
      descripcion: descripcion || alias || ''
    }).execute();

    res.status(201).json(nuevoSensor);
  } catch (error) {
    console.error('Error al instalar sensor:', error);
    res.status(500).json({ error: 'Error al instalar sensor' });
  }
});

// Obtener alertas de una instalación
router.get('/:id/alertas', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 50 } = req.query;
    
    const alertas = await from('alertas')
      .select(`
        alertas.*,
        sensor_instalado.descripcion as sensor_descripcion,
        catalogo_sensores.sensor as sensor_nombre
      `)
      .innerJoin('sensor_instalado', 'alertas.id_sensor_instalado = sensor_instalado.id_sensor_instalado')
      .innerJoin('catalogo_sensores', 'sensor_instalado.id_sensor = catalogo_sensores.id_sensor')
      .eq('alertas.id_instalacion', id)
      .orderBy('alertas.id_alertas', 'DESC')
      .limit(limit)
      .execute();

    res.json(alertas);
  } catch (error) {
    console.error('Error al obtener alertas:', error);
    res.status(500).json({ error: 'Error al obtener alertas' });
  }
});

module.exports = router;
