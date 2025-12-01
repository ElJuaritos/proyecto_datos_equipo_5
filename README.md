# Proyecto Final - Análisis de reportes de agua en Ciudad de México

**Estudiantes:**
- Carlos Emilio Elizalde Hurtado
- Emilio Juarez Avalos
- Juan Pablo Medina Esquivel

**Fecha de entrega:** 29 de septiembre del 2025

---

## A) Introducción al conjunto de datos y al problema a estudiar

### Descripción general de los datos

El dataset contiene reportes ciudadanos sobre problemas de agua potable y drenaje en la Ciudad de México durante el año 2022. Incluye información sobre fugas, falta de agua, drenajes obstruidos y su ubicación geográfica.

### ¿Quién los recolecta?

Los datos son recolectados por el Sistema de Aguas de la Ciudad de México (SACMEX) a través de su sistema de atención ciudadana.

### ¿Cuál es el propósito de su recolección?

Dar seguimiento a las solicitudes ciudadanas, mejorar los tiempos de respuesta, identificar zonas con problemas recurrentes y garantizar transparencia en la atención de reportes.

### ¿Dónde se pueden obtener?

Portal de Datos Abiertos de la Ciudad de México, sección de Medio Ambiente.

### ¿Con qué frecuencia se actualizan?

El dataset se actualiza periódicamente conforme se registran nuevos reportes.

### ¿Cuántas tuplas y cuántos atributos tiene el set de datos?

- **Tuplas (registros):** 313,756
- **Atributos (columnas):** 12

### ¿Qué significa cada atributo del set?

| Atributo | Significado |
|----------|-------------|
| folio_incidente | Identificador único del incidente |
| fecha_registro_incidente | Fecha de registro oficial del incidente |
| id_reporte | Identificador único del reporte |
| fecha_reporte | Fecha en que se realizó el reporte |
| hora_reporte | Hora en que se recibió el reporte |
| clasificacion | Tipo de problema (Agua Potable o Drenaje) |
| reporte | Descripción específica (Fuga, Falta de agua, etc.) |
| medio_recepcion | Canal de recepción (Call Center, Redes Sociales, etc.) |
| alcaldia_catalogo | Alcaldía donde ocurrió el problema |
| colonia_catalogo | Colonia donde se reportó |
| longitud | Coordenada geográfica (longitud) |
| latitud | Coordenada geográfica (latitud) |

### ¿Qué atributos son numéricos?

- longitud
- latitud

### ¿Qué atributos son categóricos?

- clasificacion
- reporte
- medio_recepcion
- alcaldia_catalogo

### ¿Qué atributos son de tipo texto?

- folio_incidente
- id_reporte
- colonia_catalogo

### ¿Qué atributos son de tipo temporal y/o fecha?

- fecha_registro_incidente
- fecha_reporte
- hora_reporte

### ¿Cuál es el objetivo buscado con el set de datos? ¿Para qué se usará por el equipo?

Analizar el comportamiento de los reportes de agua en la Ciudad de México para identificar patrones geográficos, zonas más afectadas, tipos de problemas más frecuentes y evaluar la calidad del servicio público de agua.

### ¿Qué consideraciones éticas conlleva el análisis y explotación de dichos datos?

**Privacidad ciudadana:** Las coordenadas geográficas pueden revelar ubicaciones de viviendas. No se deben usar para identificar o rastrear ciudadanos individuales.

**Evitar estigmatización territorial:** Alta incidencia de reportes no implica necesariamente negligencia; puede reflejar diferencias en densidad poblacional o antigüedad de infraestructura.

**Transparencia responsable:** Los datos deben usarse para mejorar el servicio público, no para difundir interpretaciones sesgadas.

**Calidad del dato:** Puede haber errores, duplicados o inconsistencias que deben documentarse durante la limpieza.

**Contexto socioeconómico:** Los hallazgos deben considerar factores estructurales como desigualdad en infraestructura y acceso diferenciado a canales de reporte.

---

## B) Carga inicial y análisis preliminar

### Carga inicial del set de datos a PostgreSQL

Se documentó en el repositorio cómo realizar la carga inicial del dataset a una base de datos PostgreSQL mediante el script `01_carga_inicial.sql`. Este script realiza las siguientes operaciones:

