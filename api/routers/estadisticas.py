"""
Router para endpoints de Estadísticas y Análisis
Proporciona métricas, dashboards y análisis temporal
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
from datetime import date
import crud
import schemas
from database import get_db

router = APIRouter(
    prefix="/estadisticas",
    tags=["Estadísticas"],
    responses={404: {"description": "No encontrado"}}
)


@router.get("/dashboard", response_model=schemas.DashboardResponse)
def obtener_dashboard(db: Session = Depends(get_db)):
    """
    **Dashboard General del Sistema**
    
    Retorna una visión completa del estado del sistema:
    - Totales generales (incidentes, reportes, colonias, alcaldías)
    - Distribución de incidentes por estado
    - Distribución de incidentes por clasificación
    - Distribución de reportes por medio de recepción
    - Top 10 alcaldías con más incidentes
    - Promedio de reportes por incidente
    
    **Caso de uso:** Pantalla principal de administración para supervisores
    """
    try:
        stats = crud.get_dashboard_stats(db)
        return stats
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error al obtener estadísticas: {str(e)}"
        )


@router.get("/alcaldia/{alcaldia_id}", response_model=schemas.EstadisticasAlcaldiaResponse)
def obtener_estadisticas_alcaldia(
    alcaldia_id: int,
    db: Session = Depends(get_db)
):
    """
    **Estadísticas Detalladas por Alcaldía**
    
    Retorna análisis completo de una alcaldía específica:
    - Información básica de la alcaldía
    - Total de incidentes en la alcaldía
    - Total de colonias
    - Top 5 clasificaciones más comunes
    - Distribución de estados actuales
    - Top 10 colonias más afectadas
    
    **Caso de uso:** Análisis zonal para planificación de recursos
    """
    stats = crud.get_estadisticas_alcaldia(db, alcaldia_id)
    if stats is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Alcaldía con ID {alcaldia_id} no encontrada"
        )
    return stats


@router.get("/temporal", response_model=schemas.AnalisisTemporalResponse)
def obtener_analisis_temporal(
    fecha_inicio: str = Query(..., description="Fecha inicial (formato: YYYY-MM-DD)", example="2024-01-01"),
    fecha_fin: str = Query(..., description="Fecha final (formato: YYYY-MM-DD)", example="2024-12-31"),
    agrupacion: str = Query("mes", description="Tipo de agrupación: dia, semana, mes", enum=["dia", "semana", "mes"]),
    db: Session = Depends(get_db)
):
    """
    **Análisis Temporal de Incidentes**
    
    Retorna serie temporal de incidentes agrupados por:
    - **día**: Cada punto es un día específico
    - **semana**: Agrupado por semana del año (formato: YYYY-WXX)
    - **mes**: Agrupado por mes (formato: YYYY-MM)
    
    **Incluye:**
    - Serie temporal completa
    - Total de incidentes en el período
    - Fechas de inicio y fin
    
    **Casos de uso:**
    - Identificar tendencias temporales
    - Detectar picos de actividad
    - Planificación de recursos
    - Análisis comparativo entre períodos
    """
    try:
        analisis = crud.get_analisis_temporal(
            db,
            fecha_inicio=fecha_inicio,
            fecha_fin=fecha_fin,
            agrupacion=agrupacion
        )
        return analisis
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error en parámetros: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error al realizar análisis temporal: {str(e)}"
        )


@router.get("/zonas-criticas")
def obtener_zonas_criticas(
    limit: int = Query(10, description="Número de zonas a retornar", ge=1, le=50),
    clasificacion_id: Optional[int] = Query(None, description="Filtrar por clasificación específica"),
    db: Session = Depends(get_db)
):
    """
    **Ranking de Zonas Críticas**
    
    Retorna las colonias con mayor cantidad de incidentes.
    
    - Opcionalmente filtrar por tipo de clasificación
    - Incluye información de alcaldía para cada colonia
    - Ordenado de mayor a menor cantidad de incidentes
    
    **Casos de uso:**
    - Identificar áreas de atención prioritaria
    - Asignación de recursos a zonas críticas
    - Planificación de mantenimiento preventivo
    """
    from sqlalchemy import func
    import models
    
    query = db.query(
        models.Colonia.id_colonia,
        models.Colonia.nombre_colonia,
        models.Alcaldia.nombre_alcaldia,
        func.count(models.Incidente.id_incidente).label('total_incidentes')
    ).join(
        models.Alcaldia, models.Colonia.id_alcaldia == models.Alcaldia.id_alcaldia
    ).join(
        models.Incidente, models.Colonia.id_colonia == models.Incidente.id_colonia
    )
    
    if clasificacion_id:
        query = query.filter(models.Incidente.id_clasificacion == clasificacion_id)
    
    resultados = query.group_by(
        models.Colonia.id_colonia,
        models.Colonia.nombre_colonia,
        models.Alcaldia.nombre_alcaldia
    ).order_by(func.count(models.Incidente.id_incidente).desc()).limit(limit).all()
    
    return {
        "total_zonas": len(resultados),
        "zonas": [
            {
                "id_colonia": r.id_colonia,
                "nombre_colonia": r.nombre_colonia,
                "alcaldia": r.nombre_alcaldia,
                "total_incidentes": r.total_incidentes
            }
            for r in resultados
        ]
    }

