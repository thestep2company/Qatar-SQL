USE [Operations]
GO
/****** Object:  User [arodriguez]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [arodriguez] FOR LOGIN [arodriguez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [arodriguez]
GO
