USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MSC_ORDERS_V]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MSC_ORDERS_V] AS BEGIN

	DECLARE @startDate DATETIME = GETDATE()
	
	DECLARE @proceed INT = 0 
	EXEC Oracle.Merge_FND_CONC_REQ_SUMMARY_V

	WHILE @proceed = 0 BEGIN

		SELECT @proceed = ISNULL(COUNT(*),0) 
		FROM Oracle.FND_CONC_REQ_SUMMARY_V 
		WHERE Meridiem = CASE WHEN DATEPART(HOUR,GETDATE()) < 12 THEN 'AM' ELSE 'PM' END 
			AND CAST(ACTUAL_START_DATE AS DATE) = CAST(GETDATE() AS DATE) 
			AND PHASE_CODE = 'C'
			AND DESCRIPTION = 'XX Refresh Materialized Views(140)'

		IF @proceed = 0 BEGIN
			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Waiting...', GETDATE()
			WAITFOR DELAY '00:01:00'
			EXEC Oracle.Merge_FND_CONC_REQ_SUMMARY_V
		END
	END

	TRUNCATE TABLE Oracle.MSC_ORDERS_V_STAGING
	
	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()

	INSERT INTO Oracle.MSC_ORDERS_V_STAGING (
		   [SOURCE_TABLE]
		  ,[ITEM_SEGMENTS]
		  ,[DESCRIPTION]
		  ,[DEMAND_CLASS]
		  ,[NEW_ORDER_DATE]
		  ,[FIRM_PLANNED_TYPE]
		  ,[FIRM_DATE]
		  ,[QUANTITY]
		  ,[ORDER_TYPE_TEXT]
		  ,[ORDER_TYPE]
		  ,[NEW_DUE_DATE]
		  ,[PLANNER_CODE]
		  ,[ORGANIZATION_CODE]
		  ,[SOURCE_ORGANIZATION_CODE]
		  ,[PLAN_ID]
		  ,[START_OF_WEEK]
		  ,[ROW_ID]
		  ,[TRANSACTION_ID]
		  ,[FINGERPRINT]
	)
	SELECT
		   [SOURCE_TABLE]
		  ,[ITEM_SEGMENTS]
		  ,[DESCRIPTION]
		  ,[DEMAND_CLASS]
		  ,[NEW_ORDER_DATE]
		  ,[FIRM_PLANNED_TYPE]
		  ,[FIRM_DATE]
		  ,[QUANTITY]
		  ,[ORDER_TYPE_TEXT]
		  ,[ORDER_TYPE]
		  ,[NEW_DUE_DATE]
		  ,[PLANNER_CODE]
		  ,[ORGANIZATION_CODE]
		  ,[SOURCE_ORGANIZATION_CODE]
		  ,[PLAN_ID]
		  ,[START_OF_WEEK]
		  ,[ROW_ID]
		  ,TRANSACTION_ID
		  ,'XXX' AS [FINGERPRINT]
	--where clause 317949 @ ? 4:29
	--No condition 1091963 @ 8:51
	FROM OPENQUERY(ASCP, '
		SELECT DISTINCT
			   mov.source_table
			  ,mov.item_segments
			  ,mov.description
			  ,mov.demand_class 
			  ,mov.NEW_ORDER_DATE
			  ,mov.FIRM_PLANNED_TYPE
			  ,mov.FIRM_DATE	
			  ,mov.QUANTITY
			  ,mov.ORDER_TYPE_TEXT
			  ,mov.ORDER_TYPE
			  ,mov.NEW_DUE_DATE
			  ,mov.PLANNER_CODE
			  ,mov.ORGANIZATION_CODE
			  ,mov.source_organization_Code
			  ,mov.plan_id
			  ,mov.NEW_DUE_DATE - to_char(mov.NEW_DUE_DATE,''D'') + 1  START_OF_WEEK
			  ,mov.ROW_ID 
			  ,TRANSACTION_ID
		FROM   msc_orders_v  mov
		WHERE ((mov.quantity <> 0 and mov.plan_id = 4  AND mov.order_type in (1,3,24,30) AND mov.source_table = ''MSC_DEMANDS'') --demand
			  OR (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (29, 30))  --forecast open orders
			  OR (mov.quantity <> 0	and mov.plan_id = 4  and mov.order_type = 5) --production plan
			  OR (mov.quantity <> 0 and mov.plan_id = 4  and mov.order_type = 18 and mov.item_segments < ''400000'')  --components on hand
			  OR (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type = 18 and mov.item_segments >= ''400000'')  --on hand
			  OR (mov.quantity <> 0 and mov.plan_id = 4 and mov.order_type in (1, 3) and mov.source_table = ''MSC_SUPPLIES'')  --purchase orders components
			  OR (mov.quantity <> 0 and mov.plan_id = 22 and mov.order_type in (1, 3) and mov.source_table = ''MSC_SUPPLIES'')  --purchase orders
			  OR (mov.quantity <> 0 and mov.plan_id = 22 AND mov.order_type = 51 and mov.source_table = ''MSC_SUPPLIES'') --planned inbound shipment
			  OR (mov.quantity <> 0 and mov.plan_id = 22 AND mov.order_type = 1 and mov.source_table = ''MSC_DEMANDS'')) --planned order demand
	'
	)
	--ORDER BY ORDER_TYPE_TEXT, PLAN_ID

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

	;WITH CTE AS (
		SELECT TRANSACTION_ID, MIN(PLAN_ID) AS MIN_PLAN, MAX(PLAN_ID) AS MAX_PLAN 
		FROM Oracle.MSC_ORDERS_V_STAGING
		GROUP BY TRANSACTION_ID HAVING MIN(PLAN_ID) <> MAX(PLAN_ID)
	)
	, LowestPlan AS (
		SELECT MP.TRANSACTION_ID, MP.PLAN_ID, MP.ROW_ID 
		FROM CTE 
			INNER JOIN Oracle.MSC_ORDERS_V_STAGING MP ON CTE.TRANSACTION_ID = MP.TRANSACTION_ID 
				AND CTE.MIN_PLAN = MP.PLAN_ID 
	)
	--SELECT *
	DELETE FROM MSC
	FROM Oracle.MSC_ORDERS_V_STAGING MSC
		INNER JOIN LowestPlan LP ON MSC.ROW_ID = LP.ROW_ID

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Fingerprint', GETDATE()

	/*
		DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('MSC_ORDERS_V','Oracle') SELECT @columnList
	*/
	UPDATE  Oracle.MSC_ORDERS_V_STAGING
	SET Fingerprint = 
		SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
			--replace @columnList result here
			  CAST(ISNULL([SOURCE_TABLE],'') AS VARCHAR(100)) +  CAST(ISNULL([ITEM_SEGMENTS],'') AS VARCHAR(250)) +  CAST(ISNULL([DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([DEMAND_CLASS],'') AS VARCHAR(34)) +  CAST(ISNULL([NEW_ORDER_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([FIRM_PLANNED_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([FIRM_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([QUANTITY],'0') AS VARCHAR(100)) +  CAST(ISNULL([ORDER_TYPE_TEXT],'') AS VARCHAR(4000)) +  CAST(ISNULL([ORDER_TYPE],'0') AS VARCHAR(100)) +  CAST(ISNULL([NEW_DUE_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([PLANNER_CODE],'') AS VARCHAR(10)) +  CAST(ISNULL([ORGANIZATION_CODE],'') AS VARCHAR(7)) +  CAST(ISNULL([PLAN_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([START_OF_WEEK],'') AS VARCHAR(100)) +  CAST(ISNULL([ROW_ID] COLLATE SQL_Latin1_General_CP1_CS_AS,'') AS VARCHAR(50)) +  CAST(ISNULL([SOURCE_ORGANIZATION_CODE],'') AS VARCHAR(7)) 
		),1)),3,32);

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Expire', GETDATE()

	--expire records outside the merge
	UPDATE a
	SET EndDate = @startDate, CurrentRecord = 0
	--SELECT COUNT(*)
	FROM Oracle.MSC_ORDERS_V a
		LEFT JOIN  Oracle.MSC_ORDERS_V_STAGING b ON a.Row_ID = b.Row_ID
	WHERE b.Row_ID IS NULL AND a.EndDate IS NULL

	INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Merge', GETDATE()

	INSERT INTO Oracle.MSC_ORDERS_V (
		   [SOURCE_TABLE]
		  ,[ITEM_SEGMENTS]
		  ,[DESCRIPTION]
		  ,[DEMAND_CLASS]
		  ,[NEW_ORDER_DATE]
		  ,[FIRM_PLANNED_TYPE]
		  ,[FIRM_DATE]
		  ,[QUANTITY]
		  ,[ORDER_TYPE_TEXT]
		  ,[ORDER_TYPE]
		  ,[NEW_DUE_DATE]
		  ,[PLANNER_CODE]
		  ,[ORGANIZATION_CODE]
		  ,[SOURCE_ORGANIZATION_CODE]
		  ,[PLAN_ID]
		  ,[START_OF_WEEK]
		  ,[ROW_ID]
		  ,[FINGERPRINT]
	)
		SELECT 
			   a.[SOURCE_TABLE]
			  ,a.[ITEM_SEGMENTS]
			  ,a.[DESCRIPTION]
			  ,a.[DEMAND_CLASS]
			  ,a.[NEW_ORDER_DATE]
			  ,a.[FIRM_PLANNED_TYPE]
			  ,a.[FIRM_DATE]
			  ,a.[QUANTITY]
			  ,a.[ORDER_TYPE_TEXT]
			  ,a.[ORDER_TYPE]
			  ,a.[NEW_DUE_DATE]
			  ,a.[PLANNER_CODE]
			  ,a.[ORGANIZATION_CODE]
			  ,a.[SOURCE_ORGANIZATION_CODE]
			  ,a.[PLAN_ID]
			  ,a.[START_OF_WEEK]
			  ,a.[ROW_ID]
			  ,a.[FINGERPRINT]
		FROM (
			MERGE Oracle.MSC_ORDERS_V b
			USING (SELECT * FROM  Oracle.MSC_ORDERS_V_STAGING) a
			ON a.Row_ID = b.Row_ID AND b.CurrentRecord = 1 AND b.EndDate IS NULL--swap with business key of table
			WHEN NOT MATCHED BY TARGET 
			THEN INSERT (
				   [SOURCE_TABLE]
				  ,[ITEM_SEGMENTS]
				  ,[DESCRIPTION]
				  ,[DEMAND_CLASS]
				  ,[NEW_ORDER_DATE]
				  ,[FIRM_PLANNED_TYPE]
				  ,[FIRM_DATE]
				  ,[QUANTITY]
				  ,[ORDER_TYPE_TEXT]
				  ,[ORDER_TYPE]
				  ,[NEW_DUE_DATE]
				  ,[PLANNER_CODE]
				  ,[ORGANIZATION_CODE]
				  ,[SOURCE_ORGANIZATION_CODE]
				  ,[PLAN_ID]
				  ,[START_OF_WEEK]
				  ,[ROW_ID]
				  ,[FINGERPRINT]
			)
			VALUES (
				   a.[SOURCE_TABLE]
				  ,a.[ITEM_SEGMENTS]
				  ,a.[DESCRIPTION]
				  ,a.[DEMAND_CLASS]
				  ,a.[NEW_ORDER_DATE]
				  ,a.[FIRM_PLANNED_TYPE]
				  ,a.[FIRM_DATE]
				  ,a.[QUANTITY]
				  ,a.[ORDER_TYPE_TEXT]
				  ,a.[ORDER_TYPE]
				  ,a.[NEW_DUE_DATE]
				  ,a.[PLANNER_CODE]
				  ,a.[ORGANIZATION_CODE]
				  ,a.[SOURCE_ORGANIZATION_CODE]
				  ,a.[PLAN_ID]
				  ,a.[START_OF_WEEK]
				  ,a.[ROW_ID]
				  ,a.[FINGERPRINT]
			)
			--Existing records that have changed are expired
			WHEN MATCHED AND a.Fingerprint<>b.Fingerprint 
			THEN UPDATE SET b.EndDate=@startDate
				,b.CurrentRecord=0
			----Existing records that are no longer in the data source (full compare only)
			--WHEN NOT MATCHED BY SOURCE 
			--THEN UPDATE SET b.EndDate=@startDate, CurrentRecord = 0
			OUTPUT 
				   a.[SOURCE_TABLE]
				  ,a.[ITEM_SEGMENTS]
				  ,a.[DESCRIPTION]
				  ,a.[DEMAND_CLASS]
				  ,a.[NEW_ORDER_DATE]
				  ,a.[FIRM_PLANNED_TYPE]
				  ,a.[FIRM_DATE]
				  ,a.[QUANTITY]
				  ,a.[ORDER_TYPE_TEXT]
				  ,a.[ORDER_TYPE]
				  ,a.[NEW_DUE_DATE]
				  ,a.[PLANNER_CODE]
				  ,a.[ORGANIZATION_CODE]
				  ,a.[SOURCE_ORGANIZATION_CODE]
				  ,a.[PLAN_ID]
				  ,a.[START_OF_WEEK]
				  ,a.[ROW_ID]
				  ,a.[FINGERPRINT]
				  ,$Action AS Action
		) a
		WHERE Action = 'Update' 
		;

		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

END
GO
