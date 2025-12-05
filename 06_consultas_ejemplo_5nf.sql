-- =====================================================
-- CONSULTAS DE EJEMPLO - BASE DE DATOS 5NF
-- Sistema de Reportes de Agua - CDMX
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este archivo contiene consultas de ejemplo que demuestran
-- cómo trabajar con el schema normalizado en 5NF.
-- Incluye consultas básicas, intermedias y avanzadas.
--
-- =====================================================

-- =====================================================
-- CONSULTAS BÁSICAS
-- =====================================================

-- 1. Listar todos los incidentes con su información completa
SELECT 
    i.folio_incidente,
    i.fecha_registro_incidente,
    c.nombre_clasificacion,
    i.reporte,
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    u.longitud,
    u.latitud
FROM incidente i
LEFT JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
ORDER BY i.fecha_registro_incidente DESC
LIMIT 50;

-- 2. Listar todos los reportes con información del incidente asociado
SELECT 
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    i.folio_incidente,
    i.reporte AS descripcion_incidente,
    m.nombre_medio,
    c.nombre_clasificacion
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
ORDER BY r.fecha_reporte DESC, r.hora_reporte DESC
LIMIT 50;

-- =====================================================
-- CONSULTAS DE ANÁLISIS - ESTADÍSTICAS GENERALES
-- =====================================================

-- 3. Total de incidentes por clasificación
SELECT 
    c.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / (SELECT COUNT(*) FROM incidente), 2) AS porcentaje
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion, c.nombre_clasificacion
ORDER BY total_incidentes DESC;

-- 4. Total de reportes por medio de recepción
SELECT 
    m.nombre_medio,
    COUNT(r.id_reporte_pk) AS total_reportes,
    ROUND(COUNT(r.id_reporte_pk) * 100.0 / (SELECT COUNT(*) FROM reporte), 2) AS porcentaje
FROM medio_recepcion m
LEFT JOIN reporte r ON m.id_medio_recepcion = r.id_medio_recepcion
GROUP BY m.id_medio_recepcion, m.nombre_medio
ORDER BY total_reportes DESC;

-- 5. Top 10 colonias con más incidentes
SELECT 
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    COUNT(i.id_incidente) AS total_incidentes
FROM ubicacion u
INNER JOIN incidente i ON u.id_colonia = i.id_colonia
GROUP BY u.id_colonia, u.colonia_catalogo, u.alcaldia_catalogo
ORDER BY total_incidentes DESC
LIMIT 10;

-- 6. Top 10 alcaldías con más incidentes
SELECT 
    u.alcaldia_catalogo,
    COUNT(i.id_incidente) AS total_incidentes,
    COUNT(DISTINCT u.id_colonia) AS colonias_afectadas
FROM ubicacion u
INNER JOIN incidente i ON u.id_colonia = i.id_colonia
GROUP BY u.alcaldia_catalogo
ORDER BY total_incidentes DESC
LIMIT 10;

-- =====================================================
-- CONSULTAS TEMPORALES - ANÁLISIS POR FECHA
-- =====================================================

-- 7. Incidentes por mes
SELECT 
    TO_CHAR(i.fecha_registro_incidente, 'YYYY-MM') AS mes,
    COUNT(i.id_incidente) AS total_incidentes,
    COUNT(DISTINCT i.id_colonia) AS colonias_afectadas
FROM incidente i
GROUP BY TO_CHAR(i.fecha_registro_incidente, 'YYYY-MM')
ORDER BY mes;

-- 8. Reportes por día de la semana
SELECT 
    TO_CHAR(r.fecha_reporte, 'Day') AS dia_semana,
    EXTRACT(DOW FROM r.fecha_reporte) AS dia_numero,
    COUNT(r.id_reporte_pk) AS total_reportes
FROM reporte r
GROUP BY TO_CHAR(r.fecha_reporte, 'Day'), EXTRACT(DOW FROM r.fecha_reporte)
ORDER BY dia_numero;

-- 9. Reportes por hora del día (distribución horaria)
SELECT 
    EXTRACT(HOUR FROM r.hora_reporte) AS hora,
    COUNT(r.id_reporte_pk) AS total_reportes
FROM reporte r
GROUP BY hora
ORDER BY hora;

