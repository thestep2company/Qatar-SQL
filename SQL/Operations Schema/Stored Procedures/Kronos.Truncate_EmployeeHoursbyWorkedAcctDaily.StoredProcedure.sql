USE [Operations]
GO
/****** Object:  StoredProcedure [Kronos].[Truncate_EmployeeHoursbyWorkedAcctDaily]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [Kronos].[Truncate_EmployeeHoursbyWorkedAcctDaily]
WITH EXECUTE AS OWNER
AS
TRUNCATE TABLE [Kronos].[Employee Hours by Worked Acct Daily]
GO
