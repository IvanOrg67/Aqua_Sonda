#!/bin/bash

# Script para obtener credenciales de MySQL desde Docker en VPS
# Ejecutar en el VPS donde está el contenedor Docker

echo "🔍 Buscando contenedores MySQL..."
echo ""

# Buscar contenedores MySQL
CONTAINERS=$(docker ps --format "{{.Names}}" | grep -i mysql)

if [ -z "$CONTAINERS" ]; then
    echo "❌ No se encontraron contenedores MySQL corriendo"
    echo ""
    echo "Contenedores disponibles:"
    docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
    exit 1
fi

echo "✅ Contenedores MySQL encontrados:"
echo "$CONTAINERS"
echo ""

# Tomar el primer contenedor (o puedes especificar uno)
CONTAINER_NAME=$(echo "$CONTAINERS" | head -n 1)

echo "📦 Analizando contenedor: $CONTAINER_NAME"
echo ""

# Obtener información del contenedor
echo "=== INFORMACIÓN DEL CONTENEDOR ==="
echo ""

# Puertos expuestos
echo "🔌 Puertos expuestos:"
docker port "$CONTAINER_NAME" 2>/dev/null || echo "  (No hay puertos expuestos)"
echo ""

# Variables de entorno
echo "🔐 Variables de entorno MySQL:"
docker inspect "$CONTAINER_NAME" | grep -i "MYSQL" | grep -v "MYSQL_MAJOR\|MYSQL_VERSION" | sed 's/^[[:space:]]*//'
echo ""

# IP del contenedor
echo "🌐 IP del contenedor:"
docker inspect "$CONTAINER_NAME" | grep -i "IPAddress" | grep -v "SecondaryIPAddresses" | head -1 | sed 's/^[[:space:]]*//'
echo ""

# IP pública del VPS
echo "🌍 IP Pública del VPS:"
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null)
echo "  $PUBLIC_IP"
echo ""

# Extraer credenciales específicas
echo "=== CREDENCIALES EXTRAÍDAS ==="
echo ""

MYSQL_ROOT_PASSWORD=$(docker inspect "$CONTAINER_NAME" | grep -i "MYSQL_ROOT_PASSWORD" | head -1 | sed 's/.*=//' | tr -d '", ')
MYSQL_PASSWORD=$(docker inspect "$CONTAINER_NAME" | grep -i "MYSQL_PASSWORD" | head -1 | sed 's/.*=//' | tr -d '", ')
MYSQL_USER=$(docker inspect "$CONTAINER_NAME" | grep -i "MYSQL_USER" | head -1 | sed 's/.*=//' | tr -d '", ')
MYSQL_DATABASE=$(docker inspect "$CONTAINER_NAME" | grep -i "MYSQL_DATABASE\|MYSQL_DB" | head -1 | sed 's/.*=//' | tr -d '", ')

echo "Usuario: ${MYSQL_USER:-root}"
echo "Password: ${MYSQL_ROOT_PASSWORD:-${MYSQL_PASSWORD:-(no encontrado)}}"
echo "Base de datos: ${MYSQL_DATABASE:-(no encontrado)}"
echo ""

# Generar contenido para .env
echo "=== CONTENIDO PARA backend/.env ==="
echo ""
echo "PORT=3300"
echo "HOST=0.0.0.0"
echo ""
echo "DB_HOST=$PUBLIC_IP"
echo "DB_USER=${MYSQL_USER:-root}"
echo "DB_PASSWORD=${MYSQL_ROOT_PASSWORD:-${MYSQL_PASSWORD}}"
echo "DB_NAME=${MYSQL_DATABASE:-u889902058_sonda0109}"
echo ""
echo "JWT_SECRET=ca5680dc2caf3ffa9ea8e8f37542115495ad90d3a1b7590e4dd43d4c7f56f96e"
echo ""

echo "✅ Copia el contenido de arriba y pégalo en backend/.env"
echo ""
echo "⚠️  IMPORTANTE:"
echo "   1. Verifica que el puerto MySQL esté expuesto (ver arriba)"
echo "   2. Verifica el firewall del VPS permite conexiones al puerto 3306"
echo "   3. Si el puerto no es 3306, agrega :PUERTO al DB_HOST"

