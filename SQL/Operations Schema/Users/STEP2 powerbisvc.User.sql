USE [Operations]
GO
/****** Object:  User [STEP2\powerbisvc]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\powerbisvc] FOR LOGIN [STEP2\powerbisvc] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\powerbisvc]
GO
