USE [Forecast]
GO
/****** Object:  User [STEP2\julia_t]    Script Date: 7/8/2025 3:39:34 PM ******/
CREATE USER [STEP2\julia_t] FOR LOGIN [STEP2\julia_t] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\julia_t]
GO
