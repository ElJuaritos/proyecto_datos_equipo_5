"""
Paquete de acceso a la capa de persistencia (SQLAlchemy).

Expone la clase base `Base` y las entidades de la base de datos para
mantener una estructura similar a la del proyecto `api-amazon`.
"""

from database import Base  # type: ignore

from .entities import (  # noqa: F401
    Clasificacion,
    MedioRecepcion,
    Ubicacion,
    Incidente,
    Reporte,
)


