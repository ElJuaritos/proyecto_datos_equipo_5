"""
Router para endpoints de Incidente
Operaciones CRUD: Create, Read, Update, Delete
MEJORADO - Ahora con estado_id y coordenadas de incidente
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/incidentes",
    tags=["Incidentes"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.IncidenteResponse, status_code=status.HTTP_201_CREATED)
def crear_incidente(
    incidente: schemas.IncidenteCreate,
    db: Session = Depends(get_db)
):
    """
    Crear un nuevo incidente
    
    - **folio_incidente**: Folio único del incidente
    - **fecha_registro_incidente**: Fecha de registro oficial
    - **reporte**: Descripción del incidente
    - **id_clasificacion**: ID de la clasificación del incidente
    - **id_colonia**: ID de la colonia (opcional)
    - **id_estado**: ID del estado del incidente (default: 1 = "Registrado")
    - **longitud_incidente**: Coordenada exacta del punto del incidente
    - **latitud_incidente**: Coordenada exacta del punto del incidente
    """
    # Verificar que no exista el folio
    existing = crud.get_incidente_by_folio(db, incidente.folio_incidente)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Ya existe un incidente con el folio {incidente.folio_incidente}"
        )
    
    try:
        return crud.create_incidente(db=db, incidente=incidente)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear incidente: {str(e)}"
        )


@router.get("/", response_model=List[schemas.IncidenteResponse])
def listar_incidentes(
    skip: int = 0,
    limit: int = 100,
    clasificacion_id: Optional[int] = Query(None, description="Filtrar por clasificación"),
    estado_id: Optional[int] = Query(None, description="Filtrar por estado"),
    alcaldia_id: Optional[int] = Query(None, description="Filtrar por alcaldía"),
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todos los incidentes
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    - **clasificacion_id**: Filtrar por tipo de clasificación (opcional)
    - **estado_id**: Filtrar por estado del incidente (opcional)
    - **alcaldia_id**: Filtrar por alcaldía (opcional)
    """
    incidentes = crud.get_incidentes(
        db, 
        skip=skip, 
        limit=limit, 
        clasificacion_id=clasificacion_id,
        estado_id=estado_id,
        alcaldia_id=alcaldia_id
    )
    return incidentes


@router.get("/folio/{folio}", response_model=schemas.IncidenteResponse)
def obtener_incidente_por_folio(
    folio: str,
    db: Session = Depends(get_db)
):
    """
    Obtener un incidente por su folio único
    
    Útil para búsquedas por folio de incidente (ej: "I-20220101-0001")
    """
    db_incidente = crud.get_incidente_by_folio(db, folio=folio)
    if db_incidente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incidente con folio {folio} no encontrado"
        )
    return db_incidente


@router.get("/{incidente_id}", response_model=schemas.IncidenteResponse)
def obtener_incidente(
    incidente_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener un incidente específico por ID
    """
    db_incidente = crud.get_incidente(db, incidente_id=incidente_id)
    if db_incidente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incidente con ID {incidente_id} no encontrado"
        )
    return db_incidente


@router.put("/{incidente_id}", response_model=schemas.IncidenteResponse)
def actualizar_incidente(
    incidente_id: int,
    incidente: schemas.IncidenteUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar un incidente existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    
    Casos de uso:
    - Actualizar estado: cambiar de "Registrado" a "En Atención"
    - Actualizar ubicación: agregar o corregir colonia
    - Actualizar coordenadas: corregir punto exacto del incidente
    """
    db_incidente = crud.update_incidente(
        db, 
        incidente_id=incidente_id, 
        incidente=incidente
    )
    if db_incidente is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incidente con ID {incidente_id} no encontrado"
        )
    return db_incidente


