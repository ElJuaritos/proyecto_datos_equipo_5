-- =====================================================
-- SCRIPT DE MIGRACIÓN Y CARGA DE DATOS A 5NF MEJORADO
-- Transforma datos de la tabla 'reportes' (ya limpia) a las 7 tablas normalizadas
-- VERSIÓN MEJORADA con alcaldia y estado_incidente
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este script asume que los datos del CSV ya fueron cargados y limpiados
-- en la tabla 'reportes' (scripts 01_carga_inicial.sql y 03_limpieza_datos.sql).
-- Extrae y carga los datos en las 7 tablas normalizadas.
--
-- PREREQUISITOS:
-- 1. Ejecutar primero 01_carga_inicial.sql
-- 2. Ejecutar segundo 03_limpieza_datos.sql
-- 3. Ejecutar tercero 04_schema_5nf.sql (que crea las 7 tablas)
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
-- PASO 4: POBLAR TABLA ALCALDIA (NUEVA)
-- Extrae valores únicos de alcaldías
-- =====================================================

INSERT INTO alcaldia (nombre_alcaldia)
SELECT DISTINCT 
    TRIM(alcaldia_catalogo) AS nombre_alcaldia
FROM reportes
WHERE alcaldia_catalogo IS NOT NULL 
  AND TRIM(alcaldia_catalogo) != ''
  AND TRIM(alcaldia_catalogo) != 'NA'
ORDER BY nombre_alcaldia
ON CONFLICT (nombre_alcaldia) DO NOTHING;

-- Verificación
SELECT 
    id_alcaldia,
    nombre_alcaldia
FROM alcaldia
ORDER BY nombre_alcaldia;

-- =====================================================
-- PASO 5: POBLAR TABLA ESTADO_INCIDENTE
-- Ya está poblada en 04_schema_5nf.sql con valores predefinidos
-- Solo verificamos que existan los estados
-- =====================================================

-- Verificación
SELECT 
    id_estado,
    nombre_estado,
    descripcion,
    orden
FROM estado_incidente
ORDER BY orden;

-- =====================================================
-- PASO 6: POBLAR TABLA COLONIA (ANTES: UBICACION)
-- Extrae combinaciones únicas de colonia-alcaldía-coordenadas
-- Ahora con FK a alcaldia en lugar de almacenar el nombre
-- =====================================================

INSERT INTO colonia (nombre_colonia, id_alcaldia, centroide_longitud, centroide_latitud)
SELECT DISTINCT ON (TRIM(r.colonia_catalogo), a.id_alcaldia)
    TRIM(r.colonia_catalogo) AS nombre_colonia,
    a.id_alcaldia,
    r.longitud_clean AS centroide_longitud,
    r.latitud_clean AS centroide_latitud
FROM reportes r
INNER JOIN alcaldia a ON TRIM(r.alcaldia_catalogo) = a.nombre_alcaldia
WHERE r.colonia_catalogo IS NOT NULL 
  AND TRIM(r.colonia_catalogo) != ''
  AND TRIM(r.colonia_catalogo) != 'NA'
  AND r.alcaldia_catalogo IS NOT NULL
  AND TRIM(r.alcaldia_catalogo) != ''
  AND TRIM(r.alcaldia_catalogo) != 'NA'
ORDER BY 
    TRIM(r.colonia_catalogo),
    a.id_alcaldia,
    -- Priorizar registros con coordenadas
    CASE WHEN r.longitud_clean IS NOT NULL AND r.latitud_clean IS NOT NULL THEN 0 ELSE 1 END
ON CONFLICT (nombre_colonia, id_alcaldia) DO NOTHING;

-- Verificación
SELECT 
    c.id_colonia,
    c.nombre_colonia,
    a.nombre_alcaldia,
    c.centroide_longitud,
    c.centroide_latitud
FROM colonia c
INNER JOIN alcaldia a ON c.id_alcaldia = a.id_alcaldia
ORDER BY a.nombre_alcaldia, c.nombre_colonia
LIMIT 20;

-- =====================================================
-- PASO 7: POBLAR TABLA INCIDENTE
-- Extrae incidentes únicos con sus atributos
-- Ahora incluye coordenadas específicas del incidente
-- =====================================================

