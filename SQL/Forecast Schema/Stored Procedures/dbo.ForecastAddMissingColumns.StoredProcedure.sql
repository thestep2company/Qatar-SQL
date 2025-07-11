USE [Forecast]
GO
/****** Object:  StoredProcedure [dbo].[ForecastAddMissingColumns]    Script Date: 7/8/2025 3:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ForecastAddMissingColumns] AS BEGIN

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'InvoicePriceID') 
		ALTER TABLE dbo.FactSalesBudget ADD InvoicePriceID int

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'LastForecastPriceID') 
		ALTER TABLE dbo.FactSalesBudget ADD LastForecastPriceID int
	
	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'BudgetPriceID') 
		ALTER TABLE dbo.FactSalesBudget ADD BudgetPriceID int
	
	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'LastBudgetPriceID') 
		ALTER TABLE dbo.FactSalesBudget ADD LastBudgetPriceID int
	
	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Sales Invoice Price') 
		ALTER TABLE dbo.FactSalesBudget ADD [Sales Invoice Price] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Sales Forecast Price') 
		ALTER TABLE dbo.FactSalesBudget ADD [Sales Forecast Price] float
	
	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Sales Budget Price') 
		ALTER TABLE dbo.FactSalesBudget ADD [Sales Budget Price] float
	
	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Sales Budget LY Price') 
		ALTER TABLE dbo.FactSalesBudget ADD [Sales Budget LY Price] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Sales Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Sales Operations] MONEY

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Units Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Units Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Coop Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Coop Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Other Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Other Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'DIF Returns Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [DIF Returns Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Markdown Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Markdown Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Cash Discounts Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Cash Discounts Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Freight Allowance Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Freight Allowance Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Invoiced Freight Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [Invoiced Freight Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'COGS Operations') 
		ALTER TABLE dbo.FactSalesBudget ADD [COGS Operations] float

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Base Currency') 
		ALTER TABLE dbo.FactSalesBudget ADD [Base Currency] VARCHAR(30)

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME = 'FactSalesBudget' AND COLUMN_NAME = 'Price Type') 
		ALTER TABLE dbo.FactSalesBudget ADD [Price Type] VARCHAR(34)


END
GO
