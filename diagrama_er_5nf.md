# Diagrama Entidad-Relación (ER) - Base de Datos en 5NF
## Sistema de Reportes de Agua - CDMX

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
│          INCIDENTE              │        │         UBICACION               │
│  (Evento principal)             │        │  (Datos geográficos)            │
├─────────────────────────────────┤        ├─────────────────────────────────┤
│ PK │ id_incidente         INT   │        │ PK │ id_colonia          INT   │
│    │ folio_incidente      VARCHAR│        │    │ colonia_catalogo    VARCHAR│
│    │ fecha_registro_inc.  DATE  │        │    │ alcaldia_catalogo   VARCHAR│
│    │ reporte              VARCHAR│        │    │ longitud            DECIMAL│
│ FK │ id_clasificacion     INT   │        │    │ latitud             DECIMAL│
│ FK │ id_colonia           INT   │◄───N:1─┤    │ activo              BOOLEAN│
│    │ estado               VARCHAR│        │    │ fecha_creacion      TIMESTAMP│
│    │ fecha_creacion       TIMESTAMP      └─────────────────────────────────┘
│    │ fecha_actualizacion  TIMESTAMP
└─────────────────────────────────┘
                │
                │ 1
                │
                │ N
                │
┌───────────────▼─────────────────┐
│           REPORTE               │
│  (Notificaciones individuales)  │
├─────────────────────────────────┤        ┌─────────────────────────────────┐
│ PK │ id_reporte_pk        INT   │        │      MEDIO_RECEPCION            │
│    │ id_reporte           VARCHAR│        │  (Catálogo de canales)          │
│ FK │ id_incidente         INT   │        ├─────────────────────────────────┤
│    │ fecha_reporte        DATE  │        │ PK │ id_medio_recepcion  INT   │
│    │ hora_reporte         TIME  │        │    │ nombre_medio        VARCHAR│
│ FK │ id_medio_recepcion   INT   │◄───N:1─┤    │ descripcion         VARCHAR│
│    │ fecha_creacion       TIMESTAMP      │    │ activo              BOOLEAN│
└─────────────────────────────────┘        │    │ fecha_creacion      TIMESTAMP
                                            └─────────────────────────────────┘
```

---

## Relaciones y Cardinalidades

### 1. CLASIFICACION ──(1:N)── INCIDENTE
- **Descripción**: Una clasificación puede tener múltiples incidentes
- **Cardinalidad**: 1:N
- **FK en**: `incidente.id_clasificacion`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar una clasificación con incidentes asociados)
- **Ejemplo**: "Agua Potable" → 150,000 incidentes

### 2. UBICACION ──(1:N)── INCIDENTE
- **Descripción**: Una ubicación (colonia) puede tener múltiples incidentes
- **Cardinalidad**: 1:N
- **FK en**: `incidente.id_colonia`
- **Constraint**: `ON DELETE SET NULL` (si se elimina una ubicación, los incidentes quedan sin ubicación)
- **Ejemplo**: "Del Valle Sur" → 500 incidentes

### 3. INCIDENTE ──(1:N)── REPORTE
- **Descripción**: Un incidente puede generar múltiples reportes (llamadas, notificaciones)
- **Cardinalidad**: 1:N
- **FK en**: `reporte.id_incidente`
- **Constraint**: `ON DELETE CASCADE` (si se elimina un incidente, se eliminan sus reportes)
- **Ejemplo**: Fuga en Coyoacán → 5 reportes de diferentes ciudadanos

### 4. MEDIO_RECEPCION ──(1:N)── REPORTE
- **Descripción**: Un medio de recepción puede recibir múltiples reportes
- **Cardinalidad**: 1:N
- **FK en**: `reporte.id_medio_recepcion`
- **Constraint**: `ON DELETE RESTRICT` (no se puede eliminar un medio con reportes asociados)
- **Ejemplo**: "Ciudadano (Call Center)" → 200,000 reportes

---

## Dependencias Funcionales (DF)

```
CLASIFICACION:
  id_clasificacion → nombre_clasificacion, descripcion, activo, fecha_creacion

MEDIO_RECEPCION:
  id_medio_recepcion → nombre_medio, descripcion, activo, fecha_creacion

