# 📮 Guía Completa de Pruebas con Postman

## Sistema de Reportes de Agua CDMX - API Testing

Esta guía te ayudará a probar todos los endpoints del API usando Postman.

---

## 🔧 Configuración Inicial de Postman

### 1. Crear Variable de Entorno

En Postman, crea una variable de entorno:

- **Variable:** `base_url`
- **Valor:** `http://localhost:8000/api/v1`

Así podrás usar `{{base_url}}` en todas tus peticiones.

---

## 📂 ENDPOINTS Y EJEMPLOS

### ✅ 0. Health Check (Verificar que el API funciona)

**GET** `http://localhost:8000/health`

**Respuesta esperada:**
```json
{
    "status": "healthy",
    "timestamp": 1733270400.123
}
```

---

## 🏷️ 1. CLASIFICACIONES

### 1.1 Listar todas las clasificaciones

**GET** `{{base_url}}/clasificaciones/`

**Parámetros opcionales:**
- `skip`: 0 (número de registros a saltar)
- `limit`: 100 (máximo de registros)

**Ejemplo:** `{{base_url}}/clasificaciones/?skip=0&limit=10`

---

### 1.2 Obtener clasificación por ID

**GET** `{{base_url}}/clasificaciones/1`

---

### 1.3 Crear nueva clasificación

**POST** `{{base_url}}/clasificaciones/`

**Headers:**
- `Content-Type`: `application/json`

**Body (JSON):**
```json
{
    "nombre_clasificacion": "Suministro de Agua",
    "descripcion": "Problemas relacionados con el suministro continuo de agua",
    "activo": true
}
```

**Respuesta esperada (201 Created):**
```json
{
    "id_clasificacion": 15,
    "nombre_clasificacion": "Suministro de Agua",
    "descripcion": "Problemas relacionados con el suministro continuo de agua",
    "activo": true
}
```

---

### 1.4 Actualizar clasificación

**PUT** `{{base_url}}/clasificaciones/15`

**Body (JSON):**
```json
{
    "nombre_clasificacion": "Suministro de Agua Potable",
    "descripcion": "Actualizado: Problemas de suministro",
    "activo": true
}
```

---

### 1.5 Eliminar clasificación

**DELETE** `{{base_url}}/clasificaciones/15`

**Respuesta esperada (200):**
```json
{
    "id_clasificacion": 15,
    "nombre_clasificacion": "Suministro de Agua Potable",
    "descripcion": "Actualizado: Problemas de suministro",
    "activo": true
}
```

---

## 📞 2. MEDIOS DE RECEPCIÓN

### 2.1 Listar todos los medios

**GET** `{{base_url}}/medios-recepcion/`

---

### 2.2 Obtener medio por ID

**GET** `{{base_url}}/medios-recepcion/1`

---

### 2.3 Crear nuevo medio de recepción

**POST** `{{base_url}}/medios-recepcion/`

**Body (JSON):**
```json
{
    "nombre_medio": "WhatsApp Business",
    "descripcion": "Canal de atención vía WhatsApp empresarial",
    "activo": true
}
```

---

### 2.4 Actualizar medio de recepción

**PUT** `{{base_url}}/medios-recepcion/10`

**Body (JSON):**
```json
{
    "nombre_medio": "WhatsApp Business",
    "descripcion": "Canal actualizado de WhatsApp",
    "activo": true
}
```

---

### 2.5 Eliminar medio de recepción

**DELETE** `{{base_url}}/medios-recepcion/10`

---

## 📍 3. UBICACIONES

### 3.1 Listar todas las ubicaciones

**GET** `{{base_url}}/ubicaciones/`

**Parámetros opcionales:**
- `alcaldia`: Filtrar por alcaldía (ej. "Iztapalapa")
- `skip`: 0
- `limit`: 100

**Ejemplo con filtro:**
```
{{base_url}}/ubicaciones/?alcaldia=Iztapalapa&limit=20
```

---

### 3.2 Obtener ubicación por ID

**GET** `{{base_url}}/ubicaciones/1`

