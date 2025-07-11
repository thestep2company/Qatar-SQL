USE [Operations]
GO
/****** Object:  Table [dbo].[DimLocation]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLocation](
	[LocationID] [int] IDENTITY(1,1) NOT NULL,
	[LocationKey] [nvarchar](3) NOT NULL,
	[LocationName] [nvarchar](240) NOT NULL,
	[LocationDesc] [nvarchar](245) NOT NULL,
	[Sort] [nvarchar](3) NOT NULL,
	[LocationType] [varchar](25) NOT NULL,
	[LocationCountry] [varchar](25) NOT NULL,
	[ShiftScalar] [numeric](6, 5) NULL,
	[GLLocationID] [int] NULL,
	[WarehouseCapacity] [int] NULL,
	[PhysicalLocation] [varchar](50) NULL,
	[PlanID] [int] NULL,
	[COGSLocationID] [int] NULL,
 CONSTRAINT [PK_DimLocation] PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
