USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Company]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Company] 
AS BEGIN

		CREATE TABLE #Company(
			[ID] INT IDENTITY(1,1) NOT NULL,
			[Legal Entity ID] [numeric](15, 0) NOT NULL,
			[Legal Entity] [nvarchar](240) NOT NULL,
			[Organization Name] [nvarchar](240) NOT NULL,
			[Organization ID] [numeric](15, 0) NOT NULL,
			[Location ID] [numeric](15, 0) NOT NULL,
			[Country Code] [nvarchar](60) NULL,
			[Location Code] [nvarchar](60) NULL,
			[Company Code] [nvarchar](25) NOT NULL,
			[Fingerprint] [varchar](32) NOT NULL
		) 

		INSERT INTO #Company (
			[Legal Entity ID]
			,[Legal Entity]
			,[Organization Name]
			,[Organization ID]
			,[Location ID]
			,[Country Code]
			,[Location Code]
			,[Company Code]
			,[Fingerprint]
		)
		SELECT 
			[Legal Entity ID]
			,[Legal Entity]
			,[Organization Name]
			,[Organization ID]
			,[Location ID]
			,[Country Code]
			,[Location Code]
			,[Company Code]
			,'XXXXXX' AS Fingerprint
		FROM OPENQUERY(PROD,'
		SELECT
			   xep.legal_entity_id        "Legal Entity ID",
			   xep.name                   "Legal Entity",
			   hr_outl.name               "Organization Name",
			   hr_outl.organization_id    "Organization ID",
			   hr_loc.location_id         "Location ID",
			   hr_loc.country             "Country Code",
			   hr_loc.location_code       "Location Code",
			   glev.flex_segment_value    "Company Code"
		  FROM
			   xle_entity_profiles            xep,
			   xle_registrations              reg,
			   --
			   hr_operating_units             hou,
			   -- hr_all_organization_units      hr_ou,
			   hr_all_organization_units_tl   hr_outl,
			   hr_locations_all               hr_loc,
			   --
			   gl_legal_entities_bsvs         glev
		 WHERE
			   1=1
		   AND xep.transacting_entity_flag   =  ''Y''
		   AND xep.legal_entity_id           =  reg.source_id
		   AND reg.source_table              =  ''XLE_ENTITY_PROFILES''
		   AND reg.identifying_flag          =  ''Y''
		   AND xep.legal_entity_id           =  hou.default_legal_context_id
		   AND reg.location_id               =  hr_loc.location_id
		   AND xep.legal_entity_id           =  glev.legal_entity_id
		   --
		   -- AND hr_ou.organization_id         =  hou.business_group_id
		   AND hr_outl.organization_id       =  hou.organization_id
		 ORDER BY hr_outl.name
		 ')


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Company','Oracle') SELECT @columnList
		*/
		UPDATE #Company
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				CAST(ISNULL([Legal Entity ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([Legal Entity],'') AS VARCHAR(240)) +  CAST(ISNULL([Organization Name],'') AS VARCHAR(240)) +  CAST(ISNULL([Organization ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([Location ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([Country Code],'') AS VARCHAR(60)) +  CAST(ISNULL([Location Code],'') AS VARCHAR(60)) +  CAST(ISNULL([Company Code],'') AS VARCHAR(25)) 
			),1)),3,32);

		--expire records outside the merge

		INSERT INTO Oracle.Company (
				 [Legal Entity ID]
				,[Legal Entity]
				,[Organization Name]
				,[Organization ID]
				,[Location ID]
				,[Country Code]
				,[Location Code]
				,[Company Code]
				,[Fingerprint]
		)
			SELECT 
				 a.[Legal Entity ID]
				,a.[Legal Entity]
				,a.[Organization Name]
				,a.[Organization ID]
				,a.[Location ID]
				,a.[Country Code]
				,a.[Location Code]
				,a.[Company Code]
				,a.[Fingerprint]
			FROM (
				MERGE Oracle.Company b
				USING (SELECT * FROM #Company) a
				ON a.[Legal Entity ID] = b.[Legal Entity ID] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
						[Legal Entity ID]
						,[Legal Entity]
						,[Organization Name]
						,[Organization ID]
						,[Location ID]
						,[Country Code]
						,[Location Code]
						,[Company Code]
						,[Fingerprint]
				)
				VALUES (
						 a.[Legal Entity ID]
						,a.[Legal Entity]
						,a.[Organization Name]
						,a.[Organization ID]
						,a.[Location ID]
						,a.[Country Code]
						,a.[Location Code]
						,a.[Company Code]
						,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
						 a.[Legal Entity ID]
						,a.[Legal Entity]
						,a.[Organization Name]
						,a.[Organization ID]
						,a.[Location ID]
						,a.[Country Code]
						,a.[Location Code]
						,a.[Company Code]
						,a.[Fingerprint]
						,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #Company
END
GO
