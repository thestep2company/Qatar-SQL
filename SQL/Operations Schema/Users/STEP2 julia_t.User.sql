USE [Operations]
GO
/****** Object:  User [STEP2\julia_t]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\julia_t] FOR LOGIN [STEP2\julia_t] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\julia_t]
GO
