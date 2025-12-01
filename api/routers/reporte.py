"""
Router para endpoints de Reporte
Operaciones CRUD: Create, Read, Update, Delete
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/reportes",
    tags=["Reportes"],
    responses={404: {"description": "No encontrado"}}
)


@router.post("/", response_model=schemas.ReporteResponse, status_code=status.HTTP_201_CREATED)
def crear_reporte(
    reporte: schemas.ReporteCreate,
    db: Session = Depends(get_db)
):
    """
    Crear un nuevo reporte
    
    - **id_reporte**: Código único del reporte
    - **id_incidente**: ID del incidente asociado
    - **fecha_reporte**: Fecha en que se realizó el reporte
    - **hora_reporte**: Hora en que se realizó el reporte
    - **id_medio_recepcion**: ID del medio por el que se recibió
    """
    # Verificar que no exista el id_reporte
    existing = crud.get_reporte_by_codigo(db, reporte.id_reporte)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Ya existe un reporte con el código {reporte.id_reporte}"
        )
    
    # Verificar que existe el incidente
    incidente = crud.get_incidente(db, reporte.id_incidente)
    if not incidente:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Incidente con ID {reporte.id_incidente} no encontrado"
        )
    
    # Verificar que existe el medio de recepción
    medio = crud.get_medio_recepcion(db, reporte.id_medio_recepcion)
    if not medio:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Medio de recepción con ID {reporte.id_medio_recepcion} no encontrado"
        )
    
    try:
        return crud.create_reporte(db=db, reporte=reporte)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al crear reporte: {str(e)}"
        )


@router.get("/", response_model=List[schemas.ReporteResponse])
def listar_reportes(
    skip: int = 0,
    limit: int = 100,
    incidente_id: Optional[int] = Query(None, description="Filtrar por incidente"),
    medio_id: Optional[int] = Query(None, description="Filtrar por medio de recepción"),
    db: Session = Depends(get_db)
):
    """
    Obtener lista de reportes
    
    - **skip**: Número de registros a saltar (para paginación)
    - **limit**: Número máximo de registros a retornar
    - **incidente_id**: Filtrar por ID de incidente (opcional)
    - **medio_id**: Filtrar por ID de medio de recepción (opcional)
    """
    reportes = crud.get_reportes(
        db,
        skip=skip,
        limit=limit,
        incidente_id=incidente_id,
        medio_id=medio_id
    )
    return reportes


@router.get("/codigo/{id_reporte}", response_model=schemas.ReporteResponse)
def obtener_reporte_por_codigo(
    id_reporte: str,
    db: Session = Depends(get_db)
):
    """
    Obtener un reporte por su código único
    """
    db_reporte = crud.get_reporte_by_codigo(db, id_reporte=id_reporte)
    if db_reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reporte con código {id_reporte} no encontrado"
        )
    return db_reporte


@router.get("/{reporte_id}", response_model=schemas.ReporteResponse)
def obtener_reporte(
    reporte_id: int,
    db: Session = Depends(get_db)
):
    """
    Obtener un reporte específico por ID
    """
    db_reporte = crud.get_reporte(db, reporte_id=reporte_id)
    if db_reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reporte con ID {reporte_id} no encontrado"
        )
    return db_reporte


@router.put("/{reporte_id}", response_model=schemas.ReporteResponse)
def actualizar_reporte(
    reporte_id: int,
    reporte: schemas.ReporteUpdate,
    db: Session = Depends(get_db)
):
    """
    Actualizar un reporte existente
    
    Todos los campos son opcionales. Solo se actualizarán los campos proporcionados.
    """
    db_reporte = crud.update_reporte(db, reporte_id=reporte_id, reporte=reporte)
    if db_reporte is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reporte con ID {reporte_id} no encontrado"
        )
    return db_reporte


@router.delete("/{reporte_id}", response_model=schemas.MessageResponse)
def eliminar_reporte(
    reporte_id: int,
    db: Session = Depends(get_db)
):
    """
    Eliminar un reporte
    """
    success = crud.delete_reporte(db, reporte_id=reporte_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Reporte con ID {reporte_id} no encontrado"
        )
    return schemas.MessageResponse(
        message="Reporte eliminado exitosamente",
        detail=f"ID: {reporte_id}"
    )

