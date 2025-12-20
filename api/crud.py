"""
Operaciones CRUD (Create, Read, Update, Delete) para todas las entidades
Funciones reutilizables para interactuar con la base de datos
VERSIÓN MEJORADA con Alcaldia y EstadoIncidente
"""

from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List, Optional, Type, TypeVar
import models
import schemas

# Type variable para operaciones genéricas
T = TypeVar('T')


# =====================================================
# OPERACIONES GENÉRICAS
# =====================================================

def get_all(db: Session, model: Type[T], skip: int = 0, limit: int = 100) -> List[T]:
    """Obtener todos los registros de una tabla con paginación"""
    return db.query(model).offset(skip).limit(limit).all()


def get_by_id(db: Session, model: Type[T], id_value: int, id_field: str = "id") -> Optional[T]:
    """Obtener un registro por ID"""
    return db.query(model).filter(getattr(model, id_field) == id_value).first()


def get_count(db: Session, model: Type[T]) -> int:
    """Obtener el conteo total de registros"""
    return db.query(func.count()).select_from(model).scalar()


# =====================================================
# CLASIFICACION CRUD
# =====================================================

def create_clasificacion(db: Session, clasificacion: schemas.ClasificacionCreate) -> models.Clasificacion:
    """Crear una nueva clasificación"""
    db_clasificacion = models.Clasificacion(**clasificacion.dict())
    db.add(db_clasificacion)
    db.commit()
    db.refresh(db_clasificacion)
    return db_clasificacion


def get_clasificacion(db: Session, clasificacion_id: int) -> Optional[models.Clasificacion]:
    """Obtener clasificación por ID"""
    return get_by_id(db, models.Clasificacion, clasificacion_id, "id_clasificacion")


def get_clasificaciones(db: Session, skip: int = 0, limit: int = 100) -> List[models.Clasificacion]:
    """Obtener lista de clasificaciones"""
    return get_all(db, models.Clasificacion, skip, limit)


def update_clasificacion(db: Session, clasificacion_id: int, clasificacion: schemas.ClasificacionUpdate) -> Optional[models.Clasificacion]:
    """Actualizar una clasificación"""
    db_clasificacion = get_clasificacion(db, clasificacion_id)
    if db_clasificacion:
        update_data = clasificacion.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_clasificacion, key, value)
        db.commit()
        db.refresh(db_clasificacion)
    return db_clasificacion


def delete_clasificacion(db: Session, clasificacion_id: int) -> bool:
    """Eliminar una clasificación"""
    db_clasificacion = get_clasificacion(db, clasificacion_id)
    if db_clasificacion:
        db.delete(db_clasificacion)
        db.commit()
        return True
    return False


# =====================================================
# MEDIO_RECEPCION CRUD
# =====================================================

def create_medio_recepcion(db: Session, medio: schemas.MedioRecepcionCreate) -> models.MedioRecepcion:
    """Crear un nuevo medio de recepción"""
    db_medio = models.MedioRecepcion(**medio.dict())
    db.add(db_medio)
    db.commit()
    db.refresh(db_medio)
    return db_medio


def get_medio_recepcion(db: Session, medio_id: int) -> Optional[models.MedioRecepcion]:
    """Obtener medio de recepción por ID"""
    return get_by_id(db, models.MedioRecepcion, medio_id, "id_medio_recepcion")


def get_medios_recepcion(db: Session, skip: int = 0, limit: int = 100) -> List[models.MedioRecepcion]:
    """Obtener lista de medios de recepción"""
    return get_all(db, models.MedioRecepcion, skip, limit)


def update_medio_recepcion(db: Session, medio_id: int, medio: schemas.MedioRecepcionUpdate) -> Optional[models.MedioRecepcion]:
    """Actualizar un medio de recepción"""
    db_medio = get_medio_recepcion(db, medio_id)
    if db_medio:
        update_data = medio.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_medio, key, value)
        db.commit()
        db.refresh(db_medio)
    return db_medio


def delete_medio_recepcion(db: Session, medio_id: int) -> bool:
    """Eliminar un medio de recepción"""
    db_medio = get_medio_recepcion(db, medio_id)
    if db_medio:
        db.delete(db_medio)
        db.commit()
        return True
    return False


# =====================================================
# ALCALDIA CRUD (NUEVO)
# =====================================================

