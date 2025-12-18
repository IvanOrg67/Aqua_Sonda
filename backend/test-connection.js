// Script para probar la conexión a MySQL
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const mysql = require('mysql2/promise');

async function testConnection() {
  console.log('🔍 Probando conexión a MySQL...\n');
  console.log('Configuración:');
  console.log(`  Host: ${process.env.DB_HOST}`);
  console.log(`  User: ${process.env.DB_USER}`);
  console.log(`  Database: ${process.env.DB_NAME}`);
  console.log(`  Password: ${process.env.DB_PASSWORD ? '***' + process.env.DB_PASSWORD.slice(-2) : 'NO CONFIGURADA'}\n`);

  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'aqua_sonda',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
  });

  try {
    const connection = await pool.getConnection();
    console.log('✅ Conexión exitosa a MySQL!');
    
    // Probar una query simple
    const [dbRows] = await connection.query('SELECT DATABASE() as current_db');
    console.log(`  Base de datos actual: ${dbRows[0].current_db}`);
    
    // Verificar que la base de datos existe
    const [tables] = await connection.query('SHOW TABLES');
    console.log(`  Tablas encontradas: ${tables.length}`);
    
    if (tables.length > 0) {
      console.log(`  Primeras tablas: ${tables.slice(0, 5).map(t => Object.values(t)[0]).join(', ')}`);
    }
    
    connection.release();
    await pool.end();
    
    console.log('\n✅ ¡Todo está configurado correctamente!');
    console.log('✅ El backend puede conectarse a la base de datos.');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ Error al conectar con MySQL:');
    console.error(`  Código: ${error.code}`);
    console.error(`  Mensaje: ${error.message}`);
    
    if (error.code === 'ECONNREFUSED') {
      console.error('\n💡 Posibles soluciones:');
      console.error('  1. Verifica que MySQL esté corriendo en el VPS');
      console.error('  2. Verifica que el puerto 3306 esté abierto en el firewall');
      console.error('  3. Verifica que la IP del VPS sea correcta');
    } else if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('\n💡 Posibles soluciones:');
      console.error('  1. Verifica que el usuario y password sean correctos');
      console.error('  2. Verifica que el usuario tenga permisos para conectarse desde tu IP');
    } else if (error.code === 'ER_BAD_DB_ERROR') {
      console.error('\n💡 Posibles soluciones:');
      console.error('  1. Verifica que el nombre de la base de datos sea correcto');
      console.error('  2. La base de datos debe ser: u889902058_sonda0109');
    }
    
    process.exit(1);
  }
}

testConnection();

