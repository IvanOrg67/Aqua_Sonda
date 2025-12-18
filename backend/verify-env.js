// Verificar que el archivo .env se puede leer
const fs = require('fs');
const path = require('path');

const envPath = path.join(__dirname, '.env');

console.log('🔍 Verificando archivo .env...\n');

try {
  if (!fs.existsSync(envPath)) {
    console.log('❌ El archivo .env NO existe');
    process.exit(1);
  }

  console.log('✅ El archivo .env existe');
  
  const content = fs.readFileSync(envPath, 'utf8');
  console.log(`📏 Tamaño: ${content.length} caracteres\n`);
  
  console.log('📄 Contenido del archivo:');
  console.log('---');
  console.log(content);
  console.log('---\n');
  
  // Verificar que tiene las variables necesarias
  const requiredVars = ['DB_HOST', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'];
  const missing = requiredVars.filter(v => !content.includes(v));
  
  if (missing.length > 0) {
    console.log(`❌ Faltan variables: ${missing.join(', ')}`);
  } else {
    console.log('✅ Todas las variables requeridas están presentes');
  }
  
  // Probar cargar con dotenv
  console.log('\n🔍 Probando carga con dotenv...');
  require('dotenv').config();
  
  console.log(`DB_HOST: ${process.env.DB_HOST || 'undefined'}`);
  console.log(`DB_USER: ${process.env.DB_USER || 'undefined'}`);
  console.log(`DB_NAME: ${process.env.DB_NAME || 'undefined'}`);
  console.log(`DB_PASSWORD: ${process.env.DB_PASSWORD ? '***' + process.env.DB_PASSWORD.slice(-2) : 'undefined'}`);
  
} catch (error) {
  console.error('❌ Error al leer .env:', error.message);
  process.exit(1);
}