1. **Creación de la base de datos:** Se crea una base de datos llamada `reportes_agua_cdmx`.
2. **Creación del esquema:** Se crea un esquema `agua_cdmx` para organizar las tablas.
3. **Creación de la tabla:** Se define la tabla `reportes` con las 12 columnas del dataset, todas inicialmente como tipo TEXT para facilitar la carga.
4. **Carga del CSV:** Se utiliza el comando `\copy` de PostgreSQL para importar los 313,756 registros desde el archivo CSV.
5. **Verificación:** Se confirma que los datos se cargaron correctamente mediante consultas de conteo y visualización de registros.

### Análisis exploratorio de los datos

Se realizó un análisis exploratorio mediante consultas SQL documentadas en el script `02_analisis_exploratorio.sql`. Las consultas realizadas fueron:

**1. Valores únicos:** Se verificó la unicidad de los folios de incidente, encontrando que algunos incidentes tienen múltiples reportes asociados.

**2. Mínimos y máximos de fechas:** Se identificó el rango temporal del dataset, confirmando que los datos corresponden principalmente al año 2022.

**3. Mínimos, máximos y promedios de valores numéricos:** Se analizaron las coordenadas geográficas (longitud y latitud) para verificar que se encuentren dentro del rango esperado para la Ciudad de México.

**4. Duplicados en atributos categóricos:** Se detectaron folios de incidente repetidos, lo cual es esperado ya que un mismo incidente puede generar múltiples reportes.

**5. Columnas redundantes:** Se verificó que no existen columnas con valores constantes que pudieran eliminarse.

**6. Conteo de tuplas por cada categoría:** Se realizaron conteos por:
   - Alcaldía: Para identificar las zonas con más reportes
   - Clasificación: Para ver la distribución entre problemas de Agua Potable y Drenaje
   - Tipo de reporte: Para identificar los problemas más frecuentes (fugas, falta de agua, etc.)

**7. Conteo de valores nulos:** Se identificó que algunas columnas tienen valores 'NA' o vacíos, especialmente en alcaldía, colonia y coordenadas.

**8. Inconsistencias en el set de datos:** Se detectaron:
   - Fechas con formatos incorrectos
   - Coordenadas fuera del rango geográfico de la Ciudad de México
   - Registros sin información de ubicación

---

## C) Limpieza de datos

Se realizaron las siguientes actividades de limpieza documentadas en el script `03_limpieza_datos.sql`:

### Actividades realizadas

**1. Creación de respaldo:** Se creó una tabla `reportes_raw` con una copia completa de los datos originales antes de realizar cualquier modificación. Esto permite revertir cambios si es necesario.

**2. Eliminación de registros vacíos:** Se eliminaron las filas que no contenían información relevante (sin folio, sin id de reporte y sin fecha). Esta operación fue necesaria para asegurar la calidad del dataset.

**3. Limpieza y tipificación de fechas:** Se crearon nuevas columnas `fecha_reporte_clean` y `fecha_registro_clean` de tipo DATE. Se convirtieron las fechas del formato texto al formato fecha de PostgreSQL, validando que cumplieran con el formato YYYY-MM-DD. Esta operación facilita análisis temporales posteriores.

**4. Limpieza y tipificación de coordenadas:** Se crearon columnas `longitud_clean` y `latitud_clean` de tipo NUMERIC. Se convirtieron las coordenadas de texto a números, validando que fueran valores numéricos válidos. Esta operación es necesaria para realizar análisis geoespaciales.

**5. Normalización de valores categóricos:** Se reemplazaron los valores 'NA' por NULL en las columnas de alcaldía y colonia. Esto permite identificar correctamente los valores faltantes y facilita las consultas. Esta operación fue necesaria porque 'NA' como texto no es lo mismo que un valor nulo en SQL.

**6. Eliminación de duplicados exactos:** Se eliminaron registros que tenían el mismo folio de incidente y el mismo id de reporte, conservando solo una copia. Esta operación reduce redundancia en el dataset.

**7. Verificación de la limpieza:** Se realizaron consultas para confirmar:
   - El número total de registros después de la limpieza
   - La cantidad de valores nulos en columnas importantes
   - La calidad de las conversiones de tipo de dato

