# API REST - Sistema de Reportes de Agua CDMX

API RESTful construida con FastAPI para gestionar el sistema de reportes de agua de la Ciudad de México. Implementa operaciones CRUD completas para las 7 tablas normalizadas del schema 5NF.

---

## Características

- 7 Tablas Normalizadas (5NF): Clasificación, Medio Recepción, Alcaldía, Estado Incidente, Colonia, Incidente, Reporte
- Operaciones CRUD completas para todas las entidades
- Validaciones automáticas con Pydantic
- Documentación interactiva con Swagger UI y ReDoc
- Paginación y filtros avanzados (por estado, alcaldía, clasificación)
- Integridad referencial garantizada con Foreign Keys
- CORS habilitado para integraciones frontend
- Health checks y logging de requests
- Dashboard y Estadísticas Avanzadas
- Búsqueda Geoespacial por Radio
- Análisis Temporal (día/semana/mes)
- Actualización Masiva de Estados
- Identificación de Zonas Críticas

---

## Instalación

### Requisitos Previos

- Python 3.8+
- **PostgreSQL 12+** (base de datos utilizada)
- pip (gestor de paquetes de Python)

### Paso 1: Clonar el repositorio

```bash
cd proyecto_datos_equipo_5/api
```

### Paso 2: Crear entorno virtual

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### Paso 3: Instalar dependencias

```bash
pip install -r requirements.txt
```

### Paso 4: Configurar variables de entorno

1. Copiar el archivo de ejemplo:

```bash
# Windows
copy env.example .env

# Linux/Mac
cp env.example .env
```

2. Editar `.env` con tus credenciales:

```env
DB_USER=postgres
DB_PASSWORD=tu_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=reportes_agua_cdmx
```

### Paso 5: Asegurar que la base de datos existe

```bash
# Ejecutar los scripts SQL previos en PostgreSQL
psql -U postgres -d reportes_agua_cdmx -f ../04_schema_5nf.sql
psql -U postgres -d reportes_agua_cdmx -f ../05_migracion_a_5nf.sql
```

---

## Ejecución

### Modo Desarrollo

```bash
python main.py
```

O con uvicorn:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Modo Producción

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

La API estará disponible en: **http://localhost:8000**

---

## Documentación

- **Swagger UI**: http://localhost:8000/docs (interactiva, recomendada para pruebas)
- **ReDoc**: http://localhost:8000/redoc (documentación estática)
- **OpenAPI JSON**: http://localhost:8000/openapi.json

---

## Endpoints Principales

### 1. Clasificaciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/clasificaciones/` | Crear clasificación |
| GET | `/clasificaciones/` | Listar clasificaciones |
| GET | `/clasificaciones/{id}` | Obtener por ID |
| PUT | `/clasificaciones/{id}` | Actualizar |
| DELETE | `/clasificaciones/{id}` | Eliminar |

### 2. Medios de Recepción

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/medios-recepcion/` | Crear medio |
| GET | `/medios-recepcion/` | Listar medios |
| GET | `/medios-recepcion/{id}` | Obtener por ID |
| PUT | `/medios-recepcion/{id}` | Actualizar |
| DELETE | `/medios-recepcion/{id}` | Eliminar |

### 3. Alcaldías

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/alcaldias/` | Crear alcaldía |
| GET | `/alcaldias/` | Listar alcaldías (16 de CDMX) |
| GET | `/alcaldias/{id}` | Obtener por ID |
| PUT | `/alcaldias/{id}` | Actualizar |
| DELETE | `/alcaldias/{id}` | Eliminar |

### 4. Estados de Incidente

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/estados-incidente/` | Crear estado |
| GET | `/estados-incidente/` | Listar estados |
| GET | `/estados-incidente/{id}` | Obtener por ID |
| PUT | `/estados-incidente/{id}` | Actualizar |
| DELETE | `/estados-incidente/{id}` | Eliminar |

Estados predefinidos: Registrado, En Atención, Atendido, Cerrado, Cancelado

### 5. Colonias

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/colonias/` | Crear colonia |
| GET | `/colonias/` | Listar colonias |
| GET | `/colonias/{id}` | Obtener por ID |
| PUT | `/colonias/{id}` | Actualizar |
| DELETE | `/colonias/{id}` | Eliminar |

Filtros: `?alcaldia_id=3`

