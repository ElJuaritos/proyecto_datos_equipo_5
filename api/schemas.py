"""
Schemas de Pydantic para validación y serialización de datos
Define los modelos de entrada/salida de la API
VERSIÓN MEJORADA con Alcaldia y EstadoIncidente
"""

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import date, time, datetime
from decimal import Decimal


# =====================================================
# CLASIFICACION
# =====================================================

class ClasificacionBase(BaseModel):
    """Schema base para Clasificacion"""
    nombre_clasificacion: str = Field(..., max_length=100, description="Nombre de la clasificación")
    descripcion: Optional[str] = Field(None, max_length=255, description="Descripción opcional")
    activo: bool = Field(True, description="Estado activo/inactivo")


class ClasificacionCreate(ClasificacionBase):
    """Schema para crear Clasificacion"""
    pass


class ClasificacionUpdate(BaseModel):
    """Schema para actualizar Clasificacion"""
    nombre_clasificacion: Optional[str] = Field(None, max_length=100)
    descripcion: Optional[str] = Field(None, max_length=255)
    activo: Optional[bool] = None


class ClasificacionResponse(ClasificacionBase):
    """Schema de respuesta para Clasificacion"""
    id_clasificacion: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True


# =====================================================
# MEDIO_RECEPCION
# =====================================================

class MedioRecepcionBase(BaseModel):
    """Schema base para MedioRecepcion"""
    nombre_medio: str = Field(..., max_length=100, description="Nombre del medio de recepción")
    descripcion: Optional[str] = Field(None, max_length=255, description="Descripción opcional")
    activo: bool = Field(True, description="Estado activo/inactivo")


class MedioRecepcionCreate(MedioRecepcionBase):
    """Schema para crear MedioRecepcion"""
    pass


class MedioRecepcionUpdate(BaseModel):
    """Schema para actualizar MedioRecepcion"""
    nombre_medio: Optional[str] = Field(None, max_length=100)
    descripcion: Optional[str] = Field(None, max_length=255)
    activo: Optional[bool] = None


class MedioRecepcionResponse(MedioRecepcionBase):
    """Schema de respuesta para MedioRecepcion"""
    id_medio_recepcion: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True


# =====================================================
# ALCALDIA (NUEVO)
# =====================================================

class AlcaldiaBase(BaseModel):
    """Schema base para Alcaldia"""
    nombre_alcaldia: str = Field(..., max_length=100, description="Nombre de la alcaldía")
    codigo_alcaldia: Optional[str] = Field(None, max_length=10, description="Código corto de la alcaldía")
    activo: bool = Field(True, description="Estado activo/inactivo")


class AlcaldiaCreate(AlcaldiaBase):
    """Schema para crear Alcaldia"""
    pass


class AlcaldiaUpdate(BaseModel):
    """Schema para actualizar Alcaldia"""
    nombre_alcaldia: Optional[str] = Field(None, max_length=100)
    codigo_alcaldia: Optional[str] = Field(None, max_length=10)
    activo: Optional[bool] = None


class AlcaldiaResponse(AlcaldiaBase):
    """Schema de respuesta para Alcaldia"""
    id_alcaldia: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True


# =====================================================
# ESTADO_INCIDENTE (NUEVO)
# =====================================================

class EstadoIncidenteBase(BaseModel):
    """Schema base para EstadoIncidente"""
    nombre_estado: str = Field(..., max_length=50, description="Nombre del estado")
    descripcion: Optional[str] = Field(None, max_length=255, description="Descripción del estado")
    orden: Optional[int] = Field(None, description="Orden del estado en el flujo")
    activo: bool = Field(True, description="Estado activo/inactivo")


class EstadoIncidenteCreate(EstadoIncidenteBase):
    """Schema para crear EstadoIncidente"""
    pass


class EstadoIncidenteUpdate(BaseModel):
    """Schema para actualizar EstadoIncidente"""
    nombre_estado: Optional[str] = Field(None, max_length=50)
    descripcion: Optional[str] = Field(None, max_length=255)
    orden: Optional[int] = None
    activo: Optional[bool] = None


class EstadoIncidenteResponse(EstadoIncidenteBase):
    """Schema de respuesta para EstadoIncidente"""
    id_estado: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True


# =====================================================
# COLONIA (REFACTORIZADA - antes: Ubicacion)
# =====================================================

class ColoniaBase(BaseModel):
    """Schema base para Colonia"""
    nombre_colonia: str = Field(..., max_length=255, description="Nombre de la colonia")
    id_alcaldia: int = Field(..., description="ID de la alcaldía a la que pertenece")
    codigo_postal: Optional[str] = Field(None, max_length=5, description="Código postal")
    centroide_longitud: Optional[Decimal] = Field(None, description="Coordenada del centro geográfico de la colonia")
    centroide_latitud: Optional[Decimal] = Field(None, description="Coordenada del centro geográfico de la colonia")
    activo: bool = Field(True, description="Estado activo/inactivo")

    @validator('centroide_longitud')
    def validar_centroide_longitud(cls, v):
        """Validar que la longitud esté en rango válido para CDMX"""
        if v is not None and not (-99.4 <= float(v) <= -98.9):
            raise ValueError('Longitud fuera del rango válido para CDMX (-99.4 a -98.9)')
        return v

    @validator('centroide_latitud')
    def validar_centroide_latitud(cls, v):
        """Validar que la latitud esté en rango válido para CDMX"""
        if v is not None and not (19.0 <= float(v) <= 19.6):
            raise ValueError('Latitud fuera del rango válido para CDMX (19.0 a 19.6)')
        return v


