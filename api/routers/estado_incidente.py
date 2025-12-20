"""
Router para endpoints de EstadoIncidente
Operaciones CRUD: Create, Read, Update, Delete
NUEVO - Parte de la normalización 5NF mejorada
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/estados-incidente",
    tags=["Estados de Incidente"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.EstadoIncidenteResponse, status_code=status.HTTP_201_CREATED)
def crear_estado_incidente(
    estado: schemas.EstadoIncidenteCreate,
    db: Session = Depends(get_db)
):
    """
    Crear un nuevo estado de incidente
    
    - **nombre_estado**: Nombre único del estado (ej: "Registrado", "En Atención")
    - **descripcion**: Descripción del estado
    - **orden**: Orden del estado en el flujo (para ordenamiento)
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_estado_incidente(db=db, estado=estado)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear estado de incidente: {str(e)}"
        )


@router.get("/", response_model=List[schemas.EstadoIncidenteResponse])
def listar_estados_incidente(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todos los estados de incidente
    
    Los estados se devuelven ordenados por el campo 'orden'
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    """
    estados = crud.get_estados_incidente(db, skip=skip, limit=limit)
    return estados


@router.get("/{estado_id}", response_model=schemas.EstadoIncidenteResponse)
def obtener_estado_incidente(
    estado_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener un estado de incidente específico por ID
    """
    db_estado = crud.get_estado_incidente(db, estado_id=estado_id)
    if db_estado is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Estado de incidente con ID {estado_id} no encontrado"
        )
    return db_estado


@router.put("/{estado_id}", response_model=schemas.EstadoIncidenteResponse)
def actualizar_estado_incidente(
    estado_id: int,
    estado: schemas.EstadoIncidenteUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar un estado de incidente existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_estado = crud.update_estado_incidente(
        db, 
        estado_id=estado_id, 
        estado=estado
    )
    if db_estado is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Estado de incidente con ID {estado_id} no encontrado"
        )
    return db_estado


@router.delete("/{estado_id}", response_model=schemas.MessageResponse)
def eliminar_estado_incidente(
    estado_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar un estado de incidente
    
    **Nota**: No se puede eliminar si tiene incidentes asociados (restricción FK)
    """
    success = crud.delete_estado_incidente(db, estado_id=estado_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Estado de incidente con ID {estado_id} no encontrado"
        )
    return schemas.MessageResponse(
        message="Estado de incidente eliminado exitosamente",
        detail=f"ID: {estado_id}"
    )

