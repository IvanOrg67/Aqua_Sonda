const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { from, insert, update } = require('../config/query-builder');

// Registro
router.post('/register', async (req, res) => {
  try {
    const { nombre_completo, correo, password, telefono, id_rol = 2 } = req.body;

    // Verificar si el usuario ya existe
    const existingUser = await from('usuario')
      .select('*')
      .eq('correo', correo)
      .single();

    if (existingUser) {
      return res.status(400).json({ error: 'El correo ya está registrado' });
    }

    // Hash del password
    const password_hash = await bcrypt.hash(password, 10);

    // Insertar usuario
    const newUser = await insert('usuario', {
      id_rol,
      nombre_completo,
      correo,
      telefono,
      password_hash,
      estado: 'activo'
    }).execute();

    const { password_hash: _, ...user } = newUser;

    // Generar token
    const token = jwt.sign(
      { id_usuario: user.id_usuario, correo: user.correo },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      user,
      token
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ error: 'Error al registrar usuario' });
  }
});

// Login
router.post('/login', async (req, res) => {
  try {
    const { correo, password } = req.body;

    // Buscar usuario
    const user = await from('usuario')
      .select('*')
      .eq('correo', correo)
      .single();

    if (!user) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    // Verificar estado
    if (user.estado !== 'activo') {
      return res.status(403).json({ error: 'Usuario inactivo' });
    }

    // Verificar password
    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    // Generar token
    const token = jwt.sign(
      { id_usuario: user.id_usuario, correo: user.correo },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Retornar usuario sin password
    const { password_hash, ...userWithoutPassword } = user;

    res.json({
      user: userWithoutPassword,
      token
    });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ error: 'Error al iniciar sesión' });
  }
});

// Cambiar password
router.post('/change-password', async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ error: 'No autorizado' });
    }

    const token = authHeader.replace('Bearer ', '');
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const { currentPassword, newPassword } = req.body;

    // Obtener usuario
    const result = await db.query(
      'SELECT * FROM usuario WHERE id_usuario = $1',
      [decoded.id_usuario]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    const user = result.rows[0];

    // Verificar password actual
    const validPassword = await bcrypt.compare(currentPassword, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({ error: 'Contraseña actual incorrecta' });
    }

    // Hash nuevo password
    const newPasswordHash = await bcrypt.hash(newPassword, 10);

    // Actualizar
    await db.query(
      'UPDATE usuario SET password_hash = $1 WHERE id_usuario = $2',
      [newPasswordHash, decoded.id_usuario]
    );

    res.json({ message: 'Contraseña actualizada correctamente' });
  } catch (error) {
    console.error('Error al cambiar password:', error);
    res.status(500).json({ error: 'Error al cambiar contraseña' });
  }
});

module.exports = router;