**8. Visualización de datos limpios:** Se consultaron algunos registros con las columnas limpias para verificar que las transformaciones se realizaron correctamente.

### Justificación de las operaciones

Todas las operaciones de limpieza fueron necesarias para preparar el dataset para análisis posteriores. Las conversiones de tipo de dato (fechas y coordenadas) permiten realizar cálculos y análisis que no serían posibles con datos en formato texto. La normalización de valores categóricos y la eliminación de duplicados mejoran la calidad y consistencia del dataset. El respaldo de los datos originales garantiza que siempre se puede volver al estado inicial si es necesario revisar o modificar el proceso de limpieza.

## D) Normalización de datos hasta 5NF 
   **Columnas originales:**
folio_incidente
fecha_registro_incidente
id_reporte
fecha_reporte
hora_reporte
clasificacion
reporte
medio_recepcion
alcaldia_catalogo
colonia_catalogo
longitud
latitud
   **Entidades intuitivas propuestas:**
INCIDENTE (información del fenómeno/avería)
REPORTE (cada entrada/llamada/registro que notifica un incidente)
UBICACION (datos geográficos/colonia/alcaldía)
CLASIFICACION (catálogo de tipos de incidentes)
MEDIO_RECEPCION (catálogo de canales de recepción)

   **Dependencias funcionales y multivaluadas (no triviales)**
         **Dependencias funcionales (DF)**
folio_incidente → fecha_registro_incidente
folio_incidente → clasificacion
folio_incidente → reporte
folio_incidente → colonia_catalogo
id_reporte → fecha_reporte
id_reporte → hora_reporte
id_reporte → medio_recepcion
colonia_catalogo → alcaldia_catalogo
colonia_catalogo → longitud, latitud
         **Dependencias multivaluadas (MVD)**
folio_incidente ↠ id_reporte : un mismo incidente puede generar múltiples reportes (múltiples llamadas/reports asociados al mismo folio).
         **Dependencias de Join (JD)**
Una dependencia de join existe cuando la información puede descomponerse en proyecciones más pequeñas que pueden reconstruirse mediante joins sin pérdida de información. En este caso:
- (INCIDENTE, CLASIFICACION) ⋈ (INCIDENTE, UBICACION) ⋈ (INCIDENTE, REPORTE) ⋈ (REPORTE, MEDIO_RECEPCION)
         **Comentarios sobre la naturaleza**
colonia_catalogo determina alcaldía y coordenadas: esto sugiere que UBICACION debe ser su propia entidad (evita transiciones y redundancia).
folio_incidente identifica un suceso con sus atributos (fecha, clasificación, descripción) y está relacionado con varios id_reporte.
clasificacion y medio_recepcion son catálogos que deben normalizarse para evitar redundancia y facilitar mantenimiento.

 **DISEÑO EN 5NF** 
 
 **Entidad INCIDENTE**
   columna
id_incidente (PK artificial)
folio_incidente (unique)
fecha_registro_incidente
reporte (descripción textual del incidente)
id_clasificacion FK
id_colonia FK

**Entidad REPORTE**
   columna
id_reporte (PK artificial)
id_incidente FK (referencia a INCIDENTE, no folio_incidente)
fecha_reporte
hora_reporte
id_medio_recepcion FK

**Entidad UBICACION**
   columna
id_colonia (PK artificial)
colonia_catalogo (unique)
alcaldia_catalogo
longitud
latitud

**Entidad CLASIFICACION**
   columna
id_clasificacion (PK artificial)
nombre_clasificacion (unique)
descripcion (opcional)

**Entidad MEDIO_RECEPCION**
   columna
id_medio_recepcion (PK artificial)
nombre_medio (unique)
descripcion (opcional)

**Normalización paso a paso hasta 5NF (justificaciones)**

**1NF** - Todas las columnas son atómicas (texto/tiempo/fecha). 1NF satisfecha.

**2NF** - No existe llave compuesta en la tabla original (se trata cada fila como registro), por tanto 2NF trivialmente satisfecha.

