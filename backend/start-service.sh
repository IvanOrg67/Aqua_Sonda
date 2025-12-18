#!/bin/bash

# Script para iniciar el backend como servicio
# Uso: ./start-service.sh

cd "$(dirname "$0")"

echo "🚀 Iniciando AQUA SONDA Backend..."
echo ""

# Verificar que existe .env
if [ ! -f .env ]; then
    echo "❌ Error: No se encontró el archivo .env"
    echo "   Crea el archivo .env con las credenciales de MySQL"
    exit 1
fi

# Verificar que node_modules existe
if [ ! -d node_modules ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Iniciar el servidor
echo "✅ Iniciando servidor en http://0.0.0.0:3300"
echo "   Presiona Ctrl+C para detener"
echo ""

npm start

