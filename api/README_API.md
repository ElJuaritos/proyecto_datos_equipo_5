

# API REST - Sistema de Reportes de Agua CDMX

API RESTful construida con **FastAPI** para gestionar el sistema de reportes de agua de la Ciudad de México. Implementa operaciones CRUD completas para las 5 tablas normalizadas del schema 5NF.

---

## 📋 Características

- ✅ **5 Tablas Normalizadas (5NF)**: Clasificación, Medio Recepción, Ubicación, Incidente, Reporte
- ✅ **Operaciones CRUD completas** para todas las entidades
- ✅ **Validaciones automáticas** con Pydantic
- ✅ **Documentación interactiva** con Swagger UI y ReDoc
- ✅ **Paginación y filtros** en endpoints de lectura
- ✅ **Integridad referencial** garantizada con Foreign Keys
- ✅ **CORS habilitado** para integraciones frontend
- ✅ **Health checks** y logging de requests

---

## 🚀 Instalación

### Requisitos Previos

- Python 3.8+
- MySQL 8.0+ o MariaDB 10.5+
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
DB_USER=root
DB_PASSWORD=tu_password
DB_HOST=localhost
DB_PORT=3306
DB_NAME=reportes_agua_cdmx
```

### Paso 5: Asegurar que la base de datos existe

```bash
# Ejecutar los scripts SQL previos
mysql -u root -p reportes_agua_cdmx < ../04_schema_5nf.sql
mysql -u root -p reportes_agua_cdmx < ../05_migracion_a_5nf.sql
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

Todos los endpoints están bajo el prefijo `/api/v1`

### Clasificaciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/clasificaciones/` | Crear clasificación |
| GET | `/api/v1/clasificaciones/` | Listar clasificaciones |
| GET | `/api/v1/clasificaciones/{id}` | Obtener por ID |
| PUT | `/api/v1/clasificaciones/{id}` | Actualizar |
| DELETE | `/api/v1/clasificaciones/{id}` | Eliminar |

### Medios de Recepción

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/medios-recepcion/` | Crear medio |
| GET | `/api/v1/medios-recepcion/` | Listar medios |
| GET | `/api/v1/medios-recepcion/{id}` | Obtener por ID |
| PUT | `/api/v1/medios-recepcion/{id}` | Actualizar |
| DELETE | `/api/v1/medios-recepcion/{id}` | Eliminar |

### Ubicaciones

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/ubicaciones/` | Crear ubicación |
| GET | `/api/v1/ubicaciones/` | Listar ubicaciones |
| GET | `/api/v1/ubicaciones/{id}` | Obtener por ID |
| PUT | `/api/v1/ubicaciones/{id}` | Actualizar |
| DELETE | `/api/v1/ubicaciones/{id}` | Eliminar |

**Filtros disponibles:** `?alcaldia=Iztapalapa`

### Incidentes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/incidentes/` | Crear incidente |
| GET | `/api/v1/incidentes/` | Listar incidentes |
| GET | `/api/v1/incidentes/{id}` | Obtener por ID |
| GET | `/api/v1/incidentes/folio/{folio}` | Obtener por folio |
| PUT | `/api/v1/incidentes/{id}` | Actualizar |
| DELETE | `/api/v1/incidentes/{id}` | Eliminar (+ reportes) |

**Filtros disponibles:** 
- `?clasificacion_id=1`
- `?estado=Registrado`

### Reportes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/reportes/` | Crear reporte |
| GET | `/api/v1/reportes/` | Listar reportes |
| GET | `/api/v1/reportes/{id}` | Obtener por ID |
| GET | `/api/v1/reportes/codigo/{codigo}` | Obtener por código |
| PUT | `/api/v1/reportes/{id}` | Actualizar |
| DELETE | `/api/v1/reportes/{id}` | Eliminar |

**Filtros disponibles:**
- `?incidente_id=1`
- `?medio_id=2`

### Paginación

Todos los endpoints GET de listado soportan paginación:

```
GET /api/v1/incidentes/?skip=0&limit=50
```

- `skip`: Número de registros a saltar (default: 0)
- `limit`: Máximo de registros a retornar (default: 100)

---

## 💡 Ejemplos de Uso

### 1. Crear una Clasificación