### 6. Incidentes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/incidentes/` | Crear incidente |
| GET | `/incidentes/` | Listar incidentes |
| GET | `/incidentes/{id}` | Obtener por ID |
| GET | `/incidentes/folio/{folio}` | Obtener por folio |
| PUT | `/incidentes/{id}` | Actualizar |
| DELETE | `/incidentes/{id}` | Eliminar (+ reportes en cascada) |

Filtros: `?clasificacion_id=1`, `?estado_id=2`, `?alcaldia_id=3`

### 7. Reportes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/reportes/` | Crear reporte |
| GET | `/reportes/` | Listar reportes |
| GET | `/reportes/{id}` | Obtener por ID |
| GET | `/reportes/codigo/{codigo}` | Obtener por código |
| PUT | `/reportes/{id}` | Actualizar |
| DELETE | `/reportes/{id}` | Eliminar |

Filtros: `?incidente_id=1`, `?medio_id=2`

### 8. Estadísticas y Análisis

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/estadisticas/dashboard` | **Dashboard general** - Visión completa del sistema |
| GET | `/estadisticas/alcaldia/{id}` | **Estadísticas por alcaldía** - Análisis detallado zonal |
| GET | `/estadisticas/temporal` | **Análisis temporal** - Tendencias por día/semana/mes |
| GET | `/estadisticas/zonas-criticas` | **Zonas críticas** - Colonias más afectadas |
| GET | `/incidentes/buscar/por-radio` | **Búsqueda geoespacial** - Incidentes en radio |
| POST | `/incidentes/actualizar-estado-masivo` | **Actualización masiva** - Cambiar estado de múltiples incidentes |

#### Dashboard General
**Retorna:**
- Total de incidentes, reportes, colonias y alcaldías
- Distribución de incidentes por estado
- Distribución de incidentes por clasificación
- Distribución de reportes por medio de recepción
- Top 10 alcaldías con más incidentes
- Promedio de reportes por incidente

**Casos de uso:** Pantalla principal de administración, monitoreo en tiempo real

#### Estadísticas por Alcaldía
**Retorna:**
- Información básica de la alcaldía
- Total de incidentes y colonias
- Top 5 clasificaciones más comunes en esa alcaldía
- Distribución de estados actuales
- Top 10 colonias más afectadas dentro de la alcaldía

**Casos de uso:** Planificación de recursos zonales, análisis comparativo entre alcaldías

#### Análisis Temporal
**Parámetros:**
- `fecha_inicio` (YYYY-MM-DD)
- `fecha_fin` (YYYY-MM-DD)
- `agrupacion` (dia, semana, mes)

**Retorna:**
- Serie temporal de incidentes
- Total de incidentes en el período

**Casos de uso:** Identificar tendencias, detectar picos de actividad, comparar períodos

#### Búsqueda por Radio
**Parámetros:**
- `longitud` (punto central)
- `latitud` (punto central)
- `radio_km` (0.1 a 20.0)
- `limit` (máximo de resultados)

**Retorna:**
- Incidentes dentro del radio especificado
- Usa fórmula de Haversine para precisión

**Casos de uso:** Análisis de proximidad, rutas de atención, estudios de concentración

#### Actualización Masiva
**Body:**
```json
{
  "ids_incidentes": [1, 2, 3, 4, 5],
  "nuevo_estado_id": 3
}
```

**Retorna:**
- Total solicitado vs actualizado
- IDs exitosos y fallidos

**Casos de uso:** Cierre masivo de incidentes, sincronización con sistemas externos

#### Zonas Críticas
**Parámetros:**
- `limit` (1-50, número de zonas)
- `clasificacion_id` (opcional, filtrar por tipo)

**Retorna:**
- Ranking de colonias con más incidentes
- Incluye nombre de alcaldía

**Casos de uso:** Priorización de recursos, planificación preventiva

### Paginación

Todos los endpoints GET de listado soportan paginación:

```
GET /incidentes/?skip=0&limit=50
```

- `skip`: Número de registros a saltar (default: 0)
- `limit`: Máximo de registros a retornar (default: 100)

---

## Ejemplos de Uso Básico

### Crear Clasificación

```bash
curl -X POST "http://localhost:8000/clasificaciones/" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre_clasificacion": "Agua Potable",
    "descripcion": "Problemas relacionados con agua potable",
    "activo": true
  }'
```

### Listar Incidentes

```bash
curl "http://localhost:8000/incidentes/?skip=0&limit=10"
```

### Obtener Incidente por Folio

```bash
curl "http://localhost:8000/incidentes/folio/I-20220101-0001"
```

### Crear Reporte

```bash
curl -X POST "http://localhost:8000/reportes/" \
  -H "Content-Type: application/json" \
  -d '{
    "id_reporte": "R-20221201-9999",
    "id_incidente": 1,
    "fecha_reporte": "2022-12-01",
    "hora_reporte": "14:30:00",
    "id_medio_recepcion": 1
  }'
