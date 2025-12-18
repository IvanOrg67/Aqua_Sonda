'use strict';

const bcrypt = require('bcrypt');
const { pool } = require('../config/database');

async function routes(fastify, options) {
  
  // POST /api/auth/register - Registrar nuevo usuario
  fastify.post('/auth/register', {
    schema: {
      body: {
        type: 'object',
        required: ['nombre_completo', 'correo', 'password'],
        properties: {
          nombre_completo: { type: 'string' },
          correo: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 6 },
          telefono: { type: 'string' },
          id_rol: { type: 'integer', default: 2 }
        }
      }
    }
  }, async (request, reply) => {
    const { nombre_completo, correo, password, telefono, id_rol = 2 } = request.body;
    
    try {
      // Verificar si el usuario ya existe
      const [existing] = await pool.query(
        'SELECT id_usuario FROM usuario WHERE correo = ?',
        [correo.toLowerCase().trim()]
      );
      
      if (existing.length > 0) {
        return reply.status(400).send({ error: 'El correo ya está registrado' });
      }
      
      // Hash del password
      const hashedPassword = await bcrypt.hash(password, 10);
      
      // Insertar usuario
      const [result] = await pool.query(
        `INSERT INTO usuario (id_rol, nombre_completo, correo, telefono, password_hash, estado) 
        VALUES (?, ?, ?, ?, ?, 'activo')`,
        [id_rol, nombre_completo.trim(), correo.toLowerCase().trim(), telefono?.trim() || null, hashedPassword]
      );
      
      // Obtener usuario creado con tipo_rol (igual estructura que la web)
      const [rows] = await pool.query(
        `SELECT u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
        FROM usuario u 
        LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol 
        WHERE u.id_usuario = ?`,
        [result.insertId]
      );
      
      const usuario = rows[0];
      
      // Generar token JWT usando Fastify JWT plugin (igual que la web)
      const token = request.server.jwt.sign({
        id: usuario.id_usuario,
        email: usuario.correo,
        role: usuario.rol_nombre || 'usuario'
      });
      
      // Retornar sin password_hash
      const { password_hash, ...userWithoutPassword } = usuario;
      
      // Formatear respuesta (mantener 'user' para compatibilidad con Flutter)
      const userFormateado = {
        ...userWithoutPassword,
        tipo_rol: usuario.rol_nombre ? {
          id_rol: usuario.tipo_rol_id,
          nombre: usuario.rol_nombre
        } : null
      };
      
      return reply.status(201).send({
        user: userFormateado,
        token
      });
    } catch (error) {
      console.error('Error en registro:', error);
      return reply.status(500).send({ error: 'Error al registrar usuario' });
    }
  });

  // POST /api/auth/login - Iniciar sesión (igual estructura que la web)
  fastify.post('/auth/login', {
    schema: {
      body: {
        type: 'object',
        required: ['correo', 'password'],
        properties: {
          correo: { type: 'string', format: 'email' },
          password: { type: 'string' }
        }
      }
    }
  }, async (request, reply) => {
    const { correo, password } = request.body;
    
    try {
      // Buscar usuario con tipo_rol (igual que la web con Prisma)
      const [rows] = await pool.query(
        `SELECT u.*, tr.nombre as rol_nombre, tr.id_rol as tipo_rol_id
        FROM usuario u 
        LEFT JOIN tipo_rol tr ON u.id_rol = tr.id_rol 
        WHERE u.correo = ?`,
        [correo.toLowerCase().trim()]
      );
      
      if (rows.length === 0) {
        return reply.status(401).send({ error: 'Credenciales inválidas' });
      }
      
      const usuario = rows[0];
      
      // Verificar password_hash existe
      if (!usuario.password_hash) {
        return reply.status(401).send({ error: 'Credenciales inválidas' });
      }
      
      // Verificar password (igual que la web)
      const valid = await bcrypt.compare(password, usuario.password_hash);
      if (!valid) {
        return reply.status(401).send({ error: 'Credenciales inválidas' });
      }
      
      // Generar token JWT usando Fastify JWT plugin (igual que la web)
      const token = request.server.jwt.sign({
        id: usuario.id_usuario,
        email: usuario.correo,
        role: usuario.rol_nombre || 'usuario'
      });
      
      // Retornar sin password_hash (mantener 'user' para compatibilidad con Flutter)
      const { password_hash, ...userWithoutPassword } = usuario;
      
      // Formatear respuesta igual que la web (incluir tipo_rol como objeto)
      const userFormateado = {
        ...userWithoutPassword,
        tipo_rol: usuario.rol_nombre ? {
          id_rol: usuario.tipo_rol_id,
          nombre: usuario.rol_nombre
        } : null
      };
      
      return reply.send({
        user: userFormateado,
        token
      });
    } catch (error) {
      console.error('Error en login:', error);
      return reply.status(500).send({ error: 'Error al iniciar sesión' });
    }
  });

  // POST /api/auth/change-password - Cambiar contraseña
  fastify.post('/auth/change-password', {
    schema: {
      body: {
        type: 'object',
        required: ['correo', 'currentPassword', 'newPassword'],
        properties: {
          correo: { type: 'string', format: 'email' },
          currentPassword: { type: 'string' },
          newPassword: { type: 'string', minLength: 6 }
        }
      }
    }
  }, async (request, reply) => {
    const { correo, currentPassword, newPassword } = request.body;
    
    try {
      // Buscar usuario
      const [rows] = await pool.query(
        'SELECT * FROM usuario WHERE correo = ?',
        [correo.toLowerCase().trim()]
      );
      
      if (rows.length === 0) {
        return reply.status(404).send({ error: 'Usuario no encontrado' });
      }
      
      const user = rows[0];
      
      // Verificar password actual
      const validPassword = await bcrypt.compare(currentPassword, user.password_hash);
      if (!validPassword) {
        return reply.status(401).send({ error: 'Contraseña actual incorrecta' });
      }
      
      // Hash nuevo password
      const newPasswordHash = await bcrypt.hash(newPassword, 10);
      
      // Actualizar
      await pool.query(
        'UPDATE usuario SET password_hash = ? WHERE id_usuario = ?',
        [newPasswordHash, user.id_usuario]
      );
      
      return reply.send({ message: 'Contraseña actualizada correctamente' });
    } catch (error) {
      console.error('Error al cambiar password:', error);
      return reply.status(500).send({ error: 'Error al cambiar contraseña' });
    }
  });
}

module.exports = routes;

