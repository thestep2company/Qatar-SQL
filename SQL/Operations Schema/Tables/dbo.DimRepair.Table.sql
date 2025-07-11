USE [Operations]
GO
/****** Object:  Table [dbo].[DimRepair]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRepair](
	[RepairID] [int] IDENTITY(1,1) NOT NULL,
	[RepairKey] [varchar](25) NULL,
	[RepairName] [varchar](25) NULL,
	[RepairDesc] [varchar](25) NULL,
	[RepairSort] [varchar](25) NULL,
	[Scrap] [int] NOT NULL,
	[Repair] [int] NOT NULL,
 CONSTRAINT [PK_DimRepair] PRIMARY KEY CLUSTERED 
(
	[RepairID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
