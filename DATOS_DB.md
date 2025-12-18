# Aqua Sonda — Export de tablas (salida en formato terminal)

> Nota: “Enter password:” aparece por ejecutar `mysql -p`.

===== alertas =====
(sin datos / no mostrado)

===== asignacion_usuario =====
id_asignacion  id_usuario  id_organizacion_sucursal  id_instalacion  fecha_asignacion
1              1           1                         NULL           2025-11-27 05:12:05

===== catalogo_sensores =====
id_sensor  sensor                descripcion                                                     modelo  marca  rango_medicion unidad_medida
1          Temperatura DS18B20   Sensor digital de temperatura resistente al agua                NULL    NULL   NULL           NULL
2          TDS                   Sensor de slidos disueltos totales para calidad del agua         NULL    NULL   NULL           NULL
3          Oxigeno Disuelto      Sensor de oxgeno disuelto para acuicultura                       NULL    NULL   NULL           NULL
4          ORP                   Sensor de potencial de oxidacin-reduccin                         NULL    NULL   NULL           NULL
5          Presion BMP180        Sensor baromtrico de presin y temperatura                        NULL    NULL   NULL           NULL

===== codigos_postales =====
(sin datos / no mostrado)

===== colonias =====
(sin datos / no mostrado)

===== especie_parametro =====
(sin datos / no mostrado)

===== especies =====
id_especie  nombre
1          Tilapia

===== estados =====
id_estado  nombre_estado
1         Ciudad de Mxico

===== instalacion =====
id_instalacion  id_organizacion_sucursal  nombre_instalacion  fecha_instalacion  estado_operativo  descripcion            tipo_uso        id_proceso
1              1                         Estanque 1             2025-11-27          activo          Estanque principal     acuicultura     1

===== lectura =====
id_lectura  id_sensor_instalado  valor    fecha        hora
464513     1                   23.93    2025-12-07   13:20:31
464514     2                   766.18   2025-12-07   13:20:31
464515     3                   7.95     2025-12-07   13:20:31
464516     4                   226.80   2025-12-07   13:20:31
464517     5                   986.44   2025-12-07   13:20:31
...        ...                 ...      ...          ...
(continúa)

===== municipios =====
id_municipio  id_estado  nombre_municipio
1            1         Cuauhtmoc

===== organizacion =====
id_organizacion  nombre                  razon_social           rfc            correo                telefono  descripcion  id_estado  id_municipio  estado  fecha_creacion           ultima_modificacion
1               Organizacin Ejemplo      Ejemplo S.A. de C.V.    XAXX010101000  contacto@ejemplo.com  NULL      NULL        1         1            activa  2025-11-27 05:03:48     2025-11-27 05:03:48

===== organizacion_sucursal =====
id_organizacion_sucursal  id_organizacion  nombre_sucursal   telefono_sucursal  correo_sucursal  id_estado  id_municipio  estado  fecha_creacion           ultima_modificacion
1                         1                Sucursal Centro   NULL              NULL            1         1            activa  2025-11-27 05:03:49     2025-11-27 05:03:49

===== parametros =====
(sin datos / no mostrado)

===== procesos =====
id_proceso  id_especie  fecha_inicio  fecha_final
1          1          2025-11-27    2026-11-27

===== promedio =====
(sin datos / no mostrado)

===== resumen_lectura_horaria =====
(sin datos / no mostrado)

===== sensor_instalado =====
id_sensor_instalado  id_instalacion  id_sensor  fecha_instalada  descripcion            id_lectura
1                   1              1         2025-12-07        Temperatura DS18B20     NULL
2                   1              2         2025-12-07        TDS                    NULL
3                   1              3         2025-12-07        Oxigeno Disuelto       NULL
4                   1              4         2025-12-07        ORP                    NULL
5                   1              5         2025-12-07        Presion BMP180         NULL

===== tipo_rol =====
id_rol  nombre
1      ADMIN
2      USER

===== token_recuperacion =====
(sin datos / no mostrado)

===== usuario =====
id_usuario  id_rol  nombre_completo           correo               telefono          password_hash                                                         estado  fecha_creacion
1          1      Admin User               admin@example.com      NULL             $2b$10$akQoeclwZ1VorEbzv9ZJv.GEYBGcyn7BxAeNoQnlh.tjiKaQNfjyG        activo  2025-11-27 05:03:48
2          1      Administrador Sistema    admin@aquamonitor.com  +52 999 123 4567  $2b$12$m86hXMNPTyAY05JvqAelKuFMi4OsGoZdXxTkKjbGINSpiq6AX66I6        activo  2025-12-08 23:11:32
