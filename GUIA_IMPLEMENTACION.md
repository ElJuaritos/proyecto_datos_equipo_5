# Guía de Implementación - Sistema de Reportes de Agua 5NF

Instrucciones detalladas de implementación y solución de problemas.

---

## Requisitos Previos

- PostgreSQL 12+
- Acceso a línea de comandos o pgAdmin
- Python 3.8+ (opcional, para método alternativo de carga)
- El archivo `reportes_agua_2024_01.csv`

---

## Implementación Completa con PostgreSQL

### Paso 1: Crear la Base de Datos

```bash
psql -U postgres
```

```sql
CREATE DATABASE reportes_agua_cdmx 
ENCODING 'UTF8'
LC_COLLATE = 'es_MX.UTF-8'
LC_CTYPE = 'es_MX.UTF-8';

\c reportes_agua_cdmx

-- Verificar conexión
SELECT current_database();
```

### Paso 2: Crear el Schema en 5NF

```bash
psql -U postgres -d reportes_agua_cdmx -f 04_schema_5nf.sql
```

**Verificar tablas creadas:**

```sql
\dt

-- Debe mostrar 7 tablas:
-- clasificacion, medio_recepcion, alcaldia, estado_incidente, colonia, incidente, reporte

-- Ver estructura de una tabla
\d incidente

-- Ver claves foráneas
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public';
```

### Paso 3: Ejecutar Migración a 5NF

El script `05_migracion_a_5nf.sql` crea la tabla temporal y carga los datos automáticamente.

```bash
psql -U postgres -d reportes_agua_cdmx -f 05_migracion_a_5nf.sql
```

**El script ejecuta:**
1. Crea tabla temporal `reportes_agua_raw`
2. Carga CSV con `\copy`
3. Extrae y carga catálogos (CLASIFICACION, MEDIO_RECEPCION, ALCALDIA)
4. Normaliza colonias con FK a alcaldía
5. Carga incidentes con coordenadas exactas
6. Carga reportes con integridad referencial
7. Genera estadísticas de validación

**Verificar resultados:**

```sql
-- Conteo por tabla
SELECT 'clasificacion' AS tabla, COUNT(*) FROM clasificacion
UNION ALL SELECT 'medio_recepcion', COUNT(*) FROM medio_recepcion
UNION ALL SELECT 'alcaldia', COUNT(*) FROM alcaldia
UNION ALL SELECT 'estado_incidente', COUNT(*) FROM estado_incidente
UNION ALL SELECT 'colonia', COUNT(*) FROM colonia
UNION ALL SELECT 'incidente', COUNT(*) FROM incidente
UNION ALL SELECT 'reporte', COUNT(*) FROM reporte;

-- Resultado esperado:
-- clasificacion: 2-5
-- medio_recepcion: 3-10
-- alcaldia: 16
-- estado_incidente: 5
-- colonia: 1000-2000
-- incidente: 100,000-200,000
-- reporte: 300,000+
```

### Paso 4: Probar Consultas

```bash
psql -U postgres -d reportes_agua_cdmx -f 06_consultas_ejemplo_5nf.sql
```

---

## Método Alternativo: Carga con Python

### Requisitos

```bash
pip install pandas psycopg2-binary sqlalchemy
```

### Script de Carga

```python
# cargar_datos.py
import pandas as pd
from sqlalchemy import create_engine

# Configuración de conexión
DB_CONFIG = {
    'user': 'postgres',
    'password': 'tu_password',
    'host': 'localhost',
    'port': '5432',
    'database': 'reportes_agua_cdmx'
}

# Crear engine de SQLAlchemy
engine = create_engine(
    f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@"
    f"{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# Leer CSV
print("Cargando CSV...")
df = pd.read_csv('reportes_agua_2024_01.csv', encoding='utf-8')
print(f"Registros cargados: {len(df)}")

# Cargar a tabla temporal
print("Cargando datos a PostgreSQL...")
df.to_sql(
    name='reportes_agua_raw',
    con=engine,
    if_exists='replace',
    index=False,
    chunksize=1000
)

print("Carga completada!")
print("Ejecutar ahora: psql -U postgres -d reportes_agua_cdmx -f 05_migracion_a_5nf.sql")
```