INSERT INTO incidente (
    folio_incidente, 
    fecha_registro_incidente, 
    reporte, 
    id_clasificacion,
    id_colonia,
    id_estado,
    longitud_incidente,
    latitud_incidente
)
SELECT DISTINCT ON (TRIM(r.folio_incidente))
    TRIM(r.folio_incidente) AS folio_incidente,
    r.fecha_registro_clean AS fecha_registro_incidente,
    TRIM(r.reporte) AS reporte,
    cl.id_clasificacion,
    co.id_colonia,
    1 AS id_estado, -- Por defecto "Registrado"
    r.longitud_clean AS longitud_incidente,
    r.latitud_clean AS latitud_incidente
FROM reportes r
INNER JOIN clasificacion cl ON TRIM(r.clasificacion) = cl.nombre_clasificacion
LEFT JOIN alcaldia a ON TRIM(r.alcaldia_catalogo) = a.nombre_alcaldia
LEFT JOIN colonia co ON TRIM(r.colonia_catalogo) = co.nombre_colonia 
    AND a.id_alcaldia = co.id_alcaldia
WHERE r.folio_incidente IS NOT NULL 
  AND TRIM(r.folio_incidente) != ''
  AND r.fecha_registro_clean IS NOT NULL
  AND r.clasificacion IS NOT NULL
ORDER BY 
    TRIM(r.folio_incidente),
    r.fecha_registro_clean DESC
ON CONFLICT (folio_incidente) DO NOTHING;

-- Verificación
SELECT 
    i.id_incidente,
    i.folio_incidente,
    i.fecha_registro_incidente,
    cl.nombre_clasificacion,
    co.nombre_colonia,
    a.nombre_alcaldia,
    e.nombre_estado,
    i.longitud_incidente,
    i.latitud_incidente
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
LEFT JOIN colonia co ON i.id_colonia = co.id_colonia
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
ORDER BY i.fecha_registro_incidente DESC
LIMIT 20;

-- =====================================================
-- PASO 8: POBLAR TABLA REPORTE
-- Carga todos los reportes individuales
-- Asocia cada reporte a su incidente mediante JOIN
-- =====================================================

INSERT INTO reporte (
    id_reporte,
    id_incidente,
    fecha_reporte,
    hora_reporte,
    id_medio_recepcion
)
SELECT DISTINCT
    TRIM(r.id_reporte) AS id_reporte,
    i.id_incidente,
    r.fecha_reporte_clean AS fecha_reporte,
    COALESCE(r.hora_reporte::TIME, '00:00:00'::TIME) AS hora_reporte,
    m.id_medio_recepcion
FROM reportes r
INNER JOIN incidente i ON TRIM(r.folio_incidente) = i.folio_incidente
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
ORDER BY rep.fecha_reporte DESC, rep.hora_reporte DESC
LIMIT 20;

-- =====================================================
-- PASO 9: VERIFICACIÓN FINAL DE INTEGRIDAD
-- =====================================================

-- Conteo de registros en cada tabla
SELECT 'clasificacion' AS tabla, COUNT(*) AS total FROM clasificacion
UNION ALL
SELECT 'medio_recepcion', COUNT(*) FROM medio_recepcion
UNION ALL
SELECT 'alcaldia', COUNT(*) FROM alcaldia
UNION ALL
SELECT 'estado_incidente', COUNT(*) FROM estado_incidente
UNION ALL
SELECT 'colonia', COUNT(*) FROM colonia
UNION ALL
SELECT 'incidente', COUNT(*) FROM incidente
UNION ALL
SELECT 'reporte', COUNT(*) FROM reporte
UNION ALL
SELECT 'reportes_originales', COUNT(*) FROM reportes;

-- Verificar integridad referencial
SELECT 
    'Incidentes sin clasificación' AS problema,
    COUNT(*) AS cantidad
FROM incidente i
LEFT JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
WHERE c.id_clasificacion IS NULL

UNION ALL

SELECT 
    'Incidentes sin estado' AS problema,
    COUNT(*) AS cantidad
FROM incidente i
LEFT JOIN estado_incidente e ON i.id_estado = e.id_estado
WHERE e.id_estado IS NULL

UNION ALL

SELECT 
    'Colonias sin alcaldía' AS problema,
    COUNT(*) AS cantidad
FROM colonia co
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
WHERE a.id_alcaldia IS NULL

UNION ALL

