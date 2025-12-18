# 📚 Documentación de API - AQUA SONDA Backend

## Tabla de Contenidos

1. [Introducción](#introducción)
2. [Configuración Base](#configuración-base)
3. [Health Check](#health-check)
4. [WebSocket - Lecturas en Tiempo Real](#websocket---lecturas-en-tiempo-real)
5. [APIs de Lecturas](#apis-de-lecturas)
6. [APIs CRUD - Organizaciones](#apis-crud---organizaciones)
7. [APIs CRUD - Sucursales](#apis-crud---sucursales)
8. [APIs CRUD - Instalaciones](#apis-crud---instalaciones)
9. [APIs CRUD - Sensores](#apis-crud---sensores)
10. [APIs CRUD - Usuarios](#apis-crud---usuarios)
11. [APIs CRUD - Especies](#apis-crud---especies)
12. [APIs CRUD - Procesos](#apis-crud---procesos)
13. [Códigos de Respuesta](#códigos-de-respuesta)
14. [Manejo de Errores](#manejo-de-errores)

---

## Introducción

El backend AQUA SONDA es una API REST construida con **Fastify** que proporciona acceso a datos de monitoreo de sensores acuáticos. Incluye:

- **APIs REST** para operaciones CRUD completas
- **WebSocket** para recibir lecturas en tiempo real
- **Endpoints de agregados** (promedios, resúmenes horarios)
- **Generación de reportes XML**

### Base URL

```
http://195.35.11.179:3300
```

En producción, reemplaza `195.35.11.179:3300` con tu dominio y puerto.

---

## Configuración Base

### Headers Recomendados

```http
Content-Type: application/json
Accept: application/json
```

### Variables de Entorno

El servidor utiliza las siguientes variables de entorno (configuradas en `.env`):

- `PORT`: Puerto del servidor (default: 3000)
- `HOST`: Host del servidor (default: 0.0.0.0)
- `DATABASE_URL`: URL de conexión a MySQL
- `JWT_SECRET`: Secreto para tokens JWT

---

## Health Check

### GET `/health`

Verifica el estado del servidor.

**Ejemplo de Request:**

```bash
curl http://195.35.11.179:3300/health
```

**Ejemplo de Response:**

```json
{
  "status": "ok",
  "time": "2025-11-05T11:00:00.000Z"
}
```

---

## WebSocket - Lecturas en Tiempo Real

### Conexión WebSocket

**URL:** `ws://195.35.11.179:3300/ws/lecturas`

**Parámetros de Query (obligatorio al menos uno):**
- `sensorInstaladoId` (opcional): ID del sensor instalado
- `instalacionId` (opcional): ID de la instalación

**Ejemplo de Conexión:**

```javascript
// JavaScript (Browser)
const ws = new WebSocket('ws://195.35.11.179:3300/ws/lecturas?sensorInstaladoId=1');

ws.onopen = () => {
  console.log('WebSocket conectado');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Nueva lectura:', data);
};

ws.onerror = (error) => {
  console.error('Error WebSocket:', error);
};

ws.onclose = () => {
  console.log('WebSocket desconectado');
};
```

```javascript
// Node.js
const WebSocket = require('ws');

const ws = new WebSocket('ws://195.35.11.179:3300/ws/lecturas?instalacionId=5');

ws.on('open', () => {
  console.log('Conectado');
});

ws.on('message', (data) => {
  const message = JSON.parse(data);
  if (message.type === 'lectura.created') {
    console.log('Nueva lectura recibida:', message.data);
  }
});
```

**Ejemplo de Evento Recibido:**

```json
{
  "type": "lectura.created",
  "data": {
    "id_lectura": 12345,
    "sensor_instalado_id": 1,
    "instalacion_id": 5,
    "tipo_medida": "temperatura",
    "tomada_en": "2025-11-05T11:00:00.000Z",
    "valor": 23.5
  }
}
```

**Filtros:**

- Si solo proporcionas `sensorInstaladoId`, recibirás lecturas solo de ese sensor
- Si solo proporcionas `instalacionId`, recibirás lecturas de todos los sensores en esa instalación
- Debes proporcionar al menos uno de los dos parámetros

**Error de Conexión:**

Si no proporcionas los parámetros requeridos, recibirás:

```json
{
  "type": "error",
  "message": "Debe enviar sensorInstaladoId o instalacionId"
}
```

---

## APIs de Lecturas

### GET `/api/lecturas`

Obtiene lecturas de sensores con filtros opcionales.

**Query Parameters:**
- `sensorInstaladoId` (requerido): ID del sensor instalado
- `from` (opcional): Fecha inicial en formato ISO 8601 (ej: `2025-01-01T00:00:00Z`)
- `to` (opcional): Fecha final en formato ISO 8601
- `limit` (opcional): Número máximo de resultados (default: 500, max: 5000)

**Ejemplo de Request:**

```bash
curl "http://195.35.11.179:3300/api/lecturas?sensorInstaladoId=1&from=2025-01-01T00:00:00Z&to=2025-01-31T23:59:59Z&limit=100"
```

**Ejemplo de Response:**

```json
[
  {
    "id_lectura": 12345,
    "id_sensor_instalado": 1,
    "valor": 23.5,
    "tomada_en": "2025-01-15T10:30:00.000Z",
    "fecha": "2025-01-15",
    "hora": "10:30:00"
  }
]
```

---

### GET `/api/resumen-horario`

Obtiene resúmenes horarios de lecturas.

**Query Parameters:**
- `sensorInstaladoId` (requerido): ID del sensor instalado
- `from` (opcional): Fecha inicial en formato ISO 8601
- `to` (opcional): Fecha final en formato ISO 8601

**Ejemplo de Request:**

```bash
curl "http://195.35.11.179:3300/api/resumen-horario?sensorInstaladoId=1&from=2025-01-01T00:00:00Z"
```

**Ejemplo de Response:**

```json
[
  {
    "id_resumen": 1,
    "id_sensor_instalado": 1,
    "promedio": 23.5,
    "registros": 60,
    "fecha_hora": "2025-01-15T10:00:00.000Z",
    "fecha": "2025-01-15",
    "hora": "10:00:00"
  }
]
```

---

### GET `/api/promedios`

Obtiene promedios de lecturas con granularidad configurable.

**Query Parameters:**
- `granularity` (requerido): `15min` o `hour`
- `sensorInstaladoId` (requerido): ID del sensor instalado
- `from` (opcional): Fecha inicial en formato ISO 8601
- `to` (opcional): Fecha final en formato ISO 8601

**Ejemplo de Request:**

```bash
curl "http://195.35.11.179:3300/api/promedios?granularity=15min&sensorInstaladoId=1&from=2025-01-01T00:00:00Z"
```

**Ejemplo de Response:**

```json
[
  {
    "id_sensor_instalado": 1,
    "timestamp": "2025-01-15T10:15:00.000Z",
    "promedio": 23.5
  }
]
```

---

### GET `/api/reportes/xml`

Genera un reporte XML con las lecturas de un sensor.

**Query Parameters:**
- `sensorInstaladoId` (requerido): ID del sensor instalado
- `from` (opcional): Fecha inicial en formato ISO 8601
- `to` (opcional): Fecha final en formato ISO 8601

**Ejemplo de Request:**

```bash
curl "http://195.35.11.179:3300/api/reportes/xml?sensorInstaladoId=1&from=2025-01-01T00:00:00Z&to=2025-01-31T23:59:59Z" \
  -H "Accept: application/xml" \
  -o reporte.xml
```

**Ejemplo de Response:**

```xml
<?xml version="1.0"?>
<reporte>
  <fecha>2025-11-05T11:00:00.000Z</fecha>
  <sensores>
    <sensor id="1">
      <promedio>23.500000</promedio>
      <lecturas>
        <lectura timestamp="2025-01-15T10:30:00.000Z">
          <valor>23.5</valor>
        </lectura>
      </lecturas>
    </sensor>
  </sensores>
</reporte>
```

---

## APIs CRUD - Organizaciones

### POST `/api/organizaciones`

Crea una nueva organización.

**Request Body:**

```json
{
  "nombre": "Acuicultura del Norte",
  "estado": "activa"
}
```

**Response (201 Created):**

```json
{
  "id_organizacion": 1,
  "nombre": "Acuicultura del Norte",
  "estado": "activa",
  "fecha_creacion": "2025-11-05T11:00:00.000Z"
}
```

---

### GET `/api/organizaciones`

Obtiene todas las organizaciones.

**Response (200 OK):**

```json
[
  {
    "id_organizacion": 1,
    "nombre": "Acuicultura del Norte",
    "estado": "activa",
    "organizacion_sucursal": []
  }
]
```

---

### GET `/api/organizaciones/:id`

Obtiene una organización por ID.

**Response (200 OK):**

```json
{
  "id_organizacion": 1,
  "nombre": "Acuicultura del Norte",
  "estado": "activa",
  "organizacion_sucursal": []
}
```

---

### PUT `/api/organizaciones/:id`

Actualiza una organización.

**Request Body:**

```json
{
  "nombre": "Acuicultura del Norte Actualizada",
  "estado": "inactiva"
}
```

---

### DELETE `/api/organizaciones/:id`

Elimina una organización.

**Response (204 No Content)**

---

## APIs CRUD - Sucursales

### POST `/api/sucursales`

Crea una nueva sucursal.

**Request Body:**

```json
{
  "id_organizacion": 1,
  "nombre_sucursal": "Sucursal Centro",
  "estado": "activa"
}
```

---

### GET `/api/sucursales`

Obtiene todas las sucursales.

**Response (200 OK):**

```json
[
  {
    "id_organizacion_sucursal": 1,
    "id_organizacion": 1,
    "nombre_sucursal": "Sucursal Centro",
    "estado": "activa",
    "organizacion": {},
    "instalacion": []
  }
]
```

---

### GET `/api/sucursales/:id`

Obtiene una sucursal por ID.

---

### PUT `/api/sucursales/:id`

Actualiza una sucursal.

---

### DELETE `/api/sucursales/:id`

Elimina una sucursal.

---

## APIs CRUD - Instalaciones

### POST `/api/instalaciones`

Crea una nueva instalación.

**Request Body (todos los campos son requeridos):**

```json
{
  "id_organizacion_sucursal": 1,
  "nombre_instalacion": "Tanque de Producción 1",
  "fecha_instalacion": "2025-01-01",
  "estado_operativo": "activo",
  "descripcion": "Tanque principal de producción",
  "tipo_uso": "acuicultura",
  "id_proceso": 1
}
```

**Campos requeridos:**
- `id_organizacion_sucursal` (int): ID de la sucursal de la organización
- `nombre_instalacion` (string): Nombre de la instalación
- `fecha_instalacion` (string): Fecha en formato YYYY-MM-DD
- `estado_operativo` (string): 'activo' o 'inactivo'
- `descripcion` (string): Descripción de la instalación
- `tipo_uso` (string): 'acuicultura', 'tratamiento' o 'otros'
- `id_proceso` (int): ID del proceso asociado

**Nota:** La base de datos NO incluye campos como `ubicacion` o `estado` (solo `estado_operativo`). La ubicación se maneja a través de la relación con `organizacion_sucursal` que tiene `id_estado` e `id_municipio`.

---

### GET `/api/instalaciones`

Obtiene todas las instalaciones con sus relaciones.

**Response (200 OK):**

```json
[
  {
    "id_instalacion": 1,
    "id_organizacion_sucursal": 1,
    "nombre_instalacion": "Tanque de Producción 1",
    "fecha_instalacion": "2025-01-01",
    "estado_operativo": "activo",
    "descripcion": "Tanque principal de producción",
    "tipo_uso": "acuicultura",
    "id_proceso": 1,
    "organizacion_sucursal": {},
    "sensor_instalado": []
  }
]
```

**Campos de respuesta:**
- `id_instalacion`: ID único de la instalación
- `id_organizacion_sucursal`: ID de la sucursal
- `nombre_instalacion`: Nombre de la instalación
- `fecha_instalacion`: Fecha de instalación (YYYY-MM-DD)
- `estado_operativo`: 'activo' o 'inactivo'
- `descripcion`: Descripción de la instalación
- `tipo_uso`: 'acuicultura', 'tratamiento' o 'otros'
- `id_proceso`: ID del proceso asociado

---

### GET `/api/instalaciones/:id`

Obtiene una instalación por ID con sus sensores.

---

### PUT `/api/instalaciones/:id`

Actualiza una instalación.

---

### DELETE `/api/instalaciones/:id`

Elimina una instalación.

---

## APIs CRUD - Sensores

### POST `/api/catalogo-sensores`

Crea un nuevo sensor en el catálogo.

**Request Body:**

```json
{
  "sensor": "Temperatura",
  "descripcion": "Sensor de temperatura acuática",
  "modelo": "TEMP-100",
  "marca": "SensoTech",
  "rango_medicion": "0-50°C",
  "unidad_medida": "°C"
}
```

---

### GET `/api/catalogo-sensores`

Obtiene todos los sensores del catálogo.

---

### GET `/api/catalogo-sensores/:id`

Obtiene un sensor del catálogo por ID.

---

### PUT `/api/catalogo-sensores/:id`

Actualiza un sensor del catálogo.

---

### DELETE `/api/catalogo-sensores/:id`

Elimina un sensor del catálogo.

---

### POST `/api/sensores-instalados`

Crea un nuevo sensor instalado en una instalación.

**Request Body (todos los campos son requeridos):**

```json
{
  "id_instalacion": 1,
  "id_sensor": 1,
  "fecha_instalada": "2025-01-01",
  "descripcion": "Sensor principal de temperatura"
}
```

**Campos requeridos:**
- `id_instalacion` (int): ID de la instalación donde se instalará el sensor
- `id_sensor` (int): ID del sensor del catálogo (`catalogo_sensores`)
- `fecha_instalada` (string): Fecha en formato YYYY-MM-DD
- `descripcion` (string): Descripción del sensor instalado

**Nota:** El sensor debe existir previamente en el catálogo (`catalogo_sensores`). Primero se debe crear o seleccionar un sensor del catálogo, y luego instalarlo en la instalación.

---

### GET `/api/sensores-instalados`

Obtiene todos los sensores instalados con sus relaciones.

**Response (200 OK):**

```json
[
  {
    "id_sensor_instalado": 1,
    "id_instalacion": 1,
    "id_sensor": 1,
    "fecha_instalada": "2025-01-01",
    "descripcion": "Sensor principal de temperatura",
    "id_lectura": null,
    "instalacion": {},
    "catalogo_sensores": {
      "id_sensor": 1,
      "sensor": "Temperatura",
      "descripcion": "Sensor de temperatura acuática",
      "modelo": "TEMP-100",
      "marca": "SensoTech",
      "rango_medicion": "0-50°C",
      "unidad_medida": "°C"
    }
  }
]
```

**Campos de respuesta:**
- `id_sensor_instalado`: ID único del sensor instalado
- `id_instalacion`: ID de la instalación
- `id_sensor`: ID del sensor del catálogo
- `fecha_instalada`: Fecha de instalación (YYYY-MM-DD)
- `descripcion`: Descripción del sensor instalado
- `id_lectura`: ID de la última lectura (puede ser null)
- `catalogo_sensores`: Objeto con información del sensor del catálogo

---

### GET `/api/sensores-instalados/:id`

Obtiene un sensor instalado por ID.

---

### PUT `/api/sensores-instalados/:id`

Actualiza un sensor instalado.

---

### DELETE `/api/sensores-instalados/:id`

Elimina un sensor instalado.

---

## APIs CRUD - Usuarios

### POST `/api/usuarios`

Crea un nuevo usuario.

**Request Body:**

```json
{
  "id_rol": 1,
  "nombre_completo": "Juan Pérez",
  "correo": "juan@example.com",
  "telefono": "555-1234",
  "password_hash": "$2b$10$hashedpassword",
  "estado": "activo"
}
```

---

### GET `/api/usuarios`

Obtiene todos los usuarios (sin password_hash).

**Response (200 OK):**

```json
[
  {
    "id_usuario": 1,
    "nombre_completo": "Juan Pérez",
    "correo": "juan@example.com",
    "id_rol": 1,
    "estado": "activo",
    "fecha_creacion": "2025-11-05T11:00:00.000Z",
    "tipo_rol": {}
  }
]
```

---

### GET `/api/usuarios/:id`

Obtiene un usuario por ID.

---

### PUT `/api/usuarios/:id`

Actualiza un usuario.

---

### DELETE `/api/usuarios/:id`

Elimina un usuario.

---

## APIs CRUD - Tipos de Rol

### POST `/api/tipos-rol`

Crea un nuevo tipo de rol.

**Request Body:**

```json
{
  "nombre": "Administrador"
}
```

---

### GET `/api/tipos-rol`

Obtiene todos los tipos de rol.

---

### GET `/api/tipos-rol/:id`

Obtiene un tipo de rol por ID.

---

### PUT `/api/tipos-rol/:id`

Actualiza un tipo de rol.

---

### DELETE `/api/tipos-rol/:id`

Elimina un tipo de rol.

---

## APIs CRUD - Alertas

### POST `/api/alertas`

Crea una nueva alerta.

**Request Body:**

```json
{
  "id_instalacion": 1,
  "id_sensor_instalado": 1,
  "descripcion": "Temperatura fuera de rango",
  "dato_puntual": 35.5
}
```

---

### GET `/api/alertas`

Obtiene todas las alertas con filtros opcionales.

**Query Parameters:**
- `id_instalacion` (opcional): Filtrar por instalación
- `id_sensor_instalado` (opcional): Filtrar por sensor

**Ejemplo:**

```bash
curl "http://195.35.11.179:3300/api/alertas?id_instalacion=1"
```

---

### GET `/api/alertas/:id`

Obtiene una alerta por ID.

---

### PUT `/api/alertas/:id`

Actualiza una alerta.

---

### DELETE `/api/alertas/:id`

Elimina una alerta.

---

## APIs CRUD - Parámetros

### POST `/api/parametros`

Crea un nuevo parámetro.

**Request Body:**

```json
{
  "nombre_parametro": "Temperatura Óptima",
  "unidad_medida": "°C"
}
```

---

### GET `/api/parametros`

Obtiene todos los parámetros.

---

### GET `/api/parametros/:id`

Obtiene un parámetro por ID.

---

### PUT `/api/parametros/:id`

Actualiza un parámetro.

---

### DELETE `/api/parametros/:id`

Elimina un parámetro.

---

## APIs CRUD - Especies

### POST `/api/catalogo-especies`

Crea una nueva especie en el catálogo.

**Request Body:**

```json
{
  "nombre": "Tilapia nilótica"
}
```

---

### GET `/api/catalogo-especies`

Obtiene todas las especies del catálogo.

---

### GET `/api/catalogo-especies/:id`

Obtiene una especie del catálogo por ID.

---

### PUT `/api/catalogo-especies/:id`

Actualiza una especie del catálogo.

---

### DELETE `/api/catalogo-especies/:id`

Elimina una especie del catálogo.

---

### POST `/api/especies-instaladas`

Asigna una especie a una instalación.

**Request Body:**

```json
{
  "id_instalacion": 1,
  "id_especie": 1,
  "fecha_siembra": "2025-01-01",
  "cantidad_inicial": 1000,
  "densidad_siembra": 50.0,
  "biomasa_inicial": 10.5
}
```

---

### GET `/api/especies-instaladas`

Obtiene todas las especies instaladas.

---

### GET `/api/especies-instaladas/:id`

Obtiene una especie instalada por ID.

---

### PUT `/api/especies-instaladas/:id`

Actualiza una especie instalada.

---

### DELETE `/api/especies-instaladas/:id`

Elimina una especie instalada.

---

### POST `/api/especies-parametros`

Crea una relación especie-parámetro.

**Request Body:**

```json
{
  "id_especie": 1,
  "id_parametro": 1,
  "Rmax": 30.0,
  "Rmin": 20.0
}
```

---

### GET `/api/especies-parametros`

Obtiene todas las relaciones especie-parámetro.

---

### GET `/api/especies-parametros/:id`

Obtiene una relación especie-parámetro por ID.

---

### PUT `/api/especies-parametros/:id`

Actualiza una relación especie-parámetro.

---

### DELETE `/api/especies-parametros/:id`

Elimina una relación especie-parámetro.

---

## APIs CRUD - Procesos

### POST `/api/procesos`

Crea un nuevo proceso.

**Request Body:**

```json
{
  "id_especie": 1,
  "fecha_inicio": "2025-01-01",
  "fecha_final": "2025-06-30"
}
```

---

### GET `/api/procesos`

Obtiene todos los procesos.

---

### GET `/api/procesos/:id`

Obtiene un proceso por ID.

---

### PUT `/api/procesos/:id`

Actualiza un proceso.

---

### DELETE `/api/procesos/:id`

Elimina un proceso.

---

## Códigos de Respuesta

| Código | Descripción |
|--------|-------------|
| 200 | OK - Request exitoso |
| 201 | Created - Recurso creado exitosamente |
| 204 | No Content - Recurso eliminado exitosamente |
| 400 | Bad Request - Error en los datos enviados |
| 401 | Unauthorized - No autorizado (requiere JWT) |
| 404 | Not Found - Recurso no encontrado |
| 500 | Internal Server Error - Error del servidor |

---

## Manejo de Errores

### Formato de Error

Todos los errores siguen este formato:

```json
{
  "error": "Mensaje descriptivo del error"
}
```

### Ejemplos de Errores

**400 Bad Request:**

```json
{
  "error": "sensorInstaladoId es requerido"
}
```

**404 Not Found:**

```json
{
  "error": "Especie no encontrada"
}
```

**500 Internal Server Error:**

```json
{
  "error": "Error al conectar con la base de datos"
}
```

---

## Ejemplos de Uso Completo

### Ejemplo 1: Monitoreo en Tiempo Real

```javascript
// 1. Conectar WebSocket
const ws = new WebSocket('ws://195.35.11.179:3300/ws/lecturas?sensorInstaladoId=1');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  if (data.type === 'lectura.created') {
    console.log(`Nueva lectura: ${data.data.valor} ${data.data.tipo_medida}`);
    updateDashboard(data.data);
  }
};

// 2. Obtener historial
async function getHistorial() {
  const response = await fetch(
    'http://195.35.11.179:3300/api/lecturas?sensorInstaladoId=1&limit=100'
  );
  const lecturas = await response.json();
  return lecturas;
}

// 3. Obtener promedios
async function getPromedios() {
  const response = await fetch(
    'http://195.35.11.179:3300/api/promedios?granularity=hour&sensorInstaladoId=1'
  );
  const promedios = await response.json();
  return promedios;
}
```

### Ejemplo 2: Gestión de Instalaciones

```javascript
// Crear instalación
async function crearInstalacion(data) {
  const response = await fetch('http://195.35.11.179:3300/api/instalaciones', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return await response.json();
}

// Obtener instalaciones con sensores
async function getInstalaciones() {
  const response = await fetch('http://195.35.11.179:3300/api/instalaciones');
  return await response.json();
}

// Instalar sensor
async function instalarSensor(instalacionId, sensorId) {
  const response = await fetch('http://195.35.11.179:3300/api/sensores-instalados', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      id_instalacion: instalacionId,
      id_sensor: sensorId,
      fecha_instalada: new Date().toISOString().split('T')[0],
      descripcion: 'Sensor principal'
    })
  });
  return await response.json();
}
```

### Ejemplo 3: Generar Reporte XML

```javascript
async function generarReporteXML(sensorId, fechaInicio, fechaFin) {
  const url = new URL('http://195.35.11.179:3300/api/reportes/xml');
  url.searchParams.append('sensorInstaladoId', sensorId);
  url.searchParams.append('from', fechaInicio);
  url.searchParams.append('to', fechaFin);
  
  const response = await fetch(url);
  const xml = await response.text();
  
  // Descargar archivo
  const blob = new Blob([xml], { type: 'application/xml' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `reporte_${sensorId}_${fechaInicio}.xml`;
  link.click();
}
```

---

## Rate Limiting

El servidor tiene un límite de **300 requests por minuto por IP**. Si excedes este límite, recibirás un error 429 (Too Many Requests).

---

## Notas Importantes

1. **Fechas**: 
   - Para APIs REST: formato YYYY-MM-DD (ej: `2025-01-01`)
   - Para WebSocket y filtros: formato ISO 8601 (ej: `2025-01-01T00:00:00Z`)
2. **IDs**: Todos los IDs son números enteros
3. **Estados**: 
   - Organizaciones/Sucursales: `"activa"` o `"inactiva"`
   - Instalaciones: `"activo"` o `"inactivo"` (campo `estado_operativo`)
   - Usuarios: `"activo"` o `"inactivo"`
4. **WebSocket**: El WebSocket requiere al menos uno de los parámetros de filtro (`sensorInstaladoId` o `instalacionId`)
5. **Límites**: El límite máximo de lecturas por query es 5000
6. **Estructura de la Base de Datos**:
   - Las instalaciones NO tienen campo `ubicacion` directo. La ubicación se obtiene a través de `organizacion_sucursal` → `id_estado` e `id_municipio`
   - Los sensores se crean primero en el catálogo (`catalogo_sensores`) y luego se instalan (`sensor_instalado`)
   - Las instalaciones requieren un `id_proceso` asociado (debe existir previamente)
   - Las instalaciones requieren un `id_organizacion_sucursal` (debe existir previamente)

---

## Soporte

Para más información o soporte, consulta:
- `DEPLOYMENT.md` - Guía de despliegue
- `COMPATIBILIDAD_DEBIAN_UBUNTU.md` - Compatibilidad con sistemas Linux
- Logs del servidor: `pm2 logs aqua-backend`

---

**Última actualización:** 2025-11-05

