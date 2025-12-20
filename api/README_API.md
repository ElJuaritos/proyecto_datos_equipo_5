

# API REST - Sistema de Reportes de Agua CDMX

API RESTful construida con **FastAPI** para gestionar el sistema de reportes de agua de la Ciudad de México. Implementa operaciones CRUD completas para las **7 tablas normalizadas del schema 5NF MEJORADO**.

---

## 📋 Características

- ✅ **7 Tablas Normalizadas (5NF Verdadero)**: Clasificación, Medio Recepción, **Alcaldía**, **Estado Incidente**, Colonia, Incidente, Reporte
- ✅ **Operaciones CRUD completas** para todas las entidades
- ✅ **Validaciones automáticas** con Pydantic (incluyendo estados y alcaldías)
- ✅ **Documentación interactiva** con Swagger UI y ReDoc
- ✅ **Paginación y filtros avanzados** en endpoints de lectura (por estado, alcaldía, etc.)
- ✅ **Integridad referencial TOTAL** garantizada con Foreign Keys validadas
- ✅ **CORS habilitado** para integraciones frontend
- ✅ **Health checks** y logging de requests
- ✅ **Sin dependencias transitivas** - 5NF verdadera alcanzada
- ✅ **Granularidad geoespacial** - Centroide de colonia + punto exacto de incidente
- ✅ **🆕 Dashboard y Estadísticas Avanzadas** - Análisis completo del sistema
- ✅ **🆕 Búsqueda Geoespacial por Radio** - Encuentra incidentes por proximidad
- ✅ **🆕 Análisis Temporal** - Tendencias por día/semana/mes
- ✅ **🆕 Actualización Masiva** - Cambia estado de múltiples incidentes
- ✅ **🆕 Zonas Críticas** - Identifica colonias con más incidentes

---

## 🚀 Instalación

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

## ▶️ Ejecución

### Modo Desarrollo (con hot reload)

```bash
python main.py
```

O usando uvicorn directamente:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Modo Producción

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

La API estará disponible en: **http://localhost:8000**

---

## 📚 Documentación

### Swagger UI (Interactiva)

Abre tu navegador en: **http://localhost:8000/docs**

Aquí puedes:
- Ver todos los endpoints disponibles
- Probar las operaciones directamente
- Ver los schemas de entrada/salida
- Ejecutar requests desde el navegador

### ReDoc (Documentación Estática)

Abre tu navegador en: **http://localhost:8000/redoc**

Documentación más limpia y orientada a lectura.

### OpenAPI JSON

Schema OpenAPI 3.0: **http://localhost:8000/openapi.json**

---

## 🔌 Endpoints Principales

**Nota**: Los endpoints ya NO tienen el prefijo `/api/v1` (actualizado a rutas simples)

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

### 3. Alcaldías ← **NUEVO**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/alcaldias/` | Crear alcaldía |
| GET | `/alcaldias/` | Listar alcaldías (16 de CDMX) |
| GET | `/alcaldias/{id}` | Obtener por ID |
| PUT | `/alcaldias/{id}` | Actualizar |
| DELETE | `/alcaldias/{id}` | Eliminar |

**Beneficio**: Nombres de alcaldías almacenados 1 vez (sin redundancia)

### 4. Estados de Incidente ← **NUEVO**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/estados-incidente/` | Crear estado |
| GET | `/estados-incidente/` | Listar estados (ordenados) |
| GET | `/estados-incidente/{id}` | Obtener por ID |
| PUT | `/estados-incidente/{id}` | Actualizar |
| DELETE | `/estados-incidente/{id}` | Eliminar |

**Estados predefinidos**: Registrado, En Atención, Atendido, Cerrado, Cancelado

### 5. Colonias (antes: Ubicaciones) ← **REFACTORIZADA**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/colonias/` | Crear colonia |
| GET | `/colonias/` | Listar colonias |
| GET | `/colonias/{id}` | Obtener por ID |
| PUT | `/colonias/{id}` | Actualizar |
| DELETE | `/colonias/{id}` | Eliminar |

**Filtros disponibles:** `?alcaldia_id=3` (filtrar por ID de alcaldía)  
**Mejora**: Ahora tiene FK a alcaldía (no almacena nombre repetido)

