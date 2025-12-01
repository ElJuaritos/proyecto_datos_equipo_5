"""
Schemas de Pydantic para validación y serialización de datos
Define los modelos de entrada/salida de la API
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
# UBICACION
# =====================================================

class UbicacionBase(BaseModel):
    """Schema base para Ubicacion"""
    colonia_catalogo: str = Field(..., max_length=255, description="Nombre de la colonia")
    alcaldia_catalogo: str = Field(..., max_length=100, description="Nombre de la alcaldía")
    longitud: Optional[Decimal] = Field(None, description="Coordenada de longitud")
    latitud: Optional[Decimal] = Field(None, description="Coordenada de latitud")
    activo: bool = Field(True, description="Estado activo/inactivo")

    @validator('longitud')
    def validar_longitud(cls, v):
        """Validar que la longitud esté en rango válido para CDMX"""
        if v is not None and not (-99.4 <= float(v) <= -98.9):
            raise ValueError('Longitud fuera del rango válido para CDMX (-99.4 a -98.9)')
        return v

    @validator('latitud')
    def validar_latitud(cls, v):
        """Validar que la latitud esté en rango válido para CDMX"""
        if v is not None and not (19.0 <= float(v) <= 19.6):
            raise ValueError('Latitud fuera del rango válido para CDMX (19.0 a 19.6)')
        return v


class UbicacionCreate(UbicacionBase):
    """Schema para crear Ubicacion"""
    pass


class UbicacionUpdate(BaseModel):
    """Schema para actualizar Ubicacion"""
    colonia_catalogo: Optional[str] = Field(None, max_length=255)
    alcaldia_catalogo: Optional[str] = Field(None, max_length=100)
    longitud: Optional[Decimal] = None
    latitud: Optional[Decimal] = None
    activo: Optional[bool] = None


class UbicacionResponse(UbicacionBase):
    """Schema de respuesta para Ubicacion"""
    id_colonia: int
    fecha_creacion: datetime

    class Config:
        from_attributes = True


# =====================================================
# INCIDENTE
# =====================================================

class IncidenteBase(BaseModel):
    """Schema base para Incidente"""
    folio_incidente: str = Field(..., max_length=50, description="Folio único del incidente")
    fecha_registro_incidente: date = Field(..., description="Fecha de registro oficial")
    reporte: str = Field(..., max_length=500, description="Descripción del incidente")
    id_clasificacion: int = Field(..., description="ID de la clasificación")
    id_colonia: Optional[int] = Field(None, description="ID de la colonia")
    estado: str = Field("Registrado", max_length=50, description="Estado del incidente")


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
    estado: Optional[str] = Field(None, max_length=50)


class IncidenteResponse(IncidenteBase):
    """Schema de respuesta para Incidente"""
    id_incidente: int
    fecha_creacion: datetime
    fecha_actualizacion: datetime
    clasificacion: Optional[ClasificacionResponse] = None
    ubicacion: Optional[UbicacionResponse] = None

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