SELECT 
    'Reportes sin incidente' AS problema,
    COUNT(*) AS cantidad
FROM reporte r
LEFT JOIN incidente i ON r.id_incidente = i.id_incidente
WHERE i.id_incidente IS NULL

UNION ALL

SELECT 
    'Reportes sin medio' AS problema,
    COUNT(*) AS cantidad
FROM reporte r
LEFT JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
WHERE m.id_medio_recepcion IS NULL;

-- =====================================================
-- PASO 10: ESTADÍSTICAS GENERALES
-- =====================================================

-- Incidentes por clasificación
SELECT 
    c.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion, c.nombre_clasificacion
ORDER BY total_incidentes DESC;

-- Incidentes por alcaldía
SELECT 
    a.nombre_alcaldia,
    COUNT(i.id_incidente) AS total_incidentes
FROM alcaldia a
LEFT JOIN colonia co ON a.id_alcaldia = co.id_alcaldia
LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
GROUP BY a.id_alcaldia, a.nombre_alcaldia
ORDER BY total_incidentes DESC;

-- Incidentes por estado
SELECT 
    e.nombre_estado,
    COUNT(i.id_incidente) AS total_incidentes
FROM estado_incidente e
LEFT JOIN incidente i ON e.id_estado = i.id_estado
GROUP BY e.id_estado, e.nombre_estado, e.orden
ORDER BY e.orden;

-- Reportes por medio de recepción
SELECT 
    m.nombre_medio,
    COUNT(r.id_reporte_pk) AS total_reportes
FROM medio_recepcion m
LEFT JOIN reporte r ON m.id_medio_recepcion = r.id_medio_recepcion
GROUP BY m.id_medio_recepcion, m.nombre_medio
ORDER BY total_reportes DESC;

-- Top 10 colonias con más incidentes
SELECT 
    co.nombre_colonia,
    a.nombre_alcaldia,
    COUNT(i.id_incidente) AS total_incidentes
FROM colonia co
INNER JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
GROUP BY co.id_colonia, co.nombre_colonia, a.nombre_alcaldia
ORDER BY total_incidentes DESC
LIMIT 10;

-- =====================================================
-- COMENTARIOS SOBRE LA MIGRACIÓN
-- =====================================================
/*
MEJORAS EN ESTA VERSIÓN:

1. ALCALDIA: Nueva tabla poblada primero, luego referenciada en COLONIA
   - Elimina redundancia de nombres de alcaldía
   - 16 alcaldías vs potencialmente miles de repeticiones

2. ESTADO_INCIDENTE: Ya poblada en el schema con estados predefinidos
   - Todos los incidentes se crean con estado "Registrado" (id_estado = 1)
   - Permite posterior actualización de estados de forma validada

3. COLONIA (antes UBICACION):
   - Ahora tiene FK a ALCALDIA en lugar de almacenar nombre
   - Coordenadas renombradas a centroide_* para claridad
   - UNIQUE constraint en (nombre_colonia, id_alcaldia)

4. INCIDENTE:
   - Incluye id_estado (FK a estado_incidente)
   - longitud_incidente/latitud_incidente para punto exacto
   - Mantiene id_colonia para el área general

5. REPORTE: Sin cambios estructurales

ORDEN DE CARGA:
1. clasificacion (independiente)
2. medio_recepcion (independiente)
3. alcaldia (independiente) ← NUEVO
4. estado_incidente (ya poblado en schema) ← NUEVO
5. colonia (depende de alcaldia) ← REFACTORIZADO
6. incidente (depende de clasificacion, colonia, estado) ← ACTUALIZADO
7. reporte (depende de incidente, medio_recepcion)

VERIFICACIONES:
- Conteo de registros en todas las tablas
- Integridad referencial (FKs válidas)
- Estadísticas por dimensión
- Top colonias con más incidentes

DATOS ESPERADOS (depende del CSV):
- clasificacion: ~2-5 registros (Agua Potable, Drenaje, etc.)
- medio_recepcion: ~5-10 registros (Call Center, App, Web, etc.)
- alcaldia: 16 registros (las 16 alcaldías de CDMX)
- estado_incidente: 5 registros (predefinidos)
- colonia: ~1,800+ colonias de la CDMX
- incidente: ~200,000+ incidentes únicos (según folio)
- reporte: ~300,000+ reportes individuales
*/