**3NF** - Detectamos dependencias transitivas: folio_incidente → colonia_catalogo y colonia_catalogo → alcaldia_catalogo, longitud, latitud. Para eliminar la transitividad creamos la entidad UBICACION con colonia_catalogo como atributo clave (o id_colonia PK artificial).

Proyección a 3NF: 
INCIDENTE(folio_incidente, fecha_registro_incidente, clasificacion, reporte, id_colonia)
UBICACION(id_colonia, colonia_catalogo, alcaldia_catalogo, longitud, latitud)

**4NF** - La presencia de folio_incidente ↠ id_reporte (MVD) implica que la tabla original almacena dos grupos de atributos independientes: atributos del INCIDENTE y atributos del REPORTE. Para eliminar la MVD separamos en tablas INCIDENTE y REPORTE.

**5NF** - Identificamos dependencias de join adicionales donde los catálogos (clasificacion, medio_recepcion) pueden descomponerse en entidades independientes:
1. **CLASIFICACION**: Los valores de clasificación se repiten en múltiples incidentes. Al extraer a una tabla separada eliminamos redundancia y permitimos mantener un catálogo centralizado con posibles atributos adicionales (descripción, prioridad, etc.).
2. **MEDIO_RECEPCION**: Los medios de recepción se repiten en múltiples reportes. La separación permite gestionar el catálogo de canales independientemente.
3. **Relación INCIDENTE-FK**: Cambiamos la FK de REPORTE de folio_incidente a id_incidente para mantener integridad referencial con claves artificiales.

**Justificación 5NF:** 
- Cada tabla representa un único concepto/entidad.
- No existen dependencias de join no triviales que permitan mayor descomposición sin pérdida de información.
- Los catálogos están normalizados, facilitando mantenimiento y consistencia.
- Las proyecciones pueden reconstruir la información original mediante joins naturales.
- Se eliminan anomalías de actualización (cambiar un nombre de clasificación solo requiere un UPDATE en CLASIFICACION).
- Se preserva la integridad referencial mediante claves foráneas apropiadas.

<img width="1536" height="1024" alt="imgerdbdagua" src="https://github.com/user-attachments/assets/64869bb6-743c-4439-8b5f-fd8b3d20a94a" />

📋 **Para ver el diagrama ER detallado con cardinalidades, dependencias funcionales y ejemplos, consultar:** [`diagrama_er_5nf.md`](diagrama_er_5nf.md)

---

## E) Análisis de datos a través de consultas SQL y creación de atributos analíticos

### Descripción

Utilizando los datos normalizados en 5NF, se crearon consultas SQL avanzadas que emplean **funciones de ventana** (window functions) para generar atributos analíticos enriquecidos. Estos atributos permiten análisis más profundos y toma de decisiones basada en datos.

### Archivo: `07_analisis_avanzado.sql`

Este script contiene **10 consultas analíticas** que atacan directamente el objetivo del proyecto:

#### 1. **Ranking de Colonias Más Afectadas**
- Utiliza `RANK()` y `PARTITION BY` para clasificar colonias por alcaldía
- Atributos creados: `ranking_en_alcaldia`, `ranking_general`, `porcentaje_en_alcaldia`

#### 2. **Tendencia Temporal con Comparaciones**
- Usa `LAG()` para comparar con mes anterior
- Atributos: `reportes_mes_anterior`, `variacion_porcentual`, `media_movil_3meses`

#### 3. **Tiempo de Atención a Reportes**
- Calcula diferencia entre reporte e incidente
- Atributos: `dias_diferencia`, `ranking_rapidez`, `percentil`, `cuartil`

#### 4. **Frecuencia y Criticidad por Colonia**
- Score compuesto multi-dimensional
- Atributos: `categoria_frecuencia`, `score_criticidad`, `promedio_reportes_por_incidente`

#### 5. **Patrones Horarios por Día**
- Análisis de demanda temporal
- Atributos: `categoria_horario`, `porcentaje_del_dia`, `ranking_hora_dia`

#### 6. **Incidentes Recurrentes**
- Identifica problemas sistemáticos
- Atributos: `nivel_reincidencia`, `veces_reportado`, `dias_entre_primero_ultimo`

