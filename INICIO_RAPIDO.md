# 🚀 Guía de Inicio Rápido

## ⚡ 5 Minutos para Empezar

### Requisitos Previos
- MySQL 8.0+ instalado y corriendo
- Python 3.8+ (solo para la API)

---

## 📊 Opción 1: Solo Base de Datos (2 comandos)

```bash
# 1. Crear el schema 5NF
mysql -u root -p -e "CREATE DATABASE reportes_agua_cdmx CHARACTER SET utf8mb4;"
mysql -u root -p reportes_agua_cdmx < 04_schema_5nf.sql

# 2. Cargar los datos (demora ~2-5 minutos con 300K registros)
mysql -u root -p reportes_agua_cdmx < 05_migracion_a_5nf.sql

# ✅ ¡Listo! Ahora puedes ejecutar consultas
```

### Verificar que funcionó:

```sql
mysql -u root -p reportes_agua_cdmx

-- Ver cuántos registros hay
SELECT 
    'clasificacion' AS tabla, COUNT(*) AS total FROM clasificacion
UNION ALL
SELECT 'medio_recepcion', COUNT(*) FROM medio_recepcion
UNION ALL
SELECT 'ubicacion', COUNT(*) FROM ubicacion
UNION ALL
SELECT 'incidente', COUNT(*) FROM incidente
UNION ALL
SELECT 'reporte', COUNT(*) FROM reporte;

-- Deberías ver algo como:
-- clasificacion: 2-5
-- medio_recepcion: 3-10
-- ubicacion: 1000-2000
-- incidente: 100,000-200,000
-- reporte: 300,000+
```

---

## 🔥 Opción 2: Base de Datos + API (5 minutos)

### Paso 1: Base de Datos (igual que arriba)

```bash
mysql -u root -p -e "CREATE DATABASE reportes_agua_cdmx CHARACTER SET utf8mb4;"
mysql -u root -p reportes_agua_cdmx < 04_schema_5nf.sql
mysql -u root -p reportes_agua_cdmx < 05_migracion_a_5nf.sql
```

### Paso 2: Configurar la API

```bash
# Navegar a carpeta api
cd api

# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar dependencias (~30 segundos)
pip install -r requirements.txt
```

### Paso 3: Configurar Credenciales

```bash
# Windows:
copy env.example .env

# Linux/Mac:
cp env.example .env

# Editar .env con tus credenciales:
# DB_USER=root
# DB_PASSWORD=tu_password
# DB_HOST=localhost
# DB_PORT=3306
# DB_NAME=reportes_agua_cdmx
```

### Paso 4: Iniciar la API

```bash
python main.py

# Verás:
# INFO:     Uvicorn running on http://0.0.0.0:8000
# INFO:     Application startup complete.
```

### Paso 5: Probar la API

Abre tu navegador en: **http://localhost:8000/docs**

**¡Ahora puedes probar todos los endpoints directamente desde el navegador!**

---

## 🧪 Pruebas Rápidas

### Desde el Navegador (Swagger UI)

1. Ve a http://localhost:8000/docs
2. Expande cualquier endpoint (ej: GET /api/v1/clasificaciones/)
3. Clic en "Try it out"
4. Clic en "Execute"
5. ¡Verás la respuesta!

### Desde la Terminal (curl)

```bash
# Listar clasificaciones
curl http://localhost:8000/api/v1/clasificaciones/

# Crear una ubicación
curl -X POST "http://localhost:8000/api/v1/ubicaciones/" \
  -H "Content-Type: application/json" \
  -d '{
    "colonia_catalogo": "Roma Norte",
    "alcaldia_catalogo": "Cuauhtémoc",
    "longitud": -99.1627,
    "latitud": 19.4186,
    "activo": true
  }'

# Obtener incidentes
curl "http://localhost:8000/api/v1/incidentes/?limit=10"
```

### Desde Python

```python
import requests

# Obtener clasificaciones
response = requests.get("http://localhost:8000/api/v1/clasificaciones/")
print(response.json())

# Obtener incidentes filtrados
response = requests.get(
    "http://localhost:8000/api/v1/incidentes/",
    params={"clasificacion_id": 1, "limit": 5}
)
print(response.json())
```

---

