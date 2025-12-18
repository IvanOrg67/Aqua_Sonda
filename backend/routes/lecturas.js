const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // GET /api/lecturas - Obtener lecturas con filtros
  fastify.get('/lecturas', async (request, reply) => {
    const { sensorInstaladoId, from, to, limit = 500 } = request.query;
    
    if (!sensorInstaladoId) {
      return reply.code(400).send({ error: 'sensorInstaladoId es requerido' });
    }
    
    try {
      let query = `
        SELECT 
          l.id_lectura,
          l.id_sensor_instalado,
          l.valor,
          CONCAT(l.fecha, 'T', l.hora, 'Z') as tomada_en,
          l.fecha,
          l.hora
        FROM lectura l
        WHERE l.id_sensor_instalado = ?
      `;
      const params = [sensorInstaladoId];
      
      if (from) {
        query += ' AND CONCAT(l.fecha, " ", l.hora) >= ?';
        params.push(new Date(from).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      if (to) {
        query += ' AND CONCAT(l.fecha, " ", l.hora) <= ?';
        params.push(new Date(to).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      query += ' ORDER BY l.fecha DESC, l.hora DESC LIMIT ?';
      params.push(Math.min(parseInt(limit), 5000));
      
      const [rows] = await pool.query(query, params);
      return rows;
    } catch (error) {
      console.error('Error al obtener lecturas:', error);
      return reply.code(500).send({ error: 'Error al obtener lecturas' });
    }
  });

  // GET /api/resumen-horario - Obtener resúmenes horarios
  fastify.get('/resumen-horario', async (request, reply) => {
    const { sensorInstaladoId, from, to } = request.query;
    
    if (!sensorInstaladoId) {
      return reply.code(400).send({ error: 'sensorInstaladoId es requerido' });
    }
    
    try {
      let query = `
        SELECT 
          r.id_resumen,
          r.id_sensor_instalado,
          r.promedio,
          r.registros,
          CONCAT(r.fecha, 'T', r.hora, 'Z') as fecha_hora,
          r.fecha,
          r.hora
        FROM resumen_lectura_horaria r
        WHERE r.id_sensor_instalado = ?
      `;
      const params = [sensorInstaladoId];
      
      if (from) {
        query += ' AND CONCAT(r.fecha, " ", r.hora) >= ?';
        params.push(new Date(from).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      if (to) {
        query += ' AND CONCAT(r.fecha, " ", r.hora) <= ?';
        params.push(new Date(to).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      query += ' ORDER BY r.fecha DESC, r.hora DESC';
      
      const [rows] = await pool.query(query, params);
      return rows;
    } catch (error) {
      console.error('Error al obtener resúmenes horarios:', error);
      return reply.code(500).send({ error: 'Error al obtener resúmenes horarios' });
    }
  });

  // GET /api/promedios - Obtener promedios con granularidad
  fastify.get('/promedios', async (request, reply) => {
    const { granularity, sensorInstaladoId, from, to } = request.query;
    
    if (!granularity || !sensorInstaladoId) {
      return reply.code(400).send({ error: 'granularity y sensorInstaladoId son requeridos' });
    }
    
    if (!['15min', 'hour'].includes(granularity)) {
      return reply.code(400).send({ error: 'granularity debe ser "15min" o "hour"' });
    }
    
    try {
      let dateFormat;
      if (granularity === '15min') {
        // Agrupar por intervalos de 15 minutos
        dateFormat = `DATE_FORMAT(CONCAT(fecha, ' ', hora), '%Y-%m-%d %H:') || LPAD((FLOOR(MINUTE(CONCAT(fecha, ' ', hora)) / 15) * 15), 2, '0') || ':00'`;
      } else {
        // Agrupar por hora
        dateFormat = `DATE_FORMAT(CONCAT(fecha, ' ', hora), '%Y-%m-%d %H:00:00')`;
      }
      
      let query = `
        SELECT 
          id_sensor_instalado,
          ${dateFormat} as timestamp,
          AVG(valor) as promedio
        FROM lectura
        WHERE id_sensor_instalado = ?
      `;
      const params = [sensorInstaladoId];
      
      if (from) {
        query += ' AND CONCAT(fecha, " ", hora) >= ?';
        params.push(new Date(from).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      if (to) {
        query += ' AND CONCAT(fecha, " ", hora) <= ?';
        params.push(new Date(to).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      query += ' GROUP BY id_sensor_instalado, timestamp ORDER BY timestamp DESC';
      
      const [rows] = await pool.query(query, params);
      return rows;
    } catch (error) {
      console.error('Error al obtener promedios:', error);
      return reply.code(500).send({ error: 'Error al obtener promedios' });
    }
  });

  // GET /api/reportes/xml - Generar reporte XML
  fastify.get('/reportes/xml', async (request, reply) => {
    const { sensorInstaladoId, from, to } = request.query;
    
    if (!sensorInstaladoId) {
      return reply.code(400).send({ error: 'sensorInstaladoId es requerido' });
    }
    
    try {
      let query = `
        SELECT 
          l.valor,
          CONCAT(l.fecha, 'T', l.hora, 'Z') as timestamp
        FROM lectura l
        WHERE l.id_sensor_instalado = ?
      `;
      const params = [sensorInstaladoId];
      
      if (from) {
        query += ' AND CONCAT(l.fecha, " ", l.hora) >= ?';
        params.push(new Date(from).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      if (to) {
        query += ' AND CONCAT(l.fecha, " ", l.hora) <= ?';
        params.push(new Date(to).toISOString().replace('T', ' ').replace('Z', ''));
      }
      
      query += ' ORDER BY l.fecha, l.hora';
      
      const [lecturas] = await pool.query(query, params);
      
      // Calcular promedio
      const promedio = lecturas.length > 0 
        ? lecturas.reduce((sum, l) => sum + parseFloat(l.valor), 0) / lecturas.length
        : 0;
      
      // Generar XML
      let xml = '<?xml version="1.0"?>\n<reporte>\n';
      xml += `  <fecha>${new Date().toISOString()}</fecha>\n`;
      xml += '  <sensores>\n';
      xml += `    <sensor id="${sensorInstaladoId}">\n`;
      xml += `      <promedio>${promedio.toFixed(6)}</promedio>\n`;
      xml += '      <lecturas>\n';
      
      for (const lectura of lecturas) {
        xml += `        <lectura timestamp="${lectura.timestamp}">\n`;
        xml += `          <valor>${lectura.valor}</valor>\n`;
        xml += '        </lectura>\n';
      }
      
      xml += '      </lecturas>\n';
      xml += '    </sensor>\n';
      xml += '  </sensores>\n';
      xml += '</reporte>';
      
      reply.header('Content-Type', 'application/xml');
      return xml;
    } catch (error) {
      console.error('Error al generar reporte XML:', error);
      return reply.code(500).send({ error: 'Error al generar reporte XML' });
    }
  });
}

module.exports = routes;


// Obtener lecturas de un sensor
router.get('/sensor/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { limit = 100, fecha_desde, fecha_hasta } = req.query;
    
    let query = from('lectura')
      .select('*')
      .eq('id_sensor_instalado', id)
      .orderBy('fecha', 'DESC');
    
    if (fecha_desde) {
      query = query.gte('fecha', fecha_desde);
    }
    
    if (fecha_hasta) {
      query = query.lte('fecha', fecha_hasta);
    }
    
    const lecturas = await query.limit(limit).execute();
    
    res.json(lecturas);
  } catch (error) {
    console.error('Error al obtener lecturas:', error);
    res.status(500).json({ error: 'Error al obtener lecturas' });
  }
});

// Crear lectura manual
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { id_sensor_instalado, dato_puntual, fecha, hora } = req.body;
    
    const now = new Date();
    const nuevaLectura = await insert('lectura', {
      id_sensor_instalado,
      dato_puntual,
      fecha: fecha || now.toISOString().split('T')[0],
      hora: hora || now.toTimeString().split(' ')[0]
    }).execute();
    
    res.status(201).json(nuevaLectura);
  } catch (error) {
    console.error('Error al crear lectura:', error);
    res.status(500).json({ error: 'Error al crear lectura' });
  }
});

// Obtener estadísticas de un sensor
router.get('/sensor/:id/stats', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { dias = 7 } = req.query;
    
    const db = require('../config/database');
    const result = await db.query(`
      SELECT 
        COUNT(*) as total_lecturas,
        AVG(dato_puntual) as promedio,
        MIN(dato_puntual) as minimo,
        MAX(dato_puntual) as maximo,
        STDDEV(dato_puntual) as desviacion_estandar
      FROM lectura
      WHERE id_sensor_instalado = $1
        AND fecha >= CURRENT_DATE - INTERVAL '${parseInt(dias)} days'
    `, [id]);
    
    res.json(result.rows[0] || {});
  } catch (error) {
    console.error('Error al obtener estadísticas:', error);
    res.status(500).json({ error: 'Error al obtener estadísticas' });
  }
});

// Eliminar lectura
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('lectura')
      .eq('id_lectura', id)
      .execute();
    
    res.json({ message: 'Lectura eliminada' });
  } catch (error) {
    console.error('Error al eliminar lectura:', error);
    res.status(500).json({ error: 'Error al eliminar lectura' });
  }
});

module.exports = router;