#### 7. **Clustering Geográfico**
- Agrupa por coordenadas
- Atributos: `densidad_incidentes`, `categoria_zona`, `decil_incidentes`

#### 8. **Eficiencia por Canal**
- Evalúa medios de recepción
- Atributos: `categoria_velocidad`, `dias_promedio_registro`, `ranking_rapidez`

#### 9. **Scorecard Comparativo de Alcaldías**
- Métrica compuesta de priorización
- Atributos: `score_prioridad`, `quintil_gravedad`, múltiples rankings

#### 10. **Estacionalidad Trimestral**
- Patrones anuales con `LAG()`
- Atributos: `variacion_porcentual`, `media_movil_4_trimestres`

### Resultados e Interpretación: `ANALISIS_RESULTADOS.md`

Documento completo con:
- 📊 **Tablas de resultados** para cada consulta
- 📈 **Gráficas conceptuales** de tendencias
- 🔍 **Interpretación detallada** de cada hallazgo
- 💡 **Recomendaciones estratégicas** basadas en datos
- 🎯 **Conclusiones** respecto al objetivo del proyecto

#### Hallazgos Principales

1. **Concentración Geográfica**: 40% de incidentes en 15% de colonias (zona oriente)
2. **Estacionalidad**: Q2 (Abr-Jun) requiere 50% más recursos que Q1
3. **Reincidencia**: Top 100 ubicaciones representan 60% del trabajo reactivo
4. **Brecha Digital**: Solo 2% de reportes vía digital, perdiendo eficiencia
5. **Tiempo de Respuesta**: 50% atendidos en ≤2 días, pero 25% en >5 días

📊 **Para ver resultados completos con interpretación:** [`ANALISIS_RESULTADOS.md`](ANALISIS_RESULTADOS.md)

---

## F) Creación de APIs con FastAPI

### Descripción

Se implementó una **API RESTful completa** usando FastAPI con operaciones CRUD para todas las tablas normalizadas del schema 5NF.

### Estructura de la API

```
api/
├── main.py                 # Aplicación principal FastAPI
├── database.py             # Configuración SQLAlchemy y conexión MySQL
├── models.py               # Modelos ORM (SQLAlchemy)
├── schemas.py              # Schemas Pydantic (validación)
├── crud.py                 # Operaciones CRUD reutilizables
├── requirements.txt        # Dependencias del proyecto
├── env.example             # Template de configuración
├── README_API.md           # Documentación completa de la API
└── routers/                # Endpoints organizados por entidad
    ├── clasificacion.py    # CRUD Clasificación
    ├── medio_recepcion.py  # CRUD Medio Recepción
    ├── ubicacion.py        # CRUD Ubicación
    ├── incidente.py        # CRUD Incidente
    └── reporte.py          # CRUD Reporte
```

### Características Implementadas

✅ **Operaciones CRUD Completas** para las 5 tablas:
- `POST` - Crear registros
- `GET` - Leer (individual y listado)
- `PUT` - Actualizar registros
- `DELETE` - Eliminar registros

✅ **Validaciones Automáticas** con Pydantic:
- Validación de tipos de datos
- Rangos de coordenadas para CDMX
- Unicidad de folios y códigos
- Integridad referencial

✅ **Filtros y Paginación**:
- Filtrar por alcaldía en ubicaciones
- Filtrar por clasificación/estado en incidentes
- Paginación con `skip` y `limit`

✅ **Documentación Interactiva**:
- Swagger UI en `/docs`
- ReDoc en `/redoc`
- Schema OpenAPI 3.0

✅ **Características Avanzadas**:
- CORS habilitado
- Middleware de logging
- Health checks
- Manejo global de errores

### Configuración del Ambiente

#### 1. Instalar dependencias:

