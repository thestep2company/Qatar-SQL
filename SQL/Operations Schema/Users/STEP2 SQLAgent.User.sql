USE [Operations]
GO
/****** Object:  User [STEP2\SQLAgent]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\SQLAgent] FOR LOGIN [STEP2\SQLAgent] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [STEP2\SQLAgent]
GO
