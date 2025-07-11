USE [Operations]
GO
/****** Object:  Table [dbo].[DimLocator]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLocator](
	[LocatorID] [int] IDENTITY(1,1) NOT NULL,
	[LocatorKey] [int] NULL,
	[LocationKey] [int] NULL,
	[LocatorDesc] [varchar](50) NULL,
	[LocationType] [varchar](50) NULL,
	[PickingOrder] [varchar](50) NULL,
	[SubinventoryCode] [varchar](50) NULL,
	[Segment1] [varchar](10) NULL,
	[Segment2] [varchar](10) NULL,
	[Segment3] [varchar](10) NULL,
 CONSTRAINT [PK_DimLocator] PRIMARY KEY CLUSTERED 
(
	[LocatorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
