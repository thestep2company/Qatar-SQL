USE [Operations]
GO
/****** Object:  User [STEP2\ssjulia]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\ssjulia] FOR LOGIN [STEP2\ssjulia] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\ssjulia]
GO
