# Proyecto Final - Análisis de reportes de agua en Ciudad de México

**Estudiantes:**
- Carlos Emilio Elizalde Hurtado
- Emilio Juarez Avalos
- Juan Pablo Medina Esquivel

**Fecha de entrega:** 20 de diciembre del 2025

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

###  Mejoras implementadas en la normalización:
1. **Nueva tabla ALCALDIA**: Elimina dependencia transitiva colonia→alcaldía
2. **Nueva tabla ESTADO_INCIDENTE**: Valida estados con catálogo cerrado
3. **COLONIA refactorizada**: Ahora con FK a ALCALDIA (antes UBICACION)
4. **INCIDENTE mejorado**: Coordenadas específicas del incidente + FK a estado
5. **Verdadera 5NF alcanzada**: Todas las dependencias transitivas eliminadas

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

   **Entidades normalizadas (7 tablas):**
1. CLASIFICACION (catálogo de tipos de incidentes)
2. MEDIO_RECEPCION (catálogo de canales de recepción)
3. ALCALDIA (catálogo de alcaldías) **← NUEVO**
4. ESTADO_INCIDENTE (catálogo de estados) **← NUEVO**
5. COLONIA (datos geográficos con FK a alcaldía) **← REFACTORIZADA**
6. INCIDENTE (información del fenómeno/avería) **← MEJORADA**
7. REPORTE (cada entrada/llamada/registro que notifica un incidente)

   **Dependencias funcionales y multivaluadas (no triviales)**
         **Dependencias funcionales (DF)**
folio_incidente → fecha_registro_incidente
folio_incidente → clasificacion
folio_incidente → reporte
folio_incidente → colonia_catalogo
folio_incidente → estado
id_reporte → fecha_reporte
id_reporte → hora_reporte
id_reporte → medio_recepcion
colonia_catalogo → alcaldia_catalogo   **← DEPENDENCIA TRANSITIVA (eliminada en 5NF mejorado)**
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

 **DISEÑO EN 5NF MEJORADO (7 TABLAS)** 

 **1. Entidad CLASIFICACION**
   columnas:
id_clasificacion (PK)
nombre_clasificacion (unique)
descripcion (opcional)
activo
fecha_creacion

**2. Entidad MEDIO_RECEPCION**
   columnas:
id_medio_recepcion (PK)
nombre_medio (unique)
descripcion (opcional)
activo
fecha_creacion

**3. Entidad ALCALDIA** ←
   columnas:
id_alcaldia (PK)
nombre_alcaldia (unique)
codigo_alcaldia (opcional)
activo
fecha_creacion

**4. Entidad ESTADO_INCIDENTE** ← 
   columnas:
id_estado (PK)
nombre_estado (unique)
descripcion (opcional)
orden (para ordenar estados)
activo
fecha_creacion

**5. Entidad COLONIA** (antes UBICACION) ←
   columnas:
id_colonia (PK)
nombre_colonia
id_alcaldia (FK → alcaldia) 
codigo_postal (opcional)
centroide_longitud ← **Centro de la colonia**
centroide_latitud ← **Centro de la colonia**
activo
fecha_creacion

**6. Entidad INCIDENTE** 
   columnas:
id_incidente (PK)
folio_incidente (unique)
fecha_registro_incidente
reporte (descripción textual)
id_clasificacion (FK → clasificacion)
id_colonia (FK → colonia)
id_estado (FK → estado_incidente) ← **FK validada**
longitud_incidente ← **Punto exacto del incidente**
latitud_incidente ← **Punto exacto del incidente**
fecha_creacion
fecha_actualizacion

**7. Entidad REPORTE**
   columnas:
id_reporte_pk (PK)
id_reporte (unique)
id_incidente (FK → incidente)
fecha_reporte
hora_reporte
id_medio_recepcion (FK → medio_recepcion)
fecha_creacion

**Normalización paso a paso hasta 5NF (justificaciones)**

**1NF** - Todas las columnas son atómicas (texto/tiempo/fecha). 1NF satisfecha.

**2NF** - No existe llave compuesta en la tabla original (se trata cada fila como registro), por tanto 2NF trivialmente satisfecha.

**3NF VERDADERA** - En la versión anterior existía una **dependencia transitiva** no eliminada:
- colonia_catalogo → alcaldia_catalogo (la colonia determina la alcaldía)
- Esto violaba 3NF porque alcaldia_catalogo no dependía directamente de la clave primaria

**MEJORA APLICADA**: Creamos la tabla **ALCALDIA** independiente y cambiamos alcaldia_catalogo por id_alcaldia (FK) en COLONIA.

