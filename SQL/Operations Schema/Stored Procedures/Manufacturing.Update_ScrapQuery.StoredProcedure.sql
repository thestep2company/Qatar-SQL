USE [Operations]
GO
/****** Object:  StoredProcedure [Manufacturing].[Update_ScrapQuery]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Manufacturing].[Update_ScrapQuery] AS BEGIN

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED --dirty read live data

		CREATE TABLE #Scrap(
			[COLLECTION_ID] [float] NOT NULL,
			[OCCURRENCE] [float] NOT NULL,
			[CREATION_DATE] [nvarchar](19) NULL,
			[ORG_CODE] [nvarchar](3) NULL,
			[SHIFT] [nvarchar](150) NULL,
			[LINES] [nvarchar](150) NULL,
			[REPAIR_SCRAP_TYPE] [nvarchar](150) NULL,
			[REPAIR_SCRAP_REASON] [nvarchar](150) NULL,
			[COMP_ITEM] [nvarchar](4000) NULL,
			[QTY] [nvarchar](150) NULL,
			[LBS_REPAIRED_SCRAPPED] [nvarchar](150) NULL,
			[ROTO_DESCRIPTION] [nvarchar](150) NULL,
			[PIGMEN_RESIN] [nvarchar](150) NULL,
			[ERROR_CODE] [nvarchar](150) NULL,
			[CREATED_BY] [nvarchar](100) NOT NULL,
			[SEGMENT1] [nvarchar](50) NOT NULL,
			[SHIFT_ID] INT NULL,
			[Fingerprint] [nvarchar](32) NOT NULL
		) 


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

		INSERT INTO #Scrap (
			   [COLLECTION_ID]
			  ,[OCCURRENCE]
			  ,[CREATION_DATE]
			  ,[ORG_CODE]
			  ,[SHIFT]
			  ,[LINES]
			  ,[REPAIR_SCRAP_TYPE]
			  ,[REPAIR_SCRAP_REASON]
			  ,[COMP_ITEM]
			  ,[QTY]
			  ,[LBS_REPAIRED_SCRAPPED]
			  ,[ROTO_DESCRIPTION]
			  ,[PIGMEN_RESIN]
			  ,[ERROR_CODE]
			  ,[CREATED_BY]
			  ,[SEGMENT1]
			  ,[SHIFT_ID]
			  ,[FINGERPRINT]
		)
		SELECT [COLLECTION_ID]
			  ,[OCCURRENCE]
			  ,[CREATION_DATE]
			  ,[ORG_CODE]
			  ,[SHIFT]
			  ,[LINES]
			  ,[REPAIR_SCRAP_TYPE]
			  ,[REPAIR_SCRAP_REASON]
			  ,[COMP_ITEM]
			  ,[QTY]
			  ,[LBS_REPAIRED_SCRAPPED]
			  ,[ROTO_DESCRIPTION]
			  ,[PIGMEN_RESIN]
			  ,[ERROR_CODE]
			  ,[CREATED_BY]
			  ,[SEGMENT1]
			  ,NULL AS [SHIFT_ID]
			  ,'XXX' AS [Fingerprint]
		FROM OPENQUERY(PROD,
		'SELECT 
					COLLECTION_ID
					,OCCURRENCE
					,to_char( QA_CREATION_DATE, ''MM-DD-YYYY HH24:MI:SS'') AS CREATION_DATE, 
					(SELECT ORGANIZATION_CODE  
					FROM MTL_PARAMETERS  
					WHERE ORGANIZATION_ID = QRV.ORGANIZATION_ID)         AS ORG_CODE,  
					QRV.CHARACTER1                                           AS SHIFT, 
					QRV.CHARACTER2                                           AS LINES, 
					QRV.CHARACTER3                                           AS REPAIR_SCRAP_TYPE, 
					QRV.CHARACTER4                                           AS REPAIR_SCRAP_REASON, 
					QRV.COMP_ITEM                                            AS COMP_ITEM, 
					case  
					when QRV.organization_id = 344 Then NVL(QRV.CHARACTER10,0)  
					else NVL(QRV.CHARACTER8,0)  
					end  as qty, 
					case 
					when QRV.organization_id = 344 Then NVL(QRV.CHARACTER14,0)  
					else NVL(QRV.CHARACTER10,0)  
					end  as LBS_REPAIRED_SCRAPPED, 
					case 
					when QRV.organization_id = 344 Then NVL(QRV.CHARACTER7,0)  
					else NVL(QRV.CHARACTER6,0)  
					end  as ROTO_DESCRIPTION,  
					case 
					when QRV.organization_id = 344 Then NVL(QRV.CHARACTER9,0)  
					else NVL(QRV.CHARACTER7,0)  
					end  as PIGMEN_RESIN, 
					case 
					when QRV.organization_id = 344 Then NVL(QRV.CHARACTER5,0)  
					else NVL(QRV.CHARACTER27,0)  
					end  as ERROR_CODE,      
					QRV.QA_CREATED_BY_NAME                                   AS CREATED_BY  
					, msib.segment1     
		FROM		QA_RESULTS_V QRV 
					LEFT JOIN inv.mtl_system_items_b msib ON qrv.organization_id = msib.organization_id and qrv.item_id = msib.inventory_item_id (+) 
		WHERE		NAME like ''%ROTO_REPAIR_SCRAP'' 
					AND NAME NOT LIKE ''X%'' 
					AND QRV.QA_CREATION_DATE BETWEEN sysdate - 3 and sysdate
					--AND QA_CREATION_DATE BETWEEN TO_DATE( ''" + startDate + "'',''MM/DD/RRRR HH24:MI:SS'') AND TO_DATE( ''" + endDate + ''"'',''MM/DD/RRRR HH24:MI:SS'') 
					AND QRV.organization_id IN ( 86, 87, 344 ) 
					AND QRV.CHARACTER1 = NVL(null,CHARACTER1) 
					AND QRV.CHARACTER2 = NVL(null,CHARACTER2) 
					AND QRV.CHARACTER3 = NVL(null,CHARACTER3) 
					AND QRV.CHARACTER4 = NVL(null,CHARACTER4) 
					AND QRV.COMP_ITEM  = NVL(null,COMP_ITEM) 
					AND NVL(QRV.CHARACTER27,''AAABBBCCC'')=NVL(null,NVL(QRV.CHARACTER27,''AAABBBCCC'')) 
					AND NVL(QRV.CHARACTER26,''AAABBBCCC'')=DECODE( null,''Y'',''YES'',''N'',''NO'',NVL(QRV.CHARACTER26,''AAABBBCCC'' )) 
					AND QRV.QA_CREATED_BY = NVL( null,QRV.QA_CREATED_BY ) 
		'
		)


		--assign ShiftID
		UPDATE pro
		SET SHIFT_ID = s2.Shift_ID
		FROM #Scrap pro
			LEFT JOIN Manufacturing.Shift s2 ON pro.Shift = s2.Shift AND pro.ORG_CODE = s2.Org AND pro.CREATION_DATE >= s2.Start_Date_Time AND pro.CREATION_DATE < s2.End_Date_Time AND s2.CurrentRecord = 1

		--move shift if not mapped to ShiftID
		UPDATE pro
		SET SHIFT_ID = s2.Shift_ID
			,Shift = s2.Shift
		FROM #Scrap pro 
			LEFT JOIN Manufacturing.Shift s2 ON pro.ORG_CODE = s2.Org AND pro.CREATION_DATE >= s2.Start_Date_Time AND pro.CREATION_DATE < s2.End_Date_Time AND s2.CurrentRecord = 1
		WHERE pro.Shift_ID IS NULL

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('Scrap','Oracle') SELECT @columnList
		*/

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

		UPDATE #Scrap
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				    --CAST(ISNULL(COLLECTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(OCCURRENCE,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATION_DATE,'') AS VARCHAR(19)) +  CAST(ISNULL(ORG_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(150)) +  CAST(ISNULL(LINES,'') AS VARCHAR(150)) +  CAST(ISNULL(REPAIR_SCRAP_TYPE,'') AS VARCHAR(150)) +  CAST(ISNULL(REPAIR_SCRAP_REASON,'') AS VARCHAR(150)) +  CAST(ISNULL(COMP_ITEM,'') AS VARCHAR(4000)) +  CAST(ISNULL(QTY,'') AS VARCHAR(150)) +  CAST(ISNULL(LBS_REPAIRED_SCRAPPED,'') AS VARCHAR(150)) +  CAST(ISNULL(ROTO_DESCRIPTION,'') AS VARCHAR(150)) +  CAST(ISNULL(PIGMEN_RESIN,'') AS VARCHAR(150)) +  CAST(ISNULL(ERROR_CODE,'') AS VARCHAR(150)) +  CAST(ISNULL(CREATED_BY,'') AS VARCHAR(100)) +  CAST(ISNULL(SEGMENT1,'') AS VARCHAR(50)) 
					CAST(ISNULL(COLLECTION_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(OCCURRENCE,'0') AS VARCHAR(100)) +  CAST(ISNULL(CREATION_DATE,'') AS VARCHAR(19)) +  CAST(ISNULL(ORG_CODE,'') AS VARCHAR(3)) +  CAST(ISNULL(SHIFT,'') AS VARCHAR(150)) +  CAST(ISNULL(LINES,'') AS VARCHAR(150)) +  CAST(ISNULL(REPAIR_SCRAP_TYPE,'') AS VARCHAR(150)) +  CAST(ISNULL(REPAIR_SCRAP_REASON,'') AS VARCHAR(150)) +  CAST(ISNULL(COMP_ITEM,'') AS VARCHAR(4000)) +  CAST(ISNULL(QTY,'') AS VARCHAR(150)) +  CAST(ISNULL(LBS_REPAIRED_SCRAPPED,'') AS VARCHAR(150)) +  CAST(ISNULL(ROTO_DESCRIPTION,'') AS VARCHAR(150)) +  CAST(ISNULL(PIGMEN_RESIN,'') AS VARCHAR(150)) +  CAST(ISNULL(ERROR_CODE,'') AS VARCHAR(150)) +  CAST(ISNULL(CREATED_BY,'') AS VARCHAR(100)) +  CAST(ISNULL(SEGMENT1,'') AS VARCHAR(50)) +  CAST(ISNULL(Shift_ID,'0') AS VARCHAR(100)) 
			),1)),3,32)


		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

		INSERT INTO Oracle.Scrap (
			   [COLLECTION_ID]
			  ,[OCCURRENCE]
			  ,[CREATION_DATE]
			  ,[ORG_CODE]
			  ,[SHIFT]
			  ,[LINES]
			  ,[REPAIR_SCRAP_TYPE]
			  ,[REPAIR_SCRAP_REASON]
			  ,[COMP_ITEM]
			  ,[QTY]
			  ,[LBS_REPAIRED_SCRAPPED]
			  ,[ROTO_DESCRIPTION]
			  ,[PIGMEN_RESIN]
			  ,[ERROR_CODE]
			  ,[CREATED_BY]
			  ,[SEGMENT1]
			  ,[SHIFT_ID]
			  ,[FINGERPRINT]
		)
			SELECT 
				   a.[COLLECTION_ID]
				  ,a.[OCCURRENCE]
				  ,a.[CREATION_DATE]
				  ,a.[ORG_CODE]
				  ,a.[SHIFT]
				  ,a.[LINES]
				  ,a.[REPAIR_SCRAP_TYPE]
				  ,a.[REPAIR_SCRAP_REASON]
				  ,a.[COMP_ITEM]
				  ,a.[QTY]
				  ,a.[LBS_REPAIRED_SCRAPPED]
				  ,a.[ROTO_DESCRIPTION]
				  ,a.[PIGMEN_RESIN]
				  ,a.[ERROR_CODE]
				  ,a.[CREATED_BY]
				  ,a.[SEGMENT1]
				  ,a.[SHIFT_ID]
				  ,a.[FINGERPRINT]
			FROM (
				MERGE Oracle.Scrap b
				USING (SELECT * FROM #Scrap) a
				ON a.COLLECTION_ID = b.COLLECTION_ID AND a.OCCURRENCE = b.OCCURRENCE AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [COLLECTION_ID]
					  ,[OCCURRENCE]
					  ,[CREATION_DATE]
					  ,[ORG_CODE]
					  ,[SHIFT]
					  ,[LINES]
					  ,[REPAIR_SCRAP_TYPE]
					  ,[REPAIR_SCRAP_REASON]
					  ,[COMP_ITEM]
					  ,[QTY]
					  ,[LBS_REPAIRED_SCRAPPED]
					  ,[ROTO_DESCRIPTION]
					  ,[PIGMEN_RESIN]
					  ,[ERROR_CODE]
					  ,[CREATED_BY]
					  ,[SEGMENT1]
					  ,[SHIFT_ID]
					  ,[FINGERPRINT]
				)
				VALUES (
					   a.[COLLECTION_ID]
					  ,a.[OCCURRENCE]
					  ,a.[CREATION_DATE]
					  ,a.[ORG_CODE]
					  ,a.[SHIFT]
					  ,a.[LINES]
					  ,a.[REPAIR_SCRAP_TYPE]
					  ,a.[REPAIR_SCRAP_REASON]
					  ,a.[COMP_ITEM]
					  ,a.[QTY]
					  ,a.[LBS_REPAIRED_SCRAPPED]
					  ,a.[ROTO_DESCRIPTION]
					  ,a.[PIGMEN_RESIN]
					  ,a.[ERROR_CODE]
					  ,a.[CREATED_BY]
					  ,a.[SEGMENT1]
					  ,a.[SHIFT_ID]
					  ,a.[FINGERPRINT]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[COLLECTION_ID]
					  ,a.[OCCURRENCE]
					  ,a.[CREATION_DATE]
					  ,a.[ORG_CODE]
					  ,a.[SHIFT]
					  ,a.[LINES]
					  ,a.[REPAIR_SCRAP_TYPE]
					  ,a.[REPAIR_SCRAP_REASON]
					  ,a.[COMP_ITEM]
					  ,a.[QTY]
					  ,a.[LBS_REPAIRED_SCRAPPED]
					  ,a.[ROTO_DESCRIPTION]
					  ,a.[PIGMEN_RESIN]
					  ,a.[ERROR_CODE]
					  ,a.[CREATED_BY]
					  ,a.[FINGERPRINT]
					  ,a.[SEGMENT1]
					  ,a.[SHIFT_ID]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		DROP TABLE #Scrap
END
GO
