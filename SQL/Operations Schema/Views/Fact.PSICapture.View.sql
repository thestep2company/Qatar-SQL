USE [Operations]
GO
/****** Object:  View [Fact].[PSICapture]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Fact].[PSICapture] AS 
SELECT * FROM Oracle.PSICapture
GO
