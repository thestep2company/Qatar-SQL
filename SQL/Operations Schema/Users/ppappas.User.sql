USE [Operations]
GO
/****** Object:  User [ppappas]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [ppappas] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ppappas]
GO
