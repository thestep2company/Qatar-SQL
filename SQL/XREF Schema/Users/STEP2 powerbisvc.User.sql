USE [XREF]
GO
/****** Object:  User [STEP2\powerbisvc]    Script Date: 7/8/2025 3:41:28 PM ******/
CREATE USER [STEP2\powerbisvc] FOR LOGIN [STEP2\powerbisvc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\powerbisvc]
GO
