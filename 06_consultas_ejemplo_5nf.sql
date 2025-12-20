-- =====================================================
-- CONSULTAS DE EJEMPLO - SCHEMA 5NF MEJORADO
-- Sistema de Reportes de Agua - CDMX
-- =====================================================
--
-- DESCRIPCIÓN:
-- Consultas de ejemplo que demuestran el uso del schema normalizado en 5NF.
-- Incluye consultas simples, agregaciones y análisis complejos.
-- VERSIÓN MEJORADA con alcaldia y estado_incidente
--
-- =====================================================

-- =====================================================
-- CONSULTAS BÁSICAS POR TABLA
-- =====================================================

-- 1. Ver todas las clasificaciones
SELECT * FROM clasificacion ORDER BY nombre_clasificacion;

-- 2. Ver todos los medios de recepción
SELECT * FROM medio_recepcion ORDER BY nombre_medio;

-- 3. Ver todas las alcaldías (NUEVO)
SELECT * FROM alcaldia ORDER BY nombre_alcaldia;

-- 4. Ver todos los estados de incidente (NUEVO)
SELECT * FROM estado_incidente ORDER BY orden;

-- 5. Ver colonias con sus alcaldías (REFACTORIZADO)
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

-- 6. Ver incidentes con todas sus relaciones (MEJORADO)
SELECT 
    i.id_incidente,
    i.folio_incidente,
    i.fecha_registro_incidente,
    cl.nombre_clasificacion,
    e.nombre_estado,
    c.nombre_colonia,
    a.nombre_alcaldia,
    i.reporte,
    i.longitud_incidente,
    i.latitud_incidente
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
LEFT JOIN colonia c ON i.id_colonia = c.id_colonia
LEFT JOIN alcaldia a ON c.id_alcaldia = a.id_alcaldia
ORDER BY i.fecha_registro_incidente DESC
LIMIT 20;

-- 7. Ver reportes con información completa
SELECT 
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    m.nombre_medio,
    i.folio_incidente,
    cl.nombre_clasificacion,
    co.nombre_colonia,
    a.nombre_alcaldia
FROM reporte r
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
LEFT JOIN colonia co ON i.id_colonia = co.id_colonia
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
ORDER BY r.fecha_reporte DESC, r.hora_reporte DESC
LIMIT 20;

-- =====================================================
-- AGREGACIONES Y ESTADÍSTICAS
-- =====================================================

-- 8. Contar incidentes por clasificación
SELECT 
    cl.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / SUM(COUNT(i.id_incidente)) OVER(), 2) AS porcentaje
FROM clasificacion cl
LEFT JOIN incidente i ON cl.id_clasificacion = i.id_clasificacion
GROUP BY cl.id_clasificacion, cl.nombre_clasificacion
ORDER BY total_incidentes DESC;

-- 9. Contar incidentes por alcaldía (NUEVO - aprovecha nueva estructura)
SELECT 
    a.nombre_alcaldia,
    COUNT(i.id_incidente) AS total_incidentes,
    COUNT(DISTINCT c.id_colonia) AS colonias_afectadas,
    ROUND(COUNT(i.id_incidente) * 100.0 / SUM(COUNT(i.id_incidente)) OVER(), 2) AS porcentaje
FROM alcaldia a
LEFT JOIN colonia c ON a.id_alcaldia = c.id_alcaldia
LEFT JOIN incidente i ON c.id_colonia = i.id_colonia
GROUP BY a.id_alcaldia, a.nombre_alcaldia
ORDER BY total_incidentes DESC;

-- 10. Incidentes por estado (NUEVO)
SELECT 
    e.nombre_estado,
    e.descripcion,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / SUM(COUNT(i.id_incidente)) OVER(), 2) AS porcentaje
FROM estado_incidente e
LEFT JOIN incidente i ON e.id_estado = i.id_estado
GROUP BY e.id_estado, e.nombre_estado, e.descripcion, e.orden
ORDER BY e.orden;

-- 11. Reportes por medio de recepción
SELECT 
    m.nombre_medio,
    COUNT(r.id_reporte_pk) AS total_reportes,
    ROUND(COUNT(r.id_reporte_pk) * 100.0 / SUM(COUNT(r.id_reporte_pk)) OVER(), 2) AS porcentaje