```

### Filtrar Colonias por Alcaldía

```bash
curl "http://localhost:8000/colonias/?alcaldia_id=3&limit=20"
```

---

## Ejemplos de Uso Avanzado

### 8. Dashboard General del Sistema

```bash
curl -X GET "http://localhost:8000/estadisticas/dashboard" \
  -H "accept: application/json"
```

**Respuesta de ejemplo:**
```json
{
  "total_incidentes": 1523,
  "total_reportes": 3847,
  "total_colonias": 289,
  "total_alcaldias": 16,
  "promedio_reportes_por_incidente": 2.52,
  "incidentes_por_estado": [
    {"id_estado": 1, "nombre_estado": "Registrado", "total_incidentes": 342},
    {"id_estado": 2, "nombre_estado": "En Atención", "total_incidentes": 521},
    {"id_estado": 3, "nombre_estado": "Atendido", "total_incidentes": 660}
  ],
  "incidentes_por_clasificacion": [...],
  "reportes_por_medio": [...],
  "alcaldias_top": [
    {"id_alcaldia": 1, "nombre_alcaldia": "Iztapalapa", "total_incidentes": 287}
  ]
}
```

**Caso de uso:** Pantalla principal de administración para visualizar el estado completo del sistema.

---

### 9. Estadísticas Detalladas por Alcaldía

```bash
# Primero, obtener lista de alcaldías
curl "http://localhost:8000/alcaldias/?limit=5"

# Luego, obtener estadísticas de una específica (ej: Iztapalapa = id 1)
curl -X GET "http://localhost:8000/estadisticas/alcaldia/1" \
  -H "accept: application/json"
```

**Respuesta de ejemplo:**
```json
{
  "alcaldia": {
    "id_alcaldia": 1,
    "nombre_alcaldia": "Iztapalapa",
    "codigo_alcaldia": "IZT",
    "activo": true,
    "fecha_creacion": "2024-01-01T00:00:00"
  },
  "total_incidentes": 287,
  "total_colonias": 45,
  "clasificaciones_top": [
    {"id_clasificacion": 1, "nombre_clasificacion": "Fuga de Agua", "total_incidentes": 123},
    {"id_clasificacion": 2, "nombre_clasificacion": "Sin Suministro", "total_incidentes": 89}
  ],
  "estados_actuales": [...],
  "colonias_mas_afectadas": [
    {"id_colonia": 15, "nombre_colonia": "Santa Cruz Meyehualco", "total_incidentes": 34}
  ]
}
```

**Caso de uso:** Análisis zonal para asignación de cuadrillas y planificación de recursos.

---

### 10. Análisis Temporal (Tendencias)

#### Por Mes (Todo el año 2024)
```bash
curl -X GET "http://localhost:8000/estadisticas/temporal?fecha_inicio=2024-01-01&fecha_fin=2024-12-31&agrupacion=mes" \
  -H "accept: application/json"
```

#### Por Día (Enero 2024)
```bash
curl -X GET "http://localhost:8000/estadisticas/temporal?fecha_inicio=2024-01-01&fecha_fin=2024-01-31&agrupacion=dia" \
  -H "accept: application/json"
```

#### Por Semana (Primer Trimestre 2024)
```bash
curl -X GET "http://localhost:8000/estadisticas/temporal?fecha_inicio=2024-01-01&fecha_fin=2024-03-31&agrupacion=semana" \
  -H "accept: application/json"
```

**Respuesta de ejemplo:**
```json
{
  "fecha_inicio": "2024-01-01",
  "fecha_fin": "2024-12-31",
  "agrupacion": "mes",
  "total_periodo": 1523,
  "datos": [
    {"periodo": "2024-01", "total_incidentes": 127},
    {"periodo": "2024-02", "total_incidentes": 134},
    {"periodo": "2024-03", "total_incidentes": 145},
    {"periodo": "2024-04", "total_incidentes": 132}
  ]
}
```

**Caso de uso:** 
- Identificar meses/semanas con más incidentes
- Detectar tendencias estacionales
- Planificar recursos para períodos críticos
- Comparar año actual vs año anterior

---

### 11. Búsqueda Geoespacial por Radio

#### Buscar incidentes en un radio de 2 km desde el Centro Histórico
```bash
curl -X GET "http://localhost:8000/incidentes/buscar/por-radio?longitud=-99.1332&latitud=19.4326&radio_km=2&limit=50" \
  -H "accept: application/json"
