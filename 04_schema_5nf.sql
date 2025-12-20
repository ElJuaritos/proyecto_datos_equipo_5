-- SCHEMA DE BASE DE DATOS EN 5NF (QUINTA FORMA NORMAL)
-- Sistema de Reportes de Agua - CDMX

-- DESCRIPCIÓN:
-- Este schema normaliza los datos de reportes de agua hasta 5NF verdadera,
-- eliminando TODAS las redundancias y dependencias transitivas.
-- Se descompone en 7 entidades principales con sus respectivos catálogos.


-- Eliminar tablas si existen (orden inverso por dependencias FK)
DROP TABLE IF EXISTS reporte;
DROP TABLE IF EXISTS incidente;
DROP TABLE IF EXISTS colonia;
DROP TABLE IF EXISTS alcaldia;
DROP TABLE IF EXISTS estado_incidente;
DROP TABLE IF EXISTS clasificacion;
DROP TABLE IF EXISTS medio_recepcion;

-- =====================================================
-- TABLA: CLASIFICACION
-- Catálogo de tipos/categorías de incidentes
-- =====================================================
CREATE TABLE clasificacion (
    id_clasificacion SERIAL PRIMARY KEY,
    nombre_clasificacion VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nombre_clasificacion ON clasificacion(nombre_clasificacion);

COMMENT ON TABLE clasificacion IS 'Catálogo de clasificaciones de incidentes (Agua Potable, Drenaje, etc.)';

-- =====================================================
-- TABLA: MEDIO_RECEPCION
-- Catálogo de canales por los que se reciben reportes
-- =====================================================
CREATE TABLE medio_recepcion (
    id_medio_recepcion SERIAL PRIMARY KEY,
    nombre_medio VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nombre_medio ON medio_recepcion(nombre_medio);

COMMENT ON TABLE medio_recepcion IS 'Catálogo de medios de recepción (Call Center, App Móvil, Web, etc.)';

-- =====================================================
-- TABLA: ALCALDIA
-- Catálogo de alcaldías de la CDMX
-- NUEVA: Elimina redundancia de nombres de alcaldía
-- =====================================================
CREATE TABLE alcaldia (
    id_alcaldia SERIAL PRIMARY KEY,
    nombre_alcaldia VARCHAR(100) NOT NULL UNIQUE,
    codigo_alcaldia VARCHAR(10) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nombre_alcaldia ON alcaldia(nombre_alcaldia);

COMMENT ON TABLE alcaldia IS 'Catálogo de alcaldías de la Ciudad de México (elimina dependencia transitiva colonia→alcaldía)';

-- =====================================================
-- TABLA: ESTADO_INCIDENTE
-- Catálogo de estados posibles de un incidente
-- NUEVA: Valida y centraliza los estados
-- =====================================================
CREATE TABLE estado_incidente (
    id_estado SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    orden INT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_nombre_estado ON estado_incidente(nombre_estado);

COMMENT ON TABLE estado_incidente IS 'Catálogo de estados del ciclo de vida de un incidente';

-- Poblar con estados predefinidos
INSERT INTO estado_incidente (nombre_estado, descripcion, orden) VALUES
('Registrado', 'Incidente registrado en el sistema', 1),
('En Atención', 'Incidente siendo atendido por personal técnico', 2),
('Atendido', 'Incidente atendido completamente', 3),
('Cerrado', 'Caso cerrado y archivado', 4),
('Cancelado', 'Incidente cancelado o duplicado', 5);

-- =====================================================
-- TABLA: COLONIA
-- Datos geográficos de colonias (antes: ubicacion)
-- REFACTORIZADA: Sin alcaldia_catalogo (ahora es FK)
-- =====================================================
CREATE TABLE colonia (
    id_colonia SERIAL PRIMARY KEY,
    nombre_colonia VARCHAR(255) NOT NULL,
    id_alcaldia INT NOT NULL,
    codigo_postal VARCHAR(5) NULL,
    centroide_longitud DECIMAL(11, 8) NULL,
    centroide_latitud DECIMAL(11, 8) NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Clave foránea a alcaldia
    CONSTRAINT fk_colonia_alcaldia 
        FOREIGN KEY (id_alcaldia) 
        REFERENCES alcaldia(id_alcaldia)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    -- Una colonia es única dentro de una alcaldía
    CONSTRAINT uk_colonia_alcaldia UNIQUE (nombre_colonia, id_alcaldia)
);

CREATE INDEX idx_alcaldia_colonia ON colonia(id_alcaldia);
CREATE INDEX idx_nombre_colonia ON colonia(nombre_colonia);
CREATE INDEX idx_coordenadas_colonia ON colonia(centroide_longitud, centroide_latitud);

COMMENT ON TABLE colonia IS 'Catálogo de colonias con sus centroides geográficos y referencia a alcaldía';
COMMENT ON COLUMN colonia.centroide_longitud IS 'Coordenada del centro geográfico de la colonia';
COMMENT ON COLUMN colonia.centroide_latitud IS 'Coordenada del centro geográfico de la colonia';

-- =====================================================
-- TABLA: INCIDENTE
-- Información principal del incidente/evento reportado
-- REFACTORIZADA: Ahora incluye coordenadas exactas y FK a estado
-- =====================================================
CREATE TABLE incidente (
    id_incidente SERIAL PRIMARY KEY,
    folio_incidente VARCHAR(50) NOT NULL UNIQUE,
    fecha_registro_incidente DATE NOT NULL,
    reporte VARCHAR(500) NOT NULL,
    id_clasificacion INT NOT NULL,
    id_colonia INT NULL,
    id_estado INT NOT NULL DEFAULT 1,
    
    -- Coordenadas específicas del incidente (punto exacto del reporte)
    longitud_incidente DECIMAL(11, 8) NULL,
    latitud_incidente DECIMAL(11, 8) NULL,
    
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Claves foráneas
    CONSTRAINT fk_incidente_clasificacion 
        FOREIGN KEY (id_clasificacion) 
        REFERENCES clasificacion(id_clasificacion)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_incidente_colonia 
        FOREIGN KEY (id_colonia) 
        REFERENCES colonia(id_colonia)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_incidente_estado 
        FOREIGN KEY (id_estado) 
        REFERENCES estado_incidente(id_estado)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Índices para optimización de consultas
CREATE INDEX idx_folio ON incidente(folio_incidente);
CREATE INDEX idx_fecha_registro ON incidente(fecha_registro_incidente);
CREATE INDEX idx_clasificacion ON incidente(id_clasificacion);
CREATE INDEX idx_colonia_incidente ON incidente(id_colonia);
CREATE INDEX idx_estado_incidente ON incidente(id_estado);
CREATE INDEX idx_coordenadas_incidente ON incidente(longitud_incidente, latitud_incidente);
CREATE INDEX idx_fecha_creacion ON incidente(fecha_creacion);

COMMENT ON TABLE incidente IS 'Entidad principal de incidentes: fugas, falta de agua, drenaje obstruido, etc.';
COMMENT ON COLUMN incidente.longitud_incidente IS 'Coordenada exacta del punto donde ocurre el incidente';
COMMENT ON COLUMN incidente.latitud_incidente IS 'Coordenada exacta del punto donde ocurre el incidente';

-- Trigger para actualizar fecha_actualizacion automáticamente
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incidente_fecha_actualizacion
BEFORE UPDATE ON incidente
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

-- =====================================================
-- TABLA: REPORTE
-- Registros individuales de notificaciones/llamadas
-- Un incidente puede tener múltiples reportes asociados
-- =====================================================
CREATE TABLE reporte (
    id_reporte_pk SERIAL PRIMARY KEY,
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
        ON UPDATE CASCADE
);

-- Índices para optimización de consultas
CREATE INDEX idx_id_reporte ON reporte(id_reporte);
CREATE INDEX idx_incidente ON reporte(id_incidente);
CREATE INDEX idx_fecha_reporte ON reporte(fecha_reporte);
CREATE INDEX idx_medio_recepcion ON reporte(id_medio_recepcion);
CREATE INDEX idx_fecha_hora ON reporte(fecha_reporte, hora_reporte);

COMMENT ON TABLE reporte IS 'Registros de reportes/notificaciones asociados a incidentes (relación 1:N con INCIDENTE)';

-- =====================================================
-- VERIFICACIÓN DE INTEGRIDAD REFERENCIAL
-- =====================================================

-- Verificar que todas las tablas se crearon correctamente
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('clasificacion', 'medio_recepcion', 'alcaldia', 'estado_incidente', 'colonia', 'incidente', 'reporte')
ORDER BY tablename;

-- Verificar índices creados
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('clasificacion', 'medio_recepcion', 'alcaldia', 'estado_incidente', 'colonia', 'incidente', 'reporte')
ORDER BY tablename, indexname;

-- Verificar constraints FK
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_schema = 'public'
ORDER BY tc.table_name;

-- =====================================================
-- COMENTARIOS SOBRE EL DISEÑO MEJORADO
-- =====================================================
/*
JUSTIFICACIÓN 5NF VERDADERA:

1. CLASIFICACION: Catálogo normalizado que elimina redundancia de valores repetidos.

2. MEDIO_RECEPCION: Catálogo normalizado de canales de recepción.

3. ALCALDIA: **NUEVA** - Elimina la dependencia transitiva colonia→alcaldía.
   Antes: cada colonia repetía el nombre de su alcaldía.
   Ahora: el nombre de alcaldía se almacena UNA sola vez.

4. ESTADO_INCIDENTE: **NUEVA** - Catálogo que valida y centraliza estados.
   Antes: VARCHAR(50) permitía cualquier valor (typos, inconsistencias).
   Ahora: FK garantiza solo estados válidos y predefinidos.

5. COLONIA (antes: ubicacion): Refactorizada sin alcaldia_catalogo.
   - Ahora tiene FK a ALCALDIA
   - Coordenadas renombradas a centroide_* (más claro)
   - Permite agregar código postal y otros atributos de colonia

6. INCIDENTE: Mejorado con:
   - FK a ESTADO_INCIDENTE (validación automática)
   - longitud_incidente/latitud_incidente (punto exacto del incidente)
   - Mayor granularidad geoespacial

7. REPORTE: Sin cambios estructurales (ya estaba bien normalizado).

ANÁLISIS DE DEPENDENCIAS FUNCIONALES:

ALCALDIA:
  id_alcaldia → nombre_alcaldia, codigo_alcaldia
  ✅ No hay dependencias transitivas

COLONIA:
  id_colonia → nombre_colonia, id_alcaldia, codigo_postal, coordenadas
  nombre_colonia, id_alcaldia → id_colonia (clave alternativa)
  ✅ No hay dependencias transitivas (alcaldia_catalogo eliminado)

ESTADO_INCIDENTE:
  id_estado → nombre_estado, descripcion, orden
  ✅ No hay dependencias transitivas

INCIDENTE:
  id_incidente → todos los demás atributos
  ✅ Solo dependencias funcionales directas de la PK

VENTAJAS DEL DISEÑO MEJORADO:

1. **Eliminación total de redundancia**:
   - "Benito Juárez" aparece 1 vez, no N veces por cada colonia
   - "Registrado" aparece 1 vez, no M veces por cada incidente

2. **Integridad referencial reforzada**:
   - Estados validados por FK (no más typos)
   - Alcaldías centralizadas (cambios en cascada automáticos)

3. **Granularidad geoespacial mejorada**:
   - Centroide de colonia (área general)
   - Coordenadas de incidente (punto exacto)
   - Permite análisis geoespaciales más precisos

4. **Mantenimiento simplificado**:
   - Cambiar nombre de alcaldía: 1 UPDATE (no N)
   - Agregar nuevo estado: 1 INSERT
   - Deshabilitar estados obsoletos: UPDATE activo=false

5. **Escalabilidad**:
   - Fácil agregar atributos a alcaldías (población, área, etc.)
   - Fácil agregar metadatos a estados (color, icono para UI)

6. **Performance**:
   - Índices optimizados en todas las FKs
   - Joins eficientes con claves numéricas
   - Menor uso de almacenamiento (sin redundancia)

7. **Sin anomalías**:
   - No hay anomalías de inserción (no puedes crear alcaldía inválida)
   - No hay anomalías de actualización (cambios en cascada)
   - No hay anomalías de eliminación (restricciones FK protegen)

CONSIDERACIONES:

- Las consultas ahora requieren un JOIN adicional (colonia→alcaldia)
- Pero esto está optimizado con índices y mejora la integridad
- Para reportes de alto volumen, considerar vistas materializadas
- La normalización 5NF es óptima para OLTP (transacciones)
- Para OLAP (análisis), considerar un data warehouse desnormalizado separado

COMPARACIÓN CON VERSIÓN ANTERIOR:

Antes (5 tablas):
  clasificacion, medio_recepcion, ubicacion, incidente, reporte
  ⚠️ ubicacion tenía dependencia transitiva (colonia→alcaldía)
  ⚠️ incidente.estado era VARCHAR sin validación

Después (7 tablas):
  clasificacion, medio_recepcion, alcaldia, estado_incidente, colonia, incidente, reporte
  ✅ Todas las dependencias transitivas eliminadas
  ✅ Todos los dominios finitos como catálogos
  ✅ Verdadera 5NF

*/
