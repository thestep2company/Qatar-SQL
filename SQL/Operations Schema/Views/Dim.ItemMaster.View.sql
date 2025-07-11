USE [Operations]
GO
/****** Object:  View [Dim].[ItemMaster]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[ItemMaster] AS
SELECT
    msib.segment1
    , msib.description
	, msib.organization_id
    , mp.organization_code AS Org_Code
    , ISNULL(msib.inventory_item_id,'') AS inventory_item_id
    , ISNULL(msib.primary_uom_code,'') AS UOM
    , ISNULL(msib.item_type,'') AS item_type
    , ISNULL(msib.inventory_item_status_code,'') AS inventory_item_status_code
    , ISNULL(msib.attribute9,'') AS siop_family
    , ISNULL(msib.attribute1,'') AS "CATEGORY"
    , ISNULL(msib.attribute2,'') AS SubCategory
    , ISNULL(msib.attribute3,'') AS Brand
    , ISNULL(msib.attribute7,'') AS Country_of_Origin
    , ISNULL(mcr.Cross_reference,'')     AS UPC
from Oracle.inv_mtl_system_items_b msib
    LEFT JOIN Oracle.APPS_MTL_CROSS_REFERENCES mcr on msib.INVENTORY_ITEM_ID = mcr.INVENTORY_ITEM_ID and mcr.cross_reference_type = 'UPC' AND mcr.CurrentRecord = 1
    LEFT JOIN Oracle.INV_mtl_parameters  mp ON msib.organization_id = mp.organization_id AND mp.CurrentRecord = 1
where msib.organization_id = 85 AND msib.CurrentRecord = 1

GO
