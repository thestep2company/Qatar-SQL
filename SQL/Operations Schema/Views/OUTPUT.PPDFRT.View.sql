USE [Operations]
GO
/****** Object:  View [OUTPUT].[PPDFRT]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [OUTPUT].[PPDFRT] AS 
SELECT * FROM oracle.Invoice WHERE INV_DESCRIPTION LIKE 'S2C PPD%' --ORDER BY GL_DATE, ACCT_NAME
GO
