USE [Operations]
GO
/****** Object:  UserDefinedFunction [dbo].[RegExLike]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[RegExLike](@param1 [nvarchar](max), @param2 [nvarchar](max))
RETURNS [int] WITH EXECUTE AS CALLER
AS 
EXTERNAL NAME [regex].[RegExBase].[RegExLike]
GO