-- =====================================================
-- CONSULTAS AVANZADAS - RELACIONES MÚLTIPLES
-- =====================================================

-- 10. Incidentes con múltiples reportes (más reportados)
SELECT 
    i.folio_incidente,
    i.reporte AS descripcion,
    c.nombre_clasificacion,
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    COUNT(r.id_reporte_pk) AS total_reportes,
    MIN(r.fecha_reporte) AS primer_reporte,
    MAX(r.fecha_reporte) AS ultimo_reporte,
    (MAX(r.fecha_reporte) - MIN(r.fecha_reporte)) AS dias_diferencia
FROM incidente i
INNER JOIN reporte r ON i.id_incidente = r.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
GROUP BY i.id_incidente, i.folio_incidente, i.reporte, c.nombre_clasificacion, 
         u.colonia_catalogo, u.alcaldia_catalogo
HAVING COUNT(r.id_reporte_pk) > 1
ORDER BY total_reportes DESC, dias_diferencia DESC
LIMIT 20;

-- 11. Matriz: Clasificación vs Alcaldía
SELECT 
    u.alcaldia_catalogo,
    c.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes
FROM incidente i
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
WHERE u.alcaldia_catalogo IS NOT NULL
GROUP BY u.alcaldia_catalogo, c.nombre_clasificacion
ORDER BY u.alcaldia_catalogo, total_incidentes DESC;

-- 12. Análisis de tiempo de respuesta (diferencia fecha incidente vs reporte)
SELECT 
    c.nombre_clasificacion,
    AVG(i.fecha_registro_incidente - r.fecha_reporte) AS dias_promedio_diferencia,
    MIN(i.fecha_registro_incidente - r.fecha_reporte) AS min_dias,
    MAX(i.fecha_registro_incidente - r.fecha_reporte) AS max_dias,
    COUNT(*) AS total_casos
FROM incidente i
INNER JOIN reporte r ON i.id_incidente = r.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
GROUP BY c.id_clasificacion, c.nombre_clasificacion
ORDER BY dias_promedio_diferencia DESC;

-- =====================================================
-- CONSULTAS GEOESPACIALES
-- =====================================================

-- 13. Incidentes con coordenadas válidas
SELECT 
    i.folio_incidente,
    i.reporte,
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    u.latitud,
    u.longitud
FROM incidente i
INNER JOIN ubicacion u ON i.id_colonia = u.id_colonia
WHERE u.latitud IS NOT NULL 
  AND u.longitud IS NOT NULL
ORDER BY i.fecha_registro_incidente DESC
LIMIT 100;

-- 14. Densidad de incidentes por coordenadas (clustering básico)
SELECT 
    ROUND(u.latitud::numeric, 2) AS latitud_aprox,
    ROUND(u.longitud::numeric, 2) AS longitud_aprox,
    COUNT(i.id_incidente) AS total_incidentes,
    STRING_AGG(DISTINCT c.nombre_clasificacion, ', ') AS tipos_incidentes
FROM incidente i
INNER JOIN ubicacion u ON i.id_colonia = u.id_colonia
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
WHERE u.latitud IS NOT NULL 
  AND u.longitud IS NOT NULL
GROUP BY latitud_aprox, longitud_aprox
HAVING COUNT(i.id_incidente) > 5
ORDER BY total_incidentes DESC
LIMIT 50;

-- =====================================================
-- CONSULTAS DE CALIDAD DE DATOS
-- =====================================================

-- 15. Incidentes sin ubicación
SELECT 
    COUNT(*) AS total_sin_ubicacion,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incidente), 2) AS porcentaje
FROM incidente
WHERE id_colonia IS NULL;

-- 16. Ubicaciones sin coordenadas
SELECT 
    colonia_catalogo,
    alcaldia_catalogo,
    COUNT(*) AS incidentes_afectados
FROM ubicacion u
INNER JOIN incidente i ON u.id_colonia = i.id_colonia
WHERE u.latitud IS NULL 
   OR u.longitud IS NULL
GROUP BY u.id_colonia, u.colonia_catalogo, u.alcaldia_catalogo
ORDER BY incidentes_afectados DESC
LIMIT 20;

-- 17. Reporte completo de calidad de datos
SELECT 
    'Total Clasificaciones' AS metrica,
    COUNT(*) AS valor