FROM medio_recepcion m
LEFT JOIN reporte r ON m.id_medio_recepcion = r.id_medio_recepcion
GROUP BY m.id_medio_recepcion, m.nombre_medio
ORDER BY total_reportes DESC;

-- 12. Top 10 colonias con más incidentes
SELECT 
    c.nombre_colonia,
    a.nombre_alcaldia,
    COUNT(i.id_incidente) AS total_incidentes,
    COUNT(DISTINCT i.id_clasificacion) AS tipos_problemas
FROM colonia c
INNER JOIN alcaldia a ON c.id_alcaldia = a.id_alcaldia
LEFT JOIN incidente i ON c.id_colonia = i.id_colonia
GROUP BY c.id_colonia, c.nombre_colonia, a.nombre_alcaldia
ORDER BY total_incidentes DESC
LIMIT 10;

-- 13. Incidentes con múltiples reportes (los más reportados)
SELECT 
    i.folio_incidente,
    i.fecha_registro_incidente,
    cl.nombre_clasificacion,
    co.nombre_colonia,
    a.nombre_alcaldia,
    COUNT(r.id_reporte_pk) AS num_reportes
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
LEFT JOIN colonia co ON i.id_colonia = co.id_colonia
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
LEFT JOIN reporte r ON i.id_incidente = r.id_incidente
GROUP BY i.id_incidente, i.folio_incidente, i.fecha_registro_incidente, 
         cl.nombre_clasificacion, co.nombre_colonia, a.nombre_alcaldia
HAVING COUNT(r.id_reporte_pk) > 1
ORDER BY num_reportes DESC
LIMIT 20;

-- =====================================================
-- ANÁLISIS TEMPORAL
-- =====================================================

-- 14. Incidentes por mes
SELECT 
    TO_CHAR(fecha_registro_incidente, 'YYYY-MM') AS mes,
    COUNT(*) AS total_incidentes
FROM incidente
GROUP BY TO_CHAR(fecha_registro_incidente, 'YYYY-MM')
ORDER BY mes;

-- 15. Reportes por día de la semana
SELECT 
    TO_CHAR(fecha_reporte, 'Day') AS dia_semana,
    EXTRACT(DOW FROM fecha_reporte) AS numero_dia,
    COUNT(*) AS total_reportes
FROM reporte
GROUP BY TO_CHAR(fecha_reporte, 'Day'), EXTRACT(DOW FROM fecha_reporte)
ORDER BY numero_dia;

-- 16. Reportes por hora del día
SELECT 
    EXTRACT(HOUR FROM hora_reporte) AS hora,
    COUNT(*) AS total_reportes
FROM reporte
WHERE hora_reporte IS NOT NULL
GROUP BY EXTRACT(HOUR FROM hora_reporte)
ORDER BY hora;

-- =====================================================
-- ANÁLISIS POR CLASIFICACIÓN Y UBICACIÓN
-- =====================================================

-- 17. Distribución de clasificaciones por alcaldía (MEJORADO)
SELECT 
    a.nombre_alcaldia,
    cl.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes
FROM alcaldia a
LEFT JOIN colonia co ON a.id_alcaldia = co.id_alcaldia
LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
LEFT JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
WHERE cl.nombre_clasificacion IS NOT NULL
GROUP BY a.nombre_alcaldia, cl.nombre_clasificacion
ORDER BY a.nombre_alcaldia, total_incidentes DESC;

-- 18. Alcaldías por tipo de problema predominante (NUEVO)
WITH alcaldia_clasificacion AS (
    SELECT 
        a.id_alcaldia,
        a.nombre_alcaldia,
        cl.nombre_clasificacion,
        COUNT(i.id_incidente) AS total_incidentes,
        ROW_NUMBER() OVER (PARTITION BY a.id_alcaldia ORDER BY COUNT(i.id_incidente) DESC) AS rank
    FROM alcaldia a
    LEFT JOIN colonia co ON a.id_alcaldia = co.id_alcaldia
    LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
    LEFT JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
    WHERE cl.nombre_clasificacion IS NOT NULL
    GROUP BY a.id_alcaldia, a.nombre_alcaldia, cl.nombre_clasificacion
)
SELECT 
    nombre_alcaldia,
    nombre_clasificacion AS problema_principal,
    total_incidentes
