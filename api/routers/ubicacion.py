"""
Router para endpoints de Ubicacion
Operaciones CRUD: Create, Read, Update, Delete
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/ubicaciones",
    tags=["Ubicaciones"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.UbicacionResponse, status_code=status.HTTP_201_CREATED)
def crear_ubicacion(
    ubicacion: schemas.UbicacionCreate,
    db: Session = Depends(get_db)
):
    """
    Crear una nueva ubicación (colonia)
    
    - **colonia_catalogo**: Nombre único de la colonia
    - **alcaldia_catalogo**: Nombre de la alcaldía
    - **longitud**: Coordenada de longitud (rango válido: -99.4 a -98.9)
    - **latitud**: Coordenada de latitud (rango válido: 19.0 a 19.6)
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_ubicacion(db=db, ubicacion=ubicacion)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear ubicación: {str(e)}"
        )


@router.get("/", response_model=List[schemas.UbicacionResponse])
def listar_ubicaciones(
    skip: int = 0,
    limit: int = 100,
    alcaldia: Optional[str] = Query(None, description="Filtrar por alcaldía"),
    db: Session = Depends(get_db)
):
    """
    Obtener lista de ubicaciones
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    - **alcaldia**: Filtrar por nombre de alcaldía (opcional)
    """
    ubicaciones = crud.get_ubicaciones(db, skip=skip, limit=limit, alcaldia=alcaldia)
    return ubicaciones


@router.get("/{ubicacion_id}", response_model=schemas.UbicacionResponse)
def obtener_ubicacion(
    ubicacion_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener una ubicación específica por ID
    """
    db_ubicacion = crud.get_ubicacion(db, ubicacion_id=ubicacion_id)
    if db_ubicacion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ubicación con ID {ubicacion_id} no encontrada"
        )
    return db_ubicacion


@router.put("/{ubicacion_id}", response_model=schemas.UbicacionResponse)
def actualizar_ubicacion(
    ubicacion_id: int,
    ubicacion: schemas.UbicacionUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar una ubicación existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_ubicacion = crud.update_ubicacion(db, ubicacion_id=ubicacion_id, ubicacion=ubicacion)
    if db_ubicacion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ubicación con ID {ubicacion_id} no encontrada"
        )
    return db_ubicacion


@router.delete("/{ubicacion_id}", response_model=schemas.MessageResponse)
def eliminar_ubicacion(
    ubicacion_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar una ubicación
    
    **Nota**: Los incidentes asociados quedarán con ubicación NULL (SET NULL)
    """
    success = crud.delete_ubicacion(db, ubicacion_id=ubicacion_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Ubicación con ID {ubicacion_id} no encontrada"
        )
    return schemas.MessageResponse(
        message="Ubicación eliminada exitosamente",
        detail=f"ID: {ubicacion_id}"
    )

