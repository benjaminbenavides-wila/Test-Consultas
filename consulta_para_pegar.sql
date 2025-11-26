-- Propósito: Este script extrae movimientos contables entre dos fechas (`RefDate`) y
--             clasifica las cuentas y movimientos según criterios operacionales y de
--             negocio. También calcula pérdida/ganancia y saldo por cuenta.
--
-- Estructura (resumen):
--   - Selección: Se obtienen datos de `JDT1` y se enriquecen con `OACT` y `OPCH`.
--   - Clasificaciones: Se construyen clasificaciones operacionales (`Op_NotOP`),
--     clasificación de cuenta mayor (`Cuenta Mayor`) y código mayor (`CodMayor`).
--   - BU y segmentos: Se mapea `OcrCode3` y `OcrCode2` a unidades de negocio y tipos.
--   - Agregación: Se calcula pérdida/ganancia y saldo mediante SUM de `Debit` y `Credit`.
--   - Filtros: Se filtra por rango de `RefDate` (placeholders `[%0]` y `[%1]`) y se excluyen
--     asientos de cierre mediante comprobaciones de texto en `LineMemo` y campos de cabecera.
--
-- Supuestos y notas (tercera persona):
--   - Se asume que los identificadores con comillas dobles (`"..."`) son válidos en el
--     motor SQL utilizado; en caso contrario, se sugiere adaptar la sintaxis de identificadores.
--   - Se asume que `T0."CreatedBy"` contiene el `DocEntry` de `OPCH` cuando la partida
--     proviene de una factura de proveedor; se recomienda verificar esta relación en la base.
--   - Se asume que `LEFT()` y `COALESCE()` son funciones soportadas por el motor; si no,
--     reemplazar por funciones equivalentes (por ejemplo `SUBSTRING`).
--
-- Recomendación rápida: revisar índices sobre `JDT1."RefDate"`, `JDT1."Account"` y
-- `OACT."FormatCode"` para mejorar rendimiento en rangos amplios.