UBICACION:
  id_colonia → colonia_catalogo, alcaldia_catalogo, longitud, latitud, activo, fecha_creacion
  colonia_catalogo → alcaldia_catalogo, longitud, latitud

INCIDENTE:
  id_incidente → folio_incidente, fecha_registro_incidente, reporte, id_clasificacion, id_colonia, estado
  folio_incidente → fecha_registro_incidente, reporte, id_clasificacion, id_colonia

REPORTE:
  id_reporte_pk → id_reporte, id_incidente, fecha_reporte, hora_reporte, id_medio_recepcion
  id_reporte → id_incidente, fecha_reporte, hora_reporte, id_medio_recepcion
```

---

## Índices Estratégicos

### CLASIFICACION
- `PRIMARY KEY (id_clasificacion)`
- `INDEX idx_nombre_clasificacion (nombre_clasificacion)`

### MEDIO_RECEPCION
- `PRIMARY KEY (id_medio_recepcion)`
- `INDEX idx_nombre_medio (nombre_medio)`

### UBICACION
- `PRIMARY KEY (id_colonia)`
- `UNIQUE KEY uk_colonia (colonia_catalogo)`
- `INDEX idx_alcaldia (alcaldia_catalogo)`
- `INDEX idx_coordenadas (longitud, latitud)`

### INCIDENTE
- `PRIMARY KEY (id_incidente)`
- `UNIQUE KEY (folio_incidente)`
- `INDEX idx_clasificacion (id_clasificacion)` ← para joins con CLASIFICACION
- `INDEX idx_ubicacion (id_colonia)` ← para joins con UBICACION
- `INDEX idx_fecha_registro (fecha_registro_incidente)` ← para filtros temporales
- `INDEX idx_estado (estado)` ← para filtros por estado
- `INDEX idx_fecha_creacion (fecha_creacion)`

### REPORTE
- `PRIMARY KEY (id_reporte_pk)`
- `UNIQUE KEY (id_reporte)`
- `INDEX idx_incidente (id_incidente)` ← para joins con INCIDENTE
- `INDEX idx_medio_recepcion (id_medio_recepcion)` ← para joins con MEDIO_RECEPCION
- `INDEX idx_fecha_reporte (fecha_reporte)` ← para filtros temporales
- `INDEX idx_fecha_hora (fecha_reporte, hora_reporte)` ← para ordenamiento temporal

---

## Ejemplo de Datos

### CLASIFICACION
| id_clasificacion | nombre_clasificacion | descripcion |
|------------------|---------------------|-------------|
| 1 | Agua Potable | Categoría: Agua Potable |
| 2 | Drenaje | Categoría: Drenaje |

### MEDIO_RECEPCION
| id_medio_recepcion | nombre_medio | descripcion |
|--------------------|--------------|-------------|
| 1 | Ciudadano (Call Center) | Canal: Ciudadano (Call Center) |
| 2 | Redes Sociales | Canal: Redes Sociales |

### UBICACION
| id_colonia | colonia_catalogo | alcaldia_catalogo | longitud | latitud |
|------------|------------------|-------------------|----------|---------|
| 1 | Del Valle Sur | Benito Juárez | -99.17515038 | 19.36850264 |
| 2 | Florida | Álvaro Obregón | -99.1799217 | 19.3607533 |

### INCIDENTE
| id_incidente | folio_incidente | fecha_registro_incidente | reporte | id_clasificacion | id_colonia |
|--------------|-----------------|-------------------------|---------|------------------|------------|
| 1 | I-20220101-0001 | 2022-01-02 | Fuga | 1 | 1 |
| 2 | I-20220101-0002 | 2022-01-02 | Drenaje Obstruido | 2 | 2 |

### REPORTE
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
    u.alcaldia_catalogo,
    u.colonia_catalogo,
    u.longitud,
    u.latitud
FROM reporte r
INNER JOIN incidente i ON r.id_incidente = i.id_incidente
INNER JOIN clasificacion c ON i.id_clasificacion = c.id_clasificacion
INNER JOIN medio_recepcion m ON r.id_medio_recepcion = m.id_medio_recepcion
LEFT JOIN ubicacion u ON i.id_colonia = u.id_colonia;
```

