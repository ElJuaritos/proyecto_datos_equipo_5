# Diagrama Entidad-Relación (ER) - Base de Datos en 5NF MEJORADO
## Sistema de Reportes de Agua - CDMX

---

## 🔄 Cambios en la Nueva Versión

### Mejoras Implementadas:
1. **Nueva tabla ALCALDIA**: Elimina dependencia transitiva colonia→alcaldía
2. **Nueva tabla ESTADO_INCIDENTE**: Valida estados con catálogo cerrado
3. **COLONIA refactorizada**: Ahora con FK a ALCALDIA
4. **INCIDENTE mejorado**: Coordenadas específicas del incidente
5. **Verdadera 5NF**: Todas las dependencias transitivas eliminadas

---

## Diagrama Textual de Entidades

```
┌─────────────────────────────────┐
│       CLASIFICACION             │
│  (Catálogo de tipos)            │
├─────────────────────────────────┤
│ PK │ id_clasificacion   INT     │
│    │ nombre_clasificacion VARCHAR│
│    │ descripcion         VARCHAR│
│    │ activo              BOOLEAN│
│    │ fecha_creacion      TIMESTAMP│
└─────────────────────────────────┘
                │
                │ 1
                │
                │ N
┌───────────────▼─────────────────┐        ┌─────────────────────────────────┐
│          INCIDENTE              │        │         ALCALDIA                │
│  (Evento principal)             │        │  (Catálogo de alcaldías) [NUEVO]│
├─────────────────────────────────┤        ├─────────────────────────────────┤
│ PK │ id_incidente         INT   │        │ PK │ id_alcaldia         INT   │
│    │ folio_incidente      VARCHAR│        │    │ nombre_alcaldia     VARCHAR│
│    │ fecha_registro_inc.  DATE  │        │    │ codigo_alcaldia     VARCHAR│
│    │ reporte              VARCHAR│        │    │ activo              BOOLEAN│
│ FK │ id_clasificacion     INT   │        │    │ fecha_creacion      TIMESTAMP│
│ FK │ id_colonia           INT   │◄────┐  └──────────┬──────────────────────┘
│ FK │ id_estado            INT   │     │             │ 1
│    │ longitud_incidente   DECIMAL│     │             │
│    │ latitud_incidente    DECIMAL│     │             │ N
│    │ fecha_creacion       TIMESTAMP    │  ┌──────────▼──────────────────────┐
│    │ fecha_actualizacion  TIMESTAMP    │  │         COLONIA                 │
└──────────┬──────────────────────┘     └──┤  (Datos geográficos) [REFACTOR.]│
           │                                ├─────────────────────────────────┤
           │ 1                              │ PK │ id_colonia          INT   │
           │                                │    │ nombre_colonia      VARCHAR│
           │ N                              │ FK │ id_alcaldia         INT   │
           │                                │    │ codigo_postal       VARCHAR│
┌──────────▼──────────────────────┐        │    │ centroide_longitud  DECIMAL│
│           REPORTE               │        │    │ centroide_latitud   DECIMAL│
│  (Notificaciones individuales)  │        │    │ activo              BOOLEAN│
├─────────────────────────────────┤        │    │ fecha_creacion      TIMESTAMP│
│ PK │ id_reporte_pk        INT   │        └─────────────────────────────────┘
│    │ id_reporte           VARCHAR│
│ FK │ id_incidente         INT   │        ┌─────────────────────────────────┐
│    │ fecha_reporte        DATE  │        │      MEDIO_RECEPCION            │
│    │ hora_reporte         TIME  │        │  (Catálogo de canales)          │
│ FK │ id_medio_recepcion   INT   │◄───N:1─┤─────────────────────────────────┤
│    │ fecha_creacion       TIMESTAMP      │ PK │ id_medio_recepcion  INT   │
└─────────────────────────────────┘        │    │ nombre_medio        VARCHAR│
                                            │    │ descripcion         VARCHAR│
┌─────────────────────────────────┐        │    │ activo              BOOLEAN│
│      ESTADO_INCIDENTE [NUEVO]   │        │    │ fecha_creacion      TIMESTAMP│
│  (Catálogo de estados)          │        └─────────────────────────────────┘
├─────────────────────────────────┤
│ PK │ id_estado            INT   │
│    │ nombre_estado        VARCHAR│
│    │ descripcion          VARCHAR│
│    │ orden                INT   │
│    │ activo               BOOLEAN│
│    │ fecha_creacion       TIMESTAMP│
└──────────┬──────────────────────┘
           │ 1
           │
           │ N
           └───────► INCIDENTE (FK: id_estado)
```