### 6. Incidentes ← **MEJORADA**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/incidentes/` | Crear incidente |
| GET | `/incidentes/` | Listar incidentes |
| GET | `/incidentes/{id}` | Obtener por ID |
| GET | `/incidentes/folio/{folio}` | Obtener por folio |
| PUT | `/incidentes/{id}` | Actualizar (incluyendo estado) |
| DELETE | `/incidentes/{id}` | Eliminar (+ reportes en cascada) |

**Filtros disponibles:** 
- `?clasificacion_id=1` - Por tipo de incidente
- `?estado_id=2` - **NUEVO**: Por estado validado
- `?alcaldia_id=3` - **NUEVO**: Por alcaldía (JOIN con colonia)

**Mejoras**:
- `id_estado` ahora es FK validada (no más VARCHAR)
- Incluye `longitud_incidente` y `latitud_incidente` (punto exacto)

### 7. Reportes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/reportes/` | Crear reporte |
| GET | `/reportes/` | Listar reportes |
| GET | `/reportes/{id}` | Obtener por ID |
| GET | `/reportes/codigo/{codigo}` | Obtener por código |
| PUT | `/reportes/{id}` | Actualizar |
| DELETE | `/reportes/{id}` | Eliminar |

**Filtros disponibles:**
- `?incidente_id=1`
- `?medio_id=2`

### 8. Estadísticas y Análisis ← **🆕 NUEVAS FUNCIONALIDADES**

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/estadisticas/dashboard` | **Dashboard general** - Visión completa del sistema |
| GET | `/estadisticas/alcaldia/{id}` | **Estadísticas por alcaldía** - Análisis detallado zonal |
| GET | `/estadisticas/temporal` | **Análisis temporal** - Tendencias por día/semana/mes |
| GET | `/estadisticas/zonas-criticas` | **Zonas críticas** - Colonias más afectadas |
| GET | `/incidentes/buscar/por-radio` | **Búsqueda geoespacial** - Incidentes en radio |
| POST | `/incidentes/actualizar-estado-masivo` | **Actualización masiva** - Cambiar estado de múltiples incidentes |

#### 📊 Dashboard General
**Retorna:**
- Total de incidentes, reportes, colonias y alcaldías
- Distribución de incidentes por estado
- Distribución de incidentes por clasificación
- Distribución de reportes por medio de recepción
- Top 10 alcaldías con más incidentes
- Promedio de reportes por incidente

**Casos de uso:** Pantalla principal de administración, monitoreo en tiempo real

#### 🏙️ Estadísticas por Alcaldía
**Retorna:**
- Información básica de la alcaldía
- Total de incidentes y colonias
- Top 5 clasificaciones más comunes en esa alcaldía
- Distribución de estados actuales
- Top 10 colonias más afectadas dentro de la alcaldía

**Casos de uso:** Planificación de recursos zonales, análisis comparativo entre alcaldías

#### 📈 Análisis Temporal
**Parámetros:**
- `fecha_inicio` (YYYY-MM-DD)
- `fecha_fin` (YYYY-MM-DD)
- `agrupacion` (dia, semana, mes)

**Retorna:**
- Serie temporal de incidentes
- Total de incidentes en el período

**Casos de uso:** Identificar tendencias, detectar picos de actividad, comparar períodos

#### 🗺️ Búsqueda por Radio
**Parámetros:**
- `longitud` (punto central)
- `latitud` (punto central)
- `radio_km` (0.1 a 20.0)
- `limit` (máximo de resultados)

**Retorna:**
- Incidentes dentro del radio especificado
- Usa fórmula de Haversine para precisión

**Casos de uso:** Análisis de proximidad, rutas de atención, estudios de concentración

#### 🔄 Actualización Masiva
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

#### 🏆 Zonas Críticas
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

## 💡 Ejemplos de Uso Básico (CRUD)

### 1. Crear una Clasificación

```bash
curl -X POST "http://localhost:8000/clasificaciones/" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre_clasificacion": "Agua Potable",
    "descripcion": "Problemas relacionados con agua potable",
    "activo": true
  }'
```

### 2. Listar Incidentes

```bash
curl "http://localhost:8000/incidentes/?skip=0&limit=10"
```

### 3. Obtener Incidente por Folio

```bash
curl "http://localhost:8000/incidentes/folio/I-20220101-0001"
```

### 4. Crear un Reporte

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

### 5. Filtrar Colonias por Alcaldía

```bash
curl "http://localhost:8000/colonias/?alcaldia_id=3&limit=20"
```

### 6. Actualizar Estado de Incidente

```bash
curl -X PUT "http://localhost:8000/incidentes/1" \
  -H "Content-Type: application/json" \
  -d '{
    "id_estado": 3
  }'
