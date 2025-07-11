USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ShipMethod]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT SCAC_CODE, SHIP_METHOD_CODE FROM Oracle.ShipMethod GROUP BY SCAC_CODE, SHIP_METHOD_CODE HAVING COUNT(*) > 1

--SELECT SCAC_CODE FROM Oracle.ShipMethod GROUP BY SCAC_CODE HAVING COUNT(*) > 1


--SELECT * FROM Oracle.ShipMethod WHERE SHIP_METHOD_CODE = '000001_CENTRAL TR_L_LTL'

--TRUNCATE TABLE Oracle.ShipMethod


CREATE PROCEDURE [Oracle].[Merge_ShipMethod] AS BEGIN

		CREATE TABLE #shipMethod(
			[SCAC_CODE] [nvarchar](4) NULL,
			[MODE_OF_TRANSPORT] [nvarchar](30) NULL,
			[SHIP_METHOD_CODE] [nvarchar](30) NOT NULL,
			[SERVICE_LEVEL] [nvarchar](30) NULL,
			[SHIP_METHOD_MEANING] [nvarchar](240) NULL,
			[CARRIER_ID] [float] NOT NULL,
			[FREIGHT_CODE] [nvarchar](30) NOT NULL,
			[Fingerprint] [varchar](32) NOT NULL
		) ON [PRIMARY]
	

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #ShipMethod 
		SELECT *, 'XXX'
		FROM OPENQUERY( PROD,'
		SELECT 
			SCAC_CODE,
			MODE_OF_TRANSPORT,
			SHIP_METHOD_CODE,
			SERVICE_LEVEL,
			SHIP_METHOD_MEANING,
			wc.carrier_id,
			wc.Freight_Code
		  FROM 
			WSH_CARRIERS WC,
			WSH_CARRIER_SERVICES WCS
		  WHERE
			WC.CARRIER_ID=WCS.CARRIER_ID
		  order by
			wcs.ship_method_meaning
		'
		)


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('ShipMethod','Oracle') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #shipMethod
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				 CAST(ISNULL([SCAC_CODE],'') AS VARCHAR(4)) +  CAST(ISNULL([MODE_OF_TRANSPORT],'') AS VARCHAR(30)) +  CAST(ISNULL([SHIP_METHOD_CODE],'') AS VARCHAR(30)) +  CAST(ISNULL([SERVICE_LEVEL],'') AS VARCHAR(30)) +  CAST(ISNULL([SHIP_METHOD_MEANING],'') AS VARCHAR(240)) +  CAST(ISNULL([CARRIER_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([FREIGHT_CODE],'') AS VARCHAR(30)) 
			),1)),3,32);

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.[ShipMethod] (
			 [SCAC_CODE]
			,[MODE_OF_TRANSPORT]
			,[SHIP_METHOD_CODE]
			,[SERVICE_LEVEL]
			,[SHIP_METHOD_MEANING]
			,[CARRIER_ID]
			,[FREIGHT_CODE]
			,[Fingerprint]
		)
			SELECT 
				 a.[SCAC_CODE]
				,a.[MODE_OF_TRANSPORT]
				,a.[SHIP_METHOD_CODE]
				,a.[SERVICE_LEVEL]
				,a.[SHIP_METHOD_MEANING]
				,a.[CARRIER_ID]
				,a.[FREIGHT_CODE]
				,a.[Fingerprint]
			FROM (
				MERGE Oracle.[ShipMethod] b
				USING (SELECT * FROM #shipmethod) a
				ON a.SHIP_METHOD_CODE = b.SHIP_METHOD_CODE AND ISNULL(a.SCAC_CODE,'') = ISNULL(b.SCAC_CODE,'') AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					 [SCAC_CODE]
					,[MODE_OF_TRANSPORT]
					,[SHIP_METHOD_CODE]
					,[SERVICE_LEVEL]
					,[SHIP_METHOD_MEANING]
					,[CARRIER_ID]
					,[FREIGHT_CODE]
					,[Fingerprint]

				)
				VALUES (
					 a.[SCAC_CODE]
					,a.[MODE_OF_TRANSPORT]
					,a.[SHIP_METHOD_CODE]
					,a.[SERVICE_LEVEL]
					,a.[SHIP_METHOD_MEANING]
					,a.[CARRIER_ID]
					,a.[FREIGHT_CODE]
					,a.[Fingerprint]	
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					 a.[SCAC_CODE]
					,a.[MODE_OF_TRANSPORT]
					,a.[SHIP_METHOD_CODE]
					,a.[SERVICE_LEVEL]
					,a.[SHIP_METHOD_MEANING]
					,a.[CARRIER_ID]
					,a.[FREIGHT_CODE]
					,a.[Fingerprint]	
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #shipMethod
END



GO
