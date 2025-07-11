USE [Operations]
GO
/****** Object:  Table [dbo].[DimShift]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimShift](
	[ShiftID] [int] IDENTITY(1,1) NOT NULL,
	[ShiftKey] [varchar](1) NULL,
	[ShiftName] [varchar](7) NULL,
	[ShiftDesc] [varchar](7) NULL,
	[ShiftSort] [varchar](5) NULL,
 CONSTRAINT [PK_DimShift] PRIMARY KEY CLUSTERED 
(
	[ShiftID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
