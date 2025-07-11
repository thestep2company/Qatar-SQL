USE [Operations]
GO
/****** Object:  StoredProcedure [dbo].[Upsert_FactSupplierScores]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Upsert_FactSupplierScores] AS BEGIN

	INSERT INTO [dbo].[FactSupplierScores] (
		Vendor_ID
		,CostEffectiveness
		,PriceCompetitiveness
		,QuotingProcess
		,PackingLists
		,DPPMCurrentPeriod
		,DPPMRolling12Months
		,CorrectAction
	)
	 SELECT po.VENDOR_ID
			, ATTRIBUTE1
			, ATTRIBUTE2
			, ATTRIBUTE3
			, ATTRIBUTE4
			, ATTRIBUTE5
			, ATTRIBUTE6
			, ATTRIBUTE7
	FROM Oracle.PO_HEADERS_ALL po
		LEFT JOIN dbo.FactSupplierScores s ON po.VENDOR_ID = s.VENDOR_ID
	WHERE s.VENDOR_ID IS NULL

	UPDATE s
	SET s.CostEffectiveness = po.ATTRIBUTE1
		,s.PriceCompetitiveness = po.ATTRIBUTE2
		,s.QuotingProcess = po.ATTRIBUTE3
		,s.PackingLists = po.ATTRIBUTE4
		,s.DPPMCurrentPeriod = po.ATTRIBUTE5
		,s.DPPMRolling12Months = po.ATTRIBUTE6
		,s.CorrectAction = po.ATTRIBUTE7
	FROM Oracle.PO_HEADERS_ALL po
		LEFT JOIN dbo.FactSupplierScores s ON po.VENDOR_ID = s.VENDOR_ID
	WHERE  ISNULL(po.ATTRIBUTE1,'') <>  ISNULL(s.CostEffectiveness,'')
		OR ISNULL(po.ATTRIBUTE2,'') <> ISNULL(s.PriceCompetitiveness,'')
		OR ISNULL(po.ATTRIBUTE3,'') <> ISNULL(s.QuotingProcess,'')
		OR ISNULL(po.ATTRIBUTE4,'') <> ISNULL(s.PackingLists,'')
		OR ISNULL(po.ATTRIBUTE5,'') <> ISNULL(s.DPPMCurrentPeriod,'')
		OR ISNULL(po.ATTRIBUTE6,'') <> ISNULL(s.DPPMRolling12Months,'')
		OR ISNULL(po.ATTRIBUTE7,'') <> ISNULL(s.CorrectAction,'')


	INSERT INTO [dbo].[FactSupplierScores] (
		Vendor_ID
		,PaymentTerms
	)
	SELECT t.VENDOR_ID, 
		CASE WHEN t.TermLength > 90 THEN 'A'
			WHEN t.TermLength > 60 THEN 'B'
			WHEN t.TermLength > 45 THEN 'C'
			WHEN t.TermLength > 30 THEN 'D'
			ELSE 'F'
		END
	FROM Oracle.VendorTerms t
		LEFT JOIN dbo.FactSupplierScores s ON t.VENDOR_ID = s.VENDOR_ID
	WHERE s.VENDOR_ID IS NULL

	UPDATE s
	SET s.PaymentTerms = 
		CASE WHEN t.TermLength > 90 THEN 'A'
			WHEN t.TermLength > 60 THEN 'B'
			WHEN t.TermLength > 45 THEN 'C'
			WHEN t.TermLength > 30 THEN 'D'
			ELSE 'F'
		END
	FROM Oracle.VendorTerms t
		INNER JOIN dbo.FactSupplierScores s ON t.VENDOR_ID = s.VENDOR_ID
	WHERE CASE WHEN t.TermLength > 90 THEN 'A'
			WHEN t.TermLength > 60 THEN 'B'
			WHEN t.TermLength > 45 THEN 'C'
			WHEN t.TermLength > 30 THEN 'D'
			ELSE 'F'
		END <> ISNULL(s.PaymentTerms,'')


	INSERT INTO [dbo].[FactSupplierScores] (
		Vendor_ID
		,InFull
	)
	SELECT fr.VENDOR_ID, 
		CASE WHEN fr.FillRate = 100 THEN 'A'
			WHEN fr.FillRate >= 94 THEN 'B'
			WHEN fr.FillRate >= 88 THEN 'C'
			WHEN fr.FillRate >= 82 THEN 'D'
			ELSE 'F'
		END
	FROM Output.VendorFillRate fr
		LEFT JOIN dbo.FactSupplierScores s ON fr.VENDOR_ID = s.VENDOR_ID
	WHERE s.VENDOR_ID IS NULL


	UPDATE s
	SET s.InFull = 
		CASE WHEN fr.FillRate = 100 THEN 'A'
			WHEN fr.FillRate >= 94 THEN 'B'
			WHEN fr.FillRate >= 88 THEN 'C'
			WHEN fr.FillRate >= 82 THEN 'D'
			ELSE 'F'
		END
	FROM Output.VendorFillRate fr
		INNER JOIN dbo.FactSupplierScores s ON fr.VENDOR_ID = s.VENDOR_ID
	WHERE CASE WHEN fr.FillRate = 100 THEN 'A'
			WHEN fr.FillRate >= 94 THEN 'B'
			WHEN fr.FillRate >= 88 THEN 'C'
			WHEN fr.FillRate >= 82 THEN 'D'
			ELSE 'F'
		END <> ISNULL(s.InFull,'')


	INSERT INTO [dbo].[FactSupplierScores] (
		Vendor_ID
		,OnTime
	)
	SELECT st.VENDOR_ID, 
		CASE WHEN st.ShipmentTiming = 100 THEN 'A'
			WHEN st.ShipmentTiming >= 97 THEN 'B'
			WHEN st.ShipmentTiming >= 94 THEN 'C'
			WHEN st.ShipmentTiming >= 91 THEN 'D'
			ELSE 'F'
		END
	FROM Output.VendorShipmentTiming st
		LEFT JOIN dbo.FactSupplierScores s ON st.VENDOR_ID = s.VENDOR_ID
	WHERE s.VENDOR_ID IS NULL


	UPDATE s
	SET s.OnTime = 
		CASE WHEN st.ShipmentTiming = 100 THEN 'A'
			WHEN st.ShipmentTiming >= 97 THEN 'B'
			WHEN st.ShipmentTiming >= 94 THEN 'C'
			WHEN st.ShipmentTiming >= 91 THEN 'D'
			ELSE 'F'
		END
	FROM Output.VendorShipmentTiming st
		INNER JOIN dbo.FactSupplierScores s ON st.VENDOR_ID = s.VENDOR_ID
	WHERE 	CASE WHEN st.ShipmentTiming = 100 THEN 'A'
			WHEN st.ShipmentTiming >= 97 THEN 'B'
			WHEN st.ShipmentTiming >= 94 THEN 'C'
			WHEN st.ShipmentTiming >= 91 THEN 'D'
			ELSE 'F'
		END <> ISNULL(s.OnTime,'')

	SELECT * FROM dbo.FactSupplierScores

END
GO
