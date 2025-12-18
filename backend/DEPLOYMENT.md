# 🚀 Guía de Deployment en Railway

Esta guía te ayudará a desplegar el backend de AQUA SONDA en Railway.

## 📋 Requisitos Previos

1. Cuenta en [Railway](https://railway.app)
2. Repositorio en GitHub con el código
3. Base de datos MySQL accesible (en tu VPS o servicio externo)

## 🔧 Pasos para Desplegar

### 1. Preparar el Repositorio

Asegúrate de que tu código esté en GitHub:

```bash
git add .
git commit -m "Preparado para Railway"
git push origin main
```

### 2. Crear Proyecto en Railway

1. Ve a [railway.app](https://railway.app)
2. Inicia sesión con GitHub
3. Click en **"New Project"**
4. Selecciona **"Deploy from GitHub repo"**
5. Elige tu repositorio `mi_app_2`

### 3. Configurar el Servicio

Railway detectará automáticamente que es Node.js, pero verifica:

- **Root Directory**: `backend`
- **Build Command**: `npm install` (automático)
- **Start Command**: `npm start` (automático)

### 4. Configurar Variables de Entorno

En Railway, ve a tu servicio → **Variables** y agrega:

```env
PORT=3300
HOST=0.0.0.0
NODE_ENV=production

# Base de datos MySQL
DB_HOST=195.35.11.179
DB_USER=root
DB_PASSWORD=tu_password_aqui
DB_NAME=u889902058_sonda0109
DB_PORT=3306

# JWT Secret (usa uno diferente en producción)
JWT_SECRET=tu_jwt_secret_super_seguro_aqui

# CORS (opcional, para permitir tu dominio)
CORS_ORIGIN=*
```

**⚠️ IMPORTANTE**: 
- No uses la contraseña real en este archivo
- Genera un nuevo `JWT_SECRET` para producción
- Railway encripta las variables automáticamente

### 5. Obtener la URL

1. Railway asignará una URL automáticamente
2. Ve a **Settings** → **Domains** para ver tu URL
3. Será algo como: `tu-app.up.railway.app`

### 6. Configurar Dominio Personalizado (Opcional)

1. En **Settings** → **Domains**
2. Click en **"Custom Domain"**
3. Agrega tu dominio (ej: `api.tudominio.com`)
4. Configura los DNS según las instrucciones

## 🔒 Seguridad

### Variables Sensibles

- ✅ **NUNCA** subas el archivo `.env` a GitHub
- ✅ Usa variables de entorno en Railway
- ✅ Genera un `JWT_SECRET` nuevo para producción
- ✅ Usa contraseñas fuertes para la base de datos

### Firewall de Base de Datos

Si tu MySQL está en un VPS, asegúrate de permitir conexiones desde Railway:

```bash
# En tu VPS
# Permitir conexiones desde cualquier IP (solo para desarrollo)
# En producción, restringe a la IP de Railway
```

## 📊 Monitoreo

Railway proporciona:
- **Logs en tiempo real**: Ve a tu servicio → **Deployments** → Click en el deployment
- **Métricas**: CPU, Memoria, Red
- **Alertas**: Configura alertas en **Settings** → **Notifications**

## 🔄 Actualizaciones

Railway hace auto-deploy cuando haces push a la rama principal:

```bash
git add .
git commit -m "Nueva funcionalidad"
git push origin main
```

Railway detectará el cambio y desplegará automáticamente.

## 🐛 Troubleshooting

### El servicio no inicia

1. Revisa los logs en Railway
2. Verifica que todas las variables de entorno estén configuradas
3. Asegúrate de que la base de datos sea accesible desde Railway

### Error de conexión a la base de datos

1. Verifica que `DB_HOST` sea accesible públicamente
2. Asegúrate de que el firewall permita conexiones desde Railway
3. Verifica las credenciales de la base de datos

### El servicio se reinicia constantemente

1. Revisa los logs para ver el error
2. Verifica que el puerto sea dinámico (usa `process.env.PORT`)
3. Asegúrate de que todas las dependencias estén instaladas

## 📱 Actualizar la App Flutter

Una vez desplegado, actualiza `lib/config.dart`:

```dart
static String get _resolvedHost {
  if (_apiHost.isNotEmpty) return _apiHost;
  
  // Para producción (descomentar cuando esté desplegado)
  // return 'tu-app.up.railway.app';
  
  // Defaults para DEV
  if (Platform.isAndroid) return '10.0.2.2';
  if (Platform.isIOS) return '127.0.0.1';
  return 'localhost';
}
```

O usa variables de entorno al ejecutar:

```bash
flutter run --dart-define=API_HOST=tu-app.up.railway.app --dart-define=USE_HTTPS=true
```

## 💰 Costos

- **Plan Gratuito**: $5 de crédito/mes
- **Plan Hobby**: $20/mes (más recursos)
- **Plan Pro**: $100/mes (para producción)

El plan gratuito es suficiente para desarrollo y testing.

## 📚 Recursos

- [Documentación de Railway](https://docs.railway.app)
- [Railway Discord](https://discord.gg/railway)
- [Ejemplos de Railway](https://github.com/railwayapp/starters)