```bash
cd api
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

#### 2. Configurar base de datos:

Copiar `env.example` a `.env` y editar:

```env
DB_USER=root
DB_PASSWORD=tu_password
DB_HOST=localhost
DB_PORT=3306
DB_NAME=reportes_agua_cdmx
```

#### 3. Ejecutar el servicio:

```bash
python main.py
```

O usando uvicorn:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Endpoints Disponibles

Todos los endpoints están bajo el prefijo `/api/v1`:

| Entidad | Endpoint Base | Operaciones |
|---------|---------------|-------------|
| Clasificaciones | `/api/v1/clasificaciones/` | POST, GET, GET/{id}, PUT/{id}, DELETE/{id} |
| Medios Recepción | `/api/v1/medios-recepcion/` | POST, GET, GET/{id}, PUT/{id}, DELETE/{id} |
| Ubicaciones | `/api/v1/ubicaciones/` | POST, GET, GET/{id}, PUT/{id}, DELETE/{id} |
| Incidentes | `/api/v1/incidentes/` | POST, GET, GET/{id}, GET/folio/{folio}, PUT/{id}, DELETE/{id} |
| Reportes | `/api/v1/reportes/` | POST, GET, GET/{id}, GET/codigo/{codigo}, PUT/{id}, DELETE/{id} |

### Ejemplos de Uso

#### Crear un Incidente:

```bash
curl -X POST "http://localhost:8000/api/v1/incidentes/" \
  -H "Content-Type: application/json" \
  -d '{
    "folio_incidente": "I-20221201-9999",
    "fecha_registro_incidente": "2022-12-01",
    "reporte": "Fuga de agua en calle principal",
    "id_clasificacion": 1,
    "id_colonia": 5,
    "estado": "Registrado"
  }'
```

#### Listar Incidentes con Filtros:

```bash
curl "http://localhost:8000/api/v1/incidentes/?clasificacion_id=1&skip=0&limit=10"
```

#### Obtener Incidente por Folio:

```bash
curl "http://localhost:8000/api/v1/incidentes/folio/I-20221201-9999"
```

### Interacción desde Python:

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"

# Crear ubicación
nueva_ubicacion = {
    "colonia_catalogo": "Roma Norte",
    "alcaldia_catalogo": "Cuauhtémoc",
    "longitud": -99.1627,
    "latitud": 19.4186,
    "activo": True
}

response = requests.post(f"{BASE_URL}/ubicaciones/", json=nueva_ubicacion)
print(response.json())
```

### Documentación Completa

📖 **Para documentación detallada, ejemplos completos y troubleshooting:** [`api/README_API.md`](api/README_API.md)

### Swagger UI

Una vez iniciado el servicio, acceder a:
- **Documentación Interactiva**: http://localhost:8000/docs
- **Documentación ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

---

## G) Archivos SQL del Proyecto

El proyecto incluye los siguientes archivos SQL organizados para facilitar la implementación y uso del sistema normalizado:

### Archivos Principales

#### 📄 `01_carga_inicial.sql`
Script inicial para la carga de datos desde el archivo CSV original.

#### 📄 `02_analisis_exploratorio.sql`
Consultas SQL para análisis exploratorio de datos, estadísticas descriptivas y detección de patrones en los reportes de agua.

#### 📄 `03_limpieza_datos.sql`
Procesos de limpieza y transformación de datos: eliminación de duplicados, normalización de valores, corrección de inconsistencias.

#### 📄 `04_schema_5nf.sql` ⭐
Schema de base de datos normalizado hasta 5NF con las 5 tablas, claves foráneas, índices y constraints.

#### 📄 `05_migracion_a_5nf.sql` ⭐
Script de migración y carga de datos desde CSV a las tablas normalizadas con limpieza automática.

#### 📄 `06_consultas_ejemplo_5nf.sql` ⭐
Consultas SQL de ejemplo para análisis básicos, estadísticos, temporales y de calidad de datos.

#### 📄 `07_analisis_avanzado.sql` ⭐ **NUEVO**
Consultas avanzadas con funciones de ventana para crear atributos analíticos enriquecidos.

### 🚀 Orden de Ejecución Recomendado

```bash
# 1. Crear el schema normalizado
mysql -u usuario -p nombre_bd < 04_schema_5nf.sql

# 2. Ejecutar la migración de datos
mysql -u usuario -p nombre_bd < 05_migracion_a_5nf.sql

# 3. Ejecutar análisis avanzado
mysql -u usuario -p nombre_bd < 07_analisis_avanzado.sql
```

📖 **Para instrucciones detalladas:** [`GUIA_IMPLEMENTACION.md`](GUIA_IMPLEMENTACION.md)