def create_alcaldia(db: Session, alcaldia: schemas.AlcaldiaCreate) -> models.Alcaldia:
    """Crear una nueva alcaldía"""
    db_alcaldia = models.Alcaldia(**alcaldia.dict())
    db.add(db_alcaldia)
    db.commit()
    db.refresh(db_alcaldia)
    return db_alcaldia


def get_alcaldia(db: Session, alcaldia_id: int) -> Optional[models.Alcaldia]:
    """Obtener alcaldía por ID"""
    return get_by_id(db, models.Alcaldia, alcaldia_id, "id_alcaldia")


def get_alcaldias(db: Session, skip: int = 0, limit: int = 100) -> List[models.Alcaldia]:
    """Obtener lista de alcaldías"""
    return get_all(db, models.Alcaldia, skip, limit)


def update_alcaldia(db: Session, alcaldia_id: int, alcaldia: schemas.AlcaldiaUpdate) -> Optional[models.Alcaldia]:
    """Actualizar una alcaldía"""
    db_alcaldia = get_alcaldia(db, alcaldia_id)
    if db_alcaldia:
        update_data = alcaldia.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_alcaldia, key, value)
        db.commit()
        db.refresh(db_alcaldia)
    return db_alcaldia


def delete_alcaldia(db: Session, alcaldia_id: int) -> bool:
    """Eliminar una alcaldía"""
    db_alcaldia = get_alcaldia(db, alcaldia_id)
    if db_alcaldia:
        db.delete(db_alcaldia)
        db.commit()
        return True
    return False


# =====================================================
# ESTADO_INCIDENTE CRUD (NUEVO)
# =====================================================

def create_estado_incidente(db: Session, estado: schemas.EstadoIncidenteCreate) -> models.EstadoIncidente:
    """Crear un nuevo estado de incidente"""
    db_estado = models.EstadoIncidente(**estado.dict())
    db.add(db_estado)
    db.commit()
    db.refresh(db_estado)
    return db_estado


def get_estado_incidente(db: Session, estado_id: int) -> Optional[models.EstadoIncidente]:
    """Obtener estado de incidente por ID"""
    return get_by_id(db, models.EstadoIncidente, estado_id, "id_estado")


def get_estados_incidente(db: Session, skip: int = 0, limit: int = 100) -> List[models.EstadoIncidente]:
    """Obtener lista de estados de incidente"""
    return db.query(models.EstadoIncidente).order_by(models.EstadoIncidente.orden).offset(skip).limit(limit).all()


def update_estado_incidente(db: Session, estado_id: int, estado: schemas.EstadoIncidenteUpdate) -> Optional[models.EstadoIncidente]:
    """Actualizar un estado de incidente"""
    db_estado = get_estado_incidente(db, estado_id)
    if db_estado:
        update_data = estado.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_estado, key, value)
        db.commit()
        db.refresh(db_estado)
    return db_estado


def delete_estado_incidente(db: Session, estado_id: int) -> bool:
    """Eliminar un estado de incidente"""
    db_estado = get_estado_incidente(db, estado_id)
    if db_estado:
        db.delete(db_estado)
        db.commit()
        return True
    return False


# =====================================================
# COLONIA CRUD (REFACTORIZADA - antes: UBICACION)
# =====================================================

def create_colonia(db: Session, colonia: schemas.ColoniaCreate) -> models.Colonia:
    """Crear una nueva colonia"""
    db_colonia = models.Colonia(**colonia.dict())
    db.add(db_colonia)
    db.commit()
    db.refresh(db_colonia)
    return db_colonia


def get_colonia(db: Session, colonia_id: int) -> Optional[models.Colonia]:
    """Obtener colonia por ID"""
    return get_by_id(db, models.Colonia, colonia_id, "id_colonia")


def get_colonias(
    db: Session, 
    skip: int = 0, 
    limit: int = 100, 
    alcaldia_id: Optional[int] = None
) -> List[models.Colonia]:
    """Obtener lista de colonias, opcionalmente filtrada por alcaldía"""
    query = db.query(models.Colonia)
    if alcaldia_id:
        query = query.filter(models.Colonia.id_alcaldia == alcaldia_id)
    return query.offset(skip).limit(limit).all()


def update_colonia(db: Session, colonia_id: int, colonia: schemas.ColoniaUpdate) -> Optional[models.Colonia]:
    """Actualizar una colonia"""
    db_colonia = get_colonia(db, colonia_id)
    if db_colonia:
        update_data = colonia.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_colonia, key, value)
        db.commit()
        db.refresh(db_colonia)
    return db_colonia