FROM alcaldia_clasificacion
WHERE rank = 1
ORDER BY total_incidentes DESC;

-- =====================================================
-- ANÁLISIS GEOESPACIAL
-- =====================================================

-- 19. Incidentes con coordenadas exactas (NUEVO - usando coordenadas de incidente)
SELECT 
    i.folio_incidente,
    cl.nombre_clasificacion,
    co.nombre_colonia,
    a.nombre_alcaldia,
    i.longitud_incidente,
    i.latitud_incidente,
    co.centroide_longitud AS longitud_colonia,
    co.centroide_latitud AS latitud_colonia
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
LEFT JOIN colonia co ON i.id_colonia = co.id_colonia
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia
WHERE i.longitud_incidente IS NOT NULL 
  AND i.latitud_incidente IS NOT NULL
ORDER BY i.fecha_registro_incidente DESC
LIMIT 20;

-- 20. Alcaldías con más incidentes geolocalizados (NUEVO)
SELECT 
    a.nombre_alcaldia,
    COUNT(i.id_incidente) AS total_incidentes,
    COUNT(CASE WHEN i.longitud_incidente IS NOT NULL THEN 1 END) AS con_coordenadas,
    ROUND(
        COUNT(CASE WHEN i.longitud_incidente IS NOT NULL THEN 1 END) * 100.0 / 
        NULLIF(COUNT(i.id_incidente), 0), 
        2
    ) AS porcentaje_geolocalizados
FROM alcaldia a
LEFT JOIN colonia co ON a.id_alcaldia = co.id_alcaldia
LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
GROUP BY a.id_alcaldia, a.nombre_alcaldia
HAVING COUNT(i.id_incidente) > 0
ORDER BY porcentaje_geolocalizados DESC;

-- =====================================================
-- ANÁLISIS DE ESTADO DE INCIDENTES (NUEVO)
-- =====================================================

-- 21. Distribución de estados por clasificación
SELECT 
    cl.nombre_clasificacion,
    e.nombre_estado,
    COUNT(i.id_incidente) AS total_incidentes,
    ROUND(COUNT(i.id_incidente) * 100.0 / SUM(COUNT(i.id_incidente)) OVER (PARTITION BY cl.nombre_clasificacion), 2) AS porcentaje
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
GROUP BY cl.nombre_clasificacion, e.nombre_estado, e.orden
ORDER BY cl.nombre_clasificacion, e.orden;

-- 22. Distribución de estados por alcaldía (NUEVO)
SELECT 
    a.nombre_alcaldia,
    e.nombre_estado,
    COUNT(i.id_incidente) AS total_incidentes
FROM alcaldia a
LEFT JOIN colonia co ON a.id_alcaldia = co.id_alcaldia
LEFT JOIN incidente i ON co.id_colonia = i.id_colonia
LEFT JOIN estado_incidente e ON i.id_estado = e.id_estado
WHERE e.nombre_estado IS NOT NULL
GROUP BY a.nombre_alcaldia, e.nombre_estado, e.orden
ORDER BY a.nombre_alcaldia, e.orden;

-- =====================================================
-- CONSULTAS DE VALIDACIÓN Y CALIDAD DE DATOS
-- =====================================================

-- 23. Incidentes sin ubicación
SELECT 
    COUNT(*) AS incidentes_sin_ubicacion,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incidente), 2) AS porcentaje
FROM incidente
WHERE id_colonia IS NULL;

-- 24. Incidentes sin coordenadas específicas (NUEVO)
SELECT 
    COUNT(*) AS incidentes_sin_coordenadas,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM incidente), 2) AS porcentaje
FROM incidente
WHERE longitud_incidente IS NULL OR latitud_incidente IS NULL;

-- 25. Colonias sin coordenadas de centroide (ACTUALIZADO)
SELECT 
    c.nombre_colonia,
    a.nombre_alcaldia
FROM colonia c
INNER JOIN alcaldia a ON c.id_alcaldia = a.id_alcaldia
WHERE c.centroide_longitud IS NULL OR c.centroide_latitud IS NULL
ORDER BY a.nombre_alcaldia, c.nombre_colonia;

-- =====================================================
-- VISTAS ÚTILES (OPCIONAL)
-- =====================================================

