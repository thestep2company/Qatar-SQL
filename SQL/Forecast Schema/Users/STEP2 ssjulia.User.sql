USE [Forecast]
GO
/****** Object:  User [STEP2\ssjulia]    Script Date: 7/8/2025 3:39:34 PM ******/
CREATE USER [STEP2\ssjulia] FOR LOGIN [STEP2\ssjulia] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\ssjulia]
GO
