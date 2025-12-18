# 🌊 AQUA SONDA - Sistema de Monitoreo Acuático

Sistema completo de monitoreo de sensores acuáticos con backend Node.js/Fastify y aplicación móvil Flutter.

## 📋 Requisitos

### Backend
- Node.js 16+
- MySQL 5.7+ o 8.0+

### Frontend (Flutter)
- Flutter SDK 3.0+
- Dart SDK 3.0+

## 🚀 Instalación y Configuración

### 1. Configurar Base de Datos MySQL

```bash
# Crear la base de datos
mysql -u root -p < database.sql
```

### 2. Configurar Backend

```bash
cd backend

# Instalar dependencias
npm install

# Configurar variables de entorno
# Edita backend/.env con tus credenciales de MySQL:
# - DB_HOST=localhost
# - DB_USER=root
# - DB_PASSWORD=tu_password
# - DB_NAME=aqua_sonda
```

### 3. Iniciar Servidor Backend

```bash
cd backend

# Desarrollo (con auto-reload)
npm run dev

# Producción
npm start
```

El servidor estará disponible en `http://localhost:3300`

### 4. Configurar Flutter App

```bash
# Instalar dependencias de Flutter
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run
```

## 📁 Estructura del Proyecto

```
mi_app_2/
├── backend/                 # Backend API con Fastify
│   ├── config/             # Configuración de MySQL
│   ├── routes/             # Rutas API (CRUD completo)
│   ├── server.js           # Servidor principal
│   ├── package.json        # Dependencias Node
│   └── .env                # Variables de entorno
├── lib/                    # Aplicación Flutter
│   ├── config.dart         # Configuración de endpoints
│   ├── main.dart           # Punto de entrada
│   ├── models/             # Modelos de datos
│   ├── services/           # Servicios API
│   └── pantalla_*.dart     # Pantallas de la app
├── database.sql            # Script de base de datos MySQL
└── API_DOCUMENTATION.md    # Documentación completa de API
```

## 🔌 Endpoints Principales

### Health Check
- `GET /health` - Estado del servidor

### WebSocket
- `WS /ws/lecturas?sensorInstaladoId=1` - Lecturas en tiempo real

### APIs CRUD
- Organizaciones: `/api/organizaciones`
- Sucursales: `/api/sucursales`
- Instalaciones: `/api/instalaciones`
- Sensores: `/api/catalogo-sensores`, `/api/sensores-instalados`
- Lecturas: `/api/lecturas`, `/api/resumen-horario`, `/api/promedios`
- Usuarios: `/api/usuarios`, `/api/tipos-rol`
- Alertas: `/api/alertas`
- Parámetros: `/api/parametros`
- Especies: `/api/catalogo-especies`, `/api/especies-parametros`
- Procesos: `/api/procesos`

Ver `API_DOCUMENTATION.md` para documentación completa.

## 🧪 Pruebas Rápidas

### Verificar servidor
```bash
curl http://localhost:3300/health
```

### Crear organización de prueba
```bash
curl -X POST http://localhost:3300/api/organizaciones \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Mi Organización", "estado": "activa"}'
```

## 🔧 Configuración

### Backend (.env)
```env
PORT=3300
HOST=0.0.0.0
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=aqua_sonda
JWT_SECRET=cambia_esto_en_produccion
```

### Flutter (lib/config.dart)
Las URLs del backend están configuradas en `lib/config.dart`:
- API Base: `http://localhost:3300`
- WebSocket: `ws://localhost:3300`

Para producción, cambia estas URLs a tu servidor.

## 📱 Características de la App

- ✅ Gestión de organizaciones y sucursales
- ✅ Gestión de instalaciones y sensores
- ✅ Monitoreo de lecturas en tiempo real (WebSocket)
- ✅ Visualización de gráficas y promedios
- ✅ Sistema de alertas
- ✅ Gestión de usuarios y roles
- ✅ Gestión de especies y procesos

## 🛠️ Tecnologías

### Backend
- **Fastify** - Framework web rápido
- **MySQL** - Base de datos relacional
- **WebSocket** - Comunicación en tiempo real
- **bcrypt** - Hashing de contraseñas
- **jsonwebtoken** - Autenticación JWT

### Frontend
- **Flutter** - Framework multiplataforma
- **Dart** - Lenguaje de programación
- **HTTP** - Cliente HTTP
- **WebSocket** - Comunicación en tiempo real

## 📚 Documentación

- [API Documentation](API_DOCUMENTATION.md) - Documentación completa de la API
- [Backend README](backend/README.md) - Documentación del backend
- [Database Schema](database.sql) - Esquema de base de datos

## 🐛 Solución de Problemas

### El servidor no inicia
1. Verifica que MySQL esté corriendo
2. Confirma que la base de datos `aqua_sonda` existe
3. Verifica las credenciales en `backend/.env`

### Error de conexión en Flutter
1. Verifica que el backend esté corriendo en el puerto 3300
2. Si usas emulador Android, usa `http://10.0.2.2:3300` en lugar de `localhost`
3. Si usas dispositivo físico, usa la IP de tu computadora

### WebSocket no conecta
1. Asegúrate de que el servidor esté corriendo
2. Verifica la URL del WebSocket en `lib/config.dart`
3. Revisa los logs del servidor para ver errores

## 📄 Licencia

MIT

## 👥 Soporte

Para soporte o preguntas, consulta la documentación en `API_DOCUMENTATION.md`
