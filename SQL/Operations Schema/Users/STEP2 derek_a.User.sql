USE [Operations]
GO
/****** Object:  User [STEP2\derek_a]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\derek_a] FOR LOGIN [STEP2\derek_a] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\derek_a]
GO