---

## Relaciones y Cardinalidades

### 1. CLASIFICACION ──(1:N)── INCIDENTE
- **Descripción**: Una clasificación puede tener múltiples incidentes
- **Cardinalidad**: 1:N
- **FK en**: `incidente.id_clasificacion`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar una clasificación con incidentes asociados)
- **Ejemplo**: "Agua Potable" → 150,000 incidentes

### 2. ALCALDIA ──(1:N)── COLONIA [NUEVA RELACIÓN]
- **Descripción**: Una alcaldía contiene múltiples colonias
- **Cardinalidad**: 1:N
- **FK en**: `colonia.id_alcaldia`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar una alcaldía con colonias asociadas)
- **Ejemplo**: "Benito Juárez" → 300 colonias
- **⭐ MEJORA**: Elimina redundancia de almacenar "Benito Juárez" N veces

### 3. COLONIA ──(1:N)── INCIDENTE [REFACTORIZADA]
- **Descripción**: Una colonia puede tener múltiples incidentes
- **Cardinalidad**: 1:N
- **FK en**: `incidente.id_colonia`
- **Constraint**: `ON DELETE SET NULL` (si se elimina una colonia, los incidentes quedan sin ubicación)
- **Ejemplo**: "Del Valle Sur" → 500 incidentes
- **⭐ MEJORA**: Ya no almacena alcaldia_catalogo (ahora es FK)

### 4. ESTADO_INCIDENTE ──(1:N)── INCIDENTE [NUEVA RELACIÓN]
- **Descripción**: Un estado puede aplicar a múltiples incidentes
- **Cardinalidad**: 1:N
- **FK en**: `incidente.id_estado`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar un estado en uso)
- **Ejemplo**: "Registrado" → 180,000 incidentes
- **⭐ MEJORA**: Valida estados, evita typos y inconsistencias

### 5. INCIDENTE ──(1:N)── REPORTE [SIN CAMBIOS]
- **Descripción**: Un incidente puede generar múltiples reportes (llamadas, notificaciones)
- **Cardinalidad**: 1:N
- **FK en**: `reporte.id_incidente`
- **Constraint**: `ON DELETE CASCADE` (si se elimina un incidente, se eliminan sus reportes)
- **Ejemplo**: Fuga en Coyoacán → 5 reportes de diferentes ciudadanos

### 6. MEDIO_RECEPCION ──(1:N)── REPORTE [SIN CAMBIOS]
- **Descripción**: Un medio de recepción puede recibir múltiples reportes
- **Cardinalidad**: 1:N
- **FK en**: `reporte.id_medio_recepcion`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar un medio con reportes asociados)
- **Ejemplo**: "Ciudadano (Call Center)" → 200,000 reportes

---

## Dependencias Funcionales (DF)

### CLASIFICACION
```
id_clasificacion → nombre_clasificacion, descripcion, activo, fecha_creacion
✅ Solo DF desde la PK
```

### MEDIO_RECEPCION
```
id_medio_recepcion → nombre_medio, descripcion, activo, fecha_creacion
✅ Solo DF desde la PK
```

### ALCALDIA [NUEVA]
```
id_alcaldia → nombre_alcaldia, codigo_alcaldia, activo, fecha_creacion
✅ Solo DF desde la PK
✅ Elimina repetición de nombres de alcaldía
```

### ESTADO_INCIDENTE [NUEVA]
```
id_estado → nombre_estado, descripcion, orden, activo, fecha_creacion
✅ Solo DF desde la PK
✅ Dominio finito y validado
```

### COLONIA [REFACTORIZADA]
```
ANTES (con dependencia transitiva):
  id_colonia → colonia_catalogo, alcaldia_catalogo, longitud, latitud
  colonia_catalogo → alcaldia_catalogo  ❌ DEPENDENCIA TRANSITIVA

DESPUÉS (sin dependencia transitiva):
  id_colonia → nombre_colonia, id_alcaldia, codigo_postal, centroide_longitud, centroide_latitud
  ✅ Solo DF desde la PK o FKs
  ✅ alcaldia_catalogo eliminado (ahora es FK)
```

