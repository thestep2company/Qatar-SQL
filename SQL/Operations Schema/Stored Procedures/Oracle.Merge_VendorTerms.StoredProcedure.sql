USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_VendorTerms]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_VendorTerms]
AS BEGIN

	CREATE TABLE #terms(
		--<column-list>
		[VENDOR_ID] [float] NULL,
		[VENDORNUMBER] [nvarchar](30) NOT NULL,
		[SUPPLIER_NAME] [nvarchar](240) NULL,
		[TERMS_ID] [float] NULL,
		[NAME] [nvarchar](50) NULL,
		[DESCRIPTION] [nvarchar](240) NULL,
		[VENDOR_SITE] [nvarchar](45) NULL,
		[TermLength] [int] NULL,
		[Fingerprint] [varchar](32) NOT NULL
	) ON [PRIMARY]

	--insert steps to log what is happening.  If the job fails, we can check the ETLLog and see where it failed.
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()
	
	INSERT INTO #Terms (
		  --<column-list>
		[VENDOR_ID]
      ,[VENDORNUMBER]
      ,[SUPPLIER_NAME]
      ,[TERMS_ID]
      ,[NAME]
      ,[DESCRIPTION]
      ,[VENDOR_SITE]
      ,[TermLength]
      ,[Fingerprint]
	  )
	SELECT 
		 --<column-list>
		   [VENDOR_ID]
		  ,[VENDORNUMBER]
		  ,[SUPPLIER_NAME]
		  ,[TERMS_ID]
		  ,[NAME]
		  ,[DESCRIPTION]
		  ,[VENDOR_SITE]
		, CASE WHEN ISNUMERIC(REPLACE(ISNULL(NAME,'0'),'Net','')) = 1 THEN CAST(REPLACE(ISNULL(NAME,'0'),'Net','') AS INT)
			WHEN NAME = 'Quarterly' THEN 45 --average length of payment due date (middle of the quarter due on the 1st of next quarter)
			WHEN NAME = 'Net10thProx' THEN 25 --average length of payment due date (15th of the month to 10th of the next month)
			ELSE NULL
		END AS TermLength
		,'XXX' AS Fingerprint
	FROM OPENQUERY(QA,
	'	SELECT DISTINCT 
		povs.VENDOR_ID, 
		pov.SEGMENT1 AS VendorNumber,
		pov.vendor_name SUPPLIER_NAME,
		povs.TERMS_ID,
		t.NAME,
		t.DESCRIPTION,
		povs.vendor_site_code VENDOR_SITE
	FROM po_vendors pov 
		LEFT JOIN po_vendor_sites_All povs ON pov.vendor_id = povs.vendor_id
		LEFT JOIN AP_TERMS t ON povs.TERMS_ID = t.TERM_ID
		LEFT JOIN PO_HEADERS_ALL poh ON pov.VENDOR_ID = poh.VENDOR_ID
	WHERE poh.ATTRIBUTE1 IS NOT NULL
			OR poh.ATTRIBUTE2 IS NOT NULL
			OR poh.ATTRIBUTE3 IS NOT NULL
			OR poh.ATTRIBUTE4 IS NOT NULL
			OR poh.ATTRIBUTE5 IS NOT NULL
			OR poh.ATTRIBUTE6 IS NOT NULL
			OR poh.ATTRIBUTE7 IS NOT NULL
	')  --8000 character limit for openqueries

	/*	--run this and replace @columnList below
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('VendorTerms','Oracle') SELECT @columnList
	*/

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	UPDATE #terms
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([VENDOR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([VENDORNUMBER],'') AS VARCHAR(30)) +  CAST(ISNULL([SUPPLIER_NAME],'') AS VARCHAR(240)) +  CAST(ISNULL([TERMS_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([NAME],'') AS VARCHAR(50)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_SITE],'') AS VARCHAR(45)) +  CAST(ISNULL([TermLength],'0') AS VARCHAR(100)) 
		),1)),3,32);


	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO #Terms (
		  --<column-list>
		[VENDOR_ID]
      ,[VENDORNUMBER]
      ,[SUPPLIER_NAME]
      ,[TERMS_ID]
      ,[NAME]
      ,[DESCRIPTION]
      ,[VENDOR_SITE]
      ,[TermLength]
      ,[Fingerprint]
	)
		SELECT 
			  --a.<column-list>
			   a.[VENDOR_ID]
			  ,a.[VENDORNUMBER]
			  ,a.[SUPPLIER_NAME]
			  ,a.[TERMS_ID]
			  ,a.[NAME]
			  ,a.[DESCRIPTION]
			  ,a.[VENDOR_SITE]
			  ,a.[TermLength]
			  ,a.[Fingerprint]
		FROM (
			MERGE Oracle.VendorTerms b
			USING (SELECT * FROM #Terms) a
			ON a.[VENDOR_ID] = b.[VENDOR_ID] AND a.[VENDOR_SITE] = b.[VENDOR_SITE] AND b.CurrentRecord = 1 --swap with business key of table
			WHEN NOT MATCHED --BY TARGET 
			THEN INSERT (
				  --<column-list>
				[VENDOR_ID]
			  ,[VENDORNUMBER]
			  ,[SUPPLIER_NAME]
			  ,[TERMS_ID]
			  ,[NAME]
			  ,[DESCRIPTION]
			  ,[VENDOR_SITE]
			  ,[TermLength]
			  ,[Fingerprint]		
			)
			VALUES (
				  --a.<column-list>
				   a.[VENDOR_ID]
				  ,a.[VENDORNUMBER]
				  ,a.[SUPPLIER_NAME]
				  ,a.[TERMS_ID]
				  ,a.[NAME]
				  ,a.[DESCRIPTION]
				  ,a.[VENDOR_SITE]
				  ,a.[TermLength]
				  ,a.[Fingerprint]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
			THEN UPDATE SET b.EndDate=GETDATE()
				,b.CurrentRecord=0
			OUTPUT 
				  --a.<column-list>
				   a.[VENDOR_ID]
				  ,a.[VENDORNUMBER]
				  ,a.[SUPPLIER_NAME]
				  ,a.[TERMS_ID]
				  ,a.[NAME]
				  ,a.[DESCRIPTION]
				  ,a.[VENDOR_SITE]
				  ,a.[TermLength]
				  ,a.[Fingerprint]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update'
		;

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

	DROP TABLE #Terms

END
GO
