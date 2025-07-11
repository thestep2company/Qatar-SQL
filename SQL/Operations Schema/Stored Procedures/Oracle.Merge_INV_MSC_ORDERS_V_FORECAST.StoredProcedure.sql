USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_INV_MSC_ORDERS_V_FORECAST]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_INV_MSC_ORDERS_V_FORECAST] 
AS BEGIN

	UPDATE Oracle.MSC_ORDERS_V_FORECAST
	SET CurrentRecord = 0, EndDate = GETDATE()
	WHERE EndDate IS NULL

	INSERT INTO Oracle.MSC_ORDERS_V_FORECAST
	SELECT
		   [SOURCE_TABLE]
		  ,[ITEM_SEGMENTS]
		  ,[DESCRIPTION]
		  ,[USING_ASSEMBLY_SEGMENTS]
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
		  ,CAST('XXXXXXXXXXXXX' AS VARCHAR(32)) AS Fingerprint
		  ,GETDATE() AS [StartDate]
		  ,CAST(NULL AS DATETIME) AS [EndDate]
		  ,CAST(1 AS BIT) AS CurrentRecord
	--where clause 317949 @ ? 4:29
	--No condition 1091963 @ 8:51
	FROM OPENQUERY(ASCP, '
		SELECT DISTINCT
			   mov.source_table
			  ,mov.item_segments
			  ,mov.description
			  ,mov.using_assembly_segments
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
		FROM   msc_orders_v  mov
		WHERE (mov.quantity <> 0 and mov.plan_id = 21 and mov.order_type in (18, 29, 30))  --forecast open orders on hand
	'
	)

END

GO
