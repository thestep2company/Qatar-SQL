USE [Operations]
GO
/****** Object:  User [STEP2\GG Finance]    Script Date: 7/10/2025 11:43:36 AM ******/
CREATE USER [STEP2\GG Finance] FOR LOGIN [STEP2\GG Finance]
GO
ALTER ROLE [db_datareader] ADD MEMBER [STEP2\GG Finance]
GO
