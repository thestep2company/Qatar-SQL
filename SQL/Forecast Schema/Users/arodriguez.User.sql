USE [Forecast]
GO
/****** Object:  User [arodriguez]    Script Date: 7/8/2025 3:39:34 PM ******/
CREATE USER [arodriguez] FOR LOGIN [arodriguez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [arodriguez]
GO
