USE [Operations]
GO
/****** Object:  User [STEP2\ssneale]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\ssneale] FOR LOGIN [STEP2\ssneale] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [STEP2\ssneale]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [STEP2\ssneale]
GO
