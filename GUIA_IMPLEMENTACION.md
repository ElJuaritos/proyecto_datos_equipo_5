# Guía de Implementación - Sistema de Reportes de Agua 5NF

Esta guía proporciona instrucciones paso a paso para implementar el sistema de base de datos normalizado hasta 5NF.

---

## 📋 Requisitos Previos

- MySQL 8.0+ o MariaDB 10.5+
- Acceso a línea de comandos o MySQL Workbench
- Python 3.8+ (opcional, para método alternativo de carga)
- El archivo `reportes_agua_2024_01.csv`

---

## 🚀 Método 1: Implementación Completa con MySQL

### Paso 1: Crear la Base de Datos

```bash
mysql -u root -p
```

```sql
CREATE DATABASE reportes_agua_cdmx 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE reportes_agua_cdmx;

-- Verificar configuración
SHOW VARIABLES LIKE 'character_set_database';
SHOW VARIABLES LIKE 'collation_database';
```

### Paso 2: Crear el Schema en 5NF

```bash
mysql -u root -p reportes_agua_cdmx < 04_schema_5nf.sql
```

**Verificar que las tablas se crearon correctamente:**

```sql
USE reportes_agua_cdmx;

SHOW TABLES;

-- Debe mostrar:
-- clasificacion
-- medio_recepcion
-- ubicacion
-- incidente
-- reporte

-- Ver estructura de una tabla
DESCRIBE incidente;

-- Ver claves foráneas
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'reportes_agua_cdmx'
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

### Paso 3: Cargar Datos del CSV

#### Opción A: Usando LOAD DATA INFILE (Más rápido)

1. **Habilitar carga local de archivos:**

```sql
SET GLOBAL local_infile = 1;
```

2. **Salir y reconectar con flag:**

```bash
mysql -u root -p --local-infile=1 reportes_agua_cdmx
```

3. **Crear tabla temporal:**

```sql
CREATE TABLE reportes_agua_raw (
    folio_incidente VARCHAR(50),
    fecha_registro_incidente VARCHAR(50),
    id_reporte VARCHAR(50),
    fecha_reporte VARCHAR(50),
    hora_reporte VARCHAR(50),
    clasificacion VARCHAR(100),
    reporte VARCHAR(500),
    medio_recepcion VARCHAR(100),
    alcaldia_catalogo VARCHAR(100),
    colonia_catalogo VARCHAR(255),
    longitud VARCHAR(50),
    latitud VARCHAR(50)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

4. **Cargar el CSV:**

```sql
LOAD DATA LOCAL INFILE 'C:/Users/eajae/OneDrive/Escritorio/Datos/proyecto_datos_equipo_5/reportes_agua_2024_01.csv'
INTO TABLE reportes_agua_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verificar carga
SELECT COUNT(*) FROM reportes_agua_raw;
-- Debe mostrar: 313757 (o similar)

SELECT * FROM reportes_agua_raw LIMIT 10;
```

#### Opción B: Usando MySQL Workbench (GUI)

1. Clic derecho en tabla `reportes_agua_raw` → **Table Data Import Wizard**
2. Seleccionar el archivo CSV
3. Configurar:
   - Field Separator: `,`
   - Line Separator: `\n` (Windows: `\r\n`)
   - Encoding: `UTF-8`
4. Mapear columnas automáticamente
5. Ejecutar importación

### Paso 4: Ejecutar Migración a 5NF

```bash
mysql -u root -p reportes_agua_cdmx < 05_migracion_a_5nf.sql
```

**Este script ejecuta automáticamente:**
1. ✅ Extrae y carga catálogos únicos (CLASIFICACION, MEDIO_RECEPCION)
2. ✅ Normaliza ubicaciones con validación de coordenadas
3. ✅ Carga incidentes con relaciones FK
4. ✅ Carga reportes con integridad referencial
5. ✅ Genera estadísticas de validación

**Verificar resultados:**

```sql
-- Conteo por tabla
SELECT 'clasificacion' AS tabla, COUNT(*) AS total FROM clasificacion
UNION ALL
SELECT 'medio_recepcion', COUNT(*) FROM medio_recepcion
UNION ALL
SELECT 'ubicacion', COUNT(*) FROM ubicacion
UNION ALL
SELECT 'incidente', COUNT(*) FROM incidente
UNION ALL
SELECT 'reporte', COUNT(*) FROM reporte;

-- Ejemplo de resultados esperados:
-- clasificacion: 2-5 registros
-- medio_recepcion: 3-10 registros
-- ubicacion: 1000-2000 registros
-- incidente: ~100,000-200,000 registros
-- reporte: ~313,000 registros
```

### Paso 5: Probar Consultas

```bash
mysql -u root -p reportes_agua_cdmx < 06_consultas_ejemplo_5nf.sql
```

---

## 🐍 Método 2: Implementación con Python

### Requisitos

```bash
pip install pandas pymysql sqlalchemy
```

### Script de Carga

```python
# cargar_datos.py
import pandas as pd
from sqlalchemy import create_engine
import pymysql

# Configuración de conexión
DB_CONFIG = {
    'user': 'root',
    'password': 'tu_password',
    'host': 'localhost',
    'database': 'reportes_agua_cdmx',
    'charset': 'utf8mb4'
}

# Crear engine de SQLAlchemy
engine = create_engine(
    f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@"
    f"{DB_CONFIG['host']}/{DB_CONFIG['database']}?charset={DB_CONFIG['charset']}"
)

# Leer CSV
print("Cargando CSV...")
df = pd.read_csv('reportes_agua_2024_01.csv', encoding='utf-8')
print(f"Registros cargados: {len(df)}")

# Cargar a tabla temporal
print("Cargando datos a MySQL...")
df.to_sql(
    name='reportes_agua_raw',
    con=engine,
    if_exists='replace',
    index=False,
    chunksize=1000,
    method='multi'
)

print("✅ Carga completada!")
print("Ejecutar ahora: mysql -u root -p reportes_agua_cdmx < 05_migracion_a_5nf.sql")
```

**Ejecutar:**

```bash
python cargar_datos.py
```

---

## 📊 Verificación de Integridad

### Consultas de Validación

```sql
-- 1. Verificar que todos los reportes tienen incidente válido
SELECT COUNT(*) AS reportes_huerfanos
FROM reporte r
LEFT JOIN incidente i ON r.id_incidente = i.id_incidente
WHERE i.id_incidente IS NULL;
-- Debe ser: 0

-- 2. Verificar que todos los incidentes tienen clasificación válida
SELECT COUNT(*) AS incidentes_sin_clasificacion
FROM incidente i
LEFT JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
WHERE c.id_clasificacion IS NULL;
-- Debe ser: 0

-- 3. Verificar duplicados en folios
SELECT folio_incidente, COUNT(*) AS duplicados
FROM incidente
GROUP BY folio_incidente
HAVING COUNT(*) > 1;
-- Debe estar vacío

-- 4. Verificar integridad temporal
SELECT COUNT(*) AS reportes_fecha_invalida
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
WHERE r.fecha_reporte > i.fecha_registro_incidente + INTERVAL 1 YEAR;
-- Identificar anomalías temporales

-- 5. Comparar totales con tabla original
SELECT 
    (SELECT COUNT(*) FROM reportes_agua_raw) AS registros_originales,
    (SELECT COUNT(*) FROM reporte) AS registros_normalizados,
    (SELECT COUNT(*) FROM reporte) - (SELECT COUNT(*) FROM reportes_agua_raw) AS diferencia;
-- Diferencia debe ser 0 o explicable (duplicados eliminados)
```

---

## 🔧 Solución de Problemas Comunes

### Error: "The MySQL server is running with the --secure-file-priv option"

**Problema:** MySQL restringe la carga de archivos.

**Solución 1:** Verificar directorio permitido

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

Copiar el CSV al directorio mostrado y ajustar la ruta en LOAD DATA.

**Solución 2:** Usar Python o MySQL Workbench en su lugar.

### Error: "Data too long for column"

**Problema:** Algún valor excede el tamaño de VARCHAR definido.

**Solución:** Identificar y truncar valores largos

```sql
SELECT 
    MAX(LENGTH(reporte)) AS max_reporte,
    MAX(LENGTH(colonia_catalogo)) AS max_colonia
FROM reportes_agua_raw;
```

Ajustar tamaños en el schema si es necesario.

### Error: "Cannot add foreign key constraint"

**Problema:** Hay valores en FK que no existen en la tabla referenciada.

**Solución:** Verificar datos huérfanos

```sql
-- Verificar clasificaciones inexistentes
SELECT DISTINCT r.clasificacion
FROM reportes_agua_raw r
LEFT JOIN clasificacion c ON TRIM(r.clasificacion) = c.nombre_clasificacion
WHERE c.id_clasificacion IS NULL;
```

Cargar los catálogos faltantes antes de crear FKs.

### Performance Lenta en la Carga

**Solución:** Optimizaciones

1. **Deshabilitar temporalmente índices:**

```sql
ALTER TABLE incidente DISABLE KEYS;
-- Cargar datos
ALTER TABLE incidente ENABLE KEYS;
```

2. **Aumentar tamaño de buffer:**

```sql
SET SESSION bulk_insert_buffer_size = 256 * 1024 * 1024; -- 256MB
```

3. **Usar transacciones:**

```sql
START TRANSACTION;
-- Inserts aquí
COMMIT;
```

---

## 📈 Monitoreo de Performance

### Analizar Uso de Índices

```sql
EXPLAIN SELECT 
    i.folio_incidente,
    c.nombre_clasificacion,
    u.colonia_catalogo
FROM incidente i
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia
WHERE i.fecha_registro_incidente >= '2022-01-01';
```

**Interpretar:**
- `type: ALL` → Mal, full table scan
- `type: ref` → Bien, usando índice
- `type: eq_ref` → Excelente, join optimizado

### Estadísticas de Tablas

```sql
SHOW TABLE STATUS WHERE Name IN ('incidente', 'reporte', 'ubicacion');

-- Ver tamaño de tablas
SELECT 
    TABLE_NAME,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS size_mb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'reportes_agua_cdmx'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
```

---

## 🧹 Limpieza (Opcional)

### Eliminar Tabla Temporal

```sql
DROP TABLE IF EXISTS reportes_agua_raw;
```

### Resetear Todo y Empezar de Nuevo

```sql
DROP DATABASE IF EXISTS reportes_agua_cdmx;
CREATE DATABASE reportes_agua_cdmx CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## ✅ Checklist de Implementación

- [ ] Base de datos creada con encoding correcto
- [ ] Schema 5NF ejecutado sin errores
- [ ] CSV cargado a tabla temporal
- [ ] Migración a 5NF completada
- [ ] Verificación de conteos realizada
- [ ] Integridad referencial validada
- [ ] Consultas de ejemplo probadas
- [ ] Tabla temporal eliminada (opcional)

---

## 📚 Recursos Adicionales

- **Documentación MySQL:** https://dev.mysql.com/doc/
- **Teoría de Normalización:** https://en.wikipedia.org/wiki/Database_normalization
- **Optimización de Consultas:** https://dev.mysql.com/doc/refman/8.0/en/optimization.html

---

## 🆘 Soporte

Si encuentras problemas durante la implementación:

1. Revisa los logs de MySQL: `/var/log/mysql/error.log` (Linux) o Event Viewer (Windows)
2. Verifica permisos de usuario en MySQL
3. Asegúrate de tener espacio en disco suficiente (al menos 1GB libre)
4. Consulta el archivo `diagrama_er_5nf.md` para entender las relaciones

---

**Última actualización:** Diciembre 2025  
**Versión del Schema:** 1.0 (5NF)