### INCIDENTE [MEJORADO]
```
id_incidente → folio_incidente, fecha_registro_incidente, reporte, 
               id_clasificacion, id_colonia, id_estado,
               longitud_incidente, latitud_incidente,
               fecha_creacion, fecha_actualizacion

folio_incidente → (todos los demás atributos)  // Clave alternativa

✅ Solo DF desde la PK
✅ Nuevos atributos: id_estado, longitud_incidente, latitud_incidente
```

### REPORTE [SIN CAMBIOS]
```
id_reporte_pk → id_reporte, id_incidente, fecha_reporte, hora_reporte, id_medio_recepcion
id_reporte → (todos los demás atributos)  // Clave alternativa
✅ Solo DF desde la PK
```

---

## Índices Estratégicos

### CLASIFICACION
- `PRIMARY KEY (id_clasificacion)`
- `UNIQUE INDEX (nombre_clasificacion)`
- `INDEX idx_nombre_clasificacion (nombre_clasificacion)`

### MEDIO_RECEPCION
- `PRIMARY KEY (id_medio_recepcion)`
- `UNIQUE INDEX (nombre_medio)`
- `INDEX idx_nombre_medio (nombre_medio)`

### ALCALDIA [NUEVA]
- `PRIMARY KEY (id_alcaldia)`
- `UNIQUE INDEX (nombre_alcaldia)`
- `INDEX idx_nombre_alcaldia (nombre_alcaldia)`

### ESTADO_INCIDENTE [NUEVA]
- `PRIMARY KEY (id_estado)`
- `UNIQUE INDEX (nombre_estado)`
- `INDEX idx_nombre_estado (nombre_estado)`

### COLONIA [REFACTORIZADA]
- `PRIMARY KEY (id_colonia)`
- `UNIQUE INDEX (nombre_colonia, id_alcaldia)` ← Clave alternativa compuesta
- `INDEX idx_alcaldia_colonia (id_alcaldia)` ← Para JOIN con alcaldia
- `INDEX idx_nombre_colonia (nombre_colonia)` ← Para búsquedas
- `INDEX idx_coordenadas_colonia (centroide_longitud, centroide_latitud)` ← Para geo-queries

### INCIDENTE [MEJORADO]
- `PRIMARY KEY (id_incidente)`
- `UNIQUE INDEX (folio_incidente)`
- `INDEX idx_clasificacion (id_clasificacion)` ← JOIN con clasificacion
- `INDEX idx_colonia_incidente (id_colonia)` ← JOIN con colonia
- `INDEX idx_estado_incidente (id_estado)` ← JOIN con estado_incidente [NUEVO]
- `INDEX idx_fecha_registro (fecha_registro_incidente)` ← Filtros temporales
- `INDEX idx_coordenadas_incidente (longitud_incidente, latitud_incidente)` ← Geo-queries [NUEVO]
- `INDEX idx_fecha_creacion (fecha_creacion)`

### REPORTE [SIN CAMBIOS]
- `PRIMARY KEY (id_reporte_pk)`
- `UNIQUE INDEX (id_reporte)`
- `INDEX idx_incidente (id_incidente)` ← JOIN con incidente
- `INDEX idx_medio_recepcion (id_medio_recepcion)` ← JOIN con medio_recepcion
- `INDEX idx_fecha_reporte (fecha_reporte)` ← Filtros temporales
- `INDEX idx_fecha_hora (fecha_reporte, hora_reporte)` ← Ordenamiento temporal

---

## Ejemplo de Datos

### CLASIFICACION [SIN CAMBIOS]
| id_clasificacion | nombre_clasificacion | descripcion |
|------------------|---------------------|-------------|
| 1 | Agua Potable | Categoría: Agua Potable |
| 2 | Drenaje | Categoría: Drenaje |

### MEDIO_RECEPCION [SIN CAMBIOS]
| id_medio_recepcion | nombre_medio | descripcion |
|--------------------|--------------|-------------|
| 1 | Ciudadano (Call Center) | Canal: Ciudadano (Call Center) |
| 2 | Redes Sociales | Canal: Redes Sociales |

### ALCALDIA [NUEVA]
| id_alcaldia | nombre_alcaldia | codigo_alcaldia |
|-------------|----------------|-----------------|
| 1 | Álvaro Obregón | AO |
| 2 | Azcapotzalco | AZ |
| 3 | Benito Juárez | BJ |
| ... | ... | ... |
| 16 | Xochimilco | XO |

