-- ============================================================================
-- C) Limpieza de datos
-- ============================================================================

-- Paso 1: Crear tabla de respaldo
CREATE TABLE reportes_raw AS TABLE reportes;

SELECT COUNT(*) AS registros_respaldo FROM reportes_raw;

-- Paso 2: Eliminar filas completamente vacías
DELETE FROM reportes
WHERE (folio_incidente IS NULL OR folio_incidente = '')
  AND (id_reporte IS NULL OR id_reporte = '')
  AND (fecha_reporte IS NULL OR fecha_reporte = '');

-- Verificar cuántos registros se eliminaron
SELECT 
    (SELECT COUNT(*) FROM reportes_raw) AS registros_originales,
    (SELECT COUNT(*) FROM reportes) AS registros_actuales;

-- Paso 3: Limpiar fechas - crear columnas nuevas con tipo DATE
ALTER TABLE reportes 
ADD COLUMN fecha_reporte_clean DATE,
ADD COLUMN fecha_registro_clean DATE;

UPDATE reportes
SET fecha_reporte_clean = TO_DATE(fecha_reporte, 'YYYY-MM-DD')
WHERE fecha_reporte ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

UPDATE reportes
SET fecha_registro_clean = TO_DATE(fecha_registro_incidente, 'YYYY-MM-DD')
WHERE fecha_registro_incidente ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Paso 4: Limpiar coordenadas - crear columnas nuevas con tipo NUMERIC
ALTER TABLE reportes
ADD COLUMN longitud_clean NUMERIC,
ADD COLUMN latitud_clean NUMERIC;

UPDATE reportes
SET longitud_clean = CAST(longitud AS NUMERIC)
WHERE longitud ~ '^-?[0-9]+\.?[0-9]*$';

UPDATE reportes
SET latitud_clean = CAST(latitud AS NUMERIC)
WHERE latitud ~ '^-?[0-9]+\.?[0-9]*$';

-- Paso 5: Reemplazar 'NA' por NULL en alcaldía y colonia
UPDATE reportes
SET alcaldia_catalogo = NULL
WHERE alcaldia_catalogo = 'NA' OR alcaldia_catalogo = '';

UPDATE reportes
SET colonia_catalogo = NULL
WHERE colonia_catalogo = 'NA' OR colonia_catalogo = '';

-- Paso 6: Eliminar duplicados exactos
DELETE FROM reportes a
USING reportes b
WHERE a.ctid < b.ctid
  AND a.folio_incidente = b.folio_incidente
  AND a.id_reporte = b.id_reporte;

-- Paso 7: Verificar la limpieza
SELECT COUNT(*) AS total_registros_limpios FROM reportes;

SELECT
    COUNT(*) AS total_registros,
    SUM(CASE WHEN fecha_reporte_clean IS NULL THEN 1 ELSE 0 END) AS sin_fecha,
    SUM(CASE WHEN alcaldia_catalogo IS NULL THEN 1 ELSE 0 END) AS sin_alcaldia,
    SUM(CASE WHEN longitud_clean IS NULL THEN 1 ELSE 0 END) AS sin_coordenadas
FROM reportes;

-- Paso 8: Ver algunos registros limpios
SELECT folio_incidente,
       fecha_reporte_clean,
       clasificacion,
       reporte,
       alcaldia_catalogo,
       longitud_clean,
       latitud_clean
FROM reportes
LIMIT 10;
