# Guía de Pruebas con Postman

Ejemplos prácticos para probar la API con Postman.

## Configuración Inicial

### Variable de Entorno en Postman

- **Variable:** `base_url`
- **Valor:** `http://localhost:8000`

Usar `{{base_url}}` en todas las peticiones.

---

## Pruebas Básicas

### Health Check

**GET** `{{base_url}}/health`

```json
{
    "status": "healthy",
    "timestamp": 1733270400.123
}
```

---

## 1. Clasificaciones (CRUD Básico)

**Listar:** `GET {{base_url}}/clasificaciones/`

**Obtener por ID:** `GET {{base_url}}/clasificaciones/1`

**Crear:** `POST {{base_url}}/clasificaciones/`
```json
{
    "nombre_clasificacion": "Suministro de Agua",
    "descripcion": "Problemas relacionados con el suministro continuo de agua",
    "activo": true
}
```

**Actualizar:** `PUT {{base_url}}/clasificaciones/15`

**Eliminar:** `DELETE {{base_url}}/clasificaciones/15`

---

## 2. Alcaldías

**Listar:** `GET {{base_url}}/alcaldias/`

**Crear:** `POST {{base_url}}/alcaldias/`
```json
{
    "nombre_alcaldia": "Benito Juárez",
    "codigo_alcaldia": "BJ",
    "activo": true
}
```

---

## 3. Colonias

**Listar:** `GET {{base_url}}/colonias/`

**Filtrar por alcaldía:** `GET {{base_url}}/colonias/?alcaldia_id=3&limit=20`

**Crear:** `POST {{base_url}}/colonias/`
```json
{
    "nombre_colonia": "Polanco",
    "id_alcaldia": 2,
    "centroide_longitud": -99.1927,
    "centroide_latitud": 19.4340,
    "activo": true
}
```

**Nota:** Longitud entre -99.4 y -98.9, Latitud entre 19.0 y 19.6

---

## 4. Incidentes

**Listar:** `GET {{base_url}}/incidentes/?limit=10`

**Filtrar:** `GET {{base_url}}/incidentes/?estado_id=1&alcaldia_id=3&limit=50`

**Obtener por folio:** `GET {{base_url}}/incidentes/folio/I-20220101-0001`

**Crear:** `POST {{base_url}}/incidentes/`
```json
{
    "folio_incidente": "I-20251203-9999",
    "fecha_registro_incidente": "2025-12-03",
    "reporte": "Fuga de agua importante en calle principal",
    "id_clasificacion": 1,
    "id_colonia": 1,
    "id_estado": 1,
    "longitud_incidente": -99.1750,
    "latitud_incidente": 19.3685
}
```

**Actualizar:** `PUT {{base_url}}/incidentes/1`

**Eliminar:** `DELETE {{base_url}}/incidentes/100` (elimina reportes asociados en cascada)

---

## 5. Reportes

**Listar:** `GET {{base_url}}/reportes/?limit=10`

**Filtrar por incidente:** `GET {{base_url}}/reportes/?incidente_id=1&limit=50`

**Crear:** `POST {{base_url}}/reportes/`
```json
{
    "id_reporte": "R-20251203-9999",
    "id_incidente": 1,
    "fecha_reporte": "2025-12-03",
    "hora_reporte": "14:35:00",
    "id_medio_recepcion": 1
}
```

---

## 6. Estadísticas (Funcionalidades Avanzadas)

**Dashboard general:**
```
GET {{base_url}}/estadisticas/dashboard
```

**Estadísticas por alcaldía:**
```
GET {{base_url}}/estadisticas/alcaldia/1
```

**Análisis temporal:**
```
GET {{base_url}}/estadisticas/temporal?fecha_inicio=2024-01-01&fecha_fin=2024-12-31&agrupacion=mes
```

**Zonas críticas:**
```
GET {{base_url}}/estadisticas/zonas-criticas?limit=10
```

**Búsqueda por radio:**
```
GET {{base_url}}/incidentes/buscar/por-radio?longitud=-99.1332&latitud=19.4326&radio_km=2&limit=50
```

**Actualización masiva de estado:**
```
POST {{base_url}}/incidentes/actualizar-estado-masivo
{
    "ids_incidentes": [1, 2, 3, 4, 5],
    "nuevo_estado_id": 3
}
```

---

## Flujo de Prueba Completo

### 1. Ver dashboard
```
GET /estadisticas/dashboard
```

### 2. Listar clasificaciones y alcaldías
```
GET /clasificaciones/
GET /alcaldias/
```

### 3. Crear colonia
```
POST /colonias/
{
    "nombre_colonia": "Santa Fe",
    "id_alcaldia": 2,
    "centroide_longitud": -99.2670,
    "centroide_latitud": 19.3600,
    "activo": true
}
```
Guardar `id_colonia` de la respuesta

### 4. Crear incidente
```
POST /incidentes/
{
    "folio_incidente": "I-20251203-TEST1",
    "fecha_registro_incidente": "2025-12-03",
    "reporte": "Prueba de API - Fuga importante",
    "id_clasificacion": 1,
    "id_colonia": 1500,
    "id_estado": 1
}
```
Guardar `id_incidente` de la respuesta

### 5. Crear reportes
```
POST /reportes/
{
    "id_reporte": "R-20251203-TEST1",
    "id_incidente": 5000,
    "fecha_reporte": "2025-12-03",
    "hora_reporte": "10:05:00",
    "id_medio_recepcion": 1
}
```

### 6. Consultar y actualizar
```
GET /incidentes/5000
GET /reportes/?incidente_id=5000
PUT /incidentes/5000 (cambiar id_estado a 3)
```

### 7. Limpiar datos de prueba
```
DELETE /reportes/{id}
DELETE /incidentes/5000
```

---

## Tips para Postman

**Variables de entorno:**
- `base_url`: `http://localhost:8000`
- Guardar IDs después de crear recursos

**Importar colección:**
1. Import > Link
2. URL: `http://localhost:8000/openapi.json`
3. Click Import

**Organizar en carpetas:**
- Clasificaciones
- Alcaldías
- Colonias
- Incidentes
- Reportes
- Estadísticas

---

## Recursos

- **Swagger UI**: http://localhost:8000/docs (recomendado para pruebas rápidas)
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI**: http://localhost:8000/openapi.json



