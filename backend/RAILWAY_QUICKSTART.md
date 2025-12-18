# 🚂 Railway Quick Start

Guía rápida para desplegar en Railway en 5 minutos.

## ✅ Checklist Pre-Deployment

- [x] Código en GitHub
- [x] Variables de entorno preparadas
- [x] Base de datos accesible
- [x] Backend configurado para Railway

## 🚀 Pasos Rápidos

### 1. Sube a GitHub (si no lo has hecho)

```bash
cd /Users/iviidlux/Downloads/mi_app_2
git add .
git commit -m "Ready for Railway deployment"
git push origin main
```

### 2. Crea Proyecto en Railway

1. Ve a https://railway.app
2. Login con GitHub
3. **New Project** → **Deploy from GitHub repo**
4. Selecciona `mi_app_2`
5. Railway detectará automáticamente el backend

### 3. Configura el Servicio

Railway debería detectar:
- **Root Directory**: `backend` (ajusta si es necesario)
- **Build Command**: `npm install` (automático)
- **Start Command**: `npm start` (automático)

### 4. Variables de Entorno

En Railway → Tu Servicio → **Variables**, agrega:

```
PORT=3300
HOST=0.0.0.0
NODE_ENV=production
DB_HOST=195.35.11.179
DB_USER=root
DB_PASSWORD=tu_password_real
DB_NAME=u889902058_sonda0109
DB_PORT=3306
JWT_SECRET=genera_uno_nuevo_aqui
CORS_ORIGIN=*
```

**Generar JWT_SECRET:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 5. Obtén tu URL

Railway asignará una URL como: `tu-app.up.railway.app`

### 6. Prueba el Health Check

Visita: `https://tu-app.up.railway.app/health`

Deberías ver:
```json
{
  "status": "ok",
  "time": "2025-12-17T..."
}
```

## 📱 Actualizar App Flutter

En `lib/config.dart`, actualiza:

```dart
static String get _resolvedHost {
  if (_apiHost.isNotEmpty) return _apiHost;
  
  // Producción
  return 'tu-app.up.railway.app';
  
  // O usa variables de entorno:
  // return String.fromEnvironment('API_HOST', defaultValue: 'localhost');
}
```

O ejecuta con:
```bash
flutter run --dart-define=API_HOST=tu-app.up.railway.app --dart-define=USE_HTTPS=true
```

## 🔍 Troubleshooting

### El servicio no inicia
- Revisa los logs en Railway
- Verifica todas las variables de entorno
- Asegúrate de que la base de datos sea accesible

### Error de conexión a DB
- Verifica que `DB_HOST` sea accesible públicamente
- Asegúrate de que el firewall permita conexiones desde Railway
- Verifica credenciales

### CORS errors
- Verifica `CORS_ORIGIN` en variables de entorno
- En producción, usa tu dominio específico: `CORS_ORIGIN=https://tu-dominio.com`

## 📚 Documentación Completa

Ver `DEPLOYMENT.md` para más detalles.