Proyección a 3NF mejorada: 
INCIDENTE(folio_incidente, fecha_registro_incidente, clasificacion, reporte, id_colonia, id_estado)
COLONIA(id_colonia, nombre_colonia, id_alcaldia, centroide_longitud, centroide_latitud)
ALCALDIA(id_alcaldia, nombre_alcaldia)

**4NF** - La presencia de folio_incidente ↠ id_reporte (MVD) implica que la tabla original almacena dos grupos de atributos independientes: atributos del INCIDENTE y atributos del REPORTE. Para eliminar la MVD separamos en tablas INCIDENTE y REPORTE.

**5NF ** - Identificamos todas las dependencias de join y dominios finitos que deben ser catálogos:

1. **CLASIFICACION**: Los valores de clasificación se repiten. Catálogo centralizado con atributos adicionales.

2. **MEDIO_RECEPCION**: Los medios de recepción se repiten. Catálogo independiente.

3. **ALCALDIA** ← **NUEVO**: Elimina redundancia. "Benito Juárez" se almacena 1 vez, no N veces por cada colonia.

4. **ESTADO_INCIDENTE** ← **NUEVO**: Los estados ("Registrado", "En Atención", etc.) eran VARCHAR sin validación. Ahora son catálogo validado con FK.

5. **Coordenadas específicas**: Diferenciamos centroide de colonia vs punto exacto del incidente (mejor granularidad geoespacial).

**Justificación 5NF MEJORADA:** 
-  **Cada tabla representa un único concepto**
-  **CERO dependencias transitivas** (colonia→alcaldía ahora es FK)
-  **Todos los dominios finitos son catálogos validados**
-  **No existen proyecciones adicionales** sin pérdida de información
-  **Los catálogos facilitan mantenimiento** (actualizar alcaldía = 1 UPDATE)
-  **Integridad referencial total** (todas las relaciones con FKs)
-  **Sin anomalías** de inserción, actualización o eliminación
-  **Granularidad geoespacial mejorada** (centroide + punto exacto)

<img width="2283" height="2503" alt="Untitled diagram-2025-12-01-170852" src="https://github.com/user-attachments/assets/4a27c515-fa49-4019-8c4f-6a6ce5a7bb0e" />

**Para ver el diagrama ER detallado con cardinalidades, dependencias funcionales y ejemplos, consultar:** [`diagrama_er_5nf.md`](diagrama_er_5nf.md)

---

## E) Archivos SQL del Proyecto

El proyecto incluye los siguientes archivos SQL organizados para facilitar la implementación y uso del sistema normalizado:

### Archivos Principales

####  `01_carga_inicial.sql`
Script inicial para la carga de datos desde el archivo CSV original.

####  `02_analisis_exploratorio.sql`
Consultas SQL para análisis exploratorio de datos, estadísticas descriptivas y detección de patrones en los reportes de agua.

####  `03_limpieza_datos.sql`
Procesos de limpieza y transformación de datos: eliminación de duplicados, normalización de valores, corrección de inconsistencias.

####  `04_schema_5nf.sql` 
**Schema de base de datos normalizado hasta 5NF MEJORADO**

Define la estructura completa de las **7 tablas normalizadas**:
1. **CLASIFICACION**: Catálogo de tipos de incidentes
2. **MEDIO_RECEPCION**: Catálogo de canales de recepción
3. **ALCALDIA**: Catálogo de alcaldías de la CDMX **← NUEVO**
4. **ESTADO_INCIDENTE**: Catálogo de estados validados **← NUEVO**
5. **COLONIA**: Datos geográficos con FK a alcaldía **← REFACTORIZADA**
6. **INCIDENTE**: Entidad principal con coordenadas exactas **← MEJORADA**
7. **REPORTE**: Registros individuales de notificaciones

Incluye:
- Claves primarias y foráneas (TODAS las relaciones validadas)
- Índices optimizados para consultas frecuentes
- Constraints de integridad referencial completa
- Triggers para actualización automática de timestamps
- Estados predefinidos poblados automáticamente
- Comentarios detallados sobre el diseño mejorado

####  `05_migracion_a_5nf.sql` 
**Script de migración y carga de datos a 5NF MEJORADO**

Transforma los datos del CSV original a las **7 tablas normalizadas** mediante:
1. Verificación de datos limpios en tabla `reportes`
2. Extracción y carga de catálogos independientes:
   - CLASIFICACION (tipos de incidentes)
   - MEDIO_RECEPCION (canales de recepción)
   - **ALCALDIA (16 alcaldías de CDMX)** ← NUEVO
3. Verificación de estados predefinidos (ESTADO_INCIDENTE)
4. Normalización de COLONIA con FK a alcaldía
5. Carga de INCIDENTE con coordenadas exactas y FK a estado
6. Carga de REPORTE con integridad referencial completa
7. Estadísticas detalladas y validación exhaustiva