Este JOIN demuestra que todas las proyecciones pueden recombinarse sin pérdida de datos, cumpliendo con el principio fundamental de 5NF.

---

## Normalización: 1NF → 2NF → 3NF → 4NF → 5NF

### 1NF (Primera Forma Normal) ✅
- Todas las columnas son atómicas
- No hay grupos repetitivos
- Cada celda contiene un solo valor

### 2NF (Segunda Forma Normal) ✅
- Cumple 1NF
- No hay dependencias parciales (no aplicable, no hay llave compuesta)

### 3NF (Tercera Forma Normal) ✅
- Cumple 2NF
- Se eliminan dependencias transitivas:
  - `folio_incidente → colonia_catalogo → alcaldia_catalogo, longitud, latitud`
  - Solución: Crear tabla **UBICACION**

### 4NF (Cuarta Forma Normal) ✅
- Cumple 3NF
- Se eliminan dependencias multivaluadas (MVD):
  - `folio_incidente ↠ id_reporte`
  - Un incidente puede tener múltiples reportes independientes
  - Solución: Separar **INCIDENTE** y **REPORTE**

### 5NF (Quinta Forma Normal) ✅
- Cumple 4NF
- Se eliminan dependencias de join (JD):
  - Catálogos repetitivos extraídos en tablas independientes
  - Solución: Crear **CLASIFICACION** y **MEDIO_RECEPCION**
- No existen proyecciones adicionales que puedan recombinarse sin pérdida

---

## Ventajas del Diseño 5NF

| Ventaja | Descripción | Ejemplo |
|---------|-------------|---------|
| **Eliminación de redundancia** | Los datos se almacenan una sola vez | "Agua Potable" aparece 1 vez en CLASIFICACION, no 150,000 veces |
| **Integridad referencial** | Las FKs garantizan consistencia | No puede existir un incidente con id_clasificacion inválido |
| **Mantenimiento simplificado** | Actualizar un catálogo es un UPDATE | Cambiar "Call Center" a "Centro de Atención" = 1 UPDATE |
| **Sin anomalías** | No hay problemas de inserción/actualización/eliminación | No se pueden crear inconsistencias |
| **Escalabilidad** | Fácil agregar nuevos catálogos | Agregar PRIORIDAD o ESTADO_RESOLUCION es trivial |
| **Performance optimizado** | Índices estratégicos aceleran queries | JOINs optimizados con índices en FKs |

---

## Consultas Frecuentes Optimizadas

### ¿Cuántos incidentes hay por clasificación?
```sql
SELECT c.nombre_clasificacion, COUNT(i.id_incidente)
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion;
```
**Optimización**: `INDEX idx_clasificacion` en tabla INCIDENTE

### ¿Cuáles son los incidentes más reportados?
```sql
SELECT i.folio_incidente, i.reporte, COUNT(r.id_reporte_pk) AS total_reportes
FROM incidente i
LEFT JOIN reporte r ON i.id_incidente = r.id_incidente
GROUP BY i.id_incidente
ORDER BY total_reportes DESC;
```
**Optimización**: `INDEX idx_incidente` en tabla REPORTE

### ¿Qué colonias tienen más incidentes?
```sql
SELECT u.colonia_catalogo, u.alcaldia_catalogo, COUNT(i.id_incidente)
FROM ubicacion u
LEFT JOIN incidente i ON u.id_colonia = i.id_colonia
GROUP BY u.id_colonia
ORDER BY COUNT(i.id_incidente) DESC;
```
**Optimización**: `INDEX idx_ubicacion` en tabla INCIDENTE

---

## Conclusión

El diseño en **5NF** garantiza:
1. ✅ **Máxima normalización** sin pérdida de información
2. ✅ **Integridad total** mediante constraints FK
3. ✅ **Performance optimizado** con índices estratégicos
4. ✅ **Mantenimiento simple** de catálogos centralizados
5. ✅ **Escalabilidad** para crecimiento futuro

Este modelo es apropiado para sistemas transaccionales (OLTP) donde la integridad y consistencia son prioritarias. Para sistemas analíticos (OLAP) de alto volumen, podría considerarse desnormalización controlada o tablas agregadas/materializadas.