### ESTADO_INCIDENTE [NUEVA]
| id_estado | nombre_estado | descripcion | orden |
|-----------|--------------|-------------|-------|
| 1 | Registrado | Incidente registrado en el sistema | 1 |
| 2 | En Atención | Incidente siendo atendido por personal técnico | 2 |
| 3 | Atendido | Incidente atendido completamente | 3 |
| 4 | Cerrado | Caso cerrado y archivado | 4 |
| 5 | Cancelado | Incidente cancelado o duplicado | 5 |

### COLONIA [REFACTORIZADA]
| id_colonia | nombre_colonia | id_alcaldia | centroide_longitud | centroide_latitud |
|------------|----------------|-------------|--------------------|--------------------|
| 1 | Del Valle Sur | 3 | -99.17515038 | 19.36850264 |
| 2 | Florida | 1 | -99.1799217 | 19.3607533 |

**⭐ NOTA**: Antes se almacenaba "Benito Juárez" como texto en cada fila. Ahora solo se almacena el ID (3), eliminando redundancia.

### INCIDENTE [MEJORADO]
| id_incidente | folio_incidente | fecha_registro_incidente | id_clasificacion | id_colonia | id_estado | longitud_incidente | latitud_incidente |
|--------------|-----------------|-------------------------|------------------|------------|-----------|--------------------|--------------------|
| 1 | I-20220101-0001 | 2022-01-02 | 1 | 1 | 1 | -99.17520000 | 19.36855000 |
| 2 | I-20220101-0002 | 2022-01-02 | 2 | 2 | 2 | -99.17995000 | 19.36080000 |

**⭐ NOTAS**:
- `id_estado` ahora es FK a estado_incidente (antes era VARCHAR)
- `longitud_incidente` y `latitud_incidente` son las coordenadas exactas del punto del incidente
- La colonia tiene `centroide_longitud/latitud` para el centro geográfico de la colonia

### REPORTE [SIN CAMBIOS]
| id_reporte_pk | id_reporte | id_incidente | fecha_reporte | hora_reporte | id_medio_recepcion |
|---------------|------------|--------------|---------------|--------------|-------------------|
| 1 | R-20220101-0105 | 1 | 2022-01-01 | 18:33:08 | 1 |
| 2 | R-20220101-0106 | 2 | 2022-01-01 | 18:36:38 | 1 |

---

## Reconstrucción de Tabla Original (Lossless Join)

Para demostrar que la descomposición es **sin pérdida de información**, podemos reconstruir la tabla original:

```sql
SELECT 
    i.folio_incidente,
    i.fecha_registro_incidente,
    r.id_reporte,
    r.fecha_reporte,
    r.hora_reporte,
    c.nombre_clasificacion AS clasificacion,
    i.reporte,
    m.nombre_medio AS medio_recepcion,
    a.nombre_alcaldia AS alcaldia_catalogo,        -- ← Ahora desde ALCALDIA
    col.nombre_colonia AS colonia_catalogo,         -- ← Ahora desde COLONIA
    e.nombre_estado AS estado,                      -- ← NUEVO: desde ESTADO_INCIDENTE
    col.centroide_longitud AS longitud_colonia,     -- ← Centroide de colonia
    col.centroide_latitud AS latitud_colonia,       -- ← Centroide de colonia
    i.longitud_incidente,                           -- ← NUEVO: Coordenada exacta del incidente
    i.latitud_incidente                             -- ← NUEVO: Coordenada exacta del incidente
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado            -- ← NUEVO JOIN
LEFT JOIN colonia col ON i.id_colonia = col.id_colonia
LEFT JOIN alcaldia a ON col.id_alcaldia = a.id_alcaldia;             -- ← NUEVO JOIN
```

**⭐ CAMBIOS EN EL JOIN**:
- Se agregó `JOIN estado_incidente` para obtener el nombre del estado
- Se agregó `JOIN alcaldia` para obtener el nombre de la alcaldía
- Se renombraron las coordenadas para diferenciar centroide vs punto exacto

Este JOIN demuestra que todas las proyecciones pueden recombinarse sin pérdida de datos, cumpliendo con el principio fundamental de 5NF.

---

## Normalización: 1NF → 2NF → 3NF → BCNF → 4NF → 5NF

