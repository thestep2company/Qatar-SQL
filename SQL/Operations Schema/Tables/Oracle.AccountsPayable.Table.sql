USE [Operations]
GO
/****** Object:  Table [Oracle].[AccountsPayable]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[AccountsPayable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Organization] [nvarchar](240) NULL,
	[PERIOD] [nvarchar](43) NULL,
	[GL_MONTH] [numeric](15, 0) NOT NULL,
	[GL_YEAR] [numeric](15, 0) NOT NULL,
	[Accounting Date] [datetime2](7) NOT NULL,
	[Distr Amount] [float] NULL,
	[Description] [nvarchar](240) NULL,
	[AP Account] [nvarchar](181) NULL,
	[Company] [nvarchar](25) NULL,
	[Location] [nvarchar](25) NULL,
	[Dept] [nvarchar](25) NULL,
	[Account] [nvarchar](25) NULL,
	[Addback] [nvarchar](25) NULL,
	[Supplier Num] [nvarchar](30) NULL,
	[Vendor] [nvarchar](240) NULL,
	[CITY] [nvarchar](60) NULL,
	[STATE] [nvarchar](150) NULL,
	[ZIP] [nvarchar](60) NULL,
	[PROVINCE] [nvarchar](150) NULL,
	[COUNTRY] [nvarchar](60) NULL,
	[Vendor Invoice] [nvarchar](50) NULL,
	[Invoice Date] [datetime2](7) NULL,
	[Terms] [nvarchar](50) NULL,
	[Voucher Num] [float] NULL,
	[Category Code] [nvarchar](30) NULL,
	[APIA Description] [nvarchar](240) NULL,
	[Batch Name] [nvarchar](50) NULL,
	[PO_NUMBER] [nvarchar](50) NULL,
	[GL_Account_Name] [nvarchar](240) NULL,
 CONSTRAINT [PK_AccountsPayable] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