```

#### Buscar en radio de 5 km desde Reforma
```bash
curl -X GET "http://localhost:8000/incidentes/buscar/por-radio?longitud=-99.1677&latitud=19.4270&radio_km=5&limit=100" \
  -H "accept: application/json"
```

**Coordenadas de Referencia en CDMX:**
- **Centro Histórico**: `-99.1332, 19.4326`
- **Reforma**: `-99.1677, 19.4270`
- **Polanco**: `-99.1919, 19.4339`
- **Coyoacán**: `-99.1620, 19.3502`
- **Santa Fe**: `-99.2599, 19.3600`

**Respuesta:** Lista de incidentes con todos sus datos, ordenados por proximidad.

**Caso de uso:**
- Planificar rutas de atención basadas en proximidad
- Analizar concentración de incidentes en una zona
- Identificar patrones geográficos
- Estudios de distribución espacial

---

### 12. Actualización Masiva de Estado

#### Paso 1: Obtener incidentes en estado "Registrado" (id_estado=1)
```bash
curl -X GET "http://localhost:8000/incidentes/?estado_id=1&limit=10" \
  -H "accept: application/json"
```

#### Paso 2: Extraer los IDs de los incidentes que quieres actualizar

#### Paso 3: Actualizar múltiples incidentes a "En Atención" (id_estado=2)
```bash
curl -X POST "http://localhost:8000/incidentes/actualizar-estado-masivo" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "ids_incidentes": [1, 2, 3, 4, 5, 8, 12, 15],
    "nuevo_estado_id": 2
  }'
```

**Estados Disponibles:**
- `1` = Registrado
- `2` = En Atención
- `3` = Atendido
- `4` = Cerrado
- `5` = Cancelado

**Respuesta de ejemplo:**
```json
{
  "total_solicitado": 8,
  "total_actualizado": 7,
  "ids_actualizados": [1, 2, 3, 4, 5, 8, 12],
  "ids_no_encontrados": [15]
}
```

**Caso de uso:**
- Cerrar múltiples incidentes después de una jornada de atención masiva
- Actualizar estado de incidentes filtrados previamente
- Sincronización con sistemas externos
- Operaciones administrativas batch

---

### 13. Zonas Críticas (Ranking de Colonias)

#### Top 10 colonias con más incidentes
```bash
curl -X GET "http://localhost:8000/estadisticas/zonas-criticas?limit=10" \
  -H "accept: application/json"
```

#### Top 5 colonias con incidentes de tipo "Fuga de Agua" (clasificacion_id=1)
```bash
curl -X GET "http://localhost:8000/estadisticas/zonas-criticas?limit=5&clasificacion_id=1" \
  -H "accept: application/json"
```

**Respuesta de ejemplo:**
```json
{
  "total_zonas": 10,
  "zonas": [
    {
      "id_colonia": 15,
      "nombre_colonia": "Santa Cruz Meyehualco",
      "alcaldia": "Iztapalapa",
      "total_incidentes": 34
    },
    {
      "id_colonia": 42,
      "nombre_colonia": "Doctores",
      "alcaldia": "Cuauhtémoc",
      "total_incidentes": 28
    }
  ]
}
```

**Caso de uso:**
- Identificar áreas que requieren atención prioritaria
- Asignar recursos a zonas más afectadas
- Planificar mantenimiento preventivo en zonas críticas
- Estudios de vulnerabilidad por zona

---

## Flujo de Trabajo Completo (Ejemplo Real)

### Escenario: Supervisión y Atención de Incidentes

```bash
# 1. Ver dashboard general al iniciar el día
curl "http://localhost:8000/estadisticas/dashboard"
# Resultado: 342 incidentes en estado "Registrado" requieren atención

# 2. Identificar alcaldía con más incidentes nuevos
# Dashboard muestra: Iztapalapa (id_alcaldia=1) tiene 87 incidentes nuevos

# 3. Ver estadísticas detalladas de Iztapalapa
curl "http://localhost:8000/estadisticas/alcaldia/1"
# Resultado: Colonias "Santa Cruz" y "Cabeza de Juárez" son las más afectadas

# 4. Ver tendencia temporal del último mes
curl "http://localhost:8000/estadisticas/temporal?fecha_inicio=2024-11-01&fecha_fin=2024-11-30&agrupacion=dia"
# Resultado: Picos los lunes y viernes