-- Vista: Incidentes con información completa
CREATE OR REPLACE VIEW v_incidentes_completos AS
SELECT 
    i.id_incidente,
    i.folio_incidente,
    i.fecha_registro_incidente,
    i.reporte,
    cl.nombre_clasificacion,
    e.nombre_estado,
    c.nombre_colonia,
    a.nombre_alcaldia,
    i.longitud_incidente,
    i.latitud_incidente,
    c.centroide_longitud AS longitud_colonia,
    c.centroide_latitud AS latitud_colonia,
    i.fecha_creacion,
    i.fecha_actualizacion
FROM incidente i
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
LEFT JOIN colonia c ON i.id_colonia = c.id_colonia
LEFT JOIN alcaldia a ON c.id_alcaldia = a.id_alcaldia;

-- Vista: Reportes con información completa
CREATE OR REPLACE VIEW v_reportes_completos AS
SELECT 
    r.id_reporte_pk,
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    m.nombre_medio,
    i.folio_incidente,
    i.fecha_registro_incidente,
    cl.nombre_clasificacion,
    e.nombre_estado,
    co.nombre_colonia,
    a.nombre_alcaldia,
    i.reporte AS descripcion_incidente
FROM reporte r
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion cl ON i.id_clasificacion = cl.id_clasificacion
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
LEFT JOIN colonia co ON i.id_colonia = co.id_colonia
LEFT JOIN alcaldia a ON co.id_alcaldia = a.id_alcaldia;

-- Vista: Estadísticas por alcaldía (NUEVA)
CREATE OR REPLACE VIEW v_estadisticas_alcaldia AS
SELECT 
    a.id_alcaldia,
    a.nombre_alcaldia,
    COUNT(DISTINCT c.id_colonia) AS total_colonias,
    COUNT(DISTINCT i.id_incidente) AS total_incidentes,
    COUNT(DISTINCT r.id_reporte_pk) AS total_reportes,
    ROUND(AVG(CASE WHEN i.id_incidente IS NOT NULL THEN 
        (SELECT COUNT(*) FROM reporte WHERE id_incidente = i.id_incidente) 
    END), 2) AS promedio_reportes_por_incidente
FROM alcaldia a
LEFT JOIN colonia c ON a.id_alcaldia = c.id_alcaldia
LEFT JOIN incidente i ON c.id_colonia = i.id_colonia
LEFT JOIN reporte r ON i.id_incidente = r.id_incidente
GROUP BY a.id_alcaldia, a.nombre_alcaldia;

-- Ejemplo de uso de las vistas
SELECT * FROM v_incidentes_completos LIMIT 10;
SELECT * FROM v_reportes_completos LIMIT 10;
SELECT * FROM v_estadisticas_alcaldia ORDER BY total_incidentes DESC;

-- =====================================================
-- COMENTARIOS
-- =====================================================
/*
MEJORAS EN ESTA VERSIÓN:

1. CONSULTAS CON ALCALDIA:
   - Ahora se hace JOIN con la tabla alcaldia
   - Elimina la necesidad de agrupar por string de alcaldia_catalogo
   - Más eficiente y sin duplicados por variaciones de nombre

2. CONSULTAS CON ESTADO_INCIDENTE:
   - Nueva dimensión de análisis: estado de incidentes
   - Permite análisis del ciclo de vida de incidentes
   - Filtros validados (no más strings arbitrarios)

3. COORDENADAS:
   - Diferenciación entre centroide de colonia y punto exacto de incidente
   - Permite análisis geoespaciales más precisos
   - Consultas que muestran ambos tipos de coordenadas

4. VISTAS MATERIALIZABLES:
   - Las vistas pueden convertirse en materializadas para performance
   - Especialmente útil v_estadisticas_alcaldia para dashboards

ÍNDICES QUE MEJORAN EL PERFORMANCE:
- idx_nombre_alcaldia en alcaldia
- idx_alcaldia_colonia en colonia (JOIN alcaldia→colonia)
- idx_colonia_incidente en incidente (JOIN colonia→incidente)
- idx_estado_incidente en incidente (JOIN estado→incidente)
- Todos los índices de FK aceleran los JOINs

RECOMENDACIONES:
- Para reportes frecuentes, considerar vistas materializadas
- Para análisis geoespacial avanzado, usar PostGIS
- Para dashboards en tiempo real, cachear resultados de agregaciones
*/