**Ejecutar:**

```bash
python cargar_datos.py
```

---

## Verificación de Integridad

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

## Solución de Problemas Comunes

### Error: "permission denied for database"

**Problema:** Usuario no tiene permisos.

**Solución:**

```sql
GRANT ALL PRIVILEGES ON DATABASE reportes_agua_cdmx TO postgres;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
```

### Error: "value too long for type character varying"

**Problema:** Algún valor excede el tamaño de VARCHAR definido.

**Solución:** Identificar valores largos

```sql
SELECT 
    MAX(LENGTH(reporte)) AS max_reporte,
    MAX(LENGTH(colonia_catalogo)) AS max_colonia
FROM reportes_agua_raw;
```

Ajustar tamaños en el schema si es necesario.

### Error: "insert or update violates foreign key constraint"

**Problema:** Valores en FK no existen en tabla referenciada.

**Solución:** Verificar datos huérfanos

```sql
-- Verificar clasificaciones inexistentes
SELECT DISTINCT r.clasificacion
FROM reportes_agua_raw r
LEFT JOIN clasificacion c ON TRIM(r.clasificacion) = c.nombre_clasificacion
WHERE c.id_clasificacion IS NULL;
```

Cargar los catálogos faltantes antes de insertar datos.

### Performance Lenta en la Carga

**Optimizaciones:**

1. **Usar transacciones:**

```sql
BEGIN;
-- Inserts aquí
COMMIT;
```

2. **Deshabilitar triggers temporalmente:**

```sql
ALTER TABLE incidente DISABLE TRIGGER ALL;
-- Cargar datos
ALTER TABLE incidente ENABLE TRIGGER ALL;
```

3. **Aumentar work_mem:**

```sql
SET work_mem = '256MB';
```

---

## Monitoreo de Performance

### Analizar Uso de Índices

```sql
EXPLAIN ANALYZE
SELECT 
    i.folio_incidente,
    c.nombre_clasificacion,
    col.nombre_colonia,
    a.nombre_alcaldia
FROM incidente i
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
LEFT JOIN colonia col ON i.id_colonia = col.id_colonia
LEFT JOIN alcaldia a ON col.id_alcaldia = a.id_alcaldia
WHERE i.fecha_registro_incidente >= '2022-01-01';
```

**Interpretar:**
- `Seq Scan` → Mal, escaneo secuencial completo
- `Index Scan` → Bien, usando índice
- `Index Only Scan` → Excelente, solo índice

### Estadísticas de Tablas

```sql
-- Ver tamaño de tablas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Actualizar estadísticas
ANALYZE;
```

---

## Limpieza (Opcional)

### Eliminar Tabla Temporal

```sql
DROP TABLE IF EXISTS reportes_agua_raw;
```

### Resetear Todo

```sql
DROP DATABASE IF EXISTS reportes_agua_cdmx;
CREATE DATABASE reportes_agua_cdmx ENCODING 'UTF8';
```

---

## Checklist de Implementación

- Base de datos creada con encoding correcto
- Schema 5NF ejecutado sin errores
- CSV cargado a tabla temporal
- Migración a 5NF completada
- Verificación de conteos realizada
- Integridad referencial validada
- Consultas de ejemplo probadas

---

## Soporte

Si encuentra problemas:

1. Revisar logs de PostgreSQL: `/var/log/postgresql/` (Linux) o Event Viewer (Windows)
2. Verificar permisos de usuario
3. Asegurar espacio en disco suficiente (mínimo 1GB libre)
4. Consultar `diagrama_er_5nf.md` para entender las relaciones

**Para inicio rápido:** Ver `INICIO_RAPIDO.md`

