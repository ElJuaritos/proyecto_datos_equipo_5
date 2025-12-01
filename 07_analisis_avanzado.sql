-- =====================================================
-- ANÁLISIS AVANZADO DE DATOS CON ATRIBUTOS ANALÍTICOS
-- Sistema de Reportes de Agua - CDMX
-- =====================================================
--
-- DESCRIPCIÓN:
-- Este script contiene consultas analíticas avanzadas que utilizan
-- funciones de ventana, CTEs y atributos enriquecidos para atacar
-- el objetivo del proyecto: identificar patrones, zonas críticas,
-- tendencias temporales y calidad del servicio.
--
-- PREREQUISITOS:
-- - Ejecutar 04_schema_5nf.sql
-- - Ejecutar 05_migracion_a_5nf.sql
-- =====================================================

-- =====================================================
-- 1. RANKING DE COLONIAS MÁS AFECTADAS POR ALCALDÍA
-- Atributo analítico: ranking_colonia, porcentaje_incidentes
-- =====================================================

WITH colonias_stats AS (
    SELECT 
        u.alcaldia_catalogo,
        u.colonia_catalogo,
        COUNT(i.id_incidente) AS total_incidentes,
        ROUND(COUNT(i.id_incidente) * 100.0 / SUM(COUNT(i.id_incidente)) OVER (PARTITION BY u.alcaldia_catalogo), 2) AS porcentaje_en_alcaldia
    FROM ubicacion u
    INNER JOIN incidente i ON u.id_colonia = i.id_colonia
    GROUP BY u.alcaldia_catalogo, u.colonia_catalogo
)
SELECT 
    alcaldia_catalogo,
    colonia_catalogo,
    total_incidentes,
    porcentaje_en_alcaldia,
    RANK() OVER (PARTITION BY alcaldia_catalogo ORDER BY total_incidentes DESC) AS ranking_en_alcaldia,
    DENSE_RANK() OVER (ORDER BY total_incidentes DESC) AS ranking_general
FROM colonias_stats
ORDER BY total_incidentes DESC
LIMIT 50;

-- =====================================================
-- 2. TENDENCIA TEMPORAL DE REPORTES CON COMPARACIÓN
-- Atributos analíticos: reportes_mes_anterior, variacion_mensual, media_movil_3meses
-- =====================================================

WITH reportes_mensuales AS (
    SELECT 
        DATE_FORMAT(fecha_reporte, '%Y-%m') AS mes,
        DATE_FORMAT(fecha_reporte, '%Y-%m-01') AS fecha_mes,
        COUNT(*) AS total_reportes
    FROM reporte
    GROUP BY DATE_FORMAT(fecha_reporte, '%Y-%m'), DATE_FORMAT(fecha_reporte, '%Y-%m-01')
)
SELECT 
    mes,
    total_reportes,
    LAG(total_reportes, 1) OVER (ORDER BY fecha_mes) AS reportes_mes_anterior,
    total_reportes - LAG(total_reportes, 1) OVER (ORDER BY fecha_mes) AS diferencia_absoluta,
    ROUND(
        (total_reportes - LAG(total_reportes, 1) OVER (ORDER BY fecha_mes)) * 100.0 / 
        NULLIF(LAG(total_reportes, 1) OVER (ORDER BY fecha_mes), 0), 
        2
    ) AS variacion_porcentual,
    ROUND(
        AVG(total_reportes) OVER (ORDER BY fecha_mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
        2
    ) AS media_movil_3meses
FROM reportes_mensuales
ORDER BY mes;

-- =====================================================
-- 3. TIEMPO DE ATENCIÓN - Diferencia entre reporte e incidente
-- Atributos analíticos: dias_diferencia, ranking_rapidez, percentil
-- =====================================================

WITH tiempos_atencion AS (
    SELECT 
        i.folio_incidente,
        c.nombre_clasificacion,
        u.alcaldia_catalogo,
        r.fecha_reporte,
        i.fecha_registro_incidente,
        DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte) AS dias_diferencia,
        COUNT(r.id_reporte_pk) OVER (PARTITION BY i.id_incidente) AS num_reportes_incidente
    FROM incidente i
    INNER JOIN reporte r ON i.id_incidente = r.id_incidente
    INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
    LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
)
SELECT 
    folio_incidente,
    nombre_clasificacion,
    alcaldia_catalogo,
    dias_diferencia,
    num_reportes_incidente,
    RANK() OVER (ORDER BY dias_diferencia) AS ranking_rapidez,
    NTILE(4) OVER (ORDER BY dias_diferencia) AS cuartil,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY dias_diferencia) * 100,
        2
    ) AS percentil
