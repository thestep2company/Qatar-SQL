USE [Operations]
GO
/****** Object:  UserDefinedFunction [dbo].[CleanProductName]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[CleanProductName](@evalString [nvarchar](max))
RETURNS [nvarchar](max) WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [regexEval].[RegexEvaluator].[CleanProductName]
GO
