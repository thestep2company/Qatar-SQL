USE [Operations]
GO
/****** Object:  User [STEP2\stephen_n]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\stephen_n] FOR LOGIN [STEP2\stephen_n] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\stephen_n]
GO
