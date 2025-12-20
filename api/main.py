"""
Aplicación principal FastAPI
Sistema de Reportes de Agua - CDMX
API RESTful para operaciones CRUD en base de datos normalizada 5NF
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.openapi.utils import get_openapi
import time

# Importar routers
from routers import clasificacion, medio_recepcion, alcaldia, estado_incidente, colonia, incidente, reporte, estadisticas

# Crear aplicación FastAPI
app = FastAPI(
    title="API Reportes de Agua CDMX",
    description="""
    API RESTful para gestión de reportes de agua en la Ciudad de México.
    
    ## Características
    
    * **5 Tablas Normalizadas (5NF)**: Clasificación, Medio Recepción, Ubicación, Incidente, Reporte
    * **Operaciones CRUD completas** para todas las entidades
    * **Validaciones con Pydantic**
    * **Documentación automática** con Swagger y ReDoc
    * **Filtros y paginación** en endpoints de lectura
    * **Integridad referencial** garantizada
    
    ## Entidades
    
    * **Clasificacion**: Catálogo de tipos de incidentes (Agua Potable, Drenaje, etc.)
    * **MedioRecepcion**: Canales de recepción (Call Center, App, Redes Sociales)
    * **Ubicacion**: Datos geográficos (colonias, alcaldías, coordenadas)
    * **Incidente**: Eventos principales reportados
    * **Reporte**: Registros individuales de notificaciones
    
    ## Uso
    
    1. Consulta la documentación interactiva en `/docs`
    2. Prueba los endpoints directamente desde el navegador
    3. Obtén el schema OpenAPI en `/openapi.json`
    
    ## Desarrollado por
    
    - Carlos Emilio Elizalde Hurtado
    - Emilio Juarez Avalos
    - Juan Pablo Medina Esquivel
    
    **Proyecto Final - Bases de Datos**  
    **Fecha:** Diciembre 2025
    """,
    version="1.0.0",
    contact={
        "name": "Equipo 5",
    },
    license_info={
        "name": "MIT",
    },
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar dominios permitidos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Middleware para logging de requests
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Middleware para registrar información de cada request"""
    start_time = time.time()
    
    response = await call_next(request)
    
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    
    return response


# Incluir routers (sin prefijo para endpoints simples)
app.include_router(clasificacion.router)
app.include_router(medio_recepcion.router)
app.include_router(alcaldia.router)
app.include_router(estado_incidente.router)
app.include_router(colonia.router)
app.include_router(incidente.router)
app.include_router(reporte.router)
app.include_router(estadisticas.router)


# Endpoint raíz
@app.get("/", tags=["Root"])
async def root():
    """
    Endpoint raíz con información de la API
    """
    return {
        "message": "API Reportes de Agua CDMX",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc",
        "openapi": "/openapi.json",
        "status": "active",
        "endpoints": {
            "clasificaciones": "/clasificaciones",
            "medios_recepcion": "/medios-recepcion",
            "alcaldias": "/alcaldias",
            "estados_incidente": "/estados-incidente",
            "colonias": "/colonias",
            "incidentes": "/incidentes",
            "reportes": "/reportes",
            "estadisticas": "/estadisticas"
        }
    }


# Endpoint de health check
@app.get("/health", tags=["Health"])
async def health_check():
    """
    Verificar estado de salud de la API
    """
    return {
        "status": "healthy",
        "timestamp": time.time()
    }


# Manejador de errores global
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Manejador global de excepciones no capturadas"""
    return JSONResponse(
        status_code=500,
        content={
            "message": "Error interno del servidor",
            "detail": str(exc),
            "path": str(request.url)
        }
    )


# Personalizar schema OpenAPI
def custom_openapi():
    """Personalizar documentación OpenAPI"""
    if app.openapi_schema:
        return app.openapi_schema
    
    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    
    # Agregar información adicional
    openapi_schema["info"]["x-logo"] = {
        "url": "https://www.cdmx.gob.mx/themes/custom/cdmx/logo.svg"
    }
    
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Hot reload para desarrollo
        log_level="info"
    )

