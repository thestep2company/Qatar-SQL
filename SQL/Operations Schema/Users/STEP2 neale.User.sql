USE [Operations]
GO
/****** Object:  User [STEP2\neale]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\neale] FOR LOGIN [STEP2\neale] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [STEP2\neale]
GO
