USE [Operations]
GO
/****** Object:  Table [Oracle].[Company]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Oracle].[Company](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Legal Entity ID] [numeric](15, 0) NOT NULL,
	[Legal Entity] [nvarchar](240) NOT NULL,
	[Organization Name] [nvarchar](240) NOT NULL,
	[Organization ID] [numeric](15, 0) NOT NULL,
	[Location ID] [numeric](15, 0) NOT NULL,
	[Country Code] [nvarchar](60) NULL,
	[Location Code] [nvarchar](60) NULL,
	[Company Code] [nvarchar](25) NOT NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Oracle].[Company] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [Oracle].[Company] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
