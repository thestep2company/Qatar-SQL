USE [Operations]
GO
/****** Object:  User [step2\SQLAS]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [step2\SQLAS] FOR LOGIN [STEP2\sqlas] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [step2\SQLAS]
GO