FROM tiempos_atencion
WHERE dias_diferencia >= 0
ORDER BY dias_diferencia DESC
LIMIT 100;

-- =====================================================
-- 4. FRECUENCIA DE REPORTES POR COLONIA (RECURRENCIA)
-- Atributo analítico: categoria_frecuencia, score_criticidad
-- =====================================================

WITH frecuencia_colonias AS (
    SELECT 
        u.colonia_catalogo,
        u.alcaldia_catalogo,
        COUNT(DISTINCT i.id_incidente) AS total_incidentes,
        COUNT(r.id_reporte_pk) AS total_reportes,
        ROUND(COUNT(r.id_reporte_pk) * 1.0 / NULLIF(COUNT(DISTINCT i.id_incidente), 0), 2) AS promedio_reportes_por_incidente,
        MIN(r.fecha_reporte) AS primer_reporte,
        MAX(r.fecha_reporte) AS ultimo_reporte,
        DATEDIFF(MAX(r.fecha_reporte), MIN(r.fecha_reporte)) AS dias_activos
    FROM ubicacion u
    INNER JOIN incidente i ON u.id_colonia = i.id_colonia
    INNER JOIN reporte r ON i.id_incidente = r.id_incidente
    GROUP BY u.colonia_catalogo, u.alcaldia_catalogo
)
SELECT 
    colonia_catalogo,
    alcaldia_catalogo,
    total_incidentes,
    total_reportes,
    promedio_reportes_por_incidente,
    dias_activos,
    CASE 
        WHEN total_incidentes >= 100 THEN 'Crítica'
        WHEN total_incidentes >= 50 THEN 'Alta'
        WHEN total_incidentes >= 20 THEN 'Media'
        ELSE 'Baja'
    END AS categoria_frecuencia,
    ROUND(
        (total_incidentes * 0.4 + total_reportes * 0.3 + promedio_reportes_por_incidente * 10 * 0.3),
        2
    ) AS score_criticidad,
    ROW_NUMBER() OVER (PARTITION BY alcaldia_catalogo ORDER BY total_incidentes DESC) AS ranking_en_alcaldia
FROM frecuencia_colonias
WHERE dias_activos > 0
ORDER BY score_criticidad DESC
LIMIT 50;

-- =====================================================
-- 5. ANÁLISIS DE PATRONES HORARIOS POR DÍA DE SEMANA
-- Atributos analíticos: promedio_hora, categoria_horario
-- =====================================================

WITH reportes_horarios AS (
    SELECT 
        DAYNAME(fecha_reporte) AS dia_semana,
        DAYOFWEEK(fecha_reporte) AS dia_numero,
        HOUR(hora_reporte) AS hora,
        COUNT(*) AS total_reportes
    FROM reporte
    GROUP BY dia_semana, dia_numero, hora
)
SELECT 
    dia_semana,
    hora,
    total_reportes,
    AVG(total_reportes) OVER (PARTITION BY dia_numero) AS promedio_dia,
    ROUND(
        total_reportes * 100.0 / SUM(total_reportes) OVER (PARTITION BY dia_numero),
        2
    ) AS porcentaje_del_dia,
    CASE 
        WHEN hora BETWEEN 6 AND 11 THEN 'Mañana'
        WHEN hora BETWEEN 12 AND 17 THEN 'Tarde'
        WHEN hora BETWEEN 18 AND 23 THEN 'Noche'
        ELSE 'Madrugada'
    END AS categoria_horario,
    RANK() OVER (PARTITION BY dia_numero ORDER BY total_reportes DESC) AS ranking_hora_dia
FROM reportes_horarios
ORDER BY dia_numero, hora;

-- =====================================================
-- 6. INCIDENTES RECURRENTES - Análisis de reincidencia
-- Atributos analíticos: es_recurrente, nivel_reincidencia
-- =====================================================

WITH incidentes_recurrencia AS (
    SELECT 
        u.colonia_catalogo,
        u.alcaldia_catalogo,
        c.nombre_clasificacion,
        i.reporte AS tipo_problema,
        COUNT(i.id_incidente) AS veces_reportado,
        MIN(i.fecha_registro_incidente) AS primer_incidente,
        MAX(i.fecha_registro_incidente) AS ultimo_incidente,
        DATEDIFF(MAX(i.fecha_registro_incidente), MIN(i.fecha_registro_incidente)) AS dias_entre_primero_ultimo
    FROM incidente i
    INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
    LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
    GROUP BY u.colonia_catalogo, u.alcaldia_catalogo, c.nombre_clasificacion, i.reporte
    HAVING COUNT(i.id_incidente) > 1
)
SELECT 
    colonia_catalogo,
    alcaldia_catalogo,
    nombre_clasificacion,
    tipo_problema,
    veces_reportado,
    primer_incidente,
    ultimo_incidente,
    dias_entre_primero_ultimo,
    CASE 
        WHEN veces_reportado >= 10 THEN 'Muy Alta'
        WHEN veces_reportado >= 5 THEN 'Alta'
        WHEN veces_reportado >= 3 THEN 'Media'
        ELSE 'Baja'
    END AS nivel_reincidencia,
    DENSE_RANK() OVER (ORDER BY veces_reportado DESC) AS ranking_reincidencia
