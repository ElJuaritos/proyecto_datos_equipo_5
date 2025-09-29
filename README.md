# Proyecto Final - Análisis de contratos gubernamentales en Chicago

## Base de Datos 
**Estudiantes:**
- Carlos Emilio Elizalde Hurtado
- Emilio Juarez Avalos
- Juan Pablo Medina Esquivel

**Fecha de entrega:** 29 de septiembre del 2025

**Área de enfoque:** Contratos del apartado de administración y finanzas

---

## Descripción general de los datos

El dataset recopila información detallada sobre los contratos y sus modificaciones otorgados por la Ciudad de Chicago desde 1993 hasta el presente. Incluye datos de montos adjudicados, contratistas, dependencias, fechas, modificaciones y estado de los contratos.

### ¿Quién los recolecta?
Los datos son recolectados y publicados por el gobierno de la Ciudad de Chicago, específicamente el área de Administración y Finanzas, a través de su portal de datos abiertos.

### ¿Cuál es el propósito de su recolección?
El objetivo principal es garantizar transparencia en el uso de recursos públicos, brindar acceso a información de contrataciones, permitir la supervisión ciudadana, y facilitar investigaciones académicas y auditorías.

### ¿Dónde se pueden obtener?
Están disponibles en el Chicago Data Portal, en la sección de Administración y Finanzas: **Contracts / Contracts and Modifications Awarded by the City of Chicago**

### ¿Con qué frecuencia se actualizan?
El dataset se actualiza diariamente, conforme se adjudican o modifican contratos.

---

## Información técnica del dataset

- **Tuplas (registros):** Aproximadamente 181,000 (181K)
- **Atributos (columnas):** 19

---

## Descripción de atributos

| Atributo | Significado |
|----------|-------------|
| Contract ID | Identificador único del contrato |
| Ordinance/Resolution | Ordenanza o resolución vinculada al contrato |
| Contract Type | Tipo de contrato (servicios, obra, suministro, etc.) |
| Contractor / Vendor | Nombre del contratista/proveedor |
| Award Date | Fecha de adjudicación |
| Amount | Monto inicial adjudicado |
| Purchase Order Number | Número de orden de compra |
| Description | Descripción del alcance del contrato |
| Start Date | Fecha de inicio |
| End Date | Fecha de término |
| Modification Number | Número de modificación del contrato |
| Modification Amount | Monto adicional de la modificación |
| Modification Date | Fecha de modificación |
| Fund / Source | Fondo o fuente de financiamiento |
| Status | Estado actual (activo, completado, modificado, etc.) |
| Department / Agency | Dependencia de gobierno que otorga el contrato |
| DUNS Number | Identificador de empresa del contratista |
| Vendor Address | Dirección del proveedor |
| Vendor City / State / Zip | Ubicación del contratista (ciudad, estado, código postal) |

---

## Clasificación de atributos por tipo

### Atributos numéricos
- Amount (monto adjudicado)
- Modification Amount (monto adicional de modificación)
- Modification Number (número de modificación)
- DUNS Number (aunque es identificador, se almacena como numérico)

### Atributos categóricos
- Contract Type
- Status
- Department / Agency
- Fund / Source
- Ordinance/Resolution

### Atributos de tipo texto
- Contractor / Vendor
- Description
- Vendor Address
- Vendor City / State / Zip

### Atributos temporales/fecha
- Award Date
- Start Date
- End Date
- Modification Date

---

## Objetivo del análisis

El objetivo de trabajar con este conjunto de datos es analizar el comportamiento de los contratos gubernamentales de la ciudad de Chicago para obtener una visión más clara de cómo se gestionan los recursos públicos en términos de proveedores, montos adjudicados, sectores beneficiados y duración de los contratos. 

A través de este análisis, el equipo podrá identificar patrones de gasto, posibles áreas de concentración en determinados proveedores, así como tendencias en la distribución de los contratos a lo largo del tiempo. De esta forma, el set de datos servirá como una base sólida para evaluar la transparencia en los procesos de contratación pública, proponer indicadores de eficiencia y generar información valiosa que apoye la toma de decisiones en temas de gestión financiera y control administrativo.

---

## Consideraciones éticas

### Transparencia responsable
Los datos deben usarse para rendición de cuentas y no para difundir interpretaciones sesgadas.

### Evitar estigmatización
Señalar contratistas frecuentes no implica corrupción; deben analizarse contextos como tamaño de empresa o especialización.

### Privacidad
Aunque son datos públicos, se debe asegurar que no se utilicen para rastrear individuos (ej. dirección de contratistas pequeños).

### Calidad del dato
Puede haber errores, duplicados o inconsistencias en el portal, por lo que se debe documentar cualquier limpieza o transformación.

### Implicaciones políticas
Los hallazgos deben presentarse de manera neutral, evitando juicios sin evidencia.