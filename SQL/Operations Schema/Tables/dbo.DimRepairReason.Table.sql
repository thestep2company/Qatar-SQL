USE [Operations]
GO
/****** Object:  Table [dbo].[DimRepairReason]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRepairReason](
	[RepairReasonID] [int] IDENTITY(1,1) NOT NULL,
	[OrgCode] [varchar](5) NOT NULL,
	[RepairReasonKey] [varchar](2) NULL,
	[RepairReasonName] [varchar](50) NULL,
	[RepairReasonDesc] [varchar](54) NULL,
	[RepairReasonSort] [varchar](10) NULL,
 CONSTRAINT [PK_DimRepairReason] PRIMARY KEY CLUSTERED 
(
	[RepairReasonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
