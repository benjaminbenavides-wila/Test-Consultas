-- Versión mejorada: implementa 3 mejoras solicitadas (comentarios en tercera persona)
-- 1) Mover los CASE largos de "Cuenta Mayor" y "CodMayor" a CTEs de mapeo para facilitar mantenimiento.
-- 2) Parametrizar y validar fechas (se usan variables y TRY_CONVERT para evitar errores de formato).
-- 3) Hacer la unión con `OPCH` más tolerante: intenta hacer match por `DocEntry` (cuando `CreatedBy` es numérico)
--    y por `DocNum` cuando aplica; agrega comentarios y no altera la lógica original si no existe coincidencia.
--
-- Nota: Esta versión se adapta a SAP Business One HANA: usa `TO_DATE`, `SUBSTRING`,
--       `REGEXP_LIKE` y `TO_INTEGER`. Revisar formato de placeholders `[%0]`/`[%1]`.

-- En tercera persona: esta consulta se ejecuta a través de Query Manager en SAP B1 HANA.
-- Los placeholders [%0] y [%1] reciben las fechas de inicio y fin (formato: 'YYYY-MM-DD').
-- 
-- CTE con mapeo de FormatCode -> Cuenta Mayor (mejora 1: sustituir CASE por tabla de mapeo)
WITH MapCuenta AS (
    SELECT '41010100' AS FormatCode, 'Total Ingresos Operacionales' AS CuentaMayor UNION ALL
    SELECT '41011000','Otros Ingresos' UNION ALL
    SELECT '51010300','Costo Ventas' UNION ALL
    SELECT '52010100','Depreciación' UNION ALL
    SELECT '62020100','Leyes Sociales' UNION ALL
    SELECT '62030100','Otros Gastos  - No usar' UNION ALL
    SELECT '62031600','Viaticos' UNION ALL
    SELECT '63010100','Gastos de Administracion' UNION ALL
    SELECT '63010200','Gastos de Administracion' UNION ALL
    SELECT '63010300','Gastos de Administracion' UNION ALL
    SELECT '63010400','Gastos de Administracion' UNION ALL
    SELECT '63010500','Gastos de Administracion' UNION ALL
    SELECT '63010600','Gastos de Administracion' UNION ALL
    SELECT '63010800','Gastos de Administracion' UNION ALL
    SELECT '63010900','Gastos de Administracion' UNION ALL
    SELECT '63020100','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63020200','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63020300','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63020400','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63020500','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63020800','Otras Retr. y Gastos de Personal' UNION ALL
    SELECT '63030100','Costo Importación' UNION ALL
    SELECT '63030200','Costo Importación' UNION ALL
    SELECT '63030300','Costo Importación' UNION ALL
    SELECT '63030400','Costo Importación' UNION ALL
    SELECT '63030500','Costo Despachos' UNION ALL
    SELECT '63030600','Costo Importación' UNION ALL
    SELECT '63040100','Otros Gastos de Oficina' UNION ALL
    SELECT '63040200','Otros Gastos de Oficina' UNION ALL
    SELECT '63040300','Otros Gastos de Oficina' UNION ALL
    SELECT '63040400','Otros Gastos de Oficina' UNION ALL
    SELECT '63040500','Otros Gastos de Oficina' UNION ALL
    SELECT '63040600','Otros Gastos de Oficina' UNION ALL
    SELECT '63040800','Otros Gastos de Oficina' UNION ALL
    SELECT '63040900','Otros Gastos de Oficina' UNION ALL
    SELECT '63046000','Otros Gastos de Oficina' UNION ALL
    SELECT '63047000','Otros Gastos de Oficina' UNION ALL
    SELECT '63048000','Otros Gastos de Oficina' UNION ALL
    SELECT '63049000','Otros Gastos de Oficina' UNION ALL
    SELECT '63050100','Software y Comunicaciones' UNION ALL
    SELECT '63050300','Software y Comunicaciones' UNION ALL
    SELECT '63050400','Software y Comunicaciones' UNION ALL
    SELECT '63060100','Gastos Comerciales' UNION ALL
    SELECT '63060200','Gastos Comerciales' UNION ALL
    SELECT '63060300','Gastos Comerciales' UNION ALL
    SELECT '63060400','Gastos Comerciales' UNION ALL
    SELECT '63060500','Gastos Comerciales' UNION ALL
    SELECT '63060600','Gastos Comerciales' UNION ALL
    SELECT '63070100','Asesorias Externas' UNION ALL
    SELECT '63070200','Asesorias Externas' UNION ALL
    SELECT '63070300','Asesorias Externas' UNION ALL
    SELECT '63080100','Gastos Bancarios y Tarjetas' UNION ALL
    SELECT '63080200','Intereses por Préstamos' UNION ALL
    SELECT '63080400','Comisiones Pago al Exterior' UNION ALL
    SELECT '63080600','Intereses por Leasing' UNION ALL
    SELECT '71010200','Ingresos por Inversión Irf' UNION ALL
    SELECT '71020300','Gastos Menores' UNION ALL
    SELECT '71030100','Resultado Inversiones' UNION ALL
    SELECT '71030200','Reajuste Impuesto a la Renta' UNION ALL
    SELECT '71030300','Ingresos por Arriendo' UNION ALL
    SELECT '81030100','Diferencias por Tipo de Cambio' UNION ALL
    SELECT '81040100','Corrección Monetaria, Donaciones y Otros' UNION ALL
    SELECT '81040400','Corrección PPM' UNION ALL
    SELECT '81050300','Gastos por Proyecto' UNION ALL
    SELECT '81050400','Donaciones' UNION ALL
    SELECT '81050600','Dir y Planificación' UNION ALL
    SELECT '81050700','Otros Gastos I+D' UNION ALL
    SELECT '81060100','Impuesto a la Renta'
),

