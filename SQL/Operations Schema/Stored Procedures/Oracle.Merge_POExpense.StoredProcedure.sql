USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_POExpense]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--SELECT * FROM Oracle.POExpense WHERE PO_NUMBER = '106572' AND LINE_NUM = 4

--SELECT LINE_LOCATION FROM Oracle.POExpense GROUP BY LINE_LOCATION HAVING COUNT(*) > 1

CREATE   PROCEDURE [Oracle].[Merge_POExpense]
AS BEGIN

	CREATE TABLE #POExpense (
		[PO_HEADER_ID] [float] NOT NULL,
		[PO_NUMBER] [nvarchar](20) NOT NULL,
		[PO_TYPE] [nvarchar](25) NOT NULL,
		[PO_STATUS] [nvarchar](25) NULL,
		[CREATION_DATE] [datetime2](7) NULL,
		[SUPPLIER_NAME] [nvarchar](240) NULL,
		[SUPPLIER_SITE] [nvarchar](15) NULL,
		[LINE_NUM] [float] NOT NULL,
		[LINE_LOCATION] [float] NOT NULL,
		[ITEM_DESCRIPTION] [nvarchar](240) NULL,
		[SHIPMENT_QUANTITY] [float] NULL,
		[DIST_ORDERED_QUANTITY] [float] NULL,
		[DESTINATION_TYPE_CODE] [nvarchar](25) NULL,
		[Fingerprint] [varchar](32) NOT NULL
	)
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO #POExpense
	SELECT *, 'XXX'
	FROM OPENQUERY(PROD,'
	SELECT DISTINCT
		ph.po_header_id PO_HEADER_ID
		, ph.segment1 PO_NUMBER
		, ph.type_lookup_code PO_TYPE
		, ph.authorization_status PO_STATUS
		, ph.creation_date CREATION_DATE
		, pv.vendor_name SUPPLIER_NAME
		, pvs.vendor_site_code SUPPLIER_SITE
		, pl.line_num LINE_NUM
		, pll.line_location_id AS LINE_LOCATION
		, pl.item_description ITEM_DESCRIPTION
		, pll.quantity SHIPMENT_QUANTITY
		, pd.quantity_ordered - NVL(pd.quantity_cancelled, 0) DIST_ORDERED_QUANTITY
		, pd.destination_type_code DESTINATION_TYPE_CODE
	FROM
		apps.po_headers_all ph
		INNER JOIN apps.po_lines_all pl ON ph.po_header_id = pl.po_header_id
		INNER JOIN apps.po_line_locations_all pll ON pl.po_line_id = pll.po_line_id
		INNER JOIN apps.po_distributions_all pd ON pll.line_location_id = pd.line_location_id
		INNER JOIN apps.po_vendors pv ON ph.vendor_id = pv.vendor_id
		INNER JOIN apps.po_vendor_sites_all pvs ON ph.vendor_site_id = pvs.vendor_site_id
		INNER JOIN apps.hr_operating_units hou ON ph.org_id = hou.organization_id
	WHERE
		ph.type_lookup_code = ''STANDARD''
		AND NVL(ph.authorization_status, ''INCOMPLETE'') NOT IN (''INCOMPLETE'', ''CANCELLED'')
		AND NVL(ph.closed_code, ''OPEN'') = ''OPEN''
		AND NVL(pl.cancel_flag, ''N'') = ''N''
		AND NVL(pll.cancel_flag, ''N'') = ''N''
		AND pd.destination_type_code = ''EXPENSE''
		AND pd.project_id IS NULL
	ORDER BY
		ph.creation_date DESC, ph.segment1, pl.line_num
	')

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*	
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('POExpense','Oracle') SELECT @columnList
	*/
	UPDATE #POExpense
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			 CAST(ISNULL([PO_HEADER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([PO_NUMBER],'') AS VARCHAR(20)) +  CAST(ISNULL([PO_TYPE],'') AS VARCHAR(25)) +  CAST(ISNULL([PO_STATUS],'') AS VARCHAR(25)) +  CAST(ISNULL([CREATION_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([SUPPLIER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([SUPPLIER_SITE],'') AS VARCHAR(15)) +  CAST(ISNULL([LINE_NUM],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_LOCATION],'0') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([SHIPMENT_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([DIST_ORDERED_QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([DESTINATION_TYPE_CODE],'') AS VARCHAR(25)) 
		),1)),3,32)

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.POExpense (
	   [PO_HEADER_ID]
      ,[PO_NUMBER]
      ,[PO_TYPE]
      ,[PO_STATUS]
      ,[CREATION_DATE]
      ,[SUPPLIER_NAME]
      ,[SUPPLIER_SITE]
      ,[LINE_NUM]
	  ,[LINE_LOCATION]
      ,[ITEM_DESCRIPTION]
      ,[SHIPMENT_QUANTITY]
      ,[DIST_ORDERED_QUANTITY]
      ,[DESTINATION_TYPE_CODE]
      ,[Fingerprint]
	)
			SELECT 
			   a.[PO_HEADER_ID]
			  ,a.[PO_NUMBER]
			  ,a.[PO_TYPE]
			  ,a.[PO_STATUS]
			  ,a.[CREATION_DATE]
			  ,a.[SUPPLIER_NAME]
			  ,a.[SUPPLIER_SITE]
			  ,a.[LINE_NUM]
			  ,a.[LINE_LOCATION]
			  ,a.[ITEM_DESCRIPTION]
			  ,a.[SHIPMENT_QUANTITY]
			  ,a.[DIST_ORDERED_QUANTITY]
			  ,a.[DESTINATION_TYPE_CODE]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.POExpense b
				USING (SELECT * FROM #POExpense) a
				ON a.[LINE_LOCATION] = b.[LINE_LOCATION] AND b.CurrentRecord = 1
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				   [PO_HEADER_ID]
				  ,[PO_NUMBER]
				  ,[PO_TYPE]
				  ,[PO_STATUS]
				  ,[CREATION_DATE]
				  ,[SUPPLIER_NAME]
				  ,[SUPPLIER_SITE]
				  ,[LINE_NUM]
				  ,[LINE_LOCATION]
				  ,[ITEM_DESCRIPTION]
				  ,[SHIPMENT_QUANTITY]
				  ,[DIST_ORDERED_QUANTITY]
				  ,[DESTINATION_TYPE_CODE]
				  ,[Fingerprint]
				)
				VALUES (
				   a.[PO_HEADER_ID]
				  ,a.[PO_NUMBER]
				  ,a.[PO_TYPE]
				  ,a.[PO_STATUS]
				  ,a.[CREATION_DATE]
				  ,a.[SUPPLIER_NAME]
				  ,a.[SUPPLIER_SITE]
				  ,a.[LINE_NUM]
				  ,a.[LINE_LOCATION]
				  ,a.[ITEM_DESCRIPTION]
				  ,a.[SHIPMENT_QUANTITY]
				  ,a.[DIST_ORDERED_QUANTITY]
				  ,a.[DESTINATION_TYPE_CODE]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
				   a.[PO_HEADER_ID]
				  ,a.[PO_NUMBER]
				  ,a.[PO_TYPE]
				  ,a.[PO_STATUS]
				  ,a.[CREATION_DATE]
				  ,a.[SUPPLIER_NAME]
				  ,a.[SUPPLIER_SITE]
				  ,a.[LINE_NUM]
				  ,a.[LINE_LOCATION]
				  ,a.[ITEM_DESCRIPTION]
				  ,a.[SHIPMENT_QUANTITY]
				  ,a.[DIST_ORDERED_QUANTITY]
				  ,a.[DESTINATION_TYPE_CODE]
				  ,a.[Fingerprint]
				  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()
	
	DROP TABLE #POExpense
END
GO
