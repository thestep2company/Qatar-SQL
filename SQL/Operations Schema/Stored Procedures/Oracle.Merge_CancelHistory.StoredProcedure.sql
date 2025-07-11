USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_CancelHistory]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Oracle].[Merge_CancelHistory] AS BEGIN

	BEGIN TRY
		BEGIN TRAN
		--DECLARE @lineID INT = 49764760
		--SELECT * FROM Output.CancelledOrders WHERE ORD_LINE_ID = @lineID

		/*
		50813176
		50813247
		50800454
		50867996
		50739008
		50602918
		50739008
		*/
		-- 

		--DROP TABLE IF EXISTS Oracle.OrderLineHistory

		DELETE FROM Oracle.OrderLineHistory WHERE HIST_CREATION_DATE >= '2023-01-01'
	
		INSERT INTO Oracle.OrderLineHistory
		SELECT LINE_ID
			, UNIT_SELLING_PRICE*PRICING_QUANTITY AS SELLING_PRICE
			, UNIT_LIST_PRICE*PRICING_QUANTITY AS LIST_PRICE
			, PRICING_QUANTITY
			, HIST_TYPE_CODE
			, HIST_CREATION_DATE
		FROM OPENQUERY(PROD,'SELECT * FROM oe_order_lines_history lh WHERE HIST_TYPE_CODE = ''CANCELLATION'' AND TRUNC(HIST_CREATION_DATE) >= TO_DATE(''20230101'',''YYYYMMDD'')' ) d

		SELECT YEAR(HIST_CREATION_DATE), SUM(LIST_PRICE) FROM Oracle.OrderLineHistory GROUP BY YEAR(HIST_CREATION_DATE)

		DROP TABLE IF EXISTS Output.CancelHistory

		;
		WITH PurgedOrders AS (
			SELECT ORD_LINE_ID FROM Oracle.Orders
			WHERE CAST(ORDER_DATE AS DATE) >= '2021-01-01'
			GROUP BY ORD_LINE_ID HAVING MIN(CAST(CurrentRecord AS SMALLINT)) = MAX(CAST(CurrentRecord AS SMALLINT))
		)
		, CanceledOrders AS (
			SELECT ORDER_NUM, ORDER_LINE_NUM FROM Oracle.Orders
			WHERE CAST(ORDER_DATE AS DATE) >= '2021-01-01' AND FLOW_STATUS_CODE = 'CANCELLED'
			GROUP BY ORDER_NUM, ORDER_LINE_NUM
		)

		SELECT
			  ISNULL(rd.Cancel_Reason, 'No reason provided') AS Cancel_Reason
			, ISNULL(cr.[Cancelation Category],'No reason provided') AS [Cancelation Category]
			, rd.USERNAME AS [Canceled By]
			, d.[LINE_ID]
			, d.[SELLING_PRICE]
			, d.[LIST_PRICE]
			, d.[PRICING_QUANTITY]
			, d.[HIST_TYPE_CODE]
			, d.[HIST_CREATION_DATE]
			, o.[ORD_LINE_ID]
			, o.[ORD_HEADER_ID]
			, o.[CUSTOMER_NAME]
			, o.[CUSTOMER_NUM]
			, o.[SALES_CHANNEL_CODE]
			, o.[DEMAND_CLASS]
			, CAST(o.[ORDER_DATE] AS DATE) AS [ORDER_DATE]
			, o.[ORDER_NUM]
			, o.[PART]
			, o.[ORDERED_ITEM]
			, o.[PART_DESC]
			, o.[FLOW_STATUS_CODE]
			, o.[QTY]
			, o.[SELL_DOLLARS]
			, o.[LIST_DOLLARS]
			, o.[DATE_REQUESTED]
			, o.[SCH_SHIP_DATE]
			, o.[CANCEL_DATE]
			, o.[PLANT]
			, o.[CREATE_DATE]
			, o.[ORD_LINE_CREATE_DATE]
			, o.[ORD_LINE_LST_UPDATE_DATE]
			, o.[SHIP_TO_ADDRESS1]
			, o.[SHIP_TO_ADDRESS2]
			, o.[SHIP_TO_ADDRESS3]
			, o.[SHIP_TO_ADDRESS4]
			, o.[SHIP_TO_CITY]
			, o.[SHIP_TO_STATE]
			, o.[SHIP_TO_POSTAL_CODE]
			, o.[SHIP_TO_COUNTRY]
			, o.[SHIP_TO_PROVINCE]
			, o.[Fingerprint]
			, o.[StartDate]
			, o.[EndDate]
			, o.[CurrentRecord]
			, o.[ACTUAL_SHIPMENT_DATE]
			, o.[ORDER_LINE_NUM]
			, o.[SHIPPING_METHOD_CODE]
		INTO Output.CancelHistory
		FROM Oracle.OrderLineHistory d 
			INNER JOIN Oracle.Orders o ON o.ORD_LINE_ID = d.LINE_ID AND d.HIST_CREATION_DATE BETWEEN DATEADD(MINUTE,-15,o.StartDate) AND StartDate --use current record if data was purged (no sales or qty available)
			INNER JOIN PurgedOrders po ON po.ORD_LINE_ID = o.ORD_LINE_ID
			INNER JOIN CanceledOrders co ON o.ORDER_NUM = co.ORDER_NUM AND o.ORDER_LINE_NUM = co.ORDER_LINE_NUM
			LEFT JOIN Oracle.CancelledOrdersReasonDetail rd ON o.ORDER_NUM = rd.ORDNUM AND o.ORD_LINE_ID = rd.lineID AND CAST(CANDATE AS DATE) = CAST(o.StartDate AS DATE)
			LEFT JOIN xref.CancelReason cr ON rd.[CANCEL_REASON] = cr.[Cancelation Description]
		WHERE o.CurrentRecord = 1	
			--AND d.LINE_ID = @lineID
		UNION
		SELECT 
			  ISNULL(rd.Cancel_Reason, 'No reason provided') AS Cancel_Reason
			, ISNULL(cr.[Cancelation Category],'No reason provided') AS [Cancelation Category]
			, rd.USERNAME AS [Canceled By]
			, d.[LINE_ID]
			, d.[SELLING_PRICE]
			, d.[LIST_PRICE]
			, d.[PRICING_QUANTITY]
			, d.[HIST_TYPE_CODE]
			, d.[HIST_CREATION_DATE]
			, o.[ORD_LINE_ID]
			, o.[ORD_HEADER_ID]
			, o.[CUSTOMER_NAME]
			, o.[CUSTOMER_NUM]
			, o.[SALES_CHANNEL_CODE]
			, o.[DEMAND_CLASS]
			, CAST(o.[ORDER_DATE] AS DATE) AS [ORDER_DATE]
			, o.[ORDER_NUM]
			, o.[PART]
			, o.[ORDERED_ITEM]
			, o.[PART_DESC]
			, o.[FLOW_STATUS_CODE]
			, o.[QTY]
			, o.[SELL_DOLLARS]
			, o.[LIST_DOLLARS]
			, o.[DATE_REQUESTED]
			, o.[SCH_SHIP_DATE]
			, o.[CANCEL_DATE]
			, o.[PLANT]
			, o.[CREATE_DATE]
			, o.[ORD_LINE_CREATE_DATE]
			, o.[ORD_LINE_LST_UPDATE_DATE]
			, o.[SHIP_TO_ADDRESS1]
			, o.[SHIP_TO_ADDRESS2]
			, o.[SHIP_TO_ADDRESS3]
			, o.[SHIP_TO_ADDRESS4]
			, o.[SHIP_TO_CITY]
			, o.[SHIP_TO_STATE]
			, o.[SHIP_TO_POSTAL_CODE]
			, o.[SHIP_TO_COUNTRY]
			, o.[SHIP_TO_PROVINCE]
			, o.[Fingerprint]
			, o.[StartDate]
			, o.[EndDate]
			, o.[CurrentRecord]
			, o.[ACTUAL_SHIPMENT_DATE]
			, o.[ORDER_LINE_NUM]
			, o.[SHIPPING_METHOD_CODE]	
		FROM Oracle.OrderLineHistory d 
			INNER JOIN Oracle.Orders o ON o.ORD_LINE_ID = d.LINE_ID AND d.HIST_CREATION_DATE BETWEEN DATEADD(MINUTE,-15,o.EndDate) AND o.EndDate --use prior record (non cancelled) if data has history
			LEFT JOIN PurgedOrders po ON po.ORD_LINE_ID = o.ORD_LINE_ID
			INNER JOIN CanceledOrders co ON o.ORDER_NUM = co.ORDER_NUM AND o.ORDER_LINE_NUM = co.ORDER_LINE_NUM
			LEFT JOIN Oracle.CancelledOrdersReasonDetail rd ON o.ORDER_NUM = rd.ORDNUM AND o.ORD_LINE_ID = rd.lineID AND CAST(CANDATE AS DATE) = CAST(o.EndDate AS DATE)
			LEFT JOIN xref.CancelReason cr ON rd.[CANCEL_REASON] = cr.[Cancelation Description]
		WHERE po.ORD_LINE_ID IS NULL AND o.FLOW_STATUS_CODE <> 'CANCELLED'
			--AND d.LINE_ID = @LineID
		ORDER BY StartDate

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		THROW
		ROLLBACK TRAN
	END CATCH

END

--SELECT * FROM Output.CancelHistory
--SELECT * FROM [OUTPUT].[CancelledOrders20230816]

--SELECT * FROM Oracle.Orders WHERE ORD_LINE_ID = @lineID ORDER BY StartDate 

--SELECT * FROM Output.CancelledOrders WHERE ORD_LINE_ID = @lineID

--SELECT TOP 100 * FROM Oracle.CancelledOrdersReasonDetail rd WHERE ORDNUM = '19657311' ORDER BY CANDATE
GO