---

### 3.3 Crear nueva ubicación

**POST** `{{base_url}}/ubicaciones/`

**Body (JSON):**
```json
{
    "colonia_catalogo": "Polanco",
    "alcaldia_catalogo": "Miguel Hidalgo",
    "longitud": -99.1927,
    "latitud": 19.4340,
    "activo": true
}
```

**Notas importantes:**
- **Longitud** debe estar entre -99.4 y -98.9 (CDMX)
- **Latitud** debe estar entre 19.0 y 19.6 (CDMX)

---

### 3.4 Actualizar ubicación

**PUT** `{{base_url}}/ubicaciones/1000`

**Body (JSON):**
```json
{
    "colonia_catalogo": "Polanco Reforma",
    "alcaldia_catalogo": "Miguel Hidalgo",
    "longitud": -99.1927,
    "latitud": 19.4340,
    "activo": true
}
```

---

### 3.5 Eliminar ubicación

**DELETE** `{{base_url}}/ubicaciones/1000`

---

## 🚨 4. INCIDENTES

### 4.1 Listar todos los incidentes

**GET** `{{base_url}}/incidentes/`

**Parámetros opcionales:**
- `clasificacion_id`: Filtrar por clasificación
- `estado`: "Registrado", "Atendido", "Cerrado"
- `skip`: 0
- `limit`: 100

**Ejemplo con filtros:**
```
{{base_url}}/incidentes/?clasificacion_id=1&estado=Registrado&limit=50
```

---

### 4.2 Obtener incidente por ID

**GET** `{{base_url}}/incidentes/1`

---

### 4.3 Obtener incidente por FOLIO

**GET** `{{base_url}}/incidentes/folio/I-20220101-0001`

Este es muy útil para buscar un incidente específico por su folio único.

---

### 4.4 Crear nuevo incidente

**POST** `{{base_url}}/incidentes/`

**Body (JSON):**
```json
{
    "folio_incidente": "I-20251203-9999",
    "fecha_incidente": "2025-12-03",
    "hora_incidente": "14:30:00",
    "prioridad": "Alta",
    "estado": "Registrado",
    "descripcion": "Fuga de agua importante en calle principal",
    "id_clasificacion": 1,
    "id_ubicacion": 1
}
```

**Campos importantes:**
- **folio_incidente**: Debe ser único (formato: I-YYYYMMDD-NNNN)
- **fecha_incidente**: Formato YYYY-MM-DD
- **hora_incidente**: Formato HH:MM:SS
- **prioridad**: "Baja", "Media", "Alta", "Urgente"
- **estado**: "Registrado", "En Proceso", "Atendido", "Cerrado"
- **id_clasificacion**: Debe existir en la tabla clasificacion
- **id_ubicacion**: Debe existir en la tabla ubicacion (puede ser null)

---

### 4.5 Actualizar incidente

**PUT** `{{base_url}}/incidentes/1`

**Body (JSON):**
```json
{
    "folio_incidente": "I-20220101-0001",
    "fecha_incidente": "2022-01-01",
    "hora_incidente": "08:30:00",
    "prioridad": "Media",
    "estado": "Atendido",
    "descripcion": "Incidente resuelto satisfactoriamente",
    "id_clasificacion": 1,
    "id_ubicacion": 1
}
```

---

### 4.6 Eliminar incidente (y sus reportes asociados)

**DELETE** `{{base_url}}/incidentes/100`

**⚠️ Importante:** Al eliminar un incidente, también se eliminan todos sus reportes asociados (cascada).

---

## 📄 5. REPORTES

### 5.1 Listar todos los reportes

**GET** `{{base_url}}/reportes/`

**Parámetros opcionales:**
- `incidente_id`: Filtrar por incidente
- `medio_id`: Filtrar por medio de recepción
- `skip`: 0
- `limit`: 100

**Ejemplo con filtros:**
```
{{base_url}}/reportes/?incidente_id=1&limit=50
```

---

### 5.2 Obtener reporte por ID

**GET** `{{base_url}}/reportes/1`