### 1NF (Primera Forma Normal) - COMPLETO ✅
- Todas las columnas son atómicas
- No hay grupos repetitivos
- Cada celda contiene un solo valor

### 2NF (Segunda Forma Normal) - COMPLETO ✅
- Cumple 1NF
- No hay dependencias parciales (no aplicable en la mayoría de tablas, no hay llaves compuestas)
- Excepción: COLONIA tiene clave alternativa compuesta (nombre_colonia, id_alcaldia), pero cumple 2NF

### 3NF (Tercera Forma Normal) - COMPLETO ✅
- Cumple 2NF
- Se eliminan dependencias transitivas:
  - **ANTES**: `colonia → alcaldia_catalogo` (dependencia transitiva) ❌
  - **AHORA**: `colonia → id_alcaldia → nombre_alcaldia` (FK válida) ✅
  - Solución: Crear tabla **ALCALDIA**

### BCNF (Forma Normal de Boyce-Codd) - COMPLETO ✅
- Cumple 3NF
- Todas las dependencias funcionales tienen una superclave a la izquierda
- **VERIFICACIÓN**:
  - ALCALDIA: `id_alcaldia → ...` ✅ (PK es superclave)
  - COLONIA: `id_colonia → ...` y `(nombre_colonia, id_alcaldia) → ...` ✅ (ambas son superclaves)
  - Todas las tablas cumplen BCNF

### 4NF (Cuarta Forma Normal) - COMPLETO ✅
- Cumple BCNF
- Se eliminan dependencias multivaluadas (MVD):
  - `folio_incidente ↠ id_reporte`
  - Un incidente puede tener múltiples reportes independientes
  - Solución: Separar **INCIDENTE** y **REPORTE** ✅ (ya estaba en versión anterior)

### 5NF (Quinta Forma Normal) - **AHORA SÍ COMPLETO** ✅
- Cumple 4NF
- Se eliminan dependencias de join (JD):
  - **ANTES**: Valores repetitivos de alcaldía en tabla ubicacion ❌
  - **AHORA**: Catálogo **ALCALDIA** independiente ✅
  - **ANTES**: Estados como VARCHAR sin validación ❌
  - **AHORA**: Catálogo **ESTADO_INCIDENTE** validado ✅
- No existen proyecciones adicionales que puedan recombinarse sin pérdida
- **VERDADERA 5NF ALCANZADA** 🎉

---

## Ventajas del Diseño 5NF Mejorado

| Ventaja | Antes | Después | Beneficio |
|---------|-------|---------|-----------|
| **Redundancia de alcaldías** | "Benito Juárez" repetido N veces | Almacenado 1 vez | Ahorro de espacio, consistencia |
| **Actualización de alcaldía** | UPDATE en N registros | UPDATE en 1 registro | Más rápido, sin inconsistencias |
| **Validación de estados** | VARCHAR acepta cualquier valor | FK valida contra catálogo | No más typos ("Registradoo") |
| **Gestión de estados** | Hardcodeado en código | Tabla configurable | Agregar estados sin cambiar código |
| **Granularidad geoespacial** | Solo centroide de colonia | Centroide + punto exacto | Análisis geoespacial preciso |
| **Integridad referencial** | Parcial | Total | Todas las relaciones validadas |
| **Mantenibilidad** | Media | Alta | Cambios centralizados |
| **Escalabilidad** | Limitada | Alta | Fácil agregar atributos |

---

## Consultas Frecuentes Optimizadas

### 1. ¿Cuántos incidentes hay por clasificación?
```sql
SELECT c.nombre_clasificacion, COUNT(i.id_incidente)
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion;
```
**Optimización**: `INDEX idx_clasificacion` en incidente

### 2. ¿Cuántos incidentes hay por alcaldía? [MEJORADO]
```sql
SELECT 
    a.nombre_alcaldia, 
    COUNT(i.id_incidente) AS total_incidentes
FROM alcaldia a
LEFT JOIN colonia c ON a.id_alcaldia = c.id_alcaldia
LEFT JOIN incidente i ON c.id_colonia = i.id_colonia
GROUP BY a.id_alcaldia
ORDER BY total_incidentes DESC;
```
**Optimización**: 
- `INDEX idx_alcaldia_colonia` en colonia (JOIN alcaldia→colonia)
- `INDEX idx_colonia_incidente` en incidente (JOIN colonia→incidente)
- **ANTES**: Agrupación por STRING de alcaldia_catalogo (lento, duplicados posibles)
- **AHORA**: Agrupación por INTEGER id_alcaldia (rápido, único)