Características MEJORADAS:
- Migración sin redundancia (alcaldías almacenadas 1 vez)
- Todos los estados inicializados a "Registrado" (id_estado=1)
- Diferenciación de centroide de colonia vs punto de incidente
- Validación de todas las FKs (cero registros huérfanos)
- Reportes estadísticos por dimensión (alcaldía, estado, etc.)
- Manejo robusto de duplicados con ON CONFLICT

####  `06_consultas_ejemplo_5nf.sql` 
**Consultas de ejemplo y análisis MEJORADAS**

Colección de consultas SQL organizadas por categoría:

**Consultas Básicas:**
- Listar todas las entidades con sus relaciones
- Ver incidentes y reportes con información completa

**Análisis Estadísticos:**
- Distribución por clasificación, medio de recepción, alcaldía
- **Análisis por estado de incidente** ← NUEVO
- Top colonias con más incidentes
- **Top alcaldías con más incidentes** ← MEJORADO (sin duplicados por variaciones)
- Incidentes por tipo de problema predominante por alcaldía

**Análisis Temporales:**
- Incidentes por mes, día de la semana, hora del día
- Evolución de estados a través del tiempo

**Consultas Avanzadas:**
- Incidentes con múltiples reportes
- Matriz clasificación vs alcaldía (sin redundancia)
- **Análisis geoespaciales mejorados** (centroide vs punto exacto) ← NUEVO
- **Porcentaje de incidentes geolocalizados por alcaldía** ← NUEVO

**Calidad de Datos:**
- Validación de todas las FKs
- Detección de registros incompletos
- **Verificación de integridad referencial completa** ← MEJORADO

**Vistas Útiles:**
- `v_incidentes_completos` (ahora incluye estado y alcaldía)
- `v_reportes_completos` (información completa con todas las relaciones)
- `v_estadisticas_alcaldia` (agregaciones por alcaldía) ← NUEVA

###  Orden de Ejecución Recomendado

Para implementar el sistema completo desde cero:

```bash
# 1. Crear el schema normalizado (7 tablas)
psql -U usuario -d reportes_agua_cdmx -f 04_schema_5nf.sql

# 2. Ejecutar la migración de datos
psql -U usuario -d reportes_agua_cdmx -f 05_migracion_a_5nf.sql

# 3. Probar consultas de ejemplo
psql -U usuario -d reportes_agua_cdmx -f 06_consultas_ejemplo_5nf.sql
```

📖 **Para instrucciones detalladas paso a paso, incluyendo solución de problemas y métodos alternativos de carga, consultar:** [`GUIA_IMPLEMENTACION.md`](GUIA_IMPLEMENTACION.md)

###  Beneficios del Diseño en 5NF MEJORADO

1. **Eliminación TOTAL de redundancia**: 
   - Alcaldías almacenadas 1 vez (no N veces)
   - Estados validados centralmente
   - Cero duplicación de nombres de catálogos

2. **Integridad referencial COMPLETA**: 
   - Todas las relaciones con FK validadas
   - Estados validados (no más typos en VARCHAR)
   - Alcaldías centralizadas (cambios en cascada)

3. **Mantenimiento simplificado**: 
   - Actualizar alcaldía = 1 UPDATE (no N)
   - Agregar nuevo estado = 1 INSERT
   - Deshabilitar catálogos sin eliminar datos

4. **Granularidad geoespacial mejorada**:
   - Centroide de colonia (área general)
   - Coordenadas exactas de incidente (punto específico)
   - Permite análisis geoespaciales precisos

5. **Escalabilidad**: 
   - Fácil agregar atributos a alcaldías (población, área, etc.)
   - Nuevos estados sin cambiar código
   - Extensible para futuras necesidades

6. **Performance optimizado**: 
   - Índices en todas las FKs
   - JOINs por INTEGER más rápidos que VARCHAR
   - Menor uso de almacenamiento (sin redundancia)

7. **Sin anomalías**: 
   - No hay problemas de inserción
   - No hay problemas de actualización
   - No hay problemas de eliminación
   - **VERDADERA 5NF** alcanzada

###  Verificación del Diseño

El diseño puede verificarse reconstruyendo la tabla original mediante un JOIN completo de las **7 tablas**, demostrando que la descomposición es **sin pérdida de información** (lossless decomposition), requisito fundamental de la normalización hasta 5NF.

Además, se puede verificar que:
-  No existen dependencias transitivas (colonia→alcaldía ahora es FK)
-  Todos los dominios finitos son catálogos validados
-  No hay repetición de valores en ninguna tabla
-  Todas las relaciones están formalizadas con FKs