# 5. Obtener incidentes registrados en Iztapalapa
curl "http://localhost:8000/incidentes/?estado_id=1&alcaldia_id=1&limit=50"
# Resultado: Lista de 43 incidentes nuevos con sus IDs

# 6. Buscar incidentes cerca del primer punto (supongamos -99.08, 19.35)
curl "http://localhost:8000/incidentes/buscar/por-radio?longitud=-99.08&latitud=19.35&radio_km=3&limit=20"
# Resultado: 15 incidentes en un radio de 3 km - se pueden atender en una sola ruta

# 7. Después de que la cuadrilla atiende, actualizar estado masivo
curl -X POST "http://localhost:8000/incidentes/actualizar-estado-masivo" \
  -H "Content-Type: application/json" \
  -d '{
    "ids_incidentes": [45, 46, 47, 48, 49, 50, 51, 52],
    "nuevo_estado_id": 3
  }'
# Resultado: 8 incidentes marcados como "Atendido"

# 8. Verificar zonas críticas para planificación de mañana
curl "http://localhost:8000/estadisticas/zonas-criticas?limit=10"
# Resultado: Lista de colonias que requieren atención preventiva
```

---

## Testing con Postman

### Opción 1: Swagger UI (Recomendado)

1. Abrir: http://localhost:8000/docs
2. Expandir endpoint a probar
3. Clic en "Try it out"
4. Llenar parámetros
5. Clic en "Execute"
6. Ver respuesta

### Opción 2: Importar en Postman

1. Importar colección OpenAPI:
   - URL: http://localhost:8000/openapi.json
   - En Postman: Import → Link → Pegar URL

2. Configurar variable de entorno:
   ```json
   {
     "base_url": "http://localhost:8000"
   }
   ```

### Pruebas Recomendadas

**Básicas:**
```bash
curl http://localhost:8000/health
curl http://localhost:8000/clasificaciones/
curl http://localhost:8000/alcaldias/
```

**Estadísticas:**
```bash
curl http://localhost:8000/estadisticas/dashboard
curl http://localhost:8000/estadisticas/alcaldia/1
curl "http://localhost:8000/estadisticas/zonas-criticas?limit=5"
```

**Geoespaciales:**
```bash
curl "http://localhost:8000/incidentes/buscar/por-radio?longitud=-99.1332&latitud=19.4326&radio_km=2&limit=10"
```

**Para ejemplos detallados con Postman:** Ver `GUIA_POSTMAN.md`

---

## Estructura del Proyecto

```
api/
├── main.py                 # Aplicación principal FastAPI
├── database.py             # Configuración de SQLAlchemy y PostgreSQL
├── models.py               # Modelos de SQLAlchemy (7 tablas)
├── schemas.py              # Schemas de Pydantic
├── crud.py                 # Operaciones CRUD + estadísticas
├── requirements.txt        # Dependencias
├── env.example             # Template de variables de entorno
└── routers/                # Endpoints por entidad
    ├── clasificacion.py
    ├── medio_recepcion.py
    ├── alcaldia.py
    ├── estado_incidente.py
    ├── colonia.py
    ├── incidente.py
    ├── reporte.py
    └── estadisticas.py
```

---

## Validaciones

**Coordenadas:**
- Longitud: -99.4 a -98.9 (CDMX)
- Latitud: 19.0 a 19.6 (CDMX)

**Integridad Referencial:**
- Clasificación/Medio: No se puede eliminar si tiene registros asociados
- Incidente: Al eliminar, se eliminan reportes en cascada

**Unicidad:**
- Folio de Incidente
- Código de Reporte
- Nombre de Clasificación
- Nombre de Medio
- Nombre de Alcaldía

---

## Resumen

**CRUD Completo:** 7 entidades normalizadas en 5NF

**Funcionalidades Avanzadas:**
- Dashboard General
- Estadísticas por Alcaldía
- Análisis Temporal
- Búsqueda Geoespacial
- Actualización Masiva
- Zonas Críticas

**Casos de Uso:**
- Supervisión en tiempo real
- Planificación de rutas
- Análisis de tendencias
- Gestión zonal
- Operaciones batch
- Priorización de recursos

---

## Inicio Rápido

```bash
cd api
.\venv_nuevo\Scripts\Activate.ps1  # Windows
pip install -r requirements.txt
copy env.example .env  # Editar con credenciales
python main.py
```

Abrir: http://localhost:8000/docs

**Primera prueba:**
```bash
curl http://localhost:8000/estadisticas/dashboard
```

---

