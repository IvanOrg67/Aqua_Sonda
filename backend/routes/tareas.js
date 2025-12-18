const express = require('express');
const router = express.Router();
const { from, insert, update, remove } = require('../config/query-builder');
const authMiddleware = require('../middleware/auth');

// Obtener tareas de una instalación
router.get('/instalacion/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const tareas = await from('tarea_programada')
      .select('*')
      .eq('id_instalacion', id)
      .orderBy('fecha_programada', 'DESC')
      .execute();
    
    res.json(tareas);
  } catch (error) {
    console.error('Error al obtener tareas:', error);
    res.status(500).json({ error: 'Error al obtener tareas' });
  }
});

// Crear tarea
router.post('/', authMiddleware, async (req, res) => {
  try {
    const {
      id_instalacion,
      tipo_tarea,
      descripcion,
      fecha_programada,
      hora_programada,
      recurrente
    } = req.body;
    
    const nuevaTarea = await insert('tarea_programada', {
      id_instalacion,
      tipo_tarea,
      descripcion: descripcion || '',
      fecha_programada,
      hora_programada: hora_programada || '00:00:00',
      recurrente: recurrente || false,
      completada: false
    }).execute();
    
    res.status(201).json(nuevaTarea);
  } catch (error) {
    console.error('Error al crear tarea:', error);
    res.status(500).json({ error: 'Error al crear tarea' });
  }
});

// Marcar tarea como completada
router.put('/:id/completar', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const tareaActualizada = await update('tarea_programada')
      .set({ completada: true })
      .eq('id_tarea', id)
      .execute();
    
    res.json(tareaActualizada);
  } catch (error) {
    console.error('Error al completar tarea:', error);
    res.status(500).json({ error: 'Error al completar tarea' });
  }
});

// Actualizar tarea
router.put('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      tipo_tarea,
      descripcion,
      fecha_programada,
      hora_programada,
      recurrente,
      completada
    } = req.body;
    
    const tareaActualizada = await update('tarea_programada')
      .set({
        tipo_tarea,
        descripcion,
        fecha_programada,
        hora_programada,
        recurrente,
        completada
      })
      .eq('id_tarea', id)
      .execute();
    
    res.json(tareaActualizada);
  } catch (error) {
    console.error('Error al actualizar tarea:', error);
    res.status(500).json({ error: 'Error al actualizar tarea' });
  }
});

// Eliminar tarea
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    await remove('tarea_programada')
      .eq('id_tarea', id)
      .execute();
    
    res.json({ message: 'Tarea eliminada' });
  } catch (error) {
    console.error('Error al eliminar tarea:', error);
    res.status(500).json({ error: 'Error al eliminar tarea' });
  }
});

module.exports = router;