### 3. ¿Cuáles son los incidentes en estado "En Atención"? [NUEVO]
```sql
SELECT 
    i.folio_incidente,
    i.reporte,
    e.nombre_estado
FROM incidente i
INNER JOIN estado_incidente e ON i.id_estado = e.id_estado
WHERE e.nombre_estado = 'En Atención';
```
**Optimización**: `INDEX idx_estado_incidente` en incidente
**ANTES**: `WHERE estado = 'En Atención'` (vulnerable a typos)
**AHORA**: JOIN con catálogo validado

### 4. Incidentes con punto exacto vs centroide de colonia [NUEVO]
```sql
SELECT 
    i.folio_incidente,
    col.nombre_colonia,
    i.longitud_incidente AS longitud_exacta,
    i.latitud_incidente AS latitud_exacta,
    col.centroide_longitud AS longitud_colonia,
    col.centroide_latitud AS latitud_colonia
FROM incidente i
LEFT JOIN colonia col ON i.id_colonia = col.id_colonia
WHERE i.longitud_incidente IS NOT NULL;
```
**Optimización**: `INDEX idx_coordenadas_incidente` en incidente
**MEJORA**: Permite análisis geoespacial preciso (puntos vs áreas)

---

## Comparación con Versión Anterior

### Tabla de Comparación

| Aspecto | Versión Anterior (5 tablas) | Versión Mejorada (7 tablas) |
|---------|----------------------------|------------------------------|
| **Normalización** | ⚠️ 4NF (con problemas de 3NF en ubicacion) | ✅ 5NF verdadera |
| **Dependencias transitivas** | ❌ Presente en ubicacion | ✅ Eliminadas completamente |
| **Validación de estados** | ❌ VARCHAR sin validar | ✅ FK a catálogo |
| **Redundancia de alcaldías** | ❌ Alta (N repeticiones) | ✅ Cero (1 vez) |
| **Granularidad geoespacial** | ⚠️ Solo centroide | ✅ Centroide + punto exacto |
| **Tablas** | 5 | 7 |
| **JOINs típicos** | 4-5 | 5-6 |
| **Complejidad consultas** | Media | Media-Alta |
| **Integridad datos** | Alta | Máxima |
| **Escalabilidad** | Media | Alta |
| **Performance** | Bueno (con índices) | Bueno (con índices) |

### Impacto en Performance

**Positivo:**
- Índices en FKs aceleran JOINs
- Agrupaciones por INTEGER más rápidas que por VARCHAR
- Sin duplicados por variaciones de nombres

**Neutral:**
- 1-2 JOINs adicionales compensados por índices
- Tablas más pequeñas (menos redundancia) = mejor cache hit rate

**Recomendaciones:**
- Para queries frecuentes: vistas materializadas
- Para dashboards: cachear agregaciones
- Para análisis: considerar data warehouse desnormalizado separado

---

## Conclusión

El diseño mejorado en **5NF verdadera** garantiza:

1. ✅ **Máxima normalización** sin pérdida de información
2. ✅ **Eliminación total** de dependencias transitivas
3. ✅ **Integridad absoluta** mediante constraints FK en todas las relaciones
4. ✅ **Validación de dominios** (estados, clasificaciones, medios, alcaldías)
5. ✅ **Performance optimizado** con índices estratégicos en todos los JOINs
6. ✅ **Mantenimiento centralizado** de catálogos
7. ✅ **Escalabilidad** para crecimiento y nuevas funcionalidades
8. ✅ **Granularidad geoespacial** mejorada (centroides + puntos exactos)

Este modelo es **óptimo para sistemas transaccionales (OLTP)** donde la integridad, consistencia y capacidad de actualización son prioritarias.

Para sistemas analíticos (OLAP) de alto volumen, se puede considerar:
- Data warehouse desnormalizado separado
- Vistas materializadas para agregaciones frecuentes
- Índices adicionales específicos para queries analíticas
- Particionamiento de tablas grandes (incidente, reporte)

---

**Fecha de actualización**: Diciembre 2025  
**Versión**: 2.0 - 5NF Verdadera  
**Cambios**: Agregadas tablas ALCALDIA y ESTADO_INCIDENTE, refactorizada COLONIA
