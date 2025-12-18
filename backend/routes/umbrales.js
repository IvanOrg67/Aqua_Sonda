const express = require('express');
const router = express.Router();
const { from, insert, update, remove } = require('../config/query-builder');
const authMiddleware = require('../middleware/auth');

// Obtener umbrales de un sensor instalado
router.get('/sensor/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const umbrales = await from('umbral')
      .select('*')
      .eq('id_sensor_instalado', id)
      .execute();
    
    res.json(umbrales);
  } catch (error) {
    console.error('Error al obtener umbrales:', error);
    res.status(500).json({ error: 'Error al obtener umbrales' });
  }
});

// Crear umbral
router.post('/', authMiddleware, async (req, res) => {
  try {
    const {
      id_sensor_instalado,
      tipo_umbral,
      rmax,
      rmin,
      descripcion
    } = req.body;
    
    const nuevoUmbral = await insert('umbral', {
      id_sensor_instalado,
      tipo_umbral,
      rmax,
      rmin,
      descripcion: descripcion || ''
    }).execute();
    
    res.status(201).json(nuevoUmbral);
  } catch (error) {
    console.error('Error al crear umbral:', error);
    res.status(500).json({ error: 'Error al crear umbral' });
  }
});

// Actualizar umbral
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { tipo_umbral, rmax, rmin, descripcion } = req.body;
    
    const umbralActualizado = await update('umbral')
      .set({
        tipo_umbral,
        rmax,
        rmin,
        descripcion
      })
      .eq('id_umbral', id)
      .execute();
    
    res.json(umbralActualizado);
  } catch (error) {
    console.error('Error al actualizar umbral:', error);
    res.status(500).json({ error: 'Error al actualizar umbral' });
  }
});

// Eliminar umbral
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('umbral')
      .eq('id_umbral', id)
      .execute();
    
    res.json({ message: 'Umbral eliminado' });
  } catch (error) {
    console.error('Error al eliminar umbral:', error);
    res.status(500).json({ error: 'Error al eliminar umbral' });
  }
});

// Verificar si una lectura viola umbrales
router.post('/verificar', authMiddleware, async (req, res) => {
  try {
    const { id_sensor_instalado, valor } = req.body;
    
    const umbrales = await from('umbral')
      .select('*')
      .eq('id_sensor_instalado', id_sensor_instalado)
      .execute();
    
    const violaciones = umbrales.filter(u => {
      if (u.rmax && valor > u.rmax) return true;
      if (u.rmin && valor < u.rmin) return true;
      return false;
    });
    
    res.json({
      violado: violaciones.length > 0,
      violaciones
    });
  } catch (error) {
    console.error('Error al verificar umbrales:', error);
    res.status(500).json({ error: 'Error al verificar umbrales' });
  }
});

module.exports = router;
