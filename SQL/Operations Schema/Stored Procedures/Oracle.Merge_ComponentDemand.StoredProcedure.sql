USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_ComponentDemand]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_ComponentDemand] AS BEGIN

		TRUNCATE TABLE Oracle.ComponentDemand 

		INSERT INTO Oracle.ComponentDemand 
		SELECT * FROM OPENQUERY(ASCP,
		'	select 
			md.demand_id
			,msi.item_name
			,msi.description
			,md.using_assembly_demand_date - to_char(md.using_assembly_demand_date,''D'')+1  START_OF_WEEK
			,md.using_assembly_demand_date
			,md.USING_REQUIREMENT_QUANTITY
			,md.organization_id
			,md.source_organization_id
			,md.demand_type
			,md.origination_type
			,md.demand_Priority
			,md.plan_id
			,md.promise_date
			,md.demand_class
			,md.firm_date
		from msc_demands  md
			, msc_system_items msi
		where 1=1
			and md.inventory_item_id = msi.inventory_item_id
			and md.plan_id = msi.plan_id
			and md.organization_id = msi.organization_id
			and md.USING_REQUIREMENT_QUANTITY <> 0
			and md.plan_id = 4
			and ( md.source_organization_id < 0 or md.organization_id = md.source_organization_id  )
			and msi.item_name < ''400000'' 
		--order by md.using_assembly_demand_date
		'
		)

END
GO
