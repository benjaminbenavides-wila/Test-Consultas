-- Version mejorada para SAP Business One HANA Query Manager
-- Sin CTEs, sin alias de tabla, sin comillas en nombres (maxima compatibilidad)
-- Esta consulta extrae movimientos contables del periodo especificado,
-- los clasifica y calcula saldo. Evitar caracteres acentuados.

SELECT
    OACT.FormatCode AS IdentificadorCuenta,
    OACT.AcctName AS NombreCuenta,
    JDT1.RefDate AS FechaContabilizacion,

    OPCH.DocNum AS NumeroFactura,
    OPCH.FolioNum AS Folio,

    JDT1.TransId AS NumeroTransaccion,
    JDT1.LineMemo AS Glosa,
    JDT1.ProfitCode AS CentroCosto,
    JDT1.OcrCode2 AS Segmentos,
    JDT1.OcrCode3 AS BusinessUnit,
    JDT1.OcrCode4 AS Vendedor,

    OPCH.CardCode AS CodigoProveedor,
    OPCH.CardName AS NombreProveedor,

    CASE
        WHEN SUBSTRING(OACT.FormatCode, 1, 1) IN ('1','2','3') THEN 'Balance'
        WHEN OACT.FormatCode IN ('62031600','63048000','81050700','62030100','63047000','81050600','63080200') THEN 'No Operacional'
        WHEN OACT.FormatCode = '81060100' THEN 'Impuesto a la Renta'
        WHEN SUBSTRING(OACT.FormatCode, 1, 1) IN ('4','5','6') THEN 'Operacional'
        WHEN SUBSTRING(OACT.FormatCode, 1, 1) = '7' THEN 'No Operacional'
        WHEN SUBSTRING(OACT.FormatCode, 1, 1) = '8' THEN 'Operacional'
        ELSE 'SIN CLASIFICAR'
    END AS Op_NotOP,

    CASE OACT.FormatCode
        WHEN '41010100' THEN 'Total Ingresos Operacionales'
        WHEN '41011000' THEN 'Otros Ingresos'
        WHEN '51010300' THEN 'Costo Ventas'
        WHEN '52010100' THEN 'Depreciacion'
        WHEN '62020100' THEN 'Leyes Sociales'
        WHEN '62030100' THEN 'Otros Gastos - No usar'
        WHEN '62031600' THEN 'Viaticos'
        WHEN '63010100' THEN 'Gastos de Administracion'
        WHEN '63010200' THEN 'Gastos de Administracion'
        WHEN '63010300' THEN 'Gastos de Administracion'
        WHEN '63010400' THEN 'Gastos de Administracion'
        WHEN '63010500' THEN 'Gastos de Administracion'
        WHEN '63010600' THEN 'Gastos de Administracion'
        WHEN '63010800' THEN 'Gastos de Administracion'
        WHEN '63010900' THEN 'Gastos de Administracion'
        WHEN '63020100' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63020200' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63020300' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63020400' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63020500' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63020800' THEN 'Otras Retr. y Gastos de Personal'
        WHEN '63030100' THEN 'Costo Importacion'
        WHEN '63030200' THEN 'Costo Importacion'
        WHEN '63030300' THEN 'Costo Importacion'
        WHEN '63030400' THEN 'Costo Importacion'
        WHEN '63030500' THEN 'Costo Despachos'
        WHEN '63030600' THEN 'Costo Importacion'
        WHEN '63040100' THEN 'Otros Gastos de Oficina'
        WHEN '63040200' THEN 'Otros Gastos de Oficina'
        WHEN '63040300' THEN 'Otros Gastos de Oficina'
        WHEN '63040400' THEN 'Otros Gastos de Oficina'
        WHEN '63040500' THEN 'Otros Gastos de Oficina'
        WHEN '63040600' THEN 'Otros Gastos de Oficina'
        WHEN '63040800' THEN 'Otros Gastos de Oficina'
        WHEN '63040900' THEN 'Otros Gastos de Oficina'
        WHEN '63046000' THEN 'Otros Gastos de Oficina'
        WHEN '63047000' THEN 'Otros Gastos de Oficina'
        WHEN '63048000' THEN 'Otros Gastos de Oficina'
        WHEN '63049000' THEN 'Otros Gastos de Oficina'
        WHEN '63050100' THEN 'Software y Comunicaciones'
        WHEN '63050300' THEN 'Software y Comunicaciones'
        WHEN '63050400' THEN 'Software y Comunicaciones'
        WHEN '63060100' THEN 'Gastos Comerciales'
        WHEN '63060200' THEN 'Gastos Comerciales'
        WHEN '63060300' THEN 'Gastos Comerciales'
        WHEN '63060400' THEN 'Gastos Comerciales'
        WHEN '63060500' THEN 'Gastos Comerciales'
        WHEN '63060600' THEN 'Gastos Comerciales'
        WHEN '63070100' THEN 'Asesorias Externas'
        WHEN '63070200' THEN 'Asesorias Externas'
        WHEN '63070300' THEN 'Asesorias Externas'
        WHEN '63080100' THEN 'Gastos Bancarios y Tarjetas'
        WHEN '63080200' THEN 'Intereses por Prestamos'
        WHEN '63080400' THEN 'Comisiones Pago al Exterior'
        WHEN '63080600' THEN 'Intereses por Leasing'
        WHEN '71010200' THEN 'Ingresos por Inversion Irf'
        WHEN '71020300' THEN 'Gastos Menores'
        WHEN '71030100' THEN 'Resultado Inversiones'
        WHEN '71030200' THEN 'Reajuste Impuesto a la Renta'
        WHEN '71030300' THEN 'Ingresos por Arriendo'
        WHEN '81030100' THEN 'Diferencias por Tipo de Cambio'
        WHEN '81040100' THEN 'Correccion Monetaria, Donaciones y Otros'
        WHEN '81040400' THEN 'Correccion PPM'
        WHEN '81050300' THEN 'Gastos por Proyecto'
        WHEN '81050400' THEN 'Donaciones'
        WHEN '81050600' THEN 'Dir y Planificacion'
        WHEN '81050700' THEN 'Otros Gastos I+D'
        WHEN '81060100' THEN 'Impuesto a la Renta'
        ELSE 'SIN CLASIFICAR'
    END AS CuentaMayor,

    CASE OACT.FormatCode
        WHEN '41011000' THEN '4111'
        WHEN '41010100' THEN '4110'
        WHEN '51010300' THEN '5110'
        WHEN '52010100' THEN '5210'
        WHEN '62020100' THEN '6221'
        WHEN '62030100' THEN '6231'
        WHEN '62031600' THEN '6236'
        WHEN '63010100' THEN '6310'
        WHEN '63010200' THEN '6310'
        WHEN '63010300' THEN '6310'
        WHEN '63010400' THEN '6310'
        WHEN '63010500' THEN '6310'
        WHEN '63010600' THEN '6310'
        WHEN '63010800' THEN '6310'
        WHEN '63010900' THEN '6310'
        WHEN '63020100' THEN '6320'
        WHEN '63020200' THEN '6320'
        WHEN '63020300' THEN '6320'
        WHEN '63020400' THEN '6320'
        WHEN '63020500' THEN '6320'
        WHEN '63020800' THEN '6320'
        WHEN '63030100' THEN '6330'
        WHEN '63030200' THEN '6330'
        WHEN '63030300' THEN '6330'
        WHEN '63030400' THEN '6330'
        WHEN '63030500' THEN '6335'
        WHEN '63030600' THEN '6330'
        WHEN '63040100' THEN '6340'
        WHEN '63040200' THEN '6340'
        WHEN '63040300' THEN '6340'
        WHEN '63040400' THEN '6340'
        WHEN '63040500' THEN '6340'
        WHEN '63040600' THEN '6340'
        WHEN '63040800' THEN '6340'
        WHEN '63040900' THEN '6340'
        WHEN '63046000' THEN '6340'
        WHEN '63047000' THEN '6340'
        WHEN '63048000' THEN '6348'
        WHEN '63049000' THEN '6340'
        WHEN '63050100' THEN '6350'
        WHEN '63050300' THEN '6350'
        WHEN '63050400' THEN '6350'
        WHEN '63060100' THEN '6360'
        WHEN '63060200' THEN '6360'
        WHEN '63060300' THEN '6360'
        WHEN '63060400' THEN '6360'
        WHEN '63060500' THEN '6360'
        WHEN '63060600' THEN '6360'
        WHEN '63070100' THEN '6370'
        WHEN '63070200' THEN '6370'
        WHEN '63070300' THEN '6370'
        WHEN '63080100' THEN '6381'
        WHEN '63080200' THEN '6382'
        WHEN '63080400' THEN '6384'
        WHEN '63080600' THEN '6386'
        WHEN '71010200' THEN '7110'
        WHEN '71020300' THEN '7120'
        WHEN '71030100' THEN '7131'
        WHEN '71030200' THEN '7132'
        WHEN '71030300' THEN '7133'
        WHEN '81030100' THEN '8130'
        WHEN '81040100' THEN '8141'
        WHEN '81040400' THEN '8144'
        WHEN '81050300' THEN '8153'
        WHEN '81050400' THEN '8154'
        WHEN '81050600' THEN '8156'
        WHEN '81050700' THEN '8157'
        WHEN '81060100' THEN '8161'
        ELSE '000'
    END AS CodMayor,

    CASE 
        WHEN JDT1.OcrCode3 IN ('MIN','DUK','SCHUNK') THEN 'MINERIA'
        WHEN JDT1.OcrCode3 IN ('GEN','EO','HID') THEN 'GENERACION'
        WHEN JDT1.OcrCode3 = 'FFCC' THEN 'TRANSPORTE'
        WHEN JDT1.OcrCode3 IN ('CEM','OU','PT') THEN 'INDUSTRIAL'
        ELSE 'SIN CLASIFICAR'
    END AS UnidadNegocio,

    CASE 
        WHEN JDT1.OcrCode2 IN ('CON','PV') THEN 'PISO EFECTIVO'
        WHEN JDT1.OcrCode2 IN ('EXP','PRO') THEN 'CRECIMIENTO'
        ELSE 'SIN CLASIFICAR'
    END AS TipoSegmento,

    SUM(JDT1.Debit) AS TotalDebito,
    SUM(JDT1.Credit) AS TotalCredito,
    SUM(JDT1.Debit) - SUM(JDT1.Credit) AS Saldo

FROM JDT1
INNER JOIN OACT ON JDT1.Account = OACT.AcctCode
LEFT JOIN OJDT ON OJDT.TransId = JDT1.TransId
LEFT JOIN OPCH ON OPCH.DocNum = JDT1.LineMemo

WHERE
    JDT1.RefDate >= '[%0]'
    AND JDT1.RefDate <= '[%1]'
    AND UPPER(JDT1.LineMemo) NOT LIKE '%CIERRE%'
    AND UPPER(OJDT.Memo) NOT LIKE '%CIERRE%'

GROUP BY
    OACT.FormatCode,
    OACT.AcctName,
    JDT1.RefDate,
    OPCH.DocNum,
    OPCH.FolioNum,
    JDT1.TransId,
    JDT1.LineMemo,
    JDT1.ProfitCode,
    JDT1.OcrCode2,
    JDT1.OcrCode3,
    JDT1.OcrCode4,
    OPCH.CardCode,
    OPCH.CardName

ORDER BY
    OACT.FormatCode,
    JDT1.RefDate;
