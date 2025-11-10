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