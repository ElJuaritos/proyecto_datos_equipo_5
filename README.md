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

<img width="2283" height="2503" alt="Untitled diagram-2025-12-01-170852" src="https://github.com/user-attachments/assets/4a27c515-fa49-4019-8c4f-6a6ce5a7bb0e" />

📋 **Para ver el diagrama ER detallado con cardinalidades, dependencias funcionales y ejemplos, consultar:** [`diagrama_er_5nf.md`](diagrama_er_5nf.md)

---

## E) Archivos SQL del Proyecto

El proyecto incluye los siguientes archivos SQL organizados para facilitar la implementación y uso del sistema normalizado:

### Archivos Principales

#### 📄 `01_carga_inicial.sql`
Script inicial para la carga de datos desde el archivo CSV original.

#### 📄 `02_analisis_exploratorio.sql`
Consultas SQL para análisis exploratorio de datos, estadísticas descriptivas y detección de patrones en los reportes de agua.

#### 📄 `03_limpieza_datos.sql`
Procesos de limpieza y transformación de datos: eliminación de duplicados, normalización de valores, corrección de inconsistencias.

#### 📄 `04_schema_5nf.sql` ⭐
**Schema de base de datos normalizado hasta 5NF**

Define la estructura completa de las 5 tablas normalizadas:
- **CLASIFICACION**: Catálogo de tipos de incidentes
- **MEDIO_RECEPCION**: Catálogo de canales de recepción
- **UBICACION**: Datos geográficos (colonias, alcaldías, coordenadas)
- **INCIDENTE**: Entidad principal de eventos reportados
- **REPORTE**: Registros individuales de notificaciones

Incluye:
- Claves primarias y foráneas
- Índices optimizados para consultas frecuentes
- Constraints de integridad referencial
- Comentarios detallados sobre el diseño

#### 📄 `05_migracion_a_5nf.sql` ⭐
**Script de migración y carga de datos a 5NF**

Transforma los datos del CSV original a las tablas normalizadas mediante:
1. Creación de tabla temporal para carga del CSV
2. Extracción y carga de catálogos (CLASIFICACION, MEDIO_RECEPCION)
3. Normalización de ubicaciones con validación de coordenadas
4. Carga de incidentes con relaciones FK apropiadas
5. Carga de reportes con integridad referencial
6. Estadísticas y validación de la migración

Características:
- Limpieza automática de datos (valores NA, espacios, validaciones)
- Manejo de duplicados con ON DUPLICATE KEY UPDATE
- Conversión de formatos de fecha y hora
- Reportes de calidad de datos y verificación de integridad

#### 📄 `06_consultas_ejemplo_5nf.sql` ⭐
**Consultas de ejemplo y análisis**

Colección de consultas SQL organizadas por categoría:

**Consultas Básicas:**
- Listar incidentes y reportes con información completa

**Análisis Estadísticos:**
- Distribución por clasificación, medio de recepción, ubicación
- Top colonias y alcaldías con más incidentes

**Análisis Temporales:**
- Incidentes por mes, día de la semana, hora del día
- Análisis de tiempos de respuesta

**Consultas Avanzadas:**
- Incidentes con múltiples reportes
- Matriz clasificación vs alcaldía
- Análisis geoespaciales y clustering

**Calidad de Datos:**
- Validación de integridad
- Detección de registros incompletos

**Vistas Útiles:**
- `v_incidentes_completos`
- `v_reportes_completos`

### 🚀 Orden de Ejecución Recomendado

Para implementar el sistema completo desde cero:

```bash
# 1. Crear el schema normalizado
mysql -u usuario -p nombre_bd < 04_schema_5nf.sql

# 2. Ejecutar la migración de datos
mysql -u usuario -p nombre_bd < 05_migracion_a_5nf.sql

# 3. Probar consultas de ejemplo
mysql -u usuario -p nombre_bd < 06_consultas_ejemplo_5nf.sql
```

📖 **Para instrucciones detalladas paso a paso, incluyendo solución de problemas y métodos alternativos de carga, consultar:** [`GUIA_IMPLEMENTACION.md`](GUIA_IMPLEMENTACION.md)

### 📊 Beneficios del Diseño en 5NF

1. **Eliminación de redundancia**: Los catálogos se mantienen una sola vez
2. **Integridad referencial**: Las FK garantizan consistencia de datos
3. **Mantenimiento simplificado**: Actualizar un catálogo afecta automáticamente todas las referencias
4. **Escalabilidad**: Fácil agregar nuevos catálogos o atributos
5. **Performance optimizado**: Índices estratégicos en joins frecuentes
6. **Sin anomalías**: No hay problemas de inserción, actualización o eliminación

### 🔍 Verificación del Diseño

El diseño puede verificarse reconstruyendo la tabla original mediante un JOIN completo de las 5 tablas, demostrando que la descomposición es **sin pérdida de información** (lossless decomposition), requisito fundamental de la normalización hasta 5NF.


