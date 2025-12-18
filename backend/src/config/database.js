'use strict';

const mysql = require('mysql2/promise');
require('dotenv').config();

// Usar variables individuales o DATABASE_URL si está disponible
let dbConfig;

if (process.env.DATABASE_URL) {
  // Si existe DATABASE_URL, parsearlo
  function parseDatabaseUrl(url) {
    const u = new URL(url);
    return {
      host: u.hostname,
      port: u.port ? Number(u.port) : 3306,
      user: decodeURIComponent(u.username),
      password: decodeURIComponent(u.password),
      database: u.pathname.replace('/', ''),
    };
  }
  dbConfig = parseDatabaseUrl(process.env.DATABASE_URL);
} else {
  // Usar variables individuales del .env
  dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'aqua_sonda',
  };
}

const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  timezone: 'Z', // Trabaja en UTC
});

// Función getPool para compatibilidad con algunos repositorios
function getPool() {
  return pool;
}

module.exports = { pool, getPool };
