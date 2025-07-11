USE [Operations]
GO
/****** Object:  View [OUTPUT].[BoxDims]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[BoxDims] AS
SELECT
PM.ProductKey,
PPM.[Box SKU],
PM.UPC,
PM.ProductName,
ORDER_TYPE,
MOV.ORDER_TYPE_TEXT,
START_OF_WEEK,
MOV.QUANTITY,
MOV.QUANTITY * PM.[Product Volume] as [CUBIC CONVERSION],
PLANNER_CODE,
PhysicalLocation,
PPM.[Master Carton: Packaged Height (in)],
PPM.[Master Carton: Packaged Length (in)],
PPM.[Master Carton: Packaged Width (in)],
PPM.[Master Carton: Cube (sq ft)],
PPM.[Master Carton: Packaged Weight (lbs)]
FROM 
Oracle.MSC_ORDERS_V mov
	LEFT JOIN DBO.DimProductMaster PM ON MOV.ITEM_SEGMENTS = PM.ProductKey
	--LEFT JOIN DBO.PIMCarton PMC ON PMC.UPC = PM.UPC
	LEFT JOIN DBO.PimProductMaster PPM ON PPM.SKU = PM.ProductKey
	LEFT JOIN DBO.DimLocation LOC ON RIGHT(MOV.ORGANIZATION_CODE,3) = LOC.LocationKey
WHERE
ProductKey > '399999'
AND START_OF_WEEK BETWEEN '2024-01-01' AND '2025-01-01'
AND CurrentRecord = 1

GO
