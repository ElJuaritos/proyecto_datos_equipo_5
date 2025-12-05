-- =====================================================
-- SCRIPT DE MIGRACIÓN Y CARGA DE DATOS A 5NF
-- Transforma datos de la tabla 'reportes' (ya limpia) a las tablas normalizadas
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este script asume que los datos del CSV ya fueron cargados y limpiados
-- en la tabla 'reportes' (scripts 01_carga_inicial.sql y 03_limpieza_datos.sql).
-- Extrae y carga los datos en las 5 tablas normalizadas.
--
-- PREREQUISITOS:
-- 1. Ejecutar primero 01_carga_inicial.sql
-- 2. Ejecutar segundo 03_limpieza_datos.sql
-- 3. Ejecutar tercero 04_schema_5nf.sql
-- 4. Finalmente ejecutar este script
-- =====================================================

-- =====================================================
-- PASO 1: VERIFICAR QUE EXISTE LA TABLA REPORTES LIMPIA
-- =====================================================

SELECT 
    COUNT(*) AS total_registros,
    COUNT(fecha_reporte_clean) AS con_fecha_limpia,
    COUNT(longitud_clean) AS con_coordenadas_limpias
FROM reportes;

-- =====================================================
-- PASO 2: POBLAR TABLA CLASIFICACION
-- Extrae valores únicos de clasificación
-- =====================================================

INSERT INTO clasificacion (nombre_clasificacion, descripcion)
SELECT DISTINCT 
    TRIM(clasificacion) AS nombre_clasificacion,
    'Categoría: ' || TRIM(clasificacion) AS descripcion
FROM reportes
WHERE clasificacion IS NOT NULL 
  AND TRIM(clasificacion) != ''
  AND TRIM(clasificacion) != 'NA'
ORDER BY nombre_clasificacion
ON CONFLICT (nombre_clasificacion) DO NOTHING;

-- Verificación
SELECT 
    id_clasificacion,
    nombre_clasificacion,
    descripcion
FROM clasificacion
ORDER BY nombre_clasificacion;

-- =====================================================
-- PASO 3: POBLAR TABLA MEDIO_RECEPCION
-- Extrae valores únicos de medios de recepción
-- =====================================================

INSERT INTO medio_recepcion (nombre_medio, descripcion)
SELECT DISTINCT 
    TRIM(medio_recepcion) AS nombre_medio,
    'Canal: ' || TRIM(medio_recepcion) AS descripcion
FROM reportes
WHERE medio_recepcion IS NOT NULL 
  AND TRIM(medio_recepcion) != ''
  AND TRIM(medio_recepcion) != 'NA'
ORDER BY nombre_medio
ON CONFLICT (nombre_medio) DO NOTHING;

-- Verificación
SELECT 
    id_medio_recepcion,
    nombre_medio,
    descripcion
FROM medio_recepcion
ORDER BY nombre_medio;

-- =====================================================
-- PASO 4: POBLAR TABLA UBICACION
-- Extrae combinaciones únicas de colonia-alcaldía-coordenadas
-- Usa DISTINCT ON para evitar duplicados por colonia
-- =====================================================

INSERT INTO ubicacion (colonia_catalogo, alcaldia_catalogo, longitud, latitud)
SELECT DISTINCT ON (TRIM(colonia_catalogo))
    TRIM(colonia_catalogo) AS colonia_catalogo,
    TRIM(alcaldia_catalogo) AS alcaldia_catalogo,
    longitud_clean AS longitud,
    latitud_clean AS latitud
FROM reportes
WHERE colonia_catalogo IS NOT NULL 
  AND TRIM(colonia_catalogo) != ''
  AND TRIM(colonia_catalogo) != 'NA'
  AND alcaldia_catalogo IS NOT NULL
  AND TRIM(alcaldia_catalogo) != ''
  AND TRIM(alcaldia_catalogo) != 'NA'
ORDER BY 
    TRIM(colonia_catalogo),
    -- Priorizar registros con coordenadas
    CASE WHEN longitud_clean IS NOT NULL AND latitud_clean IS NOT NULL THEN 0 ELSE 1 END,
    alcaldia_catalogo
ON CONFLICT (colonia_catalogo) DO NOTHING;

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
-- PASO 5: POBLAR TABLA INCIDENTE
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
    r.folio_incidente,
    r.fecha_registro_clean AS fecha_registro_incidente,
    r.reporte,
    c.id_clasificacion,
    u.id_colonia