SELECT 
	T1."FormatCode" AS "Identificador de Cuenta",
	T1."AcctName"   AS "Nombre de la Cuenta",
	T0."RefDate"    AS "Fecha de Contabilización",
	OI."DocNum"     AS "Número de Factura",
	OI."FolioNum"   AS "Folio",
	T0."TransId"    AS "Número de Transacción",
	T0."LineMemo"   AS "Glosa",
	T0."ProfitCode" AS "Centro de Costo",
	T0."OcrCode2"   AS "Segmentos",
	T0."OcrCode3"   AS "Business Unit",
	T0."OcrCode4"   AS "Vendedor",

	-- Proveedor (solo si la partida proviene de Factura de Proveedor)
	OI."CardCode"   AS "Código Proveedor",
	OI."CardName"   AS "Nombre Proveedor",

	-- Clasificación Operacional vs No Operacional
	CASE
		WHEN LEFT(T1."FormatCode", 1) IN ('1','2','3') THEN 'Balance'
		WHEN T1."FormatCode" IN ('62031600','63048000','81050700','62030100','63047000','81050600','63080200') THEN 'No Operacional'
		WHEN T1."FormatCode" = '81060100' THEN 'Impuesto a la Renta'
		WHEN LEFT(T1."FormatCode", 1) IN ('4','5','6') THEN 'Operacional'
		WHEN LEFT(T1."FormatCode", 1) = '7' THEN 'No Operacional'
		WHEN LEFT(T1."FormatCode", 1) = '8' THEN 'Operacional'
		ELSE 'SIN CLASIFICAR'
	END AS "Op_NotOP",

	-- Clasificación de Cuenta Mayor
	CASE T1."FormatCode"
		WHEN '41010100' THEN 'Total Ingresos Operacionales'
		WHEN '41011000' THEN 'Otros Ingresos'
		WHEN '51010300' THEN 'Costo Ventas'
		WHEN '52010100' THEN 'Depreciación'
		WHEN '62020100' THEN 'Leyes Sociales'
		WHEN '62030100' THEN 'Otros Gastos  - No usar'
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
		WHEN '63030100' THEN 'Costo Importación'
		WHEN '63030200' THEN 'Costo Importación'
		WHEN '63030300' THEN 'Costo Importación'
		WHEN '63030400' THEN 'Costo Importación'
		WHEN '63030500' THEN 'Costo Despachos'
		WHEN '63030600' THEN 'Costo Importación'
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
		WHEN '63080200' THEN 'Intereses por Préstamos'
		WHEN '63080400' THEN 'Comisiones Pago al Exterior'
		WHEN '63080600' THEN 'Intereses por Leasing'
		WHEN '71010200' THEN 'Ingresos por Inversión Irf'
		WHEN '71020300' THEN 'Gastos Menores'
		WHEN '71030100' THEN 'Resultado Inversiones'
		WHEN '71030200' THEN 'Reajuste Impuesto a la Renta'
		WHEN '71030300' THEN 'Ingresos por Arriendo'
		WHEN '81030100' THEN 'Diferencias por Tipo de Cambio'
		WHEN '81040100' THEN 'Corrección Monetaria, Donaciones y Otros'
		WHEN '81040400' THEN 'Corrección PPM'
		WHEN '81050300' THEN 'Gastos por Proyecto'
		WHEN '81050400' THEN 'Donaciones'
		WHEN '81050600' THEN 'Dir y Planificación'
		WHEN '81050700' THEN 'Otros Gastos I+D'
		WHEN '81060100' THEN 'Impuesto a la Renta'
		ELSE 'SIN CLASIFICAR'
	END AS "Cuenta Mayor",

	-- Código Mayor
	-- Codigo Mayor: agrupacion automatica por los primeros 4 digitos
	SUBSTRING(T1."FormatCode", 1, 4) AS "CodMayor",

	-- BU y Segmentos
	CASE 
		WHEN T0."OcrCode3" IN ('MIN', 'DUK', 'SCHUNK') THEN 'MINERÍA'
		WHEN T0."OcrCode3" IN ('GEN', 'EO', 'HID') THEN 'GENERACIÓN'
		WHEN T0."OcrCode3" = 'FFCC' THEN 'TRANSPORTE'
		WHEN T0."OcrCode3" IN ('CEM', 'OU', 'PT') THEN 'INDUSTRIAL'
		ELSE 'SIN CLASIFICAR'
	END AS "Unidad de Negocio",
	CASE 
		WHEN T0."OcrCode2" IN ('CON', 'PV') THEN 'PISO EFECTIVO'
		WHEN T0."OcrCode2" IN ('EXP', 'PRO') THEN 'CRECIMIENTO'
		ELSE 'SIN CLASIFICAR'
	END AS "Tipo de Segmento",

	-- Pérdida / Ganancia y Saldo
	CASE WHEN (SUM(T0."Debit") - SUM(T0."Credit")) > 0 THEN (SUM(T0."Debit") - SUM(T0."Credit")) ELSE 0 END AS "Pérdida",
	CASE WHEN (SUM(T0."Debit") - SUM(T0."Credit")) < 0 THEN ABS(SUM(T0."Debit") - SUM(T0."Credit")) ELSE 0 END AS "Ganancia",
	SUM(T0."Debit") - SUM(T0."Credit") AS "Saldo",

	CASE 
		WHEN LEFT(T1."FormatCode", 1) IN ('1','2','3') THEN 'Balance'
		WHEN LEFT(T1."FormatCode", 1) IN ('4','5','6','7','8') THEN 'Resultado'
		ELSE 'Otro'
	END AS "Tipo"

FROM JDT1 T0
INNER JOIN OACT T1
		ON T0."Account" = T1."AcctCode"

-- Cabecera del asiento (para filtrar cierres/reversas)
LEFT JOIN OJDT OJ
	   ON OJ."TransId" = T0."TransId"

-- Factura de proveedor: enlazar por DOCENTRY de origen para evitar duplicados por DocNum
LEFT JOIN OPCH OI
	   ON OI."DocEntry" = T0."CreatedBy"
	  AND T0."TransType" = 18

WHERE 
	T0."RefDate" BETWEEN [%0] AND [%1]

	-- Excluir cierres
	AND UPPER(COALESCE(T0."LineMemo", '')) NOT LIKE '%CIERRE%'
	AND UPPER(COALESCE(OJ."Memo", ''))     NOT LIKE '%CIERRE%'
	AND UPPER(COALESCE(OJ."Ref1", ''))     NOT LIKE '%CIERRE%'
	AND UPPER(COALESCE(OJ."Ref2", ''))     NOT LIKE '%CIERRE%'

GROUP BY 
	T1."FormatCode", 
	T1."AcctName", 
	T0."RefDate", 
	OI."DocNum",
	OI."FolioNum",
	T0."TransId",
	T0."LineMemo",
	T0."ProfitCode",
	T0."OcrCode2",
	T0."OcrCode3",
	T0."OcrCode4",
	OI."CardCode",
	OI."CardName"

ORDER BY 
	T1."FormatCode", 
	T0."RefDate";