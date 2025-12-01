-- =====================================================
-- SCRIPT DE MIGRACIÓN Y CARGA DE DATOS A 5NF
-- Transforma datos del CSV original a las tablas normalizadas
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este script asume que los datos del CSV ya fueron cargados
-- a una tabla temporal llamada 'reportes_agua_raw'.
-- Luego extrae, limpia y carga los datos en las 5 tablas normalizadas.
--
-- PREREQUISITOS:
-- 1. Ejecutar primero 04_schema_5nf.sql
-- 2. Cargar el CSV en tabla temporal reportes_agua_raw
-- =====================================================

-- =====================================================
-- PASO 1: CREAR TABLA TEMPORAL PARA CARGA DEL CSV
-- =====================================================

DROP TABLE IF EXISTS reportes_agua_raw;

CREATE TABLE reportes_agua_raw (
    folio_incidente VARCHAR(50),
    fecha_registro_incidente VARCHAR(50),
    id_reporte VARCHAR(50),
    fecha_reporte VARCHAR(50),
    hora_reporte VARCHAR(50),
    clasificacion VARCHAR(100),
    reporte VARCHAR(500),
    medio_recepcion VARCHAR(100),
    alcaldia_catalogo VARCHAR(100),
    colonia_catalogo VARCHAR(255),
    longitud VARCHAR(50),
    latitud VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tabla temporal para carga inicial del CSV';

-- =====================================================
-- PASO 2: CARGAR CSV A TABLA TEMPORAL
-- =====================================================
-- Ejecutar desde la línea de comandos de MySQL:
-- 
-- LOAD DATA LOCAL INFILE 'reportes_agua_2024_01.csv'
-- INTO TABLE reportes_agua_raw
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS;
--
-- O usar un script de Python/herramienta ETL
-- =====================================================

-- =====================================================
-- PASO 3: POBLAR TABLA CLASIFICACION
-- Extrae valores únicos de clasificación
-- =====================================================

INSERT INTO clasificacion (nombre_clasificacion, descripcion)
SELECT DISTINCT 
    TRIM(clasificacion) AS nombre_clasificacion,
    CONCAT('Categoría: ', TRIM(clasificacion)) AS descripcion
FROM reportes_agua_raw
WHERE clasificacion IS NOT NULL 
  AND TRIM(clasificacion) != ''
  AND TRIM(clasificacion) != 'NA'
ORDER BY nombre_clasificacion
ON DUPLICATE KEY UPDATE nombre_clasificacion = nombre_clasificacion;

-- Verificación
SELECT 
    id_clasificacion,
    nombre_clasificacion,
    descripcion
FROM clasificacion
ORDER BY nombre_clasificacion;

-- =====================================================
-- PASO 4: POBLAR TABLA MEDIO_RECEPCION
-- Extrae valores únicos de medios de recepción
-- =====================================================

INSERT INTO medio_recepcion (nombre_medio, descripcion)
SELECT DISTINCT 
    TRIM(medio_recepcion) AS nombre_medio,
    CONCAT('Canal: ', TRIM(medio_recepcion)) AS descripcion
FROM reportes_agua_raw
WHERE medio_recepcion IS NOT NULL 
  AND TRIM(medio_recepcion) != ''
  AND TRIM(medio_recepcion) != 'NA'
ORDER BY nombre_medio
ON DUPLICATE KEY UPDATE nombre_medio = nombre_medio;

-- Verificación
SELECT 
    id_medio_recepcion,
    nombre_medio,
    descripcion
FROM medio_recepcion
ORDER BY nombre_medio;

-- =====================================================
-- PASO 5: POBLAR TABLA UBICACION
-- Extrae combinaciones únicas de colonia-alcaldía-coordenadas
-- =====================================================

INSERT INTO ubicacion (colonia_catalogo, alcaldia_catalogo, longitud, latitud)
SELECT DISTINCT 
    TRIM(colonia_catalogo) AS colonia_catalogo,
    TRIM(alcaldia_catalogo) AS alcaldia_catalogo,
    CASE 
        WHEN longitud IS NOT NULL 
             AND longitud != '' 
             AND longitud != 'NA' 
             AND longitud REGEXP '^-?[0-9]+\.?[0-9]*$'
        THEN CAST(longitud AS DECIMAL(11,8))
        ELSE NULL 
    END AS longitud,
    CASE 
        WHEN latitud IS NOT NULL 
             AND latitud != '' 
             AND latitud != 'NA' 
             AND latitud REGEXP '^-?[0-9]+\.?[0-9]*$'
        THEN CAST(latitud AS DECIMAL(11,8))
        ELSE NULL 
    END AS latitud
FROM reportes_agua_raw
WHERE colonia_catalogo IS NOT NULL 
  AND TRIM(colonia_catalogo) != ''
  AND TRIM(colonia_catalogo) != 'NA'
ORDER BY colonia_catalogo
ON DUPLICATE KEY UPDATE 
    alcaldia_catalogo = VALUES(alcaldia_catalogo),
    longitud = VALUES(longitud),
    latitud = VALUES(latitud);

-- Verificación
SELECT 
    id_colonia,
    colonia_catalogo,
    alcaldia_catalogo,
    longitud,
    latitud
FROM ubicacion
ORDER BY alcaldia_catalogo, colonia_catalogo
LIMIT 20;

-- =====================================================
-- PASO 6: POBLAR TABLA INCIDENTE
-- Agrupa por folio_incidente (un incidente puede tener múltiples reportes)
-- =====================================================

INSERT INTO incidente (
    folio_incidente, 
    fecha_registro_incidente, 
    reporte, 
    id_clasificacion, 
    id_colonia
)
SELECT DISTINCT
    raw.folio_incidente,
    STR_TO_DATE(raw.fecha_registro_incidente, '%m/%d/%Y') AS fecha_registro_incidente,
    raw.reporte,
    c.id_clasificacion,
    u.id_colonia
FROM reportes_agua_raw raw
LEFT JOIN clasificacion c ON TRIM(raw.clasificacion) = c.nombre_clasificacion
LEFT JOIN ubicacion u ON TRIM(raw.colonia_catalogo) = u.colonia_catalogo
WHERE raw.folio_incidente IS NOT NULL 
  AND TRIM(raw.folio_incidente) != ''
GROUP BY 
    raw.folio_incidente,
    raw.fecha_registro_incidente,
    raw.reporte,
    c.id_clasificacion,
    u.id_colonia
ORDER BY raw.folio_incidente
ON DUPLICATE KEY UPDATE folio_incidente = folio_incidente;

-- Verificación
SELECT 
    i.id_incidente,
    i.folio_incidente,
    i.fecha_registro_incidente,
    i.reporte,
    c.nombre_clasificacion,
    u.colonia_catalogo,
    u.alcaldia_catalogo
FROM incidente i
LEFT JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
ORDER BY i.id_incidente
LIMIT 20;

-- =====================================================
-- PASO 7: POBLAR TABLA REPORTE
-- Cada fila del CSV original representa un reporte
-- =====================================================

INSERT INTO reporte (
    id_reporte,
    id_incidente,
    fecha_reporte,
    hora_reporte,
    id_medio_recepcion
)
SELECT 
    raw.id_reporte,
    i.id_incidente,
    STR_TO_DATE(raw.fecha_reporte, '%m/%d/%Y') AS fecha_reporte,
    CASE 
        WHEN raw.hora_reporte REGEXP '^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$'
        THEN raw.hora_reporte
        ELSE '00:00:00'
    END AS hora_reporte,
    m.id_medio_recepcion
FROM reportes_agua_raw raw
INNER JOIN incidente i ON raw.folio_incidente = i.folio_incidente
INNER JOIN medio_recepcion m ON TRIM(raw.medio_recepcion) = m.nombre_medio
WHERE raw.id_reporte IS NOT NULL 
  AND TRIM(raw.id_reporte) != ''
ON DUPLICATE KEY UPDATE id_reporte = id_reporte;

-- Verificación
SELECT 
    r.id_reporte_pk,
    r.id_reporte,
    i.folio_incidente,
    r.fecha_reporte,
    r.hora_reporte,
    m.nombre_medio
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
ORDER BY r.id_reporte_pk
LIMIT 20;

-- =====================================================
-- PASO 8: ESTADÍSTICAS Y VALIDACIÓN FINAL
-- =====================================================

-- Conteo de registros por tabla
SELECT 'clasificacion' AS tabla, COUNT(*) AS total FROM clasificacion
UNION ALL
SELECT 'medio_recepcion' AS tabla, COUNT(*) AS total FROM medio_recepcion
UNION ALL
SELECT 'ubicacion' AS tabla, COUNT(*) AS total FROM ubicacion
UNION ALL
SELECT 'incidente' AS tabla, COUNT(*) AS total FROM incidente
UNION ALL
SELECT 'reporte' AS tabla, COUNT(*) AS total FROM reporte
UNION ALL
SELECT 'reportes_agua_raw' AS tabla, COUNT(*) AS total FROM reportes_agua_raw;

-- Verificar integridad: incidentes sin ubicación
SELECT 
    COUNT(*) AS incidentes_sin_ubicacion
FROM incidente
WHERE id_colonia IS NULL;

-- Verificar integridad: reportes por incidente (top 10)
SELECT 
    i.folio_incidente,
    i.reporte,
    COUNT(r.id_reporte_pk) AS total_reportes
FROM incidente i
LEFT JOIN reporte r ON i.id_incidente = r.id_incidente
GROUP BY i.id_incidente, i.folio_incidente, i.reporte
ORDER BY total_reportes DESC
LIMIT 10;

-- Distribución de incidentes por clasificación
SELECT 
    c.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / (SELECT COUNT(*) FROM incidente), 2) AS porcentaje
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion, c.nombre_clasificacion
ORDER BY total_incidentes DESC;

-- Distribución de reportes por medio de recepción
SELECT 
    m.nombre_medio,
    COUNT(r.id_reporte_pk) AS total_reportes,
    ROUND(COUNT(r.id_reporte_pk) * 100.0 / (SELECT COUNT(*) FROM reporte), 2) AS porcentaje
FROM medio_recepcion m
LEFT JOIN reporte r ON m.id_medio_recepcion = r.id_medio_recepcion
GROUP BY m.id_medio_recepcion, m.nombre_medio
ORDER BY total_reportes DESC;

-- =====================================================
-- PASO 9: LIMPIEZA (OPCIONAL)
-- Descomentar para eliminar la tabla temporal
-- =====================================================

-- DROP TABLE IF EXISTS reportes_agua_raw;

-- =====================================================
-- FIN DEL SCRIPT DE MIGRACIÓN
-- =====================================================

/*
NOTAS IMPORTANTES:

1. FORMATO DE FECHAS:
   - El CSV usa formato M/D/YYYY
   - Ajustar STR_TO_DATE() si el formato es diferente

2. LIMPIEZA DE DATOS:
   - Se filtran valores 'NA', NULL y vacíos
   - Se validan coordenadas con REGEXP
   - Se normalizan espacios con TRIM()

3. INTEGRIDAD:
   - Los INNER JOIN en REPORTE garantizan que solo se inserten reportes
     con incidentes y medios de recepción válidos
   - Los LEFT JOIN en INCIDENTE permiten incidentes sin ubicación

4. OPTIMIZACIÓN:
   - Usar LOAD DATA INFILE es más rápido que INSERT individuales
   - Los índices definidos en el schema aceleran los JOINs

5. VALIDACIÓN:
   - Ejecutar las consultas de verificación después de cada paso
   - Comparar el total de registros raw vs normalizados
   
6. ROLLBACK:
   - Ejecutar este script dentro de una transacción si se desea
   - BEGIN; ... COMMIT; o ROLLBACK; en caso de error
*/

