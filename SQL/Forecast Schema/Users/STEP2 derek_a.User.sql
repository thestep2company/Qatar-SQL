USE [Forecast]
GO
/****** Object:  User [STEP2\derek_a]    Script Date: 7/8/2025 3:39:34 PM ******/
CREATE USER [STEP2\derek_a] FOR LOGIN [STEP2\derek_a] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\derek_a]
GO