FROM reportes r
LEFT JOIN clasificacion c ON TRIM(r.clasificacion) = c.nombre_clasificacion
LEFT JOIN ubicacion u ON TRIM(r.colonia_catalogo) = u.colonia_catalogo
WHERE r.folio_incidente IS NOT NULL 
  AND TRIM(r.folio_incidente) != ''
  AND r.fecha_registro_clean IS NOT NULL
  AND c.id_clasificacion IS NOT NULL
GROUP BY 
    r.folio_incidente,
    r.fecha_registro_clean,
    r.reporte,
    c.id_clasificacion,
    u.id_colonia
ORDER BY r.folio_incidente
ON CONFLICT (folio_incidente) DO NOTHING;

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
-- PASO 6: POBLAR TABLA REPORTE
-- Cada fila de la tabla reportes representa un reporte
-- =====================================================

INSERT INTO reporte (
    id_reporte,
    id_incidente,
    fecha_reporte,
    hora_reporte,
    id_medio_recepcion
)
SELECT 
    r.id_reporte,
    i.id_incidente,
    r.fecha_reporte_clean AS fecha_reporte,
    CASE 
        WHEN r.hora_reporte ~ '^[0-9]{1,2}:[0-9]{2}(:[0-9]{2})?$'
        THEN CAST(r.hora_reporte AS TIME)
        ELSE '00:00:00'
    END AS hora_reporte,
    m.id_medio_recepcion
FROM reportes r
INNER JOIN incidente i ON r.folio_incidente = i.folio_incidente
INNER JOIN medio_recepcion m ON TRIM(r.medio_recepcion) = m.nombre_medio
WHERE r.id_reporte IS NOT NULL 
  AND TRIM(r.id_reporte) != ''
  AND r.fecha_reporte_clean IS NOT NULL
ON CONFLICT (id_reporte) DO NOTHING;

-- Verificación
SELECT 
    rep.id_reporte_pk,
    rep.id_reporte,
    i.folio_incidente,
    rep.fecha_reporte,
    rep.hora_reporte,
    m.nombre_medio
FROM reporte rep
INNER JOIN incidente i ON rep.id_incidente = i.id_incidente
INNER JOIN medio_recepcion m ON rep.id_medio_recepcion = m.id_medio_recepcion
ORDER BY rep.id_reporte_pk
LIMIT 20;

-- =====================================================
-- PASO 7: ESTADÍSTICAS Y VALIDACIÓN FINAL
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
SELECT 'reportes (original)' AS tabla, COUNT(*) AS total FROM reportes;

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

-- Distribución de incidentes por alcaldía
SELECT 
    u.alcaldia_catalogo,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / (SELECT COUNT(*) FROM incidente WHERE id_colonia IS NOT NULL), 2) AS porcentaje
FROM ubicacion u
LEFT JOIN incidente i ON u.id_colonia = i.id_colonia
GROUP BY u.alcaldia_catalogo
ORDER BY total_incidentes DESC;

-- =====================================================
-- FIN DEL SCRIPT DE MIGRACIÓN
-- =====================================================

/*
NOTAS IMPORTANTES:

1. DATOS LIMPIOS:
   - Se usan las columnas '*_clean' de la tabla reportes
   - fecha_reporte_clean, fecha_registro_clean (tipo DATE)
   - longitud_clean, latitud_clean (tipo NUMERIC)

2. LIMPIEZA DE DATOS:
   - Se filtran valores 'NA', NULL y vacíos
   - Los datos ya fueron validados en 03_limpieza_datos.sql

3. INTEGRIDAD:
   - Los INNER JOIN en REPORTE garantizan que solo se inserten reportes
     con incidentes y medios de recepción válidos
   - Los LEFT JOIN en INCIDENTE permiten incidentes sin ubicación

4. CONFLICTOS:
   - Se usa ON CONFLICT DO NOTHING para evitar duplicados
   - Basado en las restricciones UNIQUE de cada tabla

5. VALIDACIÓN:
   - Ejecutar las consultas de verificación después de cada paso
   - Comparar el total de registros original vs normalizados
   
6. FLUJO DEL PROYECTO:
   01_carga_inicial.sql    → Carga CSV a tabla 'reportes'
   03_limpieza_datos.sql   → Limpia datos en 'reportes'
   04_schema_5nf.sql       → Crea tablas normalizadas (5NF)
   05_migracion_a_5nf.sql  → Migra de 'reportes' a tablas 5NF
*/
