USE [Operations]
GO
/****** Object:  Table [dbo].[DimAging]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAging](
	[AgeID] [int] NOT NULL,
	[Floor] [int] NOT NULL,
	[Ceiling] [int] NOT NULL,
	[Bucket] [varchar](7) NOT NULL,
	[Sort] [int] NOT NULL,
 CONSTRAINT [PK_DimAging] PRIMARY KEY CLUSTERED 
(
	[AgeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
