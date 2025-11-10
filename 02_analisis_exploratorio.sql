-- ============================================================================
-- B) Análisis exploratorio de datos
-- ============================================================================

-- 1. ¿Existen columnas con valores únicos?
SELECT COUNT(DISTINCT folio_incidente) AS folios_unicos,
       COUNT(*) AS total_filas
FROM reportes;

-- 2. Mínimos y máximos de fechas
SELECT MIN(fecha_reporte) AS fecha_minima,
       MAX(fecha_reporte) AS fecha_maxima
FROM reportes;

-- 3. Mínimos, máximos y promedios de valores numéricos (coordenadas)
SELECT MIN(CAST(longitud AS NUMERIC)) AS longitud_minima,
       MAX(CAST(longitud AS NUMERIC)) AS longitud_maxima,
       AVG(CAST(longitud AS NUMERIC)) AS longitud_promedio
FROM reportes
WHERE longitud ~ '^-?[0-9]+\.?[0-9]*$';

SELECT MIN(CAST(latitud AS NUMERIC)) AS latitud_minima,
       MAX(CAST(latitud AS NUMERIC)) AS latitud_maxima,
       AVG(CAST(latitud AS NUMERIC)) AS latitud_promedio
FROM reportes
WHERE latitud ~ '^-?[0-9]+\.?[0-9]*$';

-- 4. Duplicados en atributos categóricos
SELECT folio_incidente, COUNT(*) AS repeticiones
FROM reportes
GROUP BY folio_incidente
HAVING COUNT(*) > 1
ORDER BY repeticiones DESC
LIMIT 10;

-- 5. Columnas redundantes (verificar si hay valores constantes)
SELECT COUNT(DISTINCT clasificacion) AS distintas_clasificaciones,
       COUNT(DISTINCT alcaldia_catalogo) AS distintas_alcaldias
FROM reportes;

-- 6. Conteo de tuplas por cada categoría
SELECT alcaldia_catalogo, COUNT(*) AS num_reportes
FROM reportes
GROUP BY alcaldia_catalogo
ORDER BY num_reportes DESC;

SELECT clasificacion, COUNT(*) AS num_reportes
FROM reportes
GROUP BY clasificacion;

SELECT reporte, COUNT(*) AS num_reportes
FROM reportes
GROUP BY reporte
ORDER BY num_reportes DESC;

-- 7. Conteo de valores nulos
SELECT COUNT(*) AS total_registros,
       SUM(CASE WHEN alcaldia_catalogo IS NULL OR alcaldia_catalogo = 'NA' THEN 1 ELSE 0 END) AS nulos_alcaldia,
       SUM(CASE WHEN colonia_catalogo IS NULL OR colonia_catalogo = 'NA' THEN 1 ELSE 0 END) AS nulos_colonia,
       SUM(CASE WHEN longitud IS NULL OR longitud = '' THEN 1 ELSE 0 END) AS nulos_longitud,
       SUM(CASE WHEN latitud IS NULL OR latitud = '' THEN 1 ELSE 0 END) AS nulos_latitud
FROM reportes;

-- 8. ¿Existen inconsistencias en el set de datos?
-- Verificar fechas con formato incorrecto
SELECT fecha_reporte, COUNT(*) AS ocurrencias
FROM reportes
WHERE fecha_reporte !~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
GROUP BY fecha_reporte
LIMIT 10;

-- Verificar coordenadas fuera de rango de CDMX
SELECT COUNT(*) AS coordenadas_fuera_rango
FROM reportes
WHERE (CAST(longitud AS NUMERIC) < -99.35 OR CAST(longitud AS NUMERIC) > -98.95)
   OR (CAST(latitud AS NUMERIC) < 19.05 OR CAST(latitud AS NUMERIC) > 19.60);
