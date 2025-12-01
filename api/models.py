"""
Modelos de SQLAlchemy para las tablas de la base de datos
Corresponden al schema 5NF definido en 04_schema_5nf.sql
"""

from sqlalchemy import Column, Integer, String, Date, Time, ForeignKey, DECIMAL, Boolean, TIMESTAMP, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class Clasificacion(Base):
    """Catálogo de tipos de incidentes"""
    __tablename__ = "clasificacion"

    id_clasificacion = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre_clasificacion = Column(String(100), unique=True, nullable=False, index=True)
    descripcion = Column(String(255), nullable=True)
    activo = Column(Boolean, default=True)
    fecha_creacion = Column(TIMESTAMP, server_default=func.current_timestamp())

    # Relación con incidentes
    incidentes = relationship("Incidente", back_populates="clasificacion")


class MedioRecepcion(Base):
    """Catálogo de canales de recepción de reportes"""
    __tablename__ = "medio_recepcion"

    id_medio_recepcion = Column(Integer, primary_key=True, index=True, autoincrement=True)
    nombre_medio = Column(String(100), unique=True, nullable=False, index=True)
    descripcion = Column(String(255), nullable=True)
    activo = Column(Boolean, default=True)
    fecha_creacion = Column(TIMESTAMP, server_default=func.current_timestamp())

    # Relación con reportes
    reportes = relationship("Reporte", back_populates="medio_recepcion")


class Ubicacion(Base):
    """Datos geográficos: colonias, alcaldías y coordenadas"""
    __tablename__ = "ubicacion"

    id_colonia = Column(Integer, primary_key=True, index=True, autoincrement=True)
    colonia_catalogo = Column(String(255), unique=True, nullable=False)
    alcaldia_catalogo = Column(String(100), nullable=False, index=True)
    longitud = Column(DECIMAL(11, 8), nullable=True)
    latitud = Column(DECIMAL(11, 8), nullable=True)
    activo = Column(Boolean, default=True)
    fecha_creacion = Column(TIMESTAMP, server_default=func.current_timestamp())

    # Relación con incidentes
    incidentes = relationship("Incidente", back_populates="ubicacion")


class Incidente(Base):
    """Entidad principal de incidentes/eventos reportados"""
    __tablename__ = "incidente"

    id_incidente = Column(Integer, primary_key=True, index=True, autoincrement=True)
    folio_incidente = Column(String(50), unique=True, nullable=False, index=True)
    fecha_registro_incidente = Column(Date, nullable=False, index=True)
    reporte = Column(String(500), nullable=False)
    id_clasificacion = Column(Integer, ForeignKey("clasificacion.id_clasificacion"), nullable=False, index=True)
    id_colonia = Column(Integer, ForeignKey("ubicacion.id_colonia"), nullable=True, index=True)
    estado = Column(String(50), default="Registrado", index=True)
    fecha_creacion = Column(TIMESTAMP, server_default=func.current_timestamp(), index=True)
    fecha_actualizacion = Column(TIMESTAMP, server_default=func.current_timestamp(), onupdate=func.current_timestamp())

    # Relaciones
    clasificacion = relationship("Clasificacion", back_populates="incidentes")
    ubicacion = relationship("Ubicacion", back_populates="incidentes")
    reportes = relationship("Reporte", back_populates="incidente", cascade="all, delete-orphan")


class Reporte(Base):
    """Registros individuales de notificaciones/llamadas"""
    __tablename__ = "reporte"

    id_reporte_pk = Column(Integer, primary_key=True, index=True, autoincrement=True)
    id_reporte = Column(String(50), unique=True, nullable=False, index=True)
    id_incidente = Column(Integer, ForeignKey("incidente.id_incidente"), nullable=False, index=True)
    fecha_reporte = Column(Date, nullable=False, index=True)
    hora_reporte = Column(Time, nullable=False)
    id_medio_recepcion = Column(Integer, ForeignKey("medio_recepcion.id_medio_recepcion"), nullable=False, index=True)
    fecha_creacion = Column(TIMESTAMP, server_default=func.current_timestamp())

    # Relaciones
    incidente = relationship("Incidente", back_populates="reportes")
    medio_recepcion = relationship("MedioRecepcion", back_populates="reportes")

