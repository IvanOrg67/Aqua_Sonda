#!/bin/bash

# Script para detener el backend
# Uso: ./stop-service.sh

echo "🛑 Deteniendo AQUA SONDA Backend..."

# Buscar procesos de Node.js relacionados con el servidor
PIDS=$(ps aux | grep "node.*src/server.js" | grep -v grep | awk '{print $2}')

if [ -z "$PIDS" ]; then
    echo "❌ No se encontró ningún proceso del servidor corriendo"
    exit 0
fi

echo "📋 Procesos encontrados: $PIDS"

# Detener cada proceso
for PID in $PIDS; do
    echo "   Deteniendo proceso $PID..."
    kill $PID 2>/dev/null
done

# Esperar un momento
sleep 2

# Verificar si aún hay procesos corriendo
REMAINING=$(ps aux | grep "node.*src/server.js" | grep -v grep | awk '{print $2}')

if [ ! -z "$REMAINING" ]; then
    echo "⚠️  Algunos procesos no se detuvieron, forzando cierre..."
    for PID in $REMAINING; do
        kill -9 $PID 2>/dev/null
    done
fi

echo "✅ Servidor detenido"

