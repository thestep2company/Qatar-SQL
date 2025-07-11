USE [Operations]
GO
/****** Object:  Table [xref].[FreightBySKU]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[FreightBySKU](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[6 Dig] [varchar](50) NULL,
	[Year] [int] NULL,
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
	[Estimate] [money] NULL,
	[Type] [varchar](50) NULL,
 CONSTRAINT [PK_FreightBySKU] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
