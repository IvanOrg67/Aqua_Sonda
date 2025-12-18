#!/bin/bash

# Script para crear el archivo .env con las credenciales

echo "🔧 Configurando archivo .env para el backend..."

# Generar JWT_SECRET
JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

# Crear archivo .env
cat > .env << EOF
# Configuración del Servidor
PORT=3300
HOST=0.0.0.0

# Configuración de MySQL
# IMPORTANTE: Cambia estos valores con tus credenciales reales
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=u889902058_sonda0109

# JWT Secret (generado automáticamente)
JWT_SECRET=$JWT_SECRET
EOF

echo "✅ Archivo .env creado exitosamente!"
echo ""
echo "⚠️  IMPORTANTE: Edita el archivo .env y configura:"
echo "   - DB_PASSWORD: Tu contraseña de MySQL"
echo "   - DB_HOST: Si MySQL está en otro servidor"
echo "   - DB_USER: Si usas otro usuario"
echo ""
echo "📝 Archivo creado en: $(pwd)/.env"

