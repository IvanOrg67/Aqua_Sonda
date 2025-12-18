-- MySQL dump 10.13  Distrib 5.7.41, for Linux (x86_64)
--
-- Host: localhost    Database: u889902058_sonda0109
-- ------------------------------------------------------
-- Server version	5.7.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alertas`
--

DROP TABLE IF EXISTS `alertas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alertas` (
  `id_alertas` int(11) NOT NULL AUTO_INCREMENT,
  `id_instalacion` int(11) NOT NULL,
  `id_sensor_instalado` int(11) NOT NULL,
  `descripcion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dato_puntual` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_alertas`),
  KEY `id_instalacion` (`id_instalacion`),
  KEY `id_sensor_instalado` (`id_sensor_instalado`),
  CONSTRAINT `alertas_ibfk_2` FOREIGN KEY (`id_sensor_instalado`) REFERENCES `sensor_instalado` (`id_sensor_instalado`),
  CONSTRAINT `fk_alerta_instalacion` FOREIGN KEY (`id_instalacion`) REFERENCES `instalacion` (`id_instalacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `asignacion_usuario`
--

DROP TABLE IF EXISTS `asignacion_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignacion_usuario` (
  `id_asignacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `id_organizacion_sucursal` int(11) DEFAULT NULL,
  `id_instalacion` int(11) DEFAULT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_asignacion`),
  UNIQUE KEY `uq_usuario_emp_inst` (`id_usuario`,`id_organizacion_sucursal`,`id_instalacion`),
  KEY `fk_au_instalacion` (`id_instalacion`),
  KEY `fk_au_sucursal` (`id_organizacion_sucursal`),
  CONSTRAINT `fk_asig_instalacion` FOREIGN KEY (`id_instalacion`) REFERENCES `instalacion` (`id_instalacion`) ON DELETE SET NULL,
  CONSTRAINT `fk_asig_orgsuc` FOREIGN KEY (`id_organizacion_sucursal`) REFERENCES `organizacion_sucursal` (`id_organizacion_sucursal`) ON DELETE SET NULL,
  CONSTRAINT `fk_asig_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `catalogo_sensores`
--

DROP TABLE IF EXISTS `catalogo_sensores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `catalogo_sensores` (
  `id_sensor` int(11) NOT NULL AUTO_INCREMENT,
  `sensor` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `modelo` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `marca` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rango_medicion` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unidad_medida` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_sensor`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `codigos_postales`
--

DROP TABLE IF EXISTS `codigos_postales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `codigos_postales` (
  `id_cp` int(11) NOT NULL AUTO_INCREMENT,
  `id_municipio` int(11) NOT NULL,
  `codigo_postal` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_cp`),
  KEY `id_municipio` (`id_municipio`),
  CONSTRAINT `fk_cp_municipio` FOREIGN KEY (`id_municipio`) REFERENCES `municipios` (`id_municipio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `colonias`
--

DROP TABLE IF EXISTS `colonias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `colonias` (
  `id_colonia` int(11) NOT NULL AUTO_INCREMENT,
  `id_cp` int(11) NOT NULL,
  `nombre_colonia` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_colonia`),
  KEY `id_cp` (`id_cp`),
  CONSTRAINT `fk_col_cp` FOREIGN KEY (`id_cp`) REFERENCES `codigos_postales` (`id_cp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `especie_parametro`
--

DROP TABLE IF EXISTS `especie_parametro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `especie_parametro` (
  `id_especie_parametro` int(11) NOT NULL AUTO_INCREMENT,
  `id_especie` int(11) NOT NULL,
  `id_parametro` int(11) NOT NULL,
  `Rmax` float NOT NULL,
  `Rmin` float NOT NULL,
  PRIMARY KEY (`id_especie_parametro`),
  KEY `id_especie` (`id_especie`),
  KEY `id_parametro` (`id_parametro`),
  CONSTRAINT `fk_esparam_especie` FOREIGN KEY (`id_especie`) REFERENCES `especies` (`id_especie`),
  CONSTRAINT `fk_esparam_param` FOREIGN KEY (`id_parametro`) REFERENCES `parametros` (`id_parametro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `especies`
--

DROP TABLE IF EXISTS `especies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `especies` (
  `id_especie` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_especie`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `estados`
--

DROP TABLE IF EXISTS `estados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estados` (
  `id_estado` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_estado` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `instalacion`
--

DROP TABLE IF EXISTS `instalacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `instalacion` (
  `id_instalacion` int(11) NOT NULL AUTO_INCREMENT,
  `id_organizacion_sucursal` int(11) NOT NULL,
  `nombre_instalacion` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_instalacion` date NOT NULL,
  `estado_operativo` enum('activo','inactivo') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_uso` enum('acuicultura','tratamiento','otros') COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_proceso` int(11) NOT NULL,
  PRIMARY KEY (`id_instalacion`),
  KEY `idx_ins_orgsuc` (`id_organizacion_sucursal`),
  KEY `id_proceso` (`id_proceso`),
  CONSTRAINT `fk_ins_orgsuc` FOREIGN KEY (`id_organizacion_sucursal`) REFERENCES `organizacion_sucursal` (`id_organizacion_sucursal`),
  CONSTRAINT `instalacion_ibfk_2` FOREIGN KEY (`id_proceso`) REFERENCES `procesos` (`id_proceso`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lectura`
--

DROP TABLE IF EXISTS `lectura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lectura` (
  `id_lectura` int(11) NOT NULL AUTO_INCREMENT,
  `id_sensor_instalado` int(11) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  PRIMARY KEY (`id_lectura`),
  KEY `idx_lectura_sensor_fecha` (`id_sensor_instalado`,`fecha`),
  KEY `idx_lectura_fecha` (`fecha`),
  KEY `idx_lectura_id_sensor_instalado` (`id_sensor_instalado`),
  CONSTRAINT `fk_lectura_sensor_instalado` FOREIGN KEY (`id_sensor_instalado`) REFERENCES `sensor_instalado` (`id_sensor_instalado`)
) ENGINE=InnoDB AUTO_INCREMENT=612163 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `municipios`
--

DROP TABLE IF EXISTS `municipios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `municipios` (
  `id_municipio` int(11) NOT NULL AUTO_INCREMENT,
  `id_estado` int(11) NOT NULL,
  `nombre_municipio` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_municipio`),
  KEY `id_estado` (`id_estado`),
  CONSTRAINT `fk_mun_estado` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizacion`
--

DROP TABLE IF EXISTS `organizacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizacion` (
  `id_organizacion` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `razon_social` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rfc` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `id_estado` int(11) DEFAULT NULL,
  `id_municipio` int(11) DEFAULT NULL,
  `estado` enum('activa','inactiva') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ultima_modificacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_organizacion`),
  KEY `idx_organizacion_estado` (`id_estado`),
  KEY `idx_organizacion_municipio` (`id_municipio`),
  KEY `idx_organizacion_rfc` (`rfc`),
  KEY `idx_organizacion_correo` (`correo`),
  CONSTRAINT `organizacion_id_estado_fkey` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE SET NULL,
  CONSTRAINT `organizacion_id_municipio_fkey` FOREIGN KEY (`id_municipio`) REFERENCES `municipios` (`id_municipio`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organizacion_sucursal`
--

DROP TABLE IF EXISTS `organizacion_sucursal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizacion_sucursal` (
  `id_organizacion_sucursal` int(11) NOT NULL AUTO_INCREMENT,
  `id_organizacion` int(11) NOT NULL,
  `nombre_sucursal` varchar(160) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono_sucursal` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_sucursal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_estado` int(11) DEFAULT NULL,
  `id_municipio` int(11) DEFAULT NULL,
  `estado` enum('activa','inactiva') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activa',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ultima_modificacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_organizacion_sucursal`),
  KEY `idx_organizacion_sucursal_org` (`id_organizacion`),
  KEY `idx_organizacion_sucursal_estado` (`id_estado`),
  KEY `idx_organizacion_sucursal_municipio` (`id_municipio`),
  CONSTRAINT `organizacion_sucursal_id_estado_fkey` FOREIGN KEY (`id_estado`) REFERENCES `estados` (`id_estado`) ON DELETE SET NULL,
  CONSTRAINT `organizacion_sucursal_id_municipio_fkey` FOREIGN KEY (`id_municipio`) REFERENCES `municipios` (`id_municipio`) ON DELETE SET NULL,
  CONSTRAINT `organizacion_sucursal_id_organizacion_fkey` FOREIGN KEY (`id_organizacion`) REFERENCES `organizacion` (`id_organizacion`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parametros`
--

DROP TABLE IF EXISTS `parametros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parametros` (
  `id_parametro` int(11) NOT NULL AUTO_INCREMENT,
  `nombre_parametro` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unidad_medida` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_parametro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `procesos`
--

DROP TABLE IF EXISTS `procesos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `procesos` (
  `id_proceso` int(11) NOT NULL AUTO_INCREMENT,
  `id_especie` int(11) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_final` date NOT NULL,
  PRIMARY KEY (`id_proceso`),
  KEY `id_especie` (`id_especie`),
  CONSTRAINT `fk_proc_especie` FOREIGN KEY (`id_especie`) REFERENCES `especies` (`id_especie`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promedio`
--

DROP TABLE IF EXISTS `promedio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promedio` (
  `pk_promedio` int(11) NOT NULL AUTO_INCREMENT,
  `id_sensor_instalado` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `promedio` decimal(10,2) NOT NULL,
  PRIMARY KEY (`pk_promedio`),
  UNIQUE KEY `uq_sensor_fecha_hora` (`id_sensor_instalado`,`fecha`,`hora`),
  CONSTRAINT `promedio_ibfk_1` FOREIGN KEY (`id_sensor_instalado`) REFERENCES `sensor_instalado` (`id_sensor_instalado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `resumen_lectura_horaria`
--

DROP TABLE IF EXISTS `resumen_lectura_horaria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resumen_lectura_horaria` (
  `id_resumen` int(11) NOT NULL AUTO_INCREMENT,
  `id_sensor_instalado` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `hora` time NOT NULL,
  `promedio` decimal(10,2) NOT NULL,
  `registros` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_resumen`),
  UNIQUE KEY `uq_sensor_fecha_hora` (`id_sensor_instalado`,`fecha`,`hora`),
  CONSTRAINT `resumen_lectura_horaria_ibfk_1` FOREIGN KEY (`id_sensor_instalado`) REFERENCES `sensor_instalado` (`id_sensor_instalado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sensor_instalado`
--

DROP TABLE IF EXISTS `sensor_instalado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sensor_instalado` (
  `id_sensor_instalado` int(11) NOT NULL AUTO_INCREMENT,
  `id_instalacion` int(11) NOT NULL,
  `id_sensor` int(11) NOT NULL,
  `fecha_instalada` date NOT NULL,
  `descripcion` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_lectura` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_sensor_instalado`),
  KEY `id_instalacion` (`id_instalacion`),
  KEY `id_sensor` (`id_sensor`),
  KEY `id_lectura` (`id_lectura`),
  CONSTRAINT `fk_si_instalacion` FOREIGN KEY (`id_instalacion`) REFERENCES `instalacion` (`id_instalacion`),
  CONSTRAINT `fk_si_sensor` FOREIGN KEY (`id_sensor`) REFERENCES `catalogo_sensores` (`id_sensor`),
  CONSTRAINT `sensor_instalado_ibfk_3` FOREIGN KEY (`id_lectura`) REFERENCES `lectura` (`id_lectura`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tipo_rol`
--

DROP TABLE IF EXISTS `tipo_rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tipo_rol` (
  `id_rol` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `uq_nombre_rol` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `token_recuperacion`
--

DROP TABLE IF EXISTS `token_recuperacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `token_recuperacion` (
  `id_token` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `token` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiracion` datetime NOT NULL,
  PRIMARY KEY (`id_token`),
  UNIQUE KEY `uq_token` (`token`),
  KEY `fk_tr_usuario` (`id_usuario`),
  CONSTRAINT `fk_tok_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `id_rol` int(11) NOT NULL,
  `nombre_completo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` char(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('activo','inactivo') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_usuario_correo` (`correo`),
  KEY `fk_usuario_rol` (`id_rol`),
  CONSTRAINT `fk_usuario_rol` FOREIGN KEY (`id_rol`) REFERENCES `tipo_rol` (`id_rol`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'u889902058_sonda0109'
--

--
-- Dumping routines for database 'u889902058_sonda0109'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-18  1:25:39
