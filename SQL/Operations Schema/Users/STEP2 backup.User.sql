USE [Operations]
GO
/****** Object:  User [STEP2\backup]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\backup] FOR LOGIN [STEP2\backup] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [STEP2\backup]
GO
