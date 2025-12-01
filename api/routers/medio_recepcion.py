"""
Router para endpoints de MedioRecepcion
Operaciones CRUD: Create, Read, Update, Delete
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/medios-recepcion",
    tags=["Medios de Recepción"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.MedioRecepcionResponse, status_code=status.HTTP_201_CREATED)
def crear_medio_recepcion(
    medio: schemas.MedioRecepcionCreate,
    db: Session = Depends(get_db)
):
    """
    Crear un nuevo medio de recepción
    
    - **nombre_medio**: Nombre único del canal (ej: "Call Center", "App Móvil")
    - **descripcion**: Descripción opcional
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_medio_recepcion(db=db, medio=medio)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear medio de recepción: {str(e)}"
        )


@router.get("/", response_model=List[schemas.MedioRecepcionResponse])
def listar_medios_recepcion(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todos los medios de recepción
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    """
    medios = crud.get_medios_recepcion(db, skip=skip, limit=limit)
    return medios


@router.get("/{medio_id}", response_model=schemas.MedioRecepcionResponse)
def obtener_medio_recepcion(
    medio_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener un medio de recepción específico por ID
    """
    db_medio = crud.get_medio_recepcion(db, medio_id=medio_id)
    if db_medio is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Medio de recepción con ID {medio_id} no encontrado"
        )
    return db_medio


@router.put("/{medio_id}", response_model=schemas.MedioRecepcionResponse)
def actualizar_medio_recepcion(
    medio_id: int,
    medio: schemas.MedioRecepcionUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar un medio de recepción existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_medio = crud.update_medio_recepcion(db, medio_id=medio_id, medio=medio)
    if db_medio is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Medio de recepción con ID {medio_id} no encontrado"
        )
    return db_medio


@router.delete("/{medio_id}", response_model=schemas.MessageResponse)
def eliminar_medio_recepcion(
    medio_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar un medio de recepción
    
    **Nota**: No se puede eliminar si tiene reportes asociados (restricción FK)
    """
    success = crud.delete_medio_recepcion(db, medio_id=medio_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Medio de recepción con ID {medio_id} no encontrado"
        )
    return schemas.MessageResponse(
        message="Medio de recepción eliminado exitosamente",
        detail=f"ID: {medio_id}"
    )