```

### 7. Eliminar un Reporte

```bash
curl -X DELETE "http://localhost:8000/reportes/100"
```

---

## 🚀 Ejemplos de Uso Avanzado (NUEVAS FUNCIONALIDADES)

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

## 🎯 Flujo de Trabajo Completo (Ejemplo Real)

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

## 🧪 Testing con Postman/Insomnia

### Opción 1: Swagger UI (Recomendado - Más Fácil)

1. Abre tu navegador en: **http://localhost:8000/docs**
2. Busca la sección que quieres probar (ej: "Estadísticas")
3. Expande el endpoint (ej: `GET /estadisticas/dashboard`)
4. Haz clic en **"Try it out"**
5. Llena los parámetros (si los hay)
6. Haz clic en **"Execute"**
7. Ve la respuesta directamente en el navegador

**Ventajas:**
- No requiere instalación
- Documentación integrada
- Validación automática
- Pruebas inmediatas

### Opción 2: Postman / Insomnia

1. **Importar colección OpenAPI:**
   - Descarga el schema: http://localhost:8000/openapi.json
   - En Postman: `Import` → `Upload Files` → Selecciona el archivo descargado
   - En Insomnia: `Import/Export` → `Import Data` → `From File`
   - Todos los endpoints estarán disponibles automáticamente

2. **Configurar variables de entorno:**
   
   En Postman, crea un Environment con:
   ```json
   {
     "base_url": "http://localhost:8000"
   }
   ```

3. **Endpoints de prueba recomendados:**
   - ✅ `GET /health` - Verificar que la API está funcionando
   - ✅ `GET /estadisticas/dashboard` - Ver estadísticas generales
   - ✅ `GET /alcaldias/` - Listar alcaldías
   - ✅ `GET /incidentes/?limit=5` - Ver primeros 5 incidentes
   - ✅ `GET /estadisticas/zonas-criticas?limit=5` - Top 5 zonas

### Opción 3: Curl (Terminal)

Copia y pega directamente los comandos de la sección **"Ejemplos de Uso Avanzado"** en tu terminal.

### Colección de Pruebas Recomendadas

#### 1. **Pruebas Básicas** (Verificar funcionamiento)
```bash
# Health check
curl http://localhost:8000/health

# Root endpoint
curl http://localhost:8000/

# Listar clasificaciones
curl http://localhost:8000/clasificaciones/

# Listar estados
curl http://localhost:8000/estados-incidente/
```

#### 2. **Pruebas de Estadísticas** (Funcionalidades nuevas)
```bash
# Dashboard
curl http://localhost:8000/estadisticas/dashboard

# Estadísticas de alcaldía 1
curl http://localhost:8000/estadisticas/alcaldia/1

# Análisis temporal del mes actual
curl "http://localhost:8000/estadisticas/temporal?fecha_inicio=2024-01-01&fecha_fin=2024-01-31&agrupacion=dia"

# Zonas críticas
curl "http://localhost:8000/estadisticas/zonas-criticas?limit=5"
```

#### 3. **Pruebas Geoespaciales**
```bash
# Búsqueda por radio (Centro Histórico)
curl "http://localhost:8000/incidentes/buscar/por-radio?longitud=-99.1332&latitud=19.4326&radio_km=2&limit=10"
```

#### 4. **Pruebas de Actualización Masiva**
```bash
# Listar incidentes registrados
curl "http://localhost:8000/incidentes/?estado_id=1&limit=3"

# Actualizar estado (cambia los IDs según tu BD)
curl -X POST "http://localhost:8000/incidentes/actualizar-estado-masivo" \
  -H "Content-Type: application/json" \
  -d '{"ids_incidentes": [1, 2], "nuevo_estado_id": 2}'
```

---

## 🐍 Uso desde Python

### Operaciones Básicas

```python
import requests

BASE_URL = "http://localhost:8000"

# Obtener clasificaciones
response = requests.get(f"{BASE_URL}/clasificaciones/")
clasificaciones = response.json()
print(f"Total clasificaciones: {len(clasificaciones)}")