class ColoniaCreate(ColoniaBase):
    """Schema para crear Colonia"""
    pass


class ColoniaUpdate(BaseModel):
    """Schema para actualizar Colonia"""
    nombre_colonia: Optional[str] = Field(None, max_length=255)
    id_alcaldia: Optional[int] = None
    codigo_postal: Optional[str] = Field(None, max_length=5)
    centroide_longitud: Optional[Decimal] = None
    centroide_latitud: Optional[Decimal] = None
    activo: Optional[bool] = None


class ColoniaResponse(ColoniaBase):
    """Schema de respuesta para Colonia"""
    id_colonia: int
    fecha_creacion: datetime
    alcaldia: Optional[AlcaldiaResponse] = None

    class Config:
        from_attributes = True


# =====================================================
# INCIDENTE (MEJORADO)
# =====================================================

class IncidenteBase(BaseModel):
    """Schema base para Incidente"""
    folio_incidente: str = Field(..., max_length=50, description="Folio único del incidente")
    fecha_registro_incidente: date = Field(..., description="Fecha de registro oficial")
    reporte: str = Field(..., max_length=500, description="Descripción del incidente")
    id_clasificacion: int = Field(..., description="ID de la clasificación")
    id_colonia: Optional[int] = Field(None, description="ID de la colonia")
    id_estado: int = Field(1, description="ID del estado del incidente")
    longitud_incidente: Optional[Decimal] = Field(None, description="Coordenada exacta del incidente")
    latitud_incidente: Optional[Decimal] = Field(None, description="Coordenada exacta del incidente")

    @validator('longitud_incidente')
    def validar_longitud_incidente(cls, v):
        """Validar que la longitud esté en rango válido para CDMX"""
        if v is not None and not (-99.4 <= float(v) <= -98.9):
            raise ValueError('Longitud fuera del rango válido para CDMX (-99.4 a -98.9)')
        return v

    @validator('latitud_incidente')
    def validar_latitud_incidente(cls, v):
        """Validar que la latitud esté en rango válido para CDMX"""
        if v is not None and not (19.0 <= float(v) <= 19.6):
            raise ValueError('Latitud fuera del rango válido para CDMX (19.0 a 19.6)')
        return v


class IncidenteCreate(IncidenteBase):
    """Schema para crear Incidente"""
    pass


class IncidenteUpdate(BaseModel):
    """Schema para actualizar Incidente"""
    folio_incidente: Optional[str] = Field(None, max_length=50)
    fecha_registro_incidente: Optional[date] = None
    reporte: Optional[str] = Field(None, max_length=500)
    id_clasificacion: Optional[int] = None
    id_colonia: Optional[int] = None
    id_estado: Optional[int] = None
    longitud_incidente: Optional[Decimal] = None
    latitud_incidente: Optional[Decimal] = None


class IncidenteResponse(IncidenteBase):
    """Schema de respuesta para Incidente"""
    id_incidente: int
    fecha_creacion: datetime
    fecha_actualizacion: datetime
    clasificacion: Optional[ClasificacionResponse] = None
    colonia: Optional[ColoniaResponse] = None
    estado: Optional[EstadoIncidenteResponse] = None

    class Config:
        from_attributes = True


# =====================================================
# REPORTE
# =====================================================

class ReporteBase(BaseModel):
    """Schema base para Reporte"""
    id_reporte: str = Field(..., max_length=50, description="ID único del reporte")
    id_incidente: int = Field(..., description="ID del incidente asociado")
    fecha_reporte: date = Field(..., description="Fecha del reporte")
    hora_reporte: time = Field(..., description="Hora del reporte")
    id_medio_recepcion: int = Field(..., description="ID del medio de recepción")


class ReporteCreate(ReporteBase):
    """Schema para crear Reporte"""
    pass


class ReporteUpdate(BaseModel):
    """Schema para actualizar Reporte"""
    id_reporte: Optional[str] = Field(None, max_length=50)
    id_incidente: Optional[int] = None
    fecha_reporte: Optional[date] = None
    hora_reporte: Optional[time] = None
    id_medio_recepcion: Optional[int] = None


class ReporteResponse(ReporteBase):
    """Schema de respuesta para Reporte"""
    id_reporte_pk: int
    fecha_creacion: datetime
    incidente: Optional[IncidenteResponse] = None
    medio_recepcion: Optional[MedioRecepcionResponse] = None

    class Config:
        from_attributes = True


# =====================================================
# RESPUESTAS GENÉRICAS
# =====================================================

class MessageResponse(BaseModel):
    """Respuesta genérica con mensaje"""
    message: str
    detail: Optional[str] = None


class PaginatedResponse(BaseModel):
    """Respuesta paginada genérica"""
    total: int
    page: int
    page_size: int
    items: List[BaseModel]