@router.delete("/{incidente_id}", response_model=schemas.MessageResponse)
def eliminar_incidente(
    incidente_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar un incidente
    
    **Nota**: También eliminará todos los reportes asociados (cascada)
    """
    success = crud.delete_incidente(db, incidente_id=incidente_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incidente con ID {incidente_id} no encontrado"
        )
    return schemas.MessageResponse(
        message="Incidente eliminado exitosamente (incluyendo reportes asociados)",
        detail=f"ID: {incidente_id}"
    )


@router.get("/buscar/por-radio", response_model=List[schemas.IncidenteResponse])
def buscar_incidentes_por_radio(
    longitud: float = Query(..., description="Longitud del punto central", ge=-99.4, le=-98.9),
    latitud: float = Query(..., description="Latitud del punto central", ge=19.0, le=19.6),
    radio_km: float = Query(..., description="Radio de búsqueda en kilómetros", ge=0.1, le=20.0),
    limit: int = Query(100, description="Máximo de resultados", ge=1, le=500),
    db: Session = Depends(get_db)
):
    """
    **Búsqueda de Incidentes por Radio Geográfico**
    
    Encuentra todos los incidentes dentro de un radio específico desde un punto central.
    
    **Parámetros:**
    - **longitud**: Coordenada longitud del centro (-99.4 a -98.9 para CDMX)
    - **latitud**: Coordenada latitud del centro (19.0 a 19.6 para CDMX)
    - **radio_km**: Radio de búsqueda en kilómetros (0.1 a 20.0)
    - **limit**: Máximo de incidentes a retornar (1 a 500)
    
    **Algoritmo:**
    - Usa fórmula de Haversine para calcular distancias exactas
    - Solo incluye incidentes con coordenadas específicas
    - Retorna incidentes ordenados por proximidad
    
    **Casos de uso:**
    - Análisis de incidentes cerca de una ubicación específica
    - Identificar patrones de concentración
    - Planificación de rutas de atención
    - Estudios de proximidad geográfica
    
    **Ejemplo:**
    ```
    GET /incidentes/buscar/por-radio?longitud=-99.15&latitud=19.40&radio_km=2&limit=50
    ```
    """
    try:
        incidentes = crud.buscar_incidentes_por_radio(
            db,
            longitud=longitud,
            latitud=latitud,
            radio_km=radio_km,
            limit=limit
        )
        return incidentes
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en búsqueda geoespacial: {str(e)}"
        )


@router.post("/actualizar-estado-masivo", response_model=schemas.ActualizacionMasivaResponse)
def actualizar_estado_masivo(
    request: schemas.ActualizacionMasivaRequest,
    db: Session = Depends(get_db)
):
    """
    **Actualización Masiva de Estado de Incidentes**
    
    Permite cambiar el estado de múltiples incidentes en una sola operación.
    
    **Request Body:**
    ```json
    {
        "ids_incidentes": [1, 2, 3, 4, 5],
        "nuevo_estado_id": 3
    }
    ```
    
    **Respuesta:**
    - Total de incidentes solicitados
    - Total de incidentes actualizados exitosamente
    - Lista de IDs actualizados
    - Lista de IDs no encontrados (si los hay)
    
    **Casos de uso:**
    - Cerrar múltiples incidentes después de una jornada de atención masiva
    - Actualizar estado de incidentes filtrados previamente
    - Operaciones administrativas batch
    - Sincronización con sistemas externos
    
    **Validaciones:**
    - Verifica que el nuevo estado exista en el catálogo
    - Solo actualiza incidentes que existen en la BD
    - Retorna información detallada de éxitos y fallos
    
    **Ejemplo de uso:**
    1. Obtener lista de incidentes: `GET /incidentes?estado_id=1`
    2. Extraer IDs de los que se quieren cerrar
    3. Ejecutar actualización masiva: `POST /incidentes/actualizar-estado-masivo`
    """
    try:
        resultado = crud.actualizar_estado_masivo(
            db,
            ids_incidentes=request.ids_incidentes,
            nuevo_estado_id=request.nuevo_estado_id
        )
        return resultado
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error en actualización masiva: {str(e)}"
        )