# Crear nueva colonia
nueva_colonia = {
    "nombre_colonia": "Roma Norte",
    "id_alcaldia": 5,  # ID de Cuauhtémoc
    "codigo_postal": "06700",
    "centroide_longitud": -99.1627,
    "centroide_latitud": 19.4186,
    "activo": True
}

response = requests.post(
    f"{BASE_URL}/colonias/",
    json=nueva_colonia
)

if response.status_code == 201:
    colonia_creada = response.json()
    print(f"Colonia creada con ID: {colonia_creada['id_colonia']}")

# Filtrar incidentes por clasificación y estado
response = requests.get(
    f"{BASE_URL}/incidentes/",
    params={"clasificacion_id": 1, "estado_id": 1, "limit": 50}
)
incidentes = response.json()
print(f"Total incidentes: {len(incidentes)}")
```

### Uso Avanzado - Dashboard y Estadísticas

```python
import requests
import pandas as pd
from datetime import datetime, timedelta

BASE_URL = "http://localhost:8000"

# 1. Obtener dashboard general
def obtener_dashboard():
    response = requests.get(f"{BASE_URL}/estadisticas/dashboard")
    if response.status_code == 200:
        dashboard = response.json()
        print(f"📊 Total Incidentes: {dashboard['total_incidentes']}")
        print(f"📝 Total Reportes: {dashboard['total_reportes']}")
        print(f"📍 Total Colonias: {dashboard['total_colonias']}")
        print(f"🏙️ Total Alcaldías: {dashboard['total_alcaldias']}")
        print(f"📈 Promedio Reportes/Incidente: {dashboard['promedio_reportes_por_incidente']}")
        
        print("\n🚦 Incidentes por Estado:")
        for estado in dashboard['incidentes_por_estado']:
            print(f"  - {estado['nombre_estado']}: {estado['total_incidentes']}")
        
        return dashboard
    return None

# 2. Análisis temporal con gráfica
def analisis_temporal_a_dataframe(fecha_inicio, fecha_fin, agrupacion="mes"):
    response = requests.get(
        f"{BASE_URL}/estadisticas/temporal",
        params={
            "fecha_inicio": fecha_inicio,
            "fecha_fin": fecha_fin,
            "agrupacion": agrupacion
        }
    )
    
    if response.status_code == 200:
        data = response.json()
        df = pd.DataFrame(data['datos'])
        print(f"\n📅 Análisis Temporal ({agrupacion})")
        print(f"Total del período: {data['total_periodo']}")
        print(df)
        
        # Si tienes matplotlib instalado:
        # import matplotlib.pyplot as plt
        # df.plot(x='periodo', y='total_incidentes', kind='line')
        # plt.title(f'Incidentes por {agrupacion}')
        # plt.show()
        
        return df
    return None

# 3. Búsqueda geoespacial y procesamiento
def incidentes_en_radio(longitud, latitud, radio_km=2):
    response = requests.get(
        f"{BASE_URL}/incidentes/buscar/por-radio",
        params={
            "longitud": longitud,
            "latitud": latitud,
            "radio_km": radio_km,
            "limit": 100
        }
    )
    
    if response.status_code == 200:
        incidentes = response.json()
        print(f"\n🗺️ Incidentes en radio de {radio_km} km:")
        print(f"Total encontrados: {len(incidentes)}")
        
        # Agrupar por clasificación
        clasificaciones = {}
        for inc in incidentes:
            if inc.get('clasificacion'):
                nombre = inc['clasificacion']['nombre_clasificacion']
                clasificaciones[nombre] = clasificaciones.get(nombre, 0) + 1
        
        print("\n📊 Por clasificación:")
        for nombre, total in clasificaciones.items():
            print(f"  - {nombre}: {total}")
        
        return incidentes
    return []

# 4. Actualización masiva con validación
def actualizar_incidentes_masivo(ids_incidentes, nuevo_estado_id):
    payload = {
        "ids_incidentes": ids_incidentes,
        "nuevo_estado_id": nuevo_estado_id
    }
    
    response = requests.post(
        f"{BASE_URL}/incidentes/actualizar-estado-masivo",
        json=payload
    )
    
    if response.status_code == 200:
        resultado = response.json()
        print(f"\n✅ Actualización Masiva Completada:")
        print(f"  Total solicitado: {resultado['total_solicitado']}")
        print(f"  Total actualizado: {resultado['total_actualizado']}")
        
        if resultado['ids_no_encontrados']:
            print(f"  ⚠️ No encontrados: {resultado['ids_no_encontrados']}")
        
        return resultado
    else:
        print(f"❌ Error: {response.json()}")
        return None

