USE [DBA]
GO
/****** Object:  User [STEP2\backup]    Script Date: 7/8/2025 3:43:29 PM ******/
CREATE USER [STEP2\backup] FOR LOGIN [STEP2\backup] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [STEP2\backup]
GO