def delete_colonia(db: Session, colonia_id: int) -> bool:
    """Eliminar una colonia"""
    db_colonia = get_colonia(db, colonia_id)
    if db_colonia:
        db.delete(db_colonia)
        db.commit()
        return True
    return False


# =====================================================
# INCIDENTE CRUD (MEJORADO)
# =====================================================

def create_incidente(db: Session, incidente: schemas.IncidenteCreate) -> models.Incidente:
    """Crear un nuevo incidente"""
    db_incidente = models.Incidente(**incidente.dict())
    db.add(db_incidente)
    db.commit()
    db.refresh(db_incidente)
    return db_incidente


def get_incidente(db: Session, incidente_id: int) -> Optional[models.Incidente]:
    """Obtener incidente por ID"""
    return get_by_id(db, models.Incidente, incidente_id, "id_incidente")


def get_incidente_by_folio(db: Session, folio: str) -> Optional[models.Incidente]:
    """Obtener incidente por folio"""
    return db.query(models.Incidente).filter(models.Incidente.folio_incidente == folio).first()


def get_incidentes(
    db: Session, 
    skip: int = 0, 
    limit: int = 100,
    clasificacion_id: Optional[int] = None,
    estado_id: Optional[int] = None,
    alcaldia_id: Optional[int] = None
) -> List[models.Incidente]:
    """Obtener lista de incidentes con filtros opcionales"""
    query = db.query(models.Incidente)
    
    if clasificacion_id:
        query = query.filter(models.Incidente.id_clasificacion == clasificacion_id)
    
    if estado_id:
        query = query.filter(models.Incidente.id_estado == estado_id)
    
    if alcaldia_id:
        # Filtrar por alcaldía requiere JOIN con colonia
        query = query.join(models.Colonia).filter(models.Colonia.id_alcaldia == alcaldia_id)
    
    return query.offset(skip).limit(limit).all()


def update_incidente(db: Session, incidente_id: int, incidente: schemas.IncidenteUpdate) -> Optional[models.Incidente]:
    """Actualizar un incidente"""
    db_incidente = get_incidente(db, incidente_id)
    if db_incidente:
        update_data = incidente.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_incidente, key, value)
        db.commit()
        db.refresh(db_incidente)
    return db_incidente


def delete_incidente(db: Session, incidente_id: int) -> bool:
    """Eliminar un incidente (también elimina reportes asociados en cascada)"""
    db_incidente = get_incidente(db, incidente_id)
    if db_incidente:
        db.delete(db_incidente)
        db.commit()
        return True
    return False


# =====================================================
# REPORTE CRUD
# =====================================================

def create_reporte(db: Session, reporte: schemas.ReporteCreate) -> models.Reporte:
    """Crear un nuevo reporte"""
    db_reporte = models.Reporte(**reporte.dict())
    db.add(db_reporte)
    db.commit()
    db.refresh(db_reporte)
    return db_reporte


def get_reporte(db: Session, reporte_id: int) -> Optional[models.Reporte]:
    """Obtener reporte por ID"""
    return get_by_id(db, models.Reporte, reporte_id, "id_reporte_pk")


def get_reporte_by_codigo(db: Session, id_reporte: str) -> Optional[models.Reporte]:
    """Obtener reporte por código de reporte"""
    return db.query(models.Reporte).filter(models.Reporte.id_reporte == id_reporte).first()


def get_reportes(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    incidente_id: Optional[int] = None,
    medio_id: Optional[int] = None
) -> List[models.Reporte]:
    """Obtener lista de reportes con filtros opcionales"""
    query = db.query(models.Reporte)
    if incidente_id:
        query = query.filter(models.Reporte.id_incidente == incidente_id)
    if medio_id:
        query = query.filter(models.Reporte.id_medio_recepcion == medio_id)
    return query.offset(skip).limit(limit).all()


def update_reporte(db: Session, reporte_id: int, reporte: schemas.ReporteUpdate) -> Optional[models.Reporte]:
    """Actualizar un reporte"""
    db_reporte = get_reporte(db, reporte_id)
    if db_reporte:
        update_data = reporte.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_reporte, key, value)
        db.commit()
        db.refresh(db_reporte)
    return db_reporte


def delete_reporte(db: Session, reporte_id: int) -> bool:
    """Eliminar un reporte"""
    db_reporte = get_reporte(db, reporte_id)
    if db_reporte:
        db.delete(db_reporte)
        db.commit()
        return True
    return False
