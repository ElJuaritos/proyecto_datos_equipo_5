# Guía de Inicio Rápido

Levanta el sistema completo en menos de 5 minutos.

### Requisitos Previos
- PostgreSQL 12+ instalado y corriendo
- Python 3.8+ (solo para la API)

---

## Opción 1: Solo Base de Datos

```bash
# 1. Crear base de datos
psql -U postgres -c "CREATE DATABASE reportes_agua_cdmx;"

# 2. Crear schema (7 tablas en 5NF)
psql -U postgres -d reportes_agua_cdmx -f 04_schema_5nf.sql

# 3. Cargar datos (300K+ registros, demora ~2-5 minutos)
psql -U postgres -d reportes_agua_cdmx -f 05_migracion_a_5nf.sql
```

### Verificar instalación:

```sql
psql -U postgres -d reportes_agua_cdmx

-- Ver conteo de registros
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

---

## Opción 2: Base de Datos + API

### Paso 1: Base de Datos (ejecutar Opción 1)

### Paso 2: Configurar API

```bash
cd api

# Crear y activar entorno virtual
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Instalar dependencias
pip install -r requirements.txt

# Configurar credenciales
copy env.example .env  # Windows
# cp env.example .env  # Linux/Mac

# Editar .env con tus credenciales PostgreSQL:
# DB_USER=postgres
# DB_PASSWORD=tu_password
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=reportes_agua_cdmx
```

### Paso 3: Iniciar API

```bash
python main.py
```

Abre tu navegador en: **http://localhost:8000/docs**

---

## Pruebas Rápidas de la API

### Navegador (Swagger UI)
1. Abrir: http://localhost:8000/docs
2. Expandir cualquier endpoint
3. Clic en "Try it out" → "Execute"

### Terminal (curl)
```bash
# Dashboard general
curl http://localhost:8000/estadisticas/dashboard

# Top 5 zonas críticas
curl http://localhost:8000/estadisticas/zonas-criticas?limit=5

# Listar incidentes
curl http://localhost:8000/incidentes/?limit=10
```

---

## Consulta SQL Rápida

```sql
-- Top 10 alcaldías con más incidentes
SELECT a.nombre_alcaldia, COUNT(i.id_incidente) AS total
FROM alcaldia a
LEFT JOIN colonia c ON a.id_alcaldia = c.id_alcaldia
LEFT JOIN incidente i ON c.id_colonia = i.id_colonia
GROUP BY a.id_alcaldia
ORDER BY total DESC
LIMIT 10;
```

---

## Solución de Problemas

**Error: "Access denied"**
- Editar `.env` con las credenciales correctas

**Error: "Database does not exist"**
```bash
psql -U postgres -c "CREATE DATABASE reportes_agua_cdmx;"
```

**Error: "Table doesn't exist"**
```bash
psql -U postgres -d reportes_agua_cdmx -f 04_schema_5nf.sql
```

**API no inicia**
- Verificar que estás en el entorno virtual activado
- Verificar que `.env` esté configurado correctamente

**Para más detalles:** Ver `GUIA_IMPLEMENTACION.md`

---

## Siguientes Pasos

- **Explorar análisis:** Ver `ANALISIS_RESULTADOS.md`
- **Entender el modelo:** Ver `diagrama_er_5nf.md`
- **Probar con Postman:** Ver `GUIA_POSTMAN.md`
- **Documentación API:** Ver `api/README_API.md`

---

## Tiempo Estimado

| Tarea | Tiempo |
|-------|--------|
| Base de datos completa | 3 minutos |
| Instalar y configurar API | 2 minutos |
| **Total** | **5 minutos** |

