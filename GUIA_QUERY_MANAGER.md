# Guía: Ejecutar la consulta mejorada en SAP Business One HANA (Query Manager)

## Descripción General

Este documento explica cómo ejecutar `consulta_para_pegar_mejorada.sql` a través de **Query Manager** en SAP Business One HANA para extraer movimientos contables clasificados por período, operacionalidad, BU, segmento y con cálculo de pérdida/ganancia.

## Requisitos

- SAP Business One HANA instalado y configurado.
- Acceso a Query Manager (menú: **Tools → Query Manager**).
- Permiso de lectura sobre tablas: `JDT1`, `OACT`, `OJDT`, `OPCH`.

## Pasos para ejecutar

### 1. Abrir Query Manager

1. En SAP Business One, vaya a **Herramientas** → **Query Manager**.
2. Haga clic en **Nueva Consulta** o abra una existente.

### 2. Copiar y pegar la consulta

1. Copie el contenido completo de `consulta_para_pegar_mejorada.sql`.
2. Péguelo en el editor de Query Manager.

### 3. Parámetros de entrada (placeholders)

La consulta contiene dos **placeholders** que Query Manager solicitará al ejecutar:

- **`[%0]`**: Fecha de inicio (formato: `YYYY-MM-DD`, ej: `2025-01-01`)
- **`[%1]`**: Fecha de fin (formato: `YYYY-MM-DD`, ej: `2025-12-31`)

#### Ejemplo de entrada:
```
[%0] = 2025-01-01
[%1] = 2025-12-31
```

### 4. Ejecutar la consulta

1. Haga clic en **Ejecutar** (o presione **F5**).
2. Ingrese las fechas cuando se solicite.
3. Query Manager procesará y mostrará los resultados.

## Estructura de la consulta (tercera persona)

### Secciones principales:

- **CTEs (Common Table Expressions)**: `MapCuenta` y `MapCodMayor` contienen mapeos de cuentas contables a clasificaciones.

- **SELECT**: Selecciona movimientos contables con las siguientes columnas:
  - Identificador y nombre de cuenta
  - Fecha de contabilización
  - Factura de proveedor (si aplica)
  - Información transaccional (glosa, centro de costo, etc.)
  - Clasificación operativa (Balance, Operacional, No Operacional)
  - Clasificación de cuenta mayor
  - Código mayor
  - Unidad de negocio y tipo de segmento
  - Pérdida, ganancia y saldo

- **FROM/JOIN**: 
  - `JDT1 T0`: Movimientos contables (detalles de asientos)
  - `OACT T1`: Cuentas contables (metadatos)
  - `OJDT OJ`: Cabeceras de asientos (para filtrar cierres)
  - `OPCH OI`: Facturas de proveedor (relación tolerante)

- **WHERE**: Filtra por rango de `RefDate` y excluye asientos de cierre.

- **GROUP BY**: Agrupa por todos los campos no agregados para obtener subtotales de débito/crédito.

## Notas técnicas

### Funciones HANA utilizadas:

| Función | Propósito |
|---------|-----------|
| `TO_DATE(string, format)` | Convierte string a tipo DATE con formato especificado |
| `SUBSTRING(string, pos, len)` | Extrae subcadena (equivalente a `LEFT` en SQL Server) |
| `REGEXP_LIKE(string, pattern)` | Valida si string cumple patrón regex |
| `TO_INTEGER(string)` | Convierte string a tipo INTEGER |
| `COALESCE(expr1, expr2, ...)` | Retorna el primer valor no NULL |
| `UPPER(string)` | Convierte a mayúsculas |

### Mejoras implementadas:

1. **Mapeo de cuentas**: Utiliza CTEs en lugar de `CASE` largos, facilitando mantenimiento.
2. **Parametrización de fechas**: Placeholders `[%0]` y `[%1]` permiten entrada flexible.
3. **Unión OPCH tolerante**: Intenta match por `DocEntry` (numérico) o `DocNum` (textual).

### Exclusión de asientos de cierre:

La cláusula `WHERE` filtra registros cuyo `LineMemo` o campos de cabecera contengan la palabra "CIERRE":

```sql
AND UPPER(COALESCE(T0.LineMemo, '')) NOT LIKE '%CIERRE%'
AND UPPER(COALESCE(OJ.Memo, '')) NOT LIKE '%CIERRE%'
-- ... (+ validaciones en Ref1, Ref2)
```

## Solución de problemas

### Error: "Syntax error or access violation: 257"

**Causa**: Query Manager no reconoce sintaxis HANA específica.

**Solución**:
- Verifique que está usando HANA (no SQL Server).
- Asegúrese de que `TO_DATE` y `SUBSTRING` son funciones soportadas.
- Revise los placeholders: debe estar en formato `[%0]`, `[%1]`, etc.

### Error: "Referenced column not found"

**Causa**: Nombre de columna incorrecto o tabla no existe.

**Solución**:
- Valide que las tablas `JDT1`, `OACT`, `OJDT`, `OPCH` existen en su base de datos SAP B1.
- Ajuste los nombres de columna si difieren (ej: `DocNum` vs `DocNumber`).

### La consulta retorna 0 resultados

**Causas posibles**:
- Rango de fechas sin movimientos contables.
- Tablas vacías o sin permisos.
- Formato de fecha incorrecto en placeholders (debe ser `YYYY-MM-DD`).

**Solución**:
- Intente con un rango más amplio o fechas conocidas.
- Verifique permisos de lectura sobre las tablas.
- Confirme formato de placeholders.

## Exportar resultados

Una vez ejecutada la consulta:

1. Haga clic en **Exportar** (o icono similar en Query Manager).
2. Seleccione formato (Excel, CSV, etc.).
3. Guarde el archivo.

## Consultas adicionales

Para más detalles sobre Query Manager en SAP B1, consulte:
- [SAP Business One Help](https://help.sap.com/)
- Documentación de HANA SQL en SAP HANA Studio.

---

**Versión**: 1.0 | **Fecha**: 2025-11-26 | **Rama**: `mejoras/cuenta-mapping-fechas-opch`
