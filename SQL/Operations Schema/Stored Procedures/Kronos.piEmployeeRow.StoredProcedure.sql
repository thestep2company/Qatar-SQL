USE [Operations]
GO
/****** Object:  StoredProcedure [Kronos].[piEmployeeRow]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE     PROCEDURE [Kronos].[piEmployeeRow]
	@EmployeeId varchar(250)
    ,@EmployeeNumber varchar(250) null
    ,@EmployeeFullName varchar(250) null
    ,@EmployeePayRule varchar(250) null
    ,@HourlyWageRate varchar(250) null
    ,@PrimaryLocationPath varchar(250) null
    ,@PrimaryJob varchar(250) null
    ,@HomeLaborCategory varchar(250) null
    ,@JobNameFullPathWorked varchar(250) null
    ,@ActualTotalJobTransferIndicator varchar(250) null
    ,@PaycodeType varchar(250) null
    ,@PaycodeName varchar(250) null
    ,@ActualTotalApplyDate varchar(250) null
    ,@ActualTotalHours varchar(250) null
    ,@ActualTotalWages varchar(250) null
    ,@LaborCategoryName varchar(250) null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [Kronos].[Employee Hours by Worked Acct Daily]
           ([Employee ID]
           ,[Employee Number]
           ,[Employee Full Name]
           ,[Employee Pay Rule]
           ,[Hourly Wage Rate]
           ,[Primary Location (Path)]
           ,[Primary Job]
           ,[Home Labor Category]
           ,[Job Name - Full Path (Worked)]
           ,[Actual Total Job Transfer Indicator]
           ,[Paycode Type]
           ,[Paycode Name]
           ,[Actual Total Apply Date]
           ,[Actual Total Hours (Include Corrections)]
           ,[Actual Total Wages (Include Corrections)]
           ,[Labor Category Name (Path)])
     VALUES
           (
		    @EmployeeId
           ,@EmployeeNumber
           ,@EmployeeFullName
           ,@EmployeePayRule
           ,@HourlyWageRate
           ,@PrimaryLocationPath
           ,@PrimaryJob
           ,@HomeLaborCategory
           ,@JobNameFullPathWorked
           ,@ActualTotalJobTransferIndicator
           ,@PaycodeType
           ,@PaycodeName
           ,@ActualTotalApplyDate
           ,@ActualTotalHours
           ,@ActualTotalWages
           ,@LaborCategoryName
		   )
END

GO