FROM incidentes_recurrencia
ORDER BY veces_reportado DESC, dias_entre_primero_ultimo
LIMIT 100;

-- =====================================================
-- 7. DISTRIBUCIÓN GEOGRÁFICA CON CLUSTERING
-- Atributos analíticos: cluster_geografico, densidad_zona
-- =====================================================

WITH coordenadas_redondeadas AS (
    SELECT 
        u.alcaldia_catalogo,
        ROUND(u.latitud, 2) AS lat_cluster,
        ROUND(u.longitud, 2) AS long_cluster,
        COUNT(DISTINCT i.id_incidente) AS incidentes_cluster,
        COUNT(DISTINCT u.id_colonia) AS colonias_en_cluster,
        GROUP_CONCAT(DISTINCT u.colonia_catalogo SEPARATOR ', ') AS colonias
    FROM ubicacion u
    INNER JOIN incidente i ON u.id_colonia = i.id_colonia
    WHERE u.latitud IS NOT NULL AND u.longitud IS NOT NULL
    GROUP BY u.alcaldia_catalogo, lat_cluster, long_cluster
)
SELECT 
    alcaldia_catalogo,
    lat_cluster,
    long_cluster,
    incidentes_cluster,
    colonias_en_cluster,
    ROUND(incidentes_cluster * 1.0 / NULLIF(colonias_en_cluster, 0), 2) AS densidad_incidentes,
    CASE 
        WHEN incidentes_cluster >= 100 THEN 'Zona Crítica'
        WHEN incidentes_cluster >= 50 THEN 'Zona Alta Demanda'
        WHEN incidentes_cluster >= 20 THEN 'Zona Media'
        ELSE 'Zona Baja'
    END AS categoria_zona,
    NTILE(10) OVER (ORDER BY incidentes_cluster DESC) AS decil_incidentes,
    colonias
FROM coordenadas_redondeadas
ORDER BY incidentes_cluster DESC
LIMIT 50;

-- =====================================================
-- 8. EFICIENCIA POR MEDIO DE RECEPCIÓN
-- Atributos analíticos: tiempo_promedio_atencion, efectividad_canal
-- =====================================================

WITH efectividad_medio AS (
    SELECT 
        m.nombre_medio,
        COUNT(r.id_reporte_pk) AS total_reportes,
        COUNT(DISTINCT i.id_incidente) AS incidentes_generados,
        AVG(DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte)) AS dias_promedio_registro,
        MIN(DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte)) AS dias_minimo,
        MAX(DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte)) AS dias_maximo
    FROM medio_recepcion m
    INNER JOIN reporte r ON m.id_medio_recepcion = r.id_medio_recepcion
    INNER JOIN incidente i ON r.id_incidente = i.id_incidente
    WHERE DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte) >= 0
    GROUP BY m.nombre_medio
)
SELECT 
    nombre_medio,
    total_reportes,
    incidentes_generados,
    ROUND(total_reportes * 1.0 / NULLIF(incidentes_generados, 0), 2) AS reportes_por_incidente,
    dias_promedio_registro,
    dias_minimo,
    dias_maximo,
    CASE 
        WHEN dias_promedio_registro <= 1 THEN 'Excelente'
        WHEN dias_promedio_registro <= 3 THEN 'Bueno'
        WHEN dias_promedio_registro <= 7 THEN 'Regular'
        ELSE 'Lento'
    END AS categoria_velocidad,
    RANK() OVER (ORDER BY dias_promedio_registro) AS ranking_rapidez,
    RANK() OVER (ORDER BY total_reportes DESC) AS ranking_volumen
FROM efectividad_medio
ORDER BY total_reportes DESC;

-- =====================================================
-- 9. COMPARATIVA DE ALCALDÍAS - Scorecard completo
-- Múltiples atributos analíticos agregados
-- =====================================================

