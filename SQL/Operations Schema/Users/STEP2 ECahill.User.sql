USE [Operations]
GO
/****** Object:  User [STEP2\ECahill]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\ECahill] FOR LOGIN [STEP2\ECahill] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\ECahill]
GO