# 5. Análisis de zonas críticas
def analizar_zonas_criticas(limit=10, clasificacion_id=None):
    params = {"limit": limit}
    if clasificacion_id:
        params["clasificacion_id"] = clasificacion_id
    
    response = requests.get(
        f"{BASE_URL}/estadisticas/zonas-criticas",
        params=params
    )
    
    if response.status_code == 200:
        data = response.json()
        print(f"\n🏆 Top {limit} Zonas Críticas:")
        for i, zona in enumerate(data['zonas'], 1):
            print(f"{i}. {zona['nombre_colonia']} ({zona['alcaldia']}): {zona['total_incidentes']} incidentes")
        
        return data['zonas']
    return []

# 6. Estadísticas por alcaldía
def estadisticas_alcaldia(alcaldia_id):
    response = requests.get(f"{BASE_URL}/estadisticas/alcaldia/{alcaldia_id}")
    
    if response.status_code == 200:
        stats = response.json()
        print(f"\n🏙️ Estadísticas de {stats['alcaldia']['nombre_alcaldia']}:")
        print(f"  Total incidentes: {stats['total_incidentes']}")
        print(f"  Total colonias: {stats['total_colonias']}")
        
        print(f"\n  Top Clasificaciones:")
        for c in stats['clasificaciones_top'][:3]:
            print(f"    - {c['nombre_clasificacion']}: {c['total_incidentes']}")
        
        print(f"\n  Top Colonias Afectadas:")
        for c in stats['colonias_mas_afectadas'][:5]:
            print(f"    - {c['nombre_colonia']}: {c['total_incidentes']}")
        
        return stats
    return None

# EJEMPLO DE USO COMPLETO
if __name__ == "__main__":
    print("=" * 60)
    print("🚰 SISTEMA DE REPORTES DE AGUA CDMX - ANÁLISIS COMPLETO")
    print("=" * 60)
    
    # Dashboard general
    dashboard = obtener_dashboard()
    
    # Análisis temporal del último mes
    fecha_fin = datetime.now().strftime("%Y-%m-%d")
    fecha_inicio = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
    df_temporal = analisis_temporal_a_dataframe(fecha_inicio, fecha_fin, "dia")
    
    # Buscar incidentes cerca del Centro Histórico
    incidentes_centro = incidentes_en_radio(-99.1332, 19.4326, radio_km=3)
    
    # Analizar zonas críticas
    zonas = analizar_zonas_criticas(limit=10)
    
    # Estadísticas de Iztapalapa (alcaldia_id=1)
    stats_izt = estadisticas_alcaldia(1)
    
    # Ejemplo de actualización masiva (comentado por seguridad)
    # resultado = actualizar_incidentes_masivo([1, 2, 3], nuevo_estado_id=2)
    
    print("\n" + "=" * 60)
    print("✅ Análisis completado")
    print("=" * 60)
```

### Script de Monitoreo Continuo

```python
import requests
import time
from datetime import datetime

BASE_URL = "http://localhost:8000"

