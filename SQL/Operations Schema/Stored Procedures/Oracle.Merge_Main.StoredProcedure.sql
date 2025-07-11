USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_Main]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_Main] AS BEGIN

	--base Oracle tables or _V views
	EXEC [Oracle].[Merge_INV_MTL_ONHAND_QUANTITIES_DETAIL]
	EXEC [Oracle].[Merge_INV_SECONDARY_INVENTORIES]
	EXEC [Oracle].[Merge_INV_MTL_SYSTEM_ITEMS_B]
	EXEC [Oracle].[Merge_INV_MTL_SYSTEM_ITEMS_TL]
	EXEC [Oracle].[Merge_INV_MTL_UOM_CLASS_CONVERSIONS]
	
	EXEC [Oracle].[Merge_INV_MTL_MATERIAL_TRANSACTIONS]
	EXEC [Oracle].[Merge_INV_MTL_PARAMETERS]
	EXEC [Oracle].[Merge_INV_MTL_TRANSACTION_TYPES]
	EXEC [Oracle].[Merge_INV_MTL_ITEM_LOCATIONS]

	EXEC [Oracle].[Merge_JTF_RS_SALESREPS]
	EXEC [Oracle].[Merge_JTF_RS_RESOURCE_EXTNS_VL] 

	EXEC [Oracle].[Merge_PO_VENDORS]
	EXEC [Oracle].[Merge_QP_LIST_LINES_V]
	EXEC [Oracle].[Merge_QP_SECU_LIST_HEADERS_V]

	EXEC [Oracle].[Merge_RA_CUST_TRX_LINE_SALESREPS_ALL] 
	
	EXEC [Oracle].[Merge_WIP]
	EXEC [Oracle].[Merge_WIPCompletion]
	EXEC [Oracle].[Merge_WIP_FLOW_SCHEDULES]
	EXEC [Oracle].[Merge_WIP_LINES]

	EXEC [Oracle].[Merge_APPS_MTL_CROSS_REFERENCES]
	EXEC [Oracle].[Merge_BOM_RESOURCES]
	EXEC [Oracle].[Merge_CRP_RESOURCE_HOURS]
	EXEC [Oracle].[Merge_CST_ITEM_COST_TYPE_V]
	EXEC [Oracle].[Merge_HR_OPERATING_UNITS]
	EXEC [Oracle].[Merge_ORG_ORGANIZATION_DEFINITIONS]
	
	--derived Oracle data
	EXEC [Oracle].[Merge_ApprovedSupplierList]
	EXEC [Oracle].[Merge_Buyer]
	EXEC [Oracle].[Merge_CancelledOrdersReasonDetail]
	EXEC [Oracle].[Merge_COGSActual]
	EXEC [Oracle].[Merge_Inventory]
	EXEC [Oracle].[Merge_PriceList]
	EXEC [Oracle].[Merge_POExpense]
	EXEC [Oracle].[Merge_CustomerPriceList]
	EXEC [Oracle].[Merge_DebitCreditMemo]
	--EXEC [Oracle].[Merge_Pricing]
	EXEC [Oracle].[Merge_RotoParts] --clean up BOM downloads and decommission
	EXEC [Oracle].[Merge_TradeManagement]

END
GO
