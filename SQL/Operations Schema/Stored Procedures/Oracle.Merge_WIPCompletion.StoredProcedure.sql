USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_WIPCompletion]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Oracle].[Merge_WIPCompletion] AS BEGIN

	BEGIN TRY 
		BEGIN TRAN

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Delete', GETDATE()

			DELETE FROM Oracle.WIPCompletion WHERE TRANSACTION_DATE >= DATEADD(DAY,-7,CAST(GETDATE() AS DATE))

			INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Oracle Download', GETDATE()
			
			INSERT INTO Oracle.WIPCompletion

			SELECT * 
			FROM OPENQUERY(PROD,
			'select 
				mp.organization_code AS org_code,
				ood.organization_name AS org_name,
				mts.TRANSACTION_SOURCE_TYPE_NAME AS trans_src_typ_name,
				mtt.transaction_type_name AS transaction_type,
				mtt.description as transaction_description,
				mmt.TRANSACTION_DATE AS transaction_date,
				mmt.subinventory_code AS FROM_SUBINVENTORY,
				milf.concatenated_segments as from_locator, 
				mmt.transfer_subinventory AS TO_SUBINVENTORY,
				milt.concatenated_segments as to_locator,  
				msi.segment1 AS item,
				sum(mmt.PRIMARY_QUANTITY) AS primary_qty,               
				sum(mmt.PRIMARY_QUANTITY * cic.ITEM_COST) AS ext_val,
				fnd.user_name as transaction_user              
			from inv.mtl_txn_source_types mts,
				inv.mtl_material_transactions mmt,
				inv.mtl_transaction_types mtt,
				mtl_item_locations_kfv milt,
				mtl_item_locations_kfv milf,
				bom.cst_cost_types cct,
				bom.cst_item_costs cic,
				inv.mtl_system_items_b msi,
				fnd_user fnd,
				inv.mtl_parameters mp,
				ORG_ORGANIZATION_DEFINITIONS OOD
			where
				--mp.organization_id = ''122'' --nvl( :P_ORG_ID, mp.organization_id )
				cct.COST_TYPE = ''Frozen''
				and mmt.created_by = fnd.user_id
				and mmt.transaction_source_type_id = mts.TRANSACTION_SOURCE_TYPE_ID
				and mmt.transaction_type_id = mtt.transaction_type_id
				and cic.cost_type_id = cct.cost_type_id
				and cic.inventory_item_id = msi.inventory_item_id
				and cic.organization_id = msi.organization_id
				and mmt.inventory_item_id = msi.inventory_item_id
				and mmt.organization_id = msi.organization_id
				and msi.organization_id = mp.organization_id
				and mmt.transfer_locator_id = milt.inventory_location_id (+)
				and mmt.locator_id = milf.inventory_location_id (+)
				--and fnd.user_name = nvl( :P_USER, fnd.user_name )
				and ood.organization_id = mp.organization_id
				AND MMT.TRANSACTION_DATE >= trunc(sysdate - 7) --BETWEEN TO_DATE( :P_START_DATE_TIME, ''YYYY/MM/DD HH24:MI:SS'' )
				--AND TO_DATE( :P_END_DATE_TIME, ''YYYY/MM/DD HH24:MI:SS'' )
			group by
				mp.organization_code,
				ood.organization_name,
				mts.TRANSACTION_SOURCE_TYPE_NAME,
				mtt.transaction_type_name,
				mtt.description,
				milf.concatenated_segments,
				milt.concatenated_segments,  
				mmt.TRANSACTION_DATE,
				mmt.subinventory_code,
				mmt.transfer_subinventory,
				msi.segment1,
				fnd.user_name 
			')
		INSERT INTO dbo.ETLLog SELECT OBJECT_NAME(@@PROCID), 'Done', GETDATE()

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		THROW
	END CATCH
END
GO
