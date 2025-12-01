-- =====================================================
-- SCHEMA DE BASE DE DATOS EN 5NF (QUINTA FORMA NORMAL)
-- Sistema de Reportes de Agua - CDMX
-- =====================================================
-- 
-- DESCRIPCIÓN:
-- Este schema normaliza los datos de reportes de agua hasta 5NF,
-- eliminando redundancias y dependencias de join no triviales.
-- Se descompone en 5 entidades principales con sus respectivos catálogos.
--
-- =====================================================

-- Eliminar tablas si existen (orden inverso por dependencias FK)
DROP TABLE IF EXISTS reporte;
DROP TABLE IF EXISTS incidente;
DROP TABLE IF EXISTS ubicacion;
DROP TABLE IF EXISTS clasificacion;
DROP TABLE IF EXISTS medio_recepcion;

-- =====================================================
-- TABLA: CLASIFICACION
-- Catálogo de tipos/categorías de incidentes
-- =====================================================
CREATE TABLE clasificacion (
    id_clasificacion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_clasificacion VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nombre_clasificacion (nombre_clasificacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Catálogo de clasificaciones de incidentes (Agua Potable, Drenaje, etc.)';

-- =====================================================
-- TABLA: MEDIO_RECEPCION
-- Catálogo de canales por los que se reciben reportes
-- =====================================================
CREATE TABLE medio_recepcion (
    id_medio_recepcion INT AUTO_INCREMENT PRIMARY KEY,
    nombre_medio VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nombre_medio (nombre_medio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Catálogo de medios de recepción (Call Center, App Móvil, Web, etc.)';

-- =====================================================
-- TABLA: UBICACION
-- Datos geográficos y administrativos de colonias
-- =====================================================
CREATE TABLE ubicacion (
    id_colonia INT AUTO_INCREMENT PRIMARY KEY,
    colonia_catalogo VARCHAR(255) NOT NULL,
    alcaldia_catalogo VARCHAR(100) NOT NULL,
    longitud DECIMAL(11, 8) NULL,
    latitud DECIMAL(11, 8) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_colonia (colonia_catalogo),
    INDEX idx_alcaldia (alcaldia_catalogo),
    INDEX idx_coordenadas (longitud, latitud)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Catálogo de ubicaciones: colonias, alcaldías y coordenadas geográficas';

-- =====================================================
-- TABLA: INCIDENTE
-- Información principal del incidente/evento reportado
-- =====================================================
CREATE TABLE incidente (
    id_incidente INT AUTO_INCREMENT PRIMARY KEY,
    folio_incidente VARCHAR(50) NOT NULL UNIQUE,
    fecha_registro_incidente DATE NOT NULL,
    reporte VARCHAR(500) NOT NULL,
    id_clasificacion INT NOT NULL,
    id_colonia INT NULL,
    estado VARCHAR(50) DEFAULT 'Registrado',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    CONSTRAINT fk_incidente_clasificacion 
        FOREIGN KEY (id_clasificacion) 
        REFERENCES clasificacion(id_clasificacion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_incidente_ubicacion 
        FOREIGN KEY (id_colonia) 
        REFERENCES ubicacion(id_colonia)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    -- Índices para optimización de consultas
    INDEX idx_folio (folio_incidente),
    INDEX idx_fecha_registro (fecha_registro_incidente),
    INDEX idx_clasificacion (id_clasificacion),
    INDEX idx_ubicacion (id_colonia),
    INDEX idx_estado (estado),
    INDEX idx_fecha_creacion (fecha_creacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Entidad principal de incidentes: fugas, falta de agua, drenaje obstruido, etc.';

-- =====================================================
-- TABLA: REPORTE
-- Registros individuales de notificaciones/llamadas
-- Un incidente puede tener múltiples reportes asociados
-- =====================================================
CREATE TABLE reporte (
    id_reporte_pk INT AUTO_INCREMENT PRIMARY KEY,
    id_reporte VARCHAR(50) NOT NULL UNIQUE,
    id_incidente INT NOT NULL,
    fecha_reporte DATE NOT NULL,
    hora_reporte TIME NOT NULL,
    id_medio_recepcion INT NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    CONSTRAINT fk_reporte_incidente 
        FOREIGN KEY (id_incidente) 
        REFERENCES incidente(id_incidente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_reporte_medio 
        FOREIGN KEY (id_medio_recepcion) 
        REFERENCES medio_recepcion(id_medio_recepcion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Índices para optimización de consultas
    INDEX idx_id_reporte (id_reporte),
    INDEX idx_incidente (id_incidente),
    INDEX idx_fecha_reporte (fecha_reporte),
    INDEX idx_medio_recepcion (id_medio_recepcion),
    INDEX idx_fecha_hora (fecha_reporte, hora_reporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Registros de reportes/notificaciones asociados a incidentes (relación 1:N con INCIDENTE)';

-- =====================================================
-- VERIFICACIÓN DE INTEGRIDAD REFERENCIAL
-- =====================================================

-- Verificar que todas las tablas se crearon correctamente
SELECT 
    TABLE_NAME,
    ENGINE,
    TABLE_ROWS,
    CREATE_TIME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME IN ('clasificacion', 'medio_recepcion', 'ubicacion', 'incidente', 'reporte')
ORDER BY TABLE_NAME;

-- =====================================================
-- COMENTARIOS SOBRE EL DISEÑO
-- =====================================================
/*
JUSTIFICACIÓN 5NF:

1. CLASIFICACION: Catálogo normalizado que elimina redundancia de valores repetidos
   y facilita el mantenimiento centralizado de tipos de incidentes.

2. MEDIO_RECEPCION: Catálogo normalizado de canales de recepción, permitiendo
   gestión independiente y extensibilidad futura.

3. UBICACION: Entidad que elimina dependencias transitivas (colonia → alcaldía → coordenadas)
   y permite mantener datos geográficos consistentes.

4. INCIDENTE: Entidad principal que representa el evento/fenómeno reportado,
   con referencias a clasificación y ubicación mediante FKs.

5. REPORTE: Entidad que captura cada notificación/llamada individual,
   eliminando la dependencia multivaluada (folio_incidente ↠ id_reporte).

VENTAJAS:
- Eliminación completa de redundancia
- Integridad referencial garantizada por FKs
- Facilidad de mantenimiento de catálogos
- Escalabilidad y extensibilidad
- Optimización mediante índices estratégicos
- Sin anomalías de actualización, inserción o eliminación

CONSIDERACIONES:
- Las consultas requieren JOINs pero están optimizadas con índices
- La desnormalización puede considerarse solo para reportes de alto volumen
- Los catálogos facilitan la generación de dashboards y análisis
*/

