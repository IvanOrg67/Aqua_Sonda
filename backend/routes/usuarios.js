const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/usuarios - Crear usuario
  fastify.post('/usuarios', async (request, reply) => {
    const { id_rol, nombre_completo, correo, telefono, password, password_hash, estado } = request.body;
    
    try {
      // Si viene password, hashearlo. Si viene password_hash, usarlo directamente (para compatibilidad)
      let finalPasswordHash;
      
      if (password) {
        // Hashear password con bcrypt
        const bcrypt = require('bcrypt');
        finalPasswordHash = await bcrypt.hash(password, 10);
      } else if (password_hash) {
        finalPasswordHash = password_hash;
      } else {
        return reply.status(400).send({ error: 'Se requiere password o password_hash' });
      }
      
      // Verificar si el correo ya existe
      const [existing] = await pool.query(
        'SELECT id_usuario FROM usuario WHERE correo = ?',
        [correo.toLowerCase().trim()]
      );
      
      if (existing.length > 0) {
        return reply.status(400).send({ error: 'El correo ya está registrado' });
      }
      
      const [result] = await pool.query(
        `INSERT INTO usuario (id_rol, nombre_completo, correo, telefono, password_hash, estado) 
        VALUES (?, ?, ?, ?, ?, ?)`,
        [id_rol || 2, nombre_completo.trim(), correo.toLowerCase().trim(), telefono?.trim() || null, finalPasswordHash, estado || 'activo']
      );
      
      const [rows] = await pool.query(
        `SELECT u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
         FROM usuario u
         LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol
         WHERE u.id_usuario = ?`,
        [result.insertId]
      );
      
      const usuario = rows[0];
      const { password_hash, ...usuarioSinPassword } = usuario;
      
      // Formatear respuesta igual que la web (incluir tipo_rol como objeto)
      const usuarioFormateado = {
        ...usuarioSinPassword,
        tipo_rol: usuario.rol_nombre ? {
          id_rol: usuario.tipo_rol_id,
          nombre: usuario.rol_nombre
        } : null
      };
      
      return reply.status(201).send(usuarioFormateado);
    } catch (error) {
      console.error('Error al crear usuario:', error);
      return reply.status(500).send({ error: 'Error al crear usuario' });
    }
  });

  // GET /api/usuarios - Obtener todos los usuarios (sin password_hash)
  // Soporta query param ?correo=... para buscar por correo
  fastify.get('/usuarios', async (request, reply) => {
    try {
      const { correo } = request.query;
      
      let query = `
        SELECT 
          u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
        FROM usuario u
        LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol
      `;
      
      const params = [];
      
      if (correo) {
        query += ' WHERE u.correo = ?';
        params.push(correo.toLowerCase().trim());
      }
      
      query += ' ORDER BY u.id_usuario DESC';
      
      const [rows] = await pool.query(query, params);
      
      // Formatear respuestas igual que la web (incluir tipo_rol como objeto)
      const usuariosFormateados = rows.map(usuario => {
        const { password_hash, ...usuarioSinPassword } = usuario;
        return {
          ...usuarioSinPassword,
          tipo_rol: usuario.rol_nombre ? {
            id_rol: usuario.tipo_rol_id,
            nombre: usuario.rol_nombre
          } : null
        };
      });
      
      // Si se busca por correo y hay resultados, devolver solo el primero
      if (correo && usuariosFormateados.length > 0) {
        return usuariosFormateados[0];
      }
      
      return usuariosFormateados;
    } catch (error) {
      console.error('Error al obtener usuarios:', error);
      return reply.status(500).send({ error: 'Error al obtener usuarios' });
    }
  });

  // GET /api/usuarios/:id - Obtener usuario por ID
  fastify.get('/usuarios/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [rows] = await pool.query(
        `SELECT u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
         FROM usuario u
         LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol
         WHERE u.id_usuario = ?`,
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Usuario no encontrado' });
      }
      
      const usuario = rows[0];
      const { password_hash, ...usuarioSinPassword } = usuario;
      
      // Formatear respuesta igual que la web (incluir tipo_rol como objeto)
      const usuarioFormateado = {
        ...usuarioSinPassword,
        tipo_rol: usuario.rol_nombre ? {
          id_rol: usuario.tipo_rol_id,
          nombre: usuario.rol_nombre
        } : null
      };
      
      return reply.send(usuarioFormateado);
    } catch (error) {
      console.error('Error al obtener usuario:', error);
      return reply.status(500).send({ error: 'Error al obtener usuario' });
    }
  });

  // PUT /api/usuarios/:id - Actualizar usuario
  fastify.put('/usuarios/:id', async (request, reply) => {
    const { id } = request.params;
    const { nombre_completo, correo, telefono, estado, password_hash } = request.body;
    
    try {
      const updates = [];
      const values = [];
      
      if (nombre_completo !== undefined) {
        updates.push('nombre_completo = ?');
        values.push(nombre_completo);
      }
      if (correo !== undefined) {
        updates.push('correo = ?');
        values.push(correo);
      }
      if (telefono !== undefined) {
        updates.push('telefono = ?');
        values.push(telefono);
      }
      if (estado !== undefined) {
        updates.push('estado = ?');
        values.push(estado);
      }
      if (password_hash !== undefined) {
        updates.push('password_hash = ?');
        values.push(password_hash);
      }
      
      if (updates.length === 0) {
        return reply.status(400).send({ error: 'No hay datos para actualizar' });
      }
      
      values.push(id);
      
      await pool.query(
        `UPDATE usuario SET ${updates.join(', ')} WHERE id_usuario = ?`,
        values
      );
      
      const [rows] = await pool.query(
        `SELECT u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
         FROM usuario u
         LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol
         WHERE u.id_usuario = ?`,
        [id]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Usuario no encontrado' });
      }
      
      const usuario = rows[0];
      const { password_hash, ...usuarioSinPassword } = usuario;
      
      // Formatear respuesta igual que la web (incluir tipo_rol como objeto)
      const usuarioFormateado = {
        ...usuarioSinPassword,
        tipo_rol: usuario.rol_nombre ? {
          id_rol: usuario.tipo_rol_id,
          nombre: usuario.rol_nombre
        } : null
      };
      
      return reply.send(usuarioFormateado);
    } catch (error) {
      console.error('Error al actualizar usuario:', error);
      return reply.status(500).send({ error: 'Error al actualizar usuario' });
    }
  });

  // DELETE /api/usuarios/:id - Eliminar usuario
  fastify.delete('/usuarios/:id', async (request, reply) => {
    const { id } = request.params;
    
    try {
      const [result] = await pool.query(
        'DELETE FROM usuario WHERE id_usuario = ?',
        [id]
      );
      
      if (result.affectedRows === 0) {
        return reply.status(404).send({ error: 'Usuario no encontrado' });
      }
      
      return reply.status(204).send();
    } catch (error) {
      console.error('Error al eliminar usuario:', error);
      return reply.status(500).send({ error: 'Error al eliminar usuario' });
    }
  });
}

module.exports = routes;