## 📊 Consultas de Análisis Rápido

```sql
-- 1. Top 10 colonias con más incidentes
SELECT 
    u.colonia_catalogo,
    u.alcaldia_catalogo,
    COUNT(i.id_incidente) AS total_incidentes
FROM ubicacion u
INNER JOIN incidente i ON u.id_colonia = i.id_colonia
GROUP BY u.id_colonia
ORDER BY total_incidentes DESC
LIMIT 10;

-- 2. Reportes por mes
SELECT 
    DATE_FORMAT(fecha_reporte, '%Y-%m') AS mes,
    COUNT(*) AS total_reportes
FROM reporte
GROUP BY mes
ORDER BY mes;

-- 3. Distribución por clasificación
SELECT 
    c.nombre_clasificacion,
    COUNT(i.id_incidente) AS total_incidentes
FROM clasificacion c
LEFT JOIN incidente i ON c.id_clasificacion = i.id_clasificacion
GROUP BY c.id_clasificacion
ORDER BY total_incidentes DESC;
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Access denied for user"
**Solución:** Verifica tu contraseña de MySQL y edita el archivo `.env`

### Error: "Unknown database"
**Solución:** Crear la base de datos primero:
```bash
mysql -u root -p -e "CREATE DATABASE reportes_agua_cdmx;"
```

### Error: "Table doesn't exist"
**Solución:** Ejecutar el schema:
```bash
mysql -u root -p reportes_agua_cdmx < 04_schema_5nf.sql
```

### API no inicia
**Solución:** Asegúrate de estar en el entorno virtual:
```bash
cd api
venv\Scripts\activate  # Windows
python main.py
```

### Importar el CSV manualmente
Si `05_migracion_a_5nf.sql` falla, usar MySQL Workbench:
1. Clic derecho en tabla `reportes_agua_raw`
2. "Table Data Import Wizard"
3. Seleccionar `reportes_agua_2024_01.csv`
4. Siguiente → Siguiente → Importar

---

## 📚 Siguientes Pasos

Una vez que todo funciona:

1. **Explorar análisis avanzados:**
   ```bash
   mysql -u root -p reportes_agua_cdmx < 07_analisis_avanzado.sql
   ```

2. **Leer resultados interpretados:**
   - Abrir `ANALISIS_RESULTADOS.md`

3. **Entender el diseño:**
   - Abrir `diagrama_er_5nf.md`

4. **Documentación completa:**
   - `README.md` - Documentación principal
   - `GUIA_IMPLEMENTACION.md` - Guía detallada
   - `api/README_API.md` - Documentación de la API

---

## ✅ Checklist de Verificación

- [ ] MySQL está corriendo
- [ ] Base de datos `reportes_agua_cdmx` creada
- [ ] Schema 5NF ejecutado (5 tablas creadas)
- [ ] Datos migrados (300K+ reportes cargados)
- [ ] (Opcional) API iniciada en http://localhost:8000
- [ ] (Opcional) Swagger UI accesible en /docs

---

## 🎯 Tiempo Estimado por Tarea

| Tarea | Tiempo |
|-------|--------|
| Crear schema | 5 segundos |
| Migrar datos (300K registros) | 2-5 minutos |
| Instalar API (pip install) | 30 segundos |
| Configurar .env | 30 segundos |
| Iniciar API | 5 segundos |
| **Total (Base de Datos)** | **~3 minutos** |
| **Total (Base de Datos + API)** | **~5 minutos** |

---

## 📞 Ayuda

Si tienes problemas:

1. **Revisa:** `GUIA_IMPLEMENTACION.md` - Sección "Solución de Problemas"
2. **Verifica logs de MySQL:** 
   - Windows: Event Viewer
   - Linux: `/var/log/mysql/error.log`
3. **API logs:** Revisa la terminal donde ejecutaste `python main.py`

---

**¡Listo para empezar!** 🚀

Ejecuta los comandos y en menos de 5 minutos tendrás:
- ✅ Base de datos normalizada en 5NF
- ✅ 300,000+ reportes cargados
- ✅ API REST funcionando
- ✅ Documentación interactiva en Swagger

**Siguiente:** Abre http://localhost:8000/docs y empieza a explorar 🎉

