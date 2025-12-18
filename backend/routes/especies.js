const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // ===== CATÁLOGO DE ESPECIES =====
  
  // POST /api/catalogo-especies - Crear especie en catálogo
  fastify.post('/catalogo-especies', async (request, reply) => {
    const { nombre } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO especies (nombre) VALUES (?)',
        [nombre]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM especies WHERE id_especie = ?',
        [result.insertId]
      );
      
      return reply.status(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear especie:', error);
      return reply.status(500).send({ error: 'Error al crear especie' });
    }
  });

  // GET /api/catalogo-especies - Obtener todas las especies del catálogo
  fastify.get('/catalogo-especies', async (request, reply) => {
    try {
      const [rows] = await pool.query('SELECT * FROM especies ORDER BY nombre');
      return rows;
    } catch (error) {
      console.error('Error al obtener especies:', error);
      return reply.status(500).send({ error: 'Error al obtener especies' });
    }
  });

  // GET /api/catalogo-especies/:id - Obtener especie del catálogo por ID
  fastify.get('/catalogo-especies/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM especies WHERE id_especie = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Especie no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener especie:', error);
      return reply.status(500).send({ error: 'Error al obtener especie' });
    }
  });

  // PUT /api/catalogo-especies/:id - Actualizar especie del catálogo
  fastify.put('/catalogo-especies/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre } = request.body;
    
    try {
      if (nombre === undefined) {
        return reply.status(400).send({ error: 'El nombre es requerido' });
      }
      
      await pool.query(
        'UPDATE especies SET nombre = ? WHERE id_especie = ?',
        [nombre, id]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM especies WHERE id_especie = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Especie no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar especie:', error);
      return reply.status(500).send({ error: 'Error al actualizar especie' });
    }
  });

  // DELETE /api/catalogo-especies/:id - Eliminar especie del catálogo
  fastify.delete('/catalogo-especies/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM especies WHERE id_especie = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Especie no encontrada' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar especie:', error);
      return reply.status(500).send({ error: 'Error al eliminar especie' });
    }
  });

  // ===== ESPECIES PARÁMETROS =====
  
  // POST /api/catalogo-especies/parametros - Crear relación especie-parámetro (alias para compatibilidad con app)
  fastify.post('/catalogo-especies/parametros', async (request, reply) => {
    const { id_especie, id_parametro, Rmax, Rmin } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO especie_parametro (id_especie, id_parametro, Rmax, Rmin) VALUES (?, ?, ?, ?)',
        [id_especie, id_parametro, Rmax, Rmin]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM especie_parametro WHERE id_especie_parametro = ?',
        [result.insertId]
      );
      
      return reply.status(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear relación especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al crear relación especie-parámetro' });
    }
  });

  // GET /api/catalogo-especies/parametros - Obtener relaciones especie-parámetro (alias para compatibilidad con app)
  fastify.get('/catalogo-especies/parametros', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT ep.*, 
          e.nombre as especie_nombre,
          p.nombre_parametro, p.unidad_medida
        FROM especie_parametro ep
        LEFT JOIN especies e ON ep.id_especie = e.id_especie
        LEFT JOIN parametros p ON ep.id_parametro = p.id_parametro
        ORDER BY ep.id_especie_parametro
      `);
      return rows;
    } catch (error) {
      console.error('Error al obtener relaciones especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al obtener relaciones especie-parámetro' });
    }
  });
  
  // POST /api/especies-parametros - Crear relación especie-parámetro
  fastify.post('/especies-parametros', async (request, reply) => {
    const { id_especie, id_parametro, Rmax, Rmin } = request.body;
    
    try {
      const [result] = await pool.query(
        'INSERT INTO especie_parametro (id_especie, id_parametro, Rmax, Rmin) VALUES (?, ?, ?, ?)',
        [id_especie, id_parametro, Rmax, Rmin]
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM especie_parametro WHERE id_especie_parametro = ?',
        [result.insertId]
      );
      
      return reply.status(201).send(rows[0]);
    } catch (error) {
      console.error('Error al crear relación especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al crear relación especie-parámetro' });
    }
  });

  // GET /api/especies-parametros - Obtener todas las relaciones especie-parámetro
  fastify.get('/especies-parametros', async (request, reply) => {
    try {
      const [rows] = await pool.query(`
        SELECT ep.*, 
          e.nombre as especie_nombre,
          p.nombre_parametro, p.unidad_medida
        FROM especie_parametro ep
        LEFT JOIN especies e ON ep.id_especie = e.id_especie
        LEFT JOIN parametros p ON ep.id_parametro = p.id_parametro
        ORDER BY ep.id_especie_parametro
      `);
      return rows;
    } catch (error) {
      console.error('Error al obtener relaciones especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al obtener relaciones especie-parámetro' });
    }
  });

  // GET /api/especies-parametros/:id - Obtener relación especie-parámetro por ID
  fastify.get('/especies-parametros/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        'SELECT * FROM especie_parametro WHERE id_especie_parametro = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Relación especie-parámetro no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al obtener relación especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al obtener relación especie-parámetro' });
    }
  });

  // PUT /api/especies-parametros/:id - Actualizar relación especie-parámetro
  fastify.put('/especies-parametros/:id', async (request, reply) => {
    const { id } = request.params;
    const { Rmax, Rmin } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (Rmax !== undefined) {
        updates.push('Rmax = ?');
        values.push(Rmax);
      }
      if (Rmin !== undefined) {
        updates.push('Rmin = ?');
        values.push(Rmin);
      }
      
      if (updates.length === 0) {
        return reply.status(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE especie_parametro SET ${updates.join(', ')} WHERE id_especie_parametro = ?`,
        values
      );
      
      const [rows] = await pool.query(
        'SELECT * FROM especie_parametro WHERE id_especie_parametro = ?',
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Relación especie-parámetro no encontrada' });
      }
      
      return rows[0];
    } catch (error) {
      console.error('Error al actualizar relación especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al actualizar relación especie-parámetro' });
    }
  });

  // DELETE /api/especies-parametros/:id - Eliminar relación especie-parámetro
  fastify.delete('/especies-parametros/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM especie_parametro WHERE id_especie_parametro = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Relación especie-parámetro no encontrada' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar relación especie-parámetro:', error);
      return reply.status(500).send({ error: 'Error al eliminar relación especie-parámetro' });
    }
  });
}

module.exports = routes;