FROM clasificacion
UNION ALL
SELECT 
    'Total Medios de Recepción' AS metrica,
    COUNT(*) AS valor
FROM medio_recepcion
UNION ALL
SELECT 
    'Total Ubicaciones' AS metrica,
    COUNT(*) AS valor
FROM ubicacion
UNION ALL
SELECT 
    'Ubicaciones con Coordenadas' AS metrica,
    COUNT(*) AS valor
FROM ubicacion
WHERE latitud IS NOT NULL AND longitud IS NOT NULL
UNION ALL
SELECT 
    'Total Incidentes' AS metrica,
    COUNT(*) AS valor
FROM incidente
UNION ALL
SELECT 
    'Incidentes con Ubicación' AS metrica,
    COUNT(*) AS valor
FROM incidente
WHERE id_colonia IS NOT NULL
UNION ALL
SELECT 
    'Total Reportes' AS metrica,
    COUNT(*) AS valor
FROM reporte;

-- =====================================================
-- CONSULTAS DE RECONSTRUCCIÓN - VISTA ORIGINAL
-- =====================================================

-- 18. Reconstruir la tabla original (join completo)
-- Esta consulta demuestra que podemos reconstruir la tabla original
-- desde las tablas normalizadas (prueba de descomposición sin pérdida)
SELECT 
    i.folio_incidente,
    i.fecha_registro_incidente,
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    c.nombre_clasificacion AS clasificacion,
    i.reporte,
    m.nombre_medio AS medio_recepcion,
    u.alcaldia_catalogo,
    u.colonia_catalogo,
    u.longitud,
    u.latitud
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
ORDER BY r.fecha_reporte DESC, r.hora_reporte DESC
LIMIT 100;

-- =====================================================
-- VISTAS ÚTILES (OPCIONAL)
-- =====================================================

-- Vista: incidentes completos
CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT 
    i.id_incidente,
    i.folio_incidente,
    i.fecha_registro_incidente,
    i.reporte,
    i.estado,
    c.nombre_clasificacion,
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    u.latitud,
    u.longitud,
    i.fecha_creacion,
    i.fecha_actualizacion
FROM incidente i
LEFT JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia;

-- Vista: reportes completos
CREATE OR REPLACE VIEW v_reportes_completos AS
SELECT 
    r.id_reporte_pk,
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    i.folio_incidente,
    i.reporte AS descripcion_incidente,
    c.nombre_clasificacion,
    m.nombre_medio,
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    r.fecha_creacion
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia;

-- Ejemplo de uso de las vistas
SELECT * FROM v_incidentes_completos
WHERE alcaldia_catalogo = 'Coyoacán'
ORDER BY fecha_registro_incidente DESC
LIMIT 20;

SELECT * FROM v_reportes_completos
WHERE nombre_clasificacion = 'Agua Potable'
  AND fecha_reporte >= '2022-01-01'
ORDER BY fecha_reporte DESC, hora_reporte DESC
LIMIT 20;

-- =====================================================
-- FIN DE CONSULTAS DE EJEMPLO
-- =====================================================

/*
NOTAS:

1. PERFORMANCE:
   - Las consultas están optimizadas con los índices definidos en el schema
   - Para grandes volúmenes considerar particionamiento por fecha
   - Las vistas facilitan consultas frecuentes pero no se materializan automáticamente

2. JOINS:
   - LEFT JOIN: permite NULL en la tabla derecha (ej: ubicación opcional)
   - INNER JOIN: requiere match en ambas tablas (ej: clasificación obligatoria)

3. AGREGACIONES:
   - GROUP BY debe incluir todas las columnas no agregadas en SELECT
   - HAVING filtra después de la agregación, WHERE antes

4. FUNCIONES POSTGRESQL:
   - TO_CHAR(fecha, 'YYYY-MM'): Formatear fechas
   - EXTRACT(HOUR FROM hora): Extraer parte de fecha/hora
   - STRING_AGG(texto, separador): Concatenar strings
   - (fecha1 - fecha2): Diferencia de fechas en días

5. EXTENSIONES:
   - Agregar índices full-text para búsquedas en campo 'reporte'
   - Considerar índices espaciales (PostGIS) para consultas geográficas complejas
   - Implementar funciones almacenadas para operaciones frecuentes
*/