WITH metricas_alcaldia AS (
    SELECT 
        u.alcaldia_catalogo,
        COUNT(DISTINCT i.id_incidente) AS total_incidentes,
        COUNT(DISTINCT r.id_reporte_pk) AS total_reportes,
        COUNT(DISTINCT u.id_colonia) AS colonias_afectadas,
        ROUND(COUNT(DISTINCT i.id_incidente) * 1.0 / NULLIF(COUNT(DISTINCT u.id_colonia), 0), 2) AS incidentes_por_colonia,
        ROUND(COUNT(DISTINCT r.id_reporte_pk) * 1.0 / NULLIF(COUNT(DISTINCT i.id_incidente), 0), 2) AS reportes_por_incidente,
        AVG(DATEDIFF(i.fecha_registro_incidente, r.fecha_reporte)) AS dias_promedio_atencion
    FROM ubicacion u
    INNER JOIN incidente i ON u.id_colonia = i.id_colonia
    INNER JOIN reporte r ON i.id_incidente = r.id_incidente
    WHERE u.alcaldia_catalogo IS NOT NULL AND u.alcaldia_catalogo != 'NA'
    GROUP BY u.alcaldia_catalogo
)
SELECT 
    alcaldia_catalogo,
    total_incidentes,
    total_reportes,
    colonias_afectadas,
    incidentes_por_colonia,
    reportes_por_incidente,
    ROUND(dias_promedio_atencion, 2) AS dias_promedio_atencion,
    RANK() OVER (ORDER BY total_incidentes DESC) AS ranking_incidentes,
    RANK() OVER (ORDER BY incidentes_por_colonia DESC) AS ranking_densidad,
    RANK() OVER (ORDER BY dias_promedio_atencion) AS ranking_rapidez,
    NTILE(5) OVER (ORDER BY total_incidentes DESC) AS quintil_gravedad,
    ROUND(
        (PERCENT_RANK() OVER (ORDER BY total_incidentes DESC) * 40 +
         PERCENT_RANK() OVER (ORDER BY incidentes_por_colonia DESC) * 30 +
         PERCENT_RANK() OVER (ORDER BY dias_promedio_atencion) * 30) * 100,
        2
    ) AS score_prioridad
FROM metricas_alcaldia
ORDER BY score_prioridad DESC;

-- =====================================================
-- 10. ANÁLISIS DE ESTACIONALIDAD - Patrones anuales
-- Atributos analíticos: trimestre, tendencia_trimestral
-- =====================================================

WITH reportes_trimestrales AS (
    SELECT 
        YEAR(fecha_reporte) AS anio,
        QUARTER(fecha_reporte) AS trimestre,
        CONCAT('Q', QUARTER(fecha_reporte), '-', YEAR(fecha_reporte)) AS periodo,
        c.nombre_clasificacion,
        COUNT(*) AS total_reportes
    FROM reporte r
    INNER JOIN incidente i ON r.id_incidente = i.id_incidente
    INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
    GROUP BY anio, trimestre, periodo, c.nombre_clasificacion
)
SELECT 
    periodo,
    nombre_clasificacion,
    total_reportes,
    LAG(total_reportes, 1) OVER (PARTITION BY nombre_clasificacion ORDER BY anio, trimestre) AS trimestre_anterior,
    total_reportes - LAG(total_reportes, 1) OVER (PARTITION BY nombre_clasificacion ORDER BY anio, trimestre) AS variacion_absoluta,
    ROUND(
        (total_reportes - LAG(total_reportes, 1) OVER (PARTITION BY nombre_clasificacion ORDER BY anio, trimestre)) * 100.0 /
        NULLIF(LAG(total_reportes, 1) OVER (PARTITION BY nombre_clasificacion ORDER BY anio, trimestre), 0),
        2
    ) AS variacion_porcentual,
    AVG(total_reportes) OVER (PARTITION BY nombre_clasificacion ORDER BY anio, trimestre ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS media_movil_4_trimestres
FROM reportes_trimestrales
ORDER BY nombre_clasificacion, anio, trimestre;

-- =====================================================
-- FIN DEL ANÁLISIS AVANZADO
-- =====================================================

/*
NOTA SOBRE ATRIBUTOS ANALÍTICOS CREADOS:

1. ranking_colonia, ranking_general - Posición relativa por incidentes
2. reportes_mes_anterior, variacion_mensual - Tendencias temporales
3. media_movil_3meses - Suavizado de tendencias
4. dias_diferencia, percentil - Análisis de tiempos de atención
5. categoria_frecuencia, score_criticidad - Clasificación de gravedad
6. categoria_horario - Patrones de demanda temporal
7. nivel_reincidencia - Identificación de problemas recurrentes
8. cluster_geografico, densidad_zona - Agrupación espacial
9. efectividad_canal - Evaluación de medios de recepción
10. score_prioridad - Métrica compuesta para priorización

Estos atributos enriquecidos permiten análisis más profundos y toma de decisiones
basada en datos para la gestión del servicio de agua en la CDMX.
*/

