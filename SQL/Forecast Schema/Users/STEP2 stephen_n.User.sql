USE [Forecast]
GO
/****** Object:  User [STEP2\stephen_n]    Script Date: 7/8/2025 3:39:34 PM ******/
CREATE USER [STEP2\stephen_n] FOR LOGIN [STEP2\stephen_n] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\stephen_n]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [STEP2\stephen_n]
GO
