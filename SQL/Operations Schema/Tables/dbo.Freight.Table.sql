USE [Operations]
GO
/****** Object:  Table [dbo].[Freight]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Freight](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SKU] [nvarchar](255) NOT NULL,
	[1] [money] NULL,
	[2] [money] NULL,
	[3] [money] NULL,
	[4] [money] NULL,
	[5] [money] NULL,
	[6] [money] NULL,
	[7] [money] NULL,
	[8] [money] NULL,
	[9] [money] NULL,
	[10] [money] NULL,
	[11] [money] NULL,
	[12] [money] NULL,
	[Est] [money] NULL,
	[Type] [nvarchar](255) NULL,
	[Fingerprint] [varchar](32) NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[CurrentRecord] [bit] NOT NULL,
	[Year] [int] NULL,
 CONSTRAINT [PK_Freight] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Freight] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
ALTER TABLE [dbo].[Freight] ADD  DEFAULT ((1)) FOR [CurrentRecord]
GO
