USE [XREF]
GO
/****** Object:  User [STEP2\SQLAgent]    Script Date: 7/8/2025 3:41:28 PM ******/
CREATE USER [STEP2\SQLAgent] FOR LOGIN [STEP2\SQLAgent] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [STEP2\SQLAgent]
GO