---

### 5.3 Obtener reporte por CÓDIGO

**GET** `{{base_url}}/reportes/codigo/R-20220101-0001`

---

### 5.4 Crear nuevo reporte

**POST** `{{base_url}}/reportes/`

**Body (JSON):**
```json
{
    "id_reporte": "R-20251203-9999",
    "id_incidente": 1,
    "fecha_reporte": "2025-12-03",
    "hora_reporte": "14:35:00",
    "id_medio_recepcion": 1
}
```

**Campos importantes:**
- **id_reporte**: Debe ser único (formato: R-YYYYMMDD-NNNN)
- **id_incidente**: Debe existir en la tabla incidente
- **fecha_reporte**: Formato YYYY-MM-DD
- **hora_reporte**: Formato HH:MM:SS
- **id_medio_recepcion**: Debe existir en la tabla medio_recepcion

---

### 5.5 Actualizar reporte

**PUT** `{{base_url}}/reportes/1`

**Body (JSON):**
```json
{
    "id_reporte": "R-20220101-0001",
    "id_incidente": 1,
    "fecha_reporte": "2022-01-01",
    "hora_reporte": "08:35:00",
    "id_medio_recepcion": 2
}
```

---

### 5.6 Eliminar reporte

**DELETE** `{{base_url}}/reportes/1000`

---

## 🧪 FLUJO DE PRUEBA COMPLETO

Aquí tienes un flujo lógico para probar el sistema completo:

### Paso 1: Verificar datos existentes
1. `GET /clasificaciones/` - Ver clasificaciones disponibles
2. `GET /medios-recepcion/` - Ver medios disponibles
3. `GET /ubicaciones/` - Ver ubicaciones disponibles

### Paso 2: Crear una nueva ubicación
```json
POST /ubicaciones/
{
    "colonia_catalogo": "Santa Fe",
    "alcaldia_catalogo": "Cuajimalpa",
    "longitud": -99.2670,
    "latitud": 19.3600,
    "activo": true
}
```
**Guarda el `id_colonia` de la respuesta** (ej: 1500)

### Paso 3: Crear un nuevo incidente
```json
POST /incidentes/
{
    "folio_incidente": "I-20251203-TEST1",
    "fecha_incidente": "2025-12-03",
    "hora_incidente": "10:00:00",
    "prioridad": "Alta",
    "estado": "Registrado",
    "descripcion": "Prueba de API - Fuga importante",
    "id_clasificacion": 1,
    "id_ubicacion": 1500
}
```
**Guarda el `id_incidente` de la respuesta** (ej: 5000)

### Paso 4: Crear reportes para el incidente
```json
POST /reportes/
{
    "id_reporte": "R-20251203-TEST1",
    "id_incidente": 5000,
    "fecha_reporte": "2025-12-03",
    "hora_reporte": "10:05:00",
    "id_medio_recepcion": 1
}
```

```json
POST /reportes/
{
    "id_reporte": "R-20251203-TEST2",
    "id_incidente": 5000,
    "fecha_reporte": "2025-12-03",
    "hora_reporte": "10:15:00",
    "id_medio_recepcion": 3
}
```

### Paso 5: Consultar el incidente con sus reportes
```
GET /incidentes/5000
GET /reportes/?incidente_id=5000
```

### Paso 6: Actualizar el estado del incidente
```json
PUT /incidentes/5000
{
    "folio_incidente": "I-20251203-TEST1",
    "fecha_incidente": "2025-12-03",
    "hora_incidente": "10:00:00",
    "prioridad": "Alta",
    "estado": "Atendido",
    "descripcion": "Prueba de API - Fuga importante - RESUELTO",
    "id_clasificacion": 1,
    "id_ubicacion": 1500
}
```

### Paso 7: Limpiar datos de prueba
```
DELETE /reportes/{id_reporte_1}
DELETE /reportes/{id_reporte_2}
DELETE /incidentes/5000
DELETE /ubicaciones/1500
```

---

## 🔍 FILTROS Y BÚSQUEDAS ÚTILES

### Buscar incidentes de alta prioridad
```
GET /incidentes/?skip=0&limit=100
```
Luego filtrar manualmente o con código.

### Buscar reportes por canal específico
```
GET /reportes/?medio_id=1&limit=50
```

### Buscar ubicaciones de una alcaldía
```
GET /ubicaciones/?alcaldia=Iztapalapa
```

### Obtener incidente por folio
```
GET /incidentes/folio/I-20220101-0001
```

---

## 🚨 MANEJO DE ERRORES

### Error 404 - No encontrado
```json
{
    "detail": "Clasificación no encontrada"
}
```

### Error 422 - Validación fallida
```json
{
    "detail": [
        {
            "loc": ["body", "longitud"],
            "msg": "ensure this value is greater than or equal to -99.4",
            "type": "value_error.number.not_ge"
        }
    ]
}
```

### Error 500 - Error del servidor
```json
{
    "message": "Error interno del servidor",
    "detail": "...",
    "path": "/api/v1/incidentes/"
}
```

---

## 📊 CÓDIGOS DE RESPUESTA HTTP

- **200 OK**: Operación exitosa (GET, PUT, DELETE)
- **201 Created**: Recurso creado exitosamente (POST)
- **400 Bad Request**: Datos inválidos
- **404 Not Found**: Recurso no encontrado
- **422 Unprocessable Entity**: Error de validación
- **500 Internal Server Error**: Error del servidor

---

## 💡 TIPS PARA POSTMAN

### 1. Usar Variables
Crea variables para:
- `base_url`: `http://localhost:8000/api/v1`
- `test_incidente_id`: El ID de tu incidente de prueba
- `test_ubicacion_id`: El ID de tu ubicación de prueba

### 2. Guardar Respuestas
En Postman, después de hacer un POST, puedes guardar el ID retornado:

```javascript
// En Tests tab
var jsonData = pm.response.json();
pm.environment.set("ultimo_incidente_id", jsonData.id_incidente);
```

### 3. Crear Colección
Organiza tus peticiones en carpetas:
```
📁 API Reportes Agua CDMX
  📁 1. Clasificaciones
    - Listar
    - Obtener por ID
    - Crear
    - Actualizar
    - Eliminar
  📁 2. Medios Recepción
    ...
  📁 3. Ubicaciones
    ...
  📁 4. Incidentes
    ...
  📁 5. Reportes
    ...
```

### 4. Importar desde OpenAPI
Puedes importar automáticamente todos los endpoints:
1. En Postman: `Import` > `Link`
2. URL: `http://localhost:8000/openapi.json`
3. Click `Import`

---

## 🎯 CASOS DE PRUEBA RECOMENDADOS

### ✅ Casos Exitosos
- [ ] Crear clasificación nueva
- [ ] Crear medio de recepción nuevo
- [ ] Crear ubicación con coordenadas válidas
- [ ] Crear incidente con todas las FKs válidas
- [ ] Crear múltiples reportes para un incidente
- [ ] Actualizar estado de incidente
- [ ] Buscar por folio único
- [ ] Filtrar por alcaldía
- [ ] Paginación con skip/limit

### ❌ Casos de Error (deben fallar)
- [ ] Crear incidente con folio duplicado
- [ ] Crear ubicación con coordenadas fuera de rango
- [ ] Crear reporte con incidente inexistente
- [ ] Eliminar clasificación con incidentes asociados
- [ ] Actualizar con datos inválidos
- [ ] Buscar ID que no existe

---

## 📞 RECURSOS ADICIONALES

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json
- **Health Check**: http://localhost:8000/health
- **Info del API**: http://localhost:8000/

---

## 🏁 ¡LISTO PARA PROBAR!

Ahora tienes todo lo necesario para probar el API completamente con Postman. 

**Orden recomendado:**
1. Health check
2. Listar datos existentes
3. Crear nuevos registros
4. Actualizar registros
5. Buscar y filtrar
6. Eliminar registros de prueba

**¡Buena suerte con las pruebas!** 🚀

