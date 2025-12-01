"""
Router para endpoints de Clasificacion
Operaciones CRUD: Create, Read, Update, Delete
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/clasificaciones",
    tags=["Clasificaciones"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.ClasificacionResponse, status_code=status.HTTP_201_CREATED)
def crear_clasificacion(
    clasificacion: schemas.ClasificacionCreate,
    db: Session = Depends(get_db)
):
    """
    Crear una nueva clasificación de incidente
    
    - **nombre_clasificacion**: Nombre único de la clasificación (ej: "Agua Potable", "Drenaje")
    - **descripcion**: Descripción opcional
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_clasificacion(db=db, clasificacion=clasificacion)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear clasificación: {str(e)}"
        )


@router.get("/", response_model=List[schemas.ClasificacionResponse])
def listar_clasificaciones(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todas las clasificaciones
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    """
    clasificaciones = crud.get_clasificaciones(db, skip=skip, limit=limit)
    return clasificaciones


@router.get("/{clasificacion_id}", response_model=schemas.ClasificacionResponse)
def obtener_clasificacion(
    clasificacion_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener una clasificación específica por ID
    """
    db_clasificacion = crud.get_clasificacion(db, clasificacion_id=clasificacion_id)
    if db_clasificacion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Clasificación con ID {clasificacion_id} no encontrada"
        )
    return db_clasificacion


@router.put("/{clasificacion_id}", response_model=schemas.ClasificacionResponse)
def actualizar_clasificacion(
    clasificacion_id: int,
    clasificacion: schemas.ClasificacionUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar una clasificación existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_clasificacion = crud.update_clasificacion(
        db, 
        clasificacion_id=clasificacion_id, 
        clasificacion=clasificacion
    )
    if db_clasificacion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Clasificación con ID {clasificacion_id} no encontrada"
        )
    return db_clasificacion


@router.delete("/{clasificacion_id}", response_model=schemas.MessageResponse)
def eliminar_clasificacion(
    clasificacion_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar una clasificación
    
    **Nota**: No se puede eliminar si tiene incidentes asociados (restricción FK)
    """
    success = crud.delete_clasificacion(db, clasificacion_id=clasificacion_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Clasificación con ID {clasificacion_id} no encontrada"
        )
    return schemas.MessageResponse(
        message="Clasificación eliminada exitosamente",
        detail=f"ID: {clasificacion_id}"
    )