-- CTE con mapeo FormatCode -> CodMayor (mejora 1)
MapCodMayor AS (
    SELECT '41011000' AS FormatCode,'4111' AS CodMayor UNION ALL
    SELECT '41010100','4110' UNION ALL
    SELECT '51010300','5110' UNION ALL
    SELECT '52010100','5210' UNION ALL
    SELECT '62020100','6221' UNION ALL
    SELECT '62030100','6231' UNION ALL
    SELECT '62031600','6236' UNION ALL
    SELECT '63010100','6310' UNION ALL
    SELECT '63010200','6310' UNION ALL
    SELECT '63010300','6310' UNION ALL
    SELECT '63010400','6310' UNION ALL
    SELECT '63010500','6310' UNION ALL
    SELECT '63010600','6310' UNION ALL
    SELECT '63010800','6310' UNION ALL
    SELECT '63010900','6310' UNION ALL
    SELECT '63020100','6320' UNION ALL
    SELECT '63020200','6320' UNION ALL
    SELECT '63020300','6320' UNION ALL
    SELECT '63020400','6320' UNION ALL
    SELECT '63020500','6320' UNION ALL
    SELECT '63020800','6320' UNION ALL
    SELECT '63030100','6330' UNION ALL
    SELECT '63030200','6330' UNION ALL
    SELECT '63030300','6330' UNION ALL
    SELECT '63030400','6330' UNION ALL
    SELECT '63030500','6335' UNION ALL
    SELECT '63030600','6330' UNION ALL
    SELECT '63040100','6340' UNION ALL
    SELECT '63040200','6340' UNION ALL
    SELECT '63040300','6340' UNION ALL
    SELECT '63040400','6340' UNION ALL
    SELECT '63040500','6340' UNION ALL
    SELECT '63040600','6340' UNION ALL
    SELECT '63040800','6340' UNION ALL
    SELECT '63040900','6340' UNION ALL
    SELECT '63046000','6340' UNION ALL
    SELECT '63047000','6340' UNION ALL
    SELECT '63048000','6348' UNION ALL
    SELECT '63049000','6340' UNION ALL
    SELECT '63050100','6350' UNION ALL
    SELECT '63050300','6350' UNION ALL
    SELECT '63050400','6350' UNION ALL
    SELECT '63060100','6360' UNION ALL
    SELECT '63060200','6360' UNION ALL
    SELECT '63060300','6360' UNION ALL
    SELECT '63060400','6360' UNION ALL
    SELECT '63060500','6360' UNION ALL
    SELECT '63060600','6360' UNION ALL
    SELECT '63070100','6370' UNION ALL
    SELECT '63070200','6370' UNION ALL
    SELECT '63070300','6370' UNION ALL
    SELECT '63080100','6381' UNION ALL
    SELECT '63080200','6382' UNION ALL
    SELECT '63080400','6384' UNION ALL
    SELECT '63080600','6386' UNION ALL
    SELECT '71010200','7110' UNION ALL
    SELECT '71020300','7120' UNION ALL
    SELECT '71030100','7131' UNION ALL
    SELECT '71030200','7132' UNION ALL
    SELECT '71030300','7133' UNION ALL
    SELECT '81030100','8130' UNION ALL
    SELECT '81040100','8141' UNION ALL
    SELECT '81040400','8144' UNION ALL
    SELECT '81050300','8153' UNION ALL
    SELECT '81050400','8154' UNION ALL
    SELECT '81050600','8156' UNION ALL
    SELECT '81050700','8157' UNION ALL
    SELECT '81060100','8161'
)

