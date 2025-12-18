# AQUA SONDA Backend

Backend API construido con Fastify y MySQL para el sistema de monitoreo acuático AQUA SONDA.

## Características

- ✅ API REST completa con CRUD para todas las entidades
- ✅ WebSocket para lecturas en tiempo real
- ✅ Soporte para MySQL
- ✅ Rate limiting (300 req/min)
- ✅ CORS habilitado
- ✅ Generación de reportes XML
- ✅ Listo para deployment en Railway

## Requisitos

- Node.js 18+
- MySQL 5.7+ o 8.0+

## Instalación Local

1. Instala las dependencias:
```bash
npm install
```

2. Configura las variables de entorno:
```bash
cp .env.example .env
```

Edita el archivo `.env` con tus credenciales de MySQL:
```env
PORT=3300
HOST=0.0.0.0
NODE_ENV=development

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=aqua_sonda
DB_PORT=3306

JWT_SECRET=tu_secreto_super_seguro
```

3. Crea la base de datos:
```bash
mysql -u root -p < ../database.sql
```

## Ejecución

### Desarrollo (con auto-reload)
```bash
npm run dev
```

### Producción
```bash
npm start
```

El servidor estará disponible en `http://localhost:3300`

## 🚀 Deployment en Railway

Este backend está configurado para desplegarse fácilmente en Railway.

### Pasos Rápidos

1. **Sube tu código a GitHub**
2. **Crea un proyecto en [Railway](https://railway.app)**
3. **Conecta tu repositorio de GitHub**
4. **Configura las variables de entorno** (ver `DEPLOYMENT.md`)
5. **¡Listo!** Railway desplegará automáticamente

### Documentación Completa

Consulta `DEPLOYMENT.md` para una guía detallada paso a paso.

### Variables de Entorno Requeridas

- `PORT` - Puerto del servidor (Railway lo asigna automáticamente)
- `DB_HOST` - Host de MySQL
- `DB_USER` - Usuario de MySQL
- `DB_PASSWORD` - Contraseña de MySQL
- `DB_NAME` - Nombre de la base de datos
- `JWT_SECRET` - Secreto para tokens JWT
- `NODE_ENV` - Entorno (production/development)

## Endpoints Principales

### Health Check
- `GET /health` - Estado del servidor

### WebSocket
- `WS /ws/lecturas?sensorInstaladoId=1` - Lecturas en tiempo real

### APIs CRUD

#### Organizaciones
- `POST /api/organizaciones`
- `GET /api/organizaciones`
- `GET /api/organizaciones/:id`
- `PUT /api/organizaciones/:id`
- `DELETE /api/organizaciones/:id`

#### Sucursales
- `POST /api/sucursales`
- `GET /api/sucursales`
- `GET /api/sucursales/:id`
- `PUT /api/sucursales/:id`
- `DELETE /api/sucursales/:id`

#### Instalaciones
- `POST /api/instalaciones`
- `GET /api/instalaciones`
- `GET /api/instalaciones/:id`
- `PUT /api/instalaciones/:id`
- `DELETE /api/instalaciones/:id`

#### Sensores
- `POST /api/catalogo-sensores`
- `GET /api/catalogo-sensores`
- `POST /api/sensores-instalados`
- `GET /api/sensores-instalados`

#### Lecturas
- `GET /api/lecturas?sensorInstaladoId=1`
- `GET /api/resumen-horario?sensorInstaladoId=1`
- `GET /api/promedios?granularity=hour&sensorInstaladoId=1`
- `GET /api/reportes/xml?sensorInstaladoId=1`

#### Usuarios
- `POST /api/usuarios`
- `GET /api/usuarios`
- `GET /api/usuarios/:id`
- `PUT /api/usuarios/:id`
- `DELETE /api/usuarios/:id`

#### Tipos de Rol
- `POST /api/tipos-rol`
- `GET /api/tipos-rol`

#### Alertas
- `POST /api/alertas`
- `GET /api/alertas`
- `GET /api/alertas/:id`
- `PUT /api/alertas/:id`
- `DELETE /api/alertas/:id`

#### Parámetros
- `POST /api/parametros`
- `GET /api/parametros`

#### Especies
- `POST /api/catalogo-especies`
- `GET /api/catalogo-especies`
- `POST /api/especies-parametros`
- `GET /api/especies-parametros`

#### Procesos
- `POST /api/procesos`
- `GET /api/procesos`
- `GET /api/procesos/:id`
- `PUT /api/procesos/:id`
- `DELETE /api/procesos/:id`

## Documentación Completa

Consulta el archivo `API_DOCUMENTATION.md` en la raíz del proyecto para la documentación completa de la API.

## Estructura del Proyecto

```
backend/
├── config/
│   └── database.js       # Configuración de MySQL
├── routes/
│   ├── organizaciones.js # CRUD organizaciones
│   ├── sucursales.js     # CRUD sucursales
│   ├── instalaciones.js  # CRUD instalaciones
│   ├── sensores.js       # CRUD sensores
│   ├── lecturas.js       # APIs de lecturas
│   ├── usuarios.js       # CRUD usuarios
│   ├── tipos-rol.js      # CRUD tipos de rol
│   ├── alertas.js        # CRUD alertas
│   ├── parametros.js     # CRUD parámetros
│   ├── especies.js       # CRUD especies
│   └── procesos.js       # CRUD procesos
├── .env.example          # Ejemplo de variables de entorno
├── package.json          # Dependencias
├── server.js             # Servidor principal
└── README.md             # Este archivo
```

## WebSocket - Lecturas en Tiempo Real

Conecta al WebSocket para recibir lecturas en tiempo real:

```javascript
const ws = new WebSocket('ws://localhost:3300/ws/lecturas?sensorInstaladoId=1');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Nueva lectura:', data);
};
```

## Rate Limiting

El servidor tiene un límite de **300 requests por minuto** por IP.

## Soporte

Para más información, consulta la documentación completa en `API_DOCUMENTATION.md`
