USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_COGSLookup]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_COGSLookup] AS BEGIN


	--insert new invoice records
	INSERT INTO xref.COGSLookup
	SELECT --ROW_NUMBER() OVER (ORDER BY i.TRX_NUMBER, i.SKU) AS ID
		  i.TRX_NUMBER, i.SKU--, i.GL_DATE
		, SUM(QTY_INVOICED) AS Qty
		, SUM(ACCTD_USD) AS Sales
		, SUM(ITEM_FROZEN_COST*QTY_INVOICED) AS LookupCOGS
		, SUM(ITEM_FROZEN_COST*QTY_INVOICED)/SUM(QTY_INVOICED) AS LookupUnitCOGS
		, CAST(0 AS MONEY) AS GLCOGS
		, CAST(0 AS MONEY) AS GLUnitCOGS
		,SUM(ISNULL(FRZ_MAT_COST,0)*ISNULL(QTY_INVOICED,0)) AS LookupMaterial
		,SUM(ISNULL(FRZ_MAT_OH,0)*ISNULL(QTY_INVOICED,0)) AS LookupMaterialOH
		,SUM(ISNULL(FRZ_RESOUCE,0)*ISNULL(QTY_INVOICED,0)) AS LookupResourceCost
		,SUM(ISNULL(FRZ_OUT_PROC,0)*ISNULL(QTY_INVOICED,0)) AS LookupOutsideProcessing
		,SUM(ISNULL(FRZ_OH,0)*ISNULL(QTY_INVOICED,0)) AS LookupOverhead
		, CAST(0 AS MONEY) AS GLMaterial
		, CAST(0 AS MONEY) AS GLMaterialOH
		, CAST(0 AS MONEY) AS GLResourceCost
		, CAST(0 AS MONEY) AS GLOutsideProcessing
		, CAST(0 AS MONEY) AS GLOverhead
		, CAST(0 AS MONEY) AS GLUnitMaterial
		, CAST(0 AS MONEY) AS GLUnitMaterialOH
		, CAST(0 AS MONEY) AS GLUnitResourceCost
		, CAST(0 AS MONEY) AS GLUnitOutsideProcessing
		, CAST(0 AS MONEY) AS GLUnitOverhead
		, SUM(ISNULL(FRZ_MAT_COST,0)*ISNULL(QTY_INVOICED,0))/SUM(ISNULL(QTY_INVOICED,0)) AS LookupMaterial
		, SUM(ISNULL(FRZ_MAT_OH,0)*ISNULL(QTY_INVOICED,0))/SUM(ISNULL(QTY_INVOICED,0)) AS LookupMaterialOH
		, SUM(ISNULL(FRZ_RESOUCE,0)*ISNULL(QTY_INVOICED,0))/SUM(ISNULL(QTY_INVOICED,0)) AS LookupResourceCost
		, SUM(ISNULL(FRZ_OUT_PROC,0)*ISNULL(QTY_INVOICED,0))/SUM(ISNULL(QTY_INVOICED,0)) AS LookupOutsideProcessing
		, SUM(ISNULL(FRZ_OH,0)*ISNULL(QTY_INVOICED,0))/SUM(ISNULL(QTY_INVOICED,0)) AS LookupOverhead
	FROM Oracle.Invoice i 
		LEFT JOIN xref.COGSLookup cogs ON i.TRX_NUMBER = cogs.TRX_NUMBER AND i.SKU = cogs.SKU
	WHERE 
		i.GL_DATE >= '2019-01-01' --AND i.GL_DATE < '2022-01-01' 
		AND i.CurrentRecord = 1 
		AND cogs.SKU IS NULL AND i.SKU IS NOT NULL
		--AND AR_TYPE NOT LIKE '%MEMO%' --credit/debit memos do not have GL Record/COGS
		--AND LEN(TRX_NUMBER) > 5 --manual invoices do not have GL Record/COGS
		--AND ITEM_TYPE = 'STEP2 FG KIT' --recording kit on the sale side
	GROUP BY i.TRX_NUMBER, i.SKU--, i.GL_DATE
	HAVING SUM([QTY_INVOICED]) <> 0


	;
	WITH GLData AS (
		SELECT SHIPMENT_NUMBER, cogs.SKU
			, SUM(MATERIAL+MATERIAL_OH+RESOURCE_COST+OUTSIDE_PROCESSING+OVERHEAD) AS COGS
			, SUM(MATERIAL) AS Material
			, SUM(MATERIAL_OH) AS Material_OH
			, SUM(RESOURCE_COST) AS RESOURCE_COST
			, SUM(OUTSIDE_PROCESSING) AS OUTSIDE_PROCESSING
			, SUM(OVERHEAD) AS OVERHEAD
		FROM Oracle.COGSActual cogs
			LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(cogs.TRANSACTION_DATE AS DATE) = cf.DateKey
		WHERE GL_ACCOUNT LIKE '%4099%' AND TRANSACTION_DATE >= '2019-01-01'  
			AND cogs.TRANSACTION_TYPE_NAME = 'Sales order issue'
			AND cogs.CurrentRecord = 1
		GROUP BY SHIPMENT_NUMBER, cogs.SKU
	)
	--SELECT * 
	UPDATE cogs 
	SET GLCogs = gl.COGS
		,GLMaterial = gl.Material
		,GLMAterialOH = gl.Material_OH
		,GLResourceCost = gl.RESOURCE_COST
		,GLOutsideProcessing = gl.OUTSIDE_PROCESSING
		,GLOverhead = gl.OVERHEAD
	FROM xref.COGSLookup cogs
		INNER JOIN GLData gl ON gl.SHIPMENT_NUMBER = cogs.TRX_NUMBER AND cogs.SKU = gl.SKU
	WHERE ABS(GLCogs - gl.COGS) > .01

	UPDATE cogs
	SET GLUnitCOGS = GLCogs/Qty
		,GLUnitMaterial = GLMaterial/Qty
		,GLUnitMaterialOH = GLMaterialOH/Qty
		,GLUnitResourceCost = GLResourceCost/Qty
		,GLUnitOutsideProcessing = GLOutsideProcessing/Qty
		,GLUnitOverhead = GLOverhead/Qty
	FROM xref.COGSLookup cogs
	WHERE ABS(GLUnitCOGS - GLCogs/Qty) > .01

	--kit sales
	;
	WITH GLData AS (
		SELECT SHIPMENT_NUMBER, cogs.SKU, SUM(MATERIAL+MATERIAL_OH+RESOURCE_COST+OUTSIDE_PROCESSING+OVERHEAD) AS COGS
			, SUM(MATERIAL) AS Material
			, SUM(MATERIAL_OH) AS Material_OH
			, SUM(RESOURCE_COST) AS RESOURCE_COST
			, SUM(OUTSIDE_PROCESSING) AS OUTSIDE_PROCESSING
			, SUM(OVERHEAD) AS OVERHEAD
		FROM Oracle.COGSActual cogs
			LEFT JOIN dbo.DimCalendarFiscal cf ON CAST(cogs.TRANSACTION_DATE AS DATE) = cf.DateKey
		WHERE GL_ACCOUNT LIKE '%4099%' AND TRANSACTION_DATE >= '2019-01-01'
			AND cogs.TRANSACTION_TYPE_NAME = 'Sales order issue'
			AND cogs.CurrentRecord = 1
		GROUP BY SHIPMENT_NUMBER, cogs.SKU
	)
	, Kits AS (
		SELECT DISTINCT  --TOP 10000 
			i.TRX_NUMBER
			--, glData.SKU AS Kit
			, i.SKU
			, SUM(glData.COGS) OVER (PARTITION BY i.TRX_Number, i.SKU) AS COGSTotal
			, SUM(glData.Material) OVER (PARTITION BY i.TRX_Number, i.SKU) AS MaterialTotal
			, SUM(glData.Material_OH) OVER (PARTITION BY i.TRX_Number, i.SKU) AS MaterialOHTotal
			, SUM(glData.RESOURCE_COST) OVER (PARTITION BY i.TRX_Number, i.SKU) AS ResourceCostTotal
			, SUM(glData.OUTSIDE_PROCESSING) OVER (PARTITION BY i.TRX_Number, i.SKU) AS OutsideProcessingTotal
			, SUM(glData.OVERHEAD) OVER (PARTITION BY i.TRX_Number, i.SKU) AS OverheadTotal
			--, glData.COGS
			--*SUM([QTY_INVOICED]) OVER (PARTITION BY TRX_NUMBER) AS COGS, [ITEM_FROZEN_COST]*[QTY_INVOICED] AS DerivedCOGS, CAST(ISNULL(SUM(glData.COGS*i.[QTY_INVOICED]),0) - ISNULL(i.[ITEM_FROZEN_COST]*i.[QTY_INVOICED],0) AS MONEY) AS Variance
		FROM (SELECT DISTINCT TRX_NUMBER, SKU FROM Oracle.Invoice i
			WHERE i.CurrentRecord = 1 
				AND i.GL_Date >= '2019-01-01'
				--AND i.TRX_NUMBER = '39869077'
				AND i.QTY_INVOICED <> 0
			) i --compressed
			LEFT JOIN GLData ON GLData.SHIPMENT_NUMBER = i.TRX_NUMBER 
			INNER JOIN Oracle.BillOfMaterial bom ON bom.PARENT_SKU = i.SKU AND bom.Child_SKU = glData.SKU AND bom.CurrentRecord = 1 AND bom.ITEM_TYPE LIKE '%Finished Goods' AND bom.Level <= 1 --AND GLData.SKU = i.SKU 
			LEFT JOIN dbo.DimProductMaster pm ON bom.PARENT_SKU = pm.ProductKey AND pm.[Item Type] = 'STEP2 FG KIT'
		WHERE glData.SKU <> i.SKU 
		
		--GROUP BY i.TRX_NUMBER, glData.SKU, i.SKU, glData.COGS
		--ORDER BY i.TRX_Number
	)
	--SELECT *
	UPDATE cogs 
	SET  GLCogs = gl.COGSTotal
		,GLMaterial = gl.MaterialTotal
		,glMaterialOH = gl.MaterialOHTotal
		,glResourceCost = gl.ResourceCostTotal
		,glOutsideProcessing = gl.OutsideProcessingTotal
		,glOverhead = gl.OverheadTotal
	FROM xref.COGSLookup cogs
		INNER JOIN Kits gl ON gl.TRX_NUMBER = cogs.TRX_NUMBER AND cogs.SKU = gl.SKU
	WHERE ABS(GLCogs - gl.COGSTotal) > .01

	UPDATE cogs
	SET  GLUnitCOGS = GLCogs/Qty
		,GLUnitMaterial = GLMaterial/Qty
		,GLUnitMaterialOH = GLMaterialOH/Qty
		,GLUnitResourceCost = GLResourceCost/Qty
		,GLUnitOutsideProcessing = GLOutsideProcessing/Qty
		,GLUnitOverhead = GLOverhead/Qty
	FROM xref.COGSLookup cogs
	WHERE ABS(GLUnitCOGS - GLCogs/Qty) > .01


	
	UPDATE i 
	SET COGS = CASE WHEN ISNULL([GLUnitCOGS],0) <> 0 THEN [GLUnitCOGS] ELSE ISNULL(LookupUnitCOGS,0) END*[QTY_INVOICED]
	FROM Oracle.invoice i
		INNER JOIN xref.COGSLookup cogs ON cogs.TRX_NUMBER = i.TRX_NUMBER AND cogs.SKU = i.SKU
	WHERE i.CurrentRecord = 1 AND 
		i.COGS IS NULL

END
GO