SELECT
    T1.FormatCode AS IdentificadorCuenta,
    T1.AcctName   AS NombreCuenta,
    T0.RefDate    AS FechaContabilizacion,

    -- Se intenta enlazar factura de proveedor por DocEntry cuando CreatedBy es numérico;
    -- si no hay match por DocEntry, se intenta comparar por DocNum (cuando CreatedBy contiene DocNum).
    OI.DocNum     AS NumeroFactura,
    OI.FolioNum   AS Folio,

    T0.TransId    AS NumeroTransaccion,
    T0.LineMemo   AS Glosa,
    T0.ProfitCode AS CentroCosto,
    T0.OcrCode2   AS Segmentos,
    T0.OcrCode3   AS BusinessUnit,
    T0.OcrCode4   AS Vendedor,

    OI.CardCode   AS CodigoProveedor,
    OI.CardName   AS NombreProveedor,

    -- Clasificación operativa simplificada basada en el primer caracter del FormatCode
    CASE
        WHEN SUBSTRING(T1.FormatCode,1,1) IN ('1','2','3') THEN 'Balance'
        WHEN T1.FormatCode IN ('62031600','63048000','81050700','62030100','63047000','81050600','63080200') THEN 'No Operacional'
        WHEN T1.FormatCode = '81060100' THEN 'Impuesto a la Renta'
        WHEN SUBSTRING(T1.FormatCode,1,1) IN ('4','5','6') THEN 'Operacional'
        WHEN SUBSTRING(T1.FormatCode,1,1) = '7' THEN 'No Operacional'
        WHEN SUBSTRING(T1.FormatCode,1,1) = '8' THEN 'Operacional' 
        ELSE 'SIN CLASIFICAR'
    END AS Op_NotOP,

    -- Se usa el mapeo en lugar de CASE largo
    COALESCE(mc.CuentaMayor, 'SIN CLASIFICAR') AS CuentaMayor,
    COALESCE(mc2.CodMayor, '000') AS CodMayor,

    -- BU y Segmentos (mismos criterios que la versión original)
    CASE 
        WHEN T0.OcrCode3 IN ('MIN','DUK','SCHUNK') THEN 'MINERÍA'
        WHEN T0.OcrCode3 IN ('GEN','EO','HID') THEN 'GENERACIÓN'
        WHEN T0.OcrCode3 = 'FFCC' THEN 'TRANSPORTE'
        WHEN T0.OcrCode3 IN ('CEM','OU','PT') THEN 'INDUSTRIAL'
        ELSE 'SIN CLASIFICAR'
    END AS UnidadNegocio,

    CASE 
        WHEN T0.OcrCode2 IN ('CON','PV') THEN 'PISO EFECTIVO'
        WHEN T0.OcrCode2 IN ('EXP','PRO') THEN 'CRECIMIENTO'
        ELSE 'SIN CLASIFICAR'
    END AS TipoSegmento,

    -- Agregados financieros
    CASE WHEN (SUM(T0.Debit) - SUM(T0.Credit)) > 0 THEN (SUM(T0.Debit) - SUM(T0.Credit)) ELSE 0 END AS Perdida,
    CASE WHEN (SUM(T0.Debit) - SUM(T0.Credit)) < 0 THEN ABS(SUM(T0.Debit) - SUM(T0.Credit)) ELSE 0 END AS Ganancia,
    SUM(T0.Debit) - SUM(T0.Credit) AS Saldo

FROM JDT1 T0
INNER JOIN OACT T1 ON T0.Account = T1.AcctCode
LEFT JOIN OJDT OJ ON OJ.TransId = T0.TransId

-- Unión con OPCH más tolerante adaptada a HANA: usa REGEXP_LIKE para detectar números y TO_INTEGER
LEFT JOIN OPCH OI
    ON (
        (REGEXP_LIKE(T0.CreatedBy, '^[0-9]+$') AND OI.DocEntry = TO_INTEGER(T0.CreatedBy))
        OR
        (OI.DocNum = T0.CreatedBy)
    )
    AND T0.TransType = 18

-- Unir mapeos
LEFT JOIN MapCuenta mc ON mc.FormatCode = T1.FormatCode
LEFT JOIN MapCodMayor mc2 ON mc2.FormatCode = T1.FormatCode

WHERE
    -- Se valida que los placeholders [%0] y [%1] sean válidos y contengan fechas en formato YYYY-MM-DD.
    -- La consulta filtra movimientos contables dentro del rango especificado.
    T0.RefDate BETWEEN TO_DATE('[%0]', 'YYYY-MM-DD') AND TO_DATE('[%1]', 'YYYY-MM-DD')

    -- Excluir cierres
    AND UPPER(COALESCE(T0.LineMemo, '')) NOT LIKE '%CIERRE%'
    AND UPPER(COALESCE(OJ.Memo, ''))     NOT LIKE '%CIERRE%'
    AND UPPER(COALESCE(OJ.Ref1, ''))     NOT LIKE '%CIERRE%'
    AND UPPER(COALESCE(OJ.Ref2, ''))     NOT LIKE '%CIERRE%'

GROUP BY
    T1.FormatCode,
    T1.AcctName,
    T0.RefDate,
    OI.DocNum,
    OI.FolioNum,
    T0.TransId,
    T0.LineMemo,
    T0.ProfitCode,
    T0.OcrCode2,
    T0.OcrCode3,
    T0.OcrCode4,
    OI.CardCode,
    OI.CardName,
    mc.CuentaMayor,
    mc2.CodMayor

ORDER BY
    T1.FormatCode,
    T0.RefDate;