```bash
curl -X POST "http://localhost:8000/api/v1/clasificaciones/" \
  -H "Content-Type: application/json" \
  -d '{
    "nombre_clasificacion": "Agua Potable",
    "descripcion": "Problemas relacionados con agua potable",
    "activo": true
  }'
```

### 2. Listar Incidentes

```bash
curl "http://localhost:8000/api/v1/incidentes/?skip=0&limit=10"
```

### 3. Obtener Incidente por Folio

```bash
curl "http://localhost:8000/api/v1/incidentes/folio/I-20220101-0001"
```

### 4. Crear un Reporte

```bash
curl -X POST "http://localhost:8000/api/v1/reportes/" \
  -H "Content-Type: application/json" \
  -d '{
    "id_reporte": "R-20221201-9999",
    "id_incidente": 1,
    "fecha_reporte": "2022-12-01",
    "hora_reporte": "14:30:00",
    "id_medio_recepcion": 1
  }'
```

### 5. Filtrar Ubicaciones por Alcaldía

```bash
curl "http://localhost:8000/api/v1/ubicaciones/?alcaldia=Iztapalapa&limit=20"
```

### 6. Actualizar Estado de Incidente

```bash
curl -X PUT "http://localhost:8000/api/v1/incidentes/1" \
  -H "Content-Type: application/json" \
  -d '{
    "estado": "Atendido"
  }'
```

### 7. Eliminar un Reporte

```bash
curl -X DELETE "http://localhost:8000/api/v1/reportes/100"
```

---

## 🧪 Testing con Postman/Insomnia

1. **Importar colección OpenAPI:**
   - Descarga el schema: http://localhost:8000/openapi.json
   - Importa en Postman o Insomnia
   - Todos los endpoints estarán disponibles automáticamente

2. **Variables de entorno:**
   ```json
   {
     "base_url": "http://localhost:8000/api/v1"
   }
   ```

---

## 🐍 Uso desde Python

```python
import requests

BASE_URL = "http://localhost:8000/api/v1"

# Obtener clasificaciones
response = requests.get(f"{BASE_URL}/clasificaciones/")
clasificaciones = response.json()
print(clasificaciones)

# Crear nueva ubicación
nueva_ubicacion = {
    "colonia_catalogo": "Roma Norte",
    "alcaldia_catalogo": "Cuauhtémoc",
    "longitud": -99.1627,
    "latitud": 19.4186,
    "activo": True
}

response = requests.post(
    f"{BASE_URL}/ubicaciones/",
    json=nueva_ubicacion
)

if response.status_code == 201:
    ubicacion_creada = response.json()
    print(f"Ubicación creada con ID: {ubicacion_creada['id_colonia']}")
else:
    print(f"Error: {response.json()}")

# Filtrar incidentes por clasificación
response = requests.get(
    f"{BASE_URL}/incidentes/",
    params={"clasificacion_id": 1, "limit": 50}
)
incidentes = response.json()
print(f"Total incidentes: {len(incidentes)}")
```

---

## 📦 Estructura del Proyecto

```
api/
├── main.py                 # Aplicación principal FastAPI
├── database.py             # Configuración de SQLAlchemy
├── models.py               # Modelos de SQLAlchemy (ORM)
├── schemas.py              # Schemas de Pydantic (validación)
├── crud.py                 # Operaciones CRUD
├── requirements.txt        # Dependencias
├── env.example             # Template de variables de entorno
├── README_API.md           # Esta documentación
└── routers/                # Endpoints organizados por entidad
    ├── clasificacion.py
    ├── medio_recepcion.py
    ├── ubicacion.py
    ├── incidente.py
    └── reporte.py
```

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

### Error: "Can't connect to MySQL server"

**Causa:** La base de datos no está corriendo o credenciales incorrectas.

**Solución:**
1. Verificar que MySQL está corriendo
2. Revisar credenciales en `.env`
3. Probar conexión: `mysql -u root -p`

### Error: "Table doesn't exist"

**Causa:** El schema 5NF no se ha ejecutado.

**Solución:**
```bash
mysql -u root -p reportes_agua_cdmx < ../04_schema_5nf.sql
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
**Base de Datos:** MySQL 8.0+

