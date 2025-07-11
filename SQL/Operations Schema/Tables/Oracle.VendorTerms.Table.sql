USE [Operations]
GO
/****** Object:  Table [Oracle].[VendorTerms]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[VendorTerms](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[VENDOR_ID] [float] NULL,
	[VENDORNUMBER] [nvarchar](30) NOT NULL,
	[SUPPLIER_NAME] [nvarchar](240) NULL,
	[TERMS_ID] [float] NULL,
	[NAME] [nvarchar](50) NULL,
	[DESCRIPTION] [nvarchar](240) NULL,
	[VENDOR_SITE] [nvarchar](45) NULL,
	[TermLength] [int] NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[VendorTerms] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[VendorTerms] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
