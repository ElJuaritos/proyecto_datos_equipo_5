"""
Router para endpoints de Colonia
Operaciones CRUD: Create, Read, Update, Delete
REFACTORIZADO - Antes era Ubicacion, ahora con FK a Alcaldia
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/colonias",
    tags=["Colonias"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.ColoniaResponse, status_code=status.HTTP_201_CREATED)
def crear_colonia(
    colonia: schemas.ColoniaCreate,
    db: Session = Depends(get_db)
):
    """
    Crear una nueva colonia
    
    - **nombre_colonia**: Nombre de la colonia
    - **id_alcaldia**: ID de la alcaldía a la que pertenece (FK)
    - **codigo_postal**: Código postal opcional
    - **centroide_longitud**: Coordenada del centro geográfico de la colonia
    - **centroide_latitud**: Coordenada del centro geográfico de la colonia
    - **activo**: Estado activo/inactivo (default: True)
    """
    try:
        return crud.create_colonia(db=db, colonia=colonia)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear colonia: {str(e)}"
        )


@router.get("/", response_model=List[schemas.ColoniaResponse])
def listar_colonias(
    skip: int = 0,
    limit: int = 100,
    alcaldia_id: Optional[int] = Query(None, description="Filtrar por ID de alcaldía"),
    db: Session = Depends(get_db)
):
    """
    Obtener lista de todas las colonias
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    - **alcaldia_id**: Filtrar colonias por alcaldía (opcional)
    """
    colonias = crud.get_colonias(db, skip=skip, limit=limit, alcaldia_id=alcaldia_id)
    return colonias


@router.get("/{colonia_id}", response_model=schemas.ColoniaResponse)
def obtener_colonia(
    colonia_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener una colonia específica por ID
    """
    db_colonia = crud.get_colonia(db, colonia_id=colonia_id)
    if db_colonia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Colonia con ID {colonia_id} no encontrada"
        )
    return db_colonia


@router.put("/{colonia_id}", response_model=schemas.ColoniaResponse)
def actualizar_colonia(
    colonia_id: int,
    colonia: schemas.ColoniaUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar una colonia existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_colonia = crud.update_colonia(
        db, 
        colonia_id=colonia_id, 
        colonia=colonia
    )
    if db_colonia is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Colonia con ID {colonia_id} no encontrada"
        )
    return db_colonia


@router.delete("/{colonia_id}", response_model=schemas.MessageResponse)
def eliminar_colonia(
    colonia_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar una colonia
    
    **Nota**: Si la colonia tiene incidentes asociados, éstos quedarán sin ubicación (FK SET NULL)
    """
    success = crud.delete_colonia(db, colonia_id=colonia_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Colonia con ID {colonia_id} no encontrada"
        )
    return schemas.MessageResponse(
        message="Colonia eliminada exitosamente",
        detail=f"ID: {colonia_id}"
    )

