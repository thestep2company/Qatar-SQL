USE [Operations]
GO
/****** Object:  Table [xref].[Royalty]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Royalty](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Royalty License Name] [nvarchar](255) NULL,
	[Royalty License %] [float] NULL,
	[4 Digit] [nvarchar](255) NULL,
	[Year] [int] NULL,
 CONSTRAINT [PK_Royalty] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
