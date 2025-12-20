"""
Router para endpoints de Alcaldia
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
    prefix="/alcaldias",
    tags=["Alcaldías"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.AlcaldiaResponse, status_code=status.HTTP_201_CREATED)
def crear_alcaldia(
    alcaldia: schemas.AlcaldiaCreate,
    db: Session = Depends(get_db)
):
    """
    Crear una nueva alcaldía
    
    - **nombre_alcaldia**: Nombre único de la alcaldía (ej: "Benito Juárez", "Coyoacán")
    - **codigo_alcaldia**: Código corto opcional (ej: "BJ", "COY")
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_alcaldia(db=db, alcaldia=alcaldia)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear alcaldía: {str(e)}"
        )


@router.get("/", response_model=List[schemas.AlcaldiaResponse])
def listar_alcaldias(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todas las alcaldías
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    """
    alcaldias = crud.get_alcaldias(db, skip=skip, limit=limit)
    return alcaldias


@router.get("/{alcaldia_id}", response_model=schemas.AlcaldiaResponse)
def obtener_alcaldia(
    alcaldia_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener una alcaldía específica por ID
    """
    db_alcaldia = crud.get_alcaldia(db, alcaldia_id=alcaldia_id)
    if db_alcaldia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alcaldía con ID {alcaldia_id} no encontrada"
        )
    return db_alcaldia


@router.put("/{alcaldia_id}", response_model=schemas.AlcaldiaResponse)
def actualizar_alcaldia(
    alcaldia_id: int,
    alcaldia: schemas.AlcaldiaUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar una alcaldía existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_alcaldia = crud.update_alcaldia(
        db, 
        alcaldia_id=alcaldia_id, 
        alcaldia=alcaldia
    )
    if db_alcaldia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alcaldía con ID {alcaldia_id} no encontrada"
        )
    return db_alcaldia


@router.delete("/{alcaldia_id}", response_model=schemas.MessageResponse)
def eliminar_alcaldia(
    alcaldia_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar una alcaldía
    
    **Nota**: No se puede eliminar si tiene colonias asociadas (restricción FK)
    """
    success = crud.delete_alcaldia(db, alcaldia_id=alcaldia_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alcaldía con ID {alcaldia_id} no encontrada"
        )
    return schemas.MessageResponse(
        message="Alcaldía eliminada exitosamente",
        detail=f"ID: {alcaldia_id}"
    )

