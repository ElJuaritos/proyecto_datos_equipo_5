-- ============================================================================
-- B) Carga inicial de datos
-- ============================================================================
-- Este script crea la base de datos y carga el archivo CSV

-- Paso 1: Crear la base de datos
CREATE DATABASE reportes_agua_cdmx;

-- Paso 2: Conectarse a la base de datos
\c reportes_agua_cdmx;

-- Paso 3: Crear el esquema
CREATE SCHEMA IF NOT EXISTS agua_cdmx;

-- Paso 4: Eliminar tabla si existe
DROP TABLE IF EXISTS agua_cdmx.reportes;

-- Paso 5: Crear la tabla con las 12 columnas
CREATE TABLE agua_cdmx.reportes (
    folio_incidente TEXT,
    fecha_registro_incidente TEXT,
    id_reporte TEXT,
    fecha_reporte TEXT,
    hora_reporte TEXT,
    clasificacion TEXT,
    reporte TEXT,
    medio_recepcion TEXT,
    alcaldia_catalogo TEXT,
    colonia_catalogo TEXT,
    longitud TEXT,
    latitud TEXT
);

-- Paso 6: Cargar datos desde el CSV
-- IMPORTANTE: Cambiar la ruta por la ubicación de tu archivo
-- Se usa LATIN1 que es más tolerante con caracteres especiales de Windows
\copy agua_cdmx.reportes FROM 'C:\Users\eajae\OneDrive\Escritorio\Datos\proyecto_datos_equipo_5\reportes_agua_2024_01.csv' DELIMITER ',' CSV HEADER ENCODING 'LATIN1';

-- SI SIGUE DANDO ERROR, usa el script de Python para convertir a UTF-8:
-- 1. Ejecuta: pip install -r requirements.txt
-- 2. Ejecuta: python convertir_csv_utf8.py
-- 3. Luego usa esta línea (descomenta y comenta la de arriba):
-- \copy agua_cdmx.reportes FROM 'C:\Users\eajae\OneDrive\Escritorio\Datos\proyecto_datos_equipo_5\reportes_agua_2024_01_utf8.csv' DELIMITER ',' CSV HEADER;

-- Paso 7: Verificar que se cargaron los datos
SELECT COUNT(*) AS total_registros FROM agua_cdmx.reportes;

-- Paso 8: Ver algunos registros
SELECT * FROM agua_cdmx.reportes LIMIT 10;

-- Paso 9: Crear una copia en el esquema público para trabajar más fácil
CREATE TABLE reportes AS TABLE agua_cdmx.reportes;

-- Paso 10: Confirmar
SELECT COUNT(*) FROM reportes;