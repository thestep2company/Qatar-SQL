USE [Operations]
GO
/****** Object:  User [STEP2\MLodhi]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\MLodhi] FOR LOGIN [STEP2\MLodhi] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\MLodhi]
GO