def monitorear_sistema(intervalo_segundos=300):
    """Monitoreo continuo cada 5 minutos"""
    while True:
        print(f"\n{'='*60}")
        print(f"🕐 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"{'='*60}")
        
        # Dashboard
        dashboard = requests.get(f"{BASE_URL}/estadisticas/dashboard").json()
        
        # Incidentes nuevos (Registrado)
        registrados = [e for e in dashboard['incidentes_por_estado'] 
                      if e['nombre_estado'] == 'Registrado']
        
        if registrados:
            total_nuevos = registrados[0]['total_incidentes']
            print(f"🆕 Incidentes nuevos: {total_nuevos}")
            
            if total_nuevos > 50:
                print("⚠️  ALERTA: Más de 50 incidentes nuevos!")
        
        # Zonas críticas
        zonas = requests.get(
            f"{BASE_URL}/estadisticas/zonas-criticas",
            params={"limit": 3}
        ).json()
        
        print(f"\n🏆 Top 3 Zonas Críticas:")
        for zona in zonas['zonas']:
            print(f"  - {zona['nombre_colonia']}: {zona['total_incidentes']}")
        
        time.sleep(intervalo_segundos)

# Ejecutar monitoreo (descomentar para usar)
# monitorear_sistema(intervalo_segundos=300)
```

---

## 📦 Estructura del Proyecto

```
api/
├── main.py                 # Aplicación principal FastAPI
├── database.py             # Configuración de SQLAlchemy y conexión a PostgreSQL
├── models.py               # Modelos de SQLAlchemy (ORM) - 7 tablas
├── schemas.py              # Schemas de Pydantic (validación y serialización)
├── crud.py                 # Operaciones CRUD + funciones de estadísticas
├── requirements.txt        # Dependencias de Python
├── env.example             # Template de variables de entorno
├── README_API.md           # Esta documentación completa
└── routers/                # Endpoints organizados por entidad
    ├── clasificacion.py        # CRUD de clasificaciones
    ├── medio_recepcion.py      # CRUD de medios de recepción
    ├── alcaldia.py            # CRUD de alcaldías (NUEVO)
    ├── estado_incidente.py    # CRUD de estados de incidente (NUEVO)
    ├── colonia.py             # CRUD de colonias (refactorizado)
    ├── incidente.py           # CRUD + búsqueda geoespacial + actualización masiva
    ├── reporte.py             # CRUD de reportes
    └── estadisticas.py        # Dashboard y análisis avanzados (NUEVO)
```

### Descripción de Archivos Clave

| Archivo | Líneas | Propósito |
|---------|--------|-----------|
| `main.py` | ~180 | Configuración FastAPI, CORS, middleware, registro de routers |
| `models.py` | ~350 | Definición de 7 tablas con SQLAlchemy (Alcaldia, EstadoIncidente, Colonia, etc.) |
| `schemas.py` | ~450 | Schemas Pydantic para validación + schemas de estadísticas |
| `crud.py` | ~600 | CRUD básico + funciones avanzadas (dashboard, temporal, radio, masivo) |
| `routers/estadisticas.py` | ~200 | Endpoints de dashboard, análisis temporal, zonas críticas |
| `routers/incidente.py` | ~280 | CRUD + búsqueda por radio + actualización masiva |

---

## 🔒 Validaciones Automáticas

### Ubicación

- **Longitud**: Rango válido para CDMX (-99.4 a -98.9)
- **Latitud**: Rango válido para CDMX (19.0 a 19.6)

### Integridad Referencial

- **Clasificación**: No se puede eliminar si tiene incidentes asociados
- **Medio Recepción**: No se puede eliminar si tiene reportes asociados
- **Incidente**: Al eliminar, se eliminan reportes asociados (cascada)
- **Ubicación**: Al eliminar, incidentes quedan con ubicación NULL

### Unicidad

- **Folio de Incidente**: No se permiten duplicados
- **Código de Reporte**: No se permiten duplicados
- **Nombre de Clasificación**: Único
- **Nombre de Medio**: Único

---

## 🐛 Solución de Problemas

### Error: "Can't connect to PostgreSQL server"

**Causa:** La base de datos no está corriendo o credenciales incorrectas.

**Solución:**
1. Verificar que PostgreSQL está corriendo:
   ```bash
   # Windows (Services)
   services.msc  # Buscar "postgresql"
   
   # Linux
   sudo systemctl status postgresql
   ```
2. Revisar credenciales en `.env`:
   ```env
   DB_USER=postgres
   DB_PASSWORD=tu_password_correcto
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=reportes_agua_cdmx
   ```
3. Probar conexión manualmente:
   ```bash
   psql -U postgres -d reportes_agua_cdmx
   ```

### Error: "Table doesn't exist"

**Causa:** El schema 5NF no se ha ejecutado en PostgreSQL.

**Solución:**
```bash
# Ejecutar los scripts SQL en orden
psql -U postgres -d reportes_agua_cdmx -f 04_schema_5nf.sql
psql -U postgres -d reportes_agua_cdmx -f 05_migracion_a_5nf.sql
```

### Error: "ModuleNotFoundError: No module named 'fastapi'"

**Causa:** Dependencias no instaladas o entorno virtual no activado.

**Solución:**
```bash
# Activar entorno virtual
# Windows
.\venv_nuevo\Scripts\Activate.ps1

# Linux/Mac
source venv_nuevo/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### Error: "Cannot add foreign key constraint"

**Causa:** Intentando crear registro con FK inválido.

**Solución:**
Asegúrate de que el registro referenciado existe primero:
```python
# Primero crear la clasificación
clasificacion = requests.post(...).json()

# Luego usar su ID en el incidente
incidente = {
    "id_clasificacion": clasificacion["id_clasificacion"],
    ...
}
```

### Error: "422 Unprocessable Entity"

**Causa:** Datos de entrada no cumplen con el schema.

**Solución:**
Revisa la documentación en `/docs` para ver el schema exacto requerido.

---

## 🚀 Despliegue en Producción

### Usando Docker (Recomendado)

Crear `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Construir y ejecutar:

```bash
docker build -t api-agua-cdmx .
docker run -p 8000:8000 --env-file .env api-agua-cdmx
```

### Usando Gunicorn (Servidor de Producción)

```bash
pip install gunicorn
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

---

## 📊 Rendimiento

- **Concurrencia**: Uvicorn soporta async/await para alto rendimiento
- **Workers**: Usar múltiples workers para aprovechar múltiples cores
- **Pool de Conexiones**: SQLAlchemy maneja pool automáticamente
- **Caching**: Considerar Redis para endpoints frecuentes en producción

---

## 🤝 Contribución

Este proyecto fue desarrollado como parte del proyecto final de Bases de Datos.

**Equipo 5:**
- Carlos Emilio Elizalde Hurtado
- Emilio Juarez Avalos
- Juan Pablo Medina Esquivel

---

## 📝 Licencia

MIT License - Proyecto Educativo

---

## 📧 Soporte

Para preguntas o problemas, contacta al equipo de desarrollo.

**Fecha:** Diciembre 2025  
**Versión API:** 1.0.0  
**Framework:** FastAPI 0.104+  
**Base de Datos:** PostgreSQL 12+  
**Python:** 3.8+

---

## 📊 Resumen de Funcionalidades

### ✅ CRUD Completo (7 Entidades)
- Clasificaciones
- Medios de Recepción
- Alcaldías
- Estados de Incidente
- Colonias
- Incidentes
- Reportes

### 🆕 Funcionalidades Avanzadas
1. **Dashboard General** - Visión completa del sistema
2. **Estadísticas por Alcaldía** - Análisis zonal detallado
3. **Análisis Temporal** - Tendencias por día/semana/mes
4. **Búsqueda por Radio** - Incidentes en proximidad geográfica
5. **Actualización Masiva** - Cambio de estado de múltiples incidentes
6. **Zonas Críticas** - Ranking de colonias más afectadas

### 🎯 Casos de Uso Principales
- 📱 **Supervisión en Tiempo Real** - Dashboard para operadores
- 🗺️ **Planificación de Rutas** - Búsqueda geoespacial
- 📊 **Análisis de Tendencias** - Reportes temporales
- 🏙️ **Gestión Zonal** - Estadísticas por alcaldía
- ⚡ **Operaciones Batch** - Actualización masiva
- 🎯 **Priorización** - Identificar zonas críticas

---

## 🚀 Inicio Rápido (Quick Start)

```bash
# 1. Activar entorno virtual
cd api
.\venv_nuevo\Scripts\Activate.ps1  # Windows
# source venv_nuevo/bin/activate   # Linux/Mac

# 2. Instalar dependencias (si no están instaladas)
pip install -r requirements.txt

# 3. Configurar .env con credenciales PostgreSQL
copy env.example .env  # Editar con tus credenciales

# 4. Ejecutar servidor
python main.py

# 5. Abrir navegador
# http://localhost:8000/docs
```

### Primera Prueba
```bash
# Ver dashboard
curl http://localhost:8000/estadisticas/dashboard

# Ver zonas críticas
curl http://localhost:8000/estadisticas/zonas-criticas?limit=5
```

---

## 📝 Notas Finales

- ✅ Todos los endpoints NO tienen prefijo `/api/v1` (rutas simples)
- ✅ Base de datos: **PostgreSQL** (no MySQL)
- ✅ Puerto por defecto: **8000**
- ✅ Documentación interactiva: **/docs**
- ✅ Hot reload habilitado en modo desarrollo
- ✅ CORS habilitado para desarrollo (ajustar en producción)

### Próximos Pasos Sugeridos
1. ✅ Probar endpoints en `/docs`
2. ✅ Revisar dashboard con tus datos reales
3. ✅ Experimentar con búsqueda geoespacial
4. ✅ Crear scripts Python personalizados
5. ✅ Integrar con frontend (React, Vue, etc.)

