USE [Operations]
GO
/****** Object:  UserDefinedFunction [dbo].[getHashField]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[getHashField] (
	@p_table_name VARCHAR(100)
	,@p_schema_Name VARCHAR(20)
)
RETURNS VARCHAR(MAX)
AS BEGIN
	DECLARE @sqlString AS VARCHAR(MAX)
	SET @sqlString = ''

	SELECT @sqlString = @sqlString + ' CAST(ISNULL([' + COLUMN_NAME + '],'
		+ CASE WHEN DATA_TYPE IN ('numeric', 'money', 'int', 'decimal', 'float', 'real') THEN '''0''' ELSE '''''' END + ') AS VARCHAR('
		+ CASE WHEN DATA_TYPE IN ('nvarchar', 'varchar', 'char') THEN CAST(ISNULL(CHARACTER_MAXIMUM_LENGTH,'100') AS VARCHAR(5)) ELSE '100' END + ')) + '
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = @p_schema_name AND TABLE_NAME = @p_table_name
		AND COLUMN_NAME NOT IN ('ID', 'Fingerprint', 'StartDate', 'EndDate', 'CurrentRecord')

	SET @sqlSTring = LEFT(ISNULL(@sqlString,''),LEN(@sqlString)-1)

	RETURN(@sqlString)
END
GO
