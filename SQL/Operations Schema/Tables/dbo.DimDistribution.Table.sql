USE [Operations]
GO
/****** Object:  Table [dbo].[DimDistribution]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDistribution](
	[BucketID] [bigint] IDENTITY(1,1) NOT NULL,
	[BucketKey] [numeric](5, 2) NULL,
	[BucketNickle] [nvarchar](4000) NULL,
	[BucketNickelSort] [numeric](11, 2) NULL,
	[BucketDime] [nvarchar](4000) NULL,
	[BucketDimeSort] [numeric](10, 1) NULL,
	[BucketQuarter] [nvarchar](4000) NULL,
	[BucketQuarterSort] [numeric](10, 2) NULL,
	[BucketHalf] [nvarchar](4000) NULL,
	[BucketHalfSort] [numeric](9, 1) NULL,
	[BucketOne] [nvarchar](4000) NULL,
	[BucketOneSort] [numeric](5, 0) NULL,
	[BucketFive] [nvarchar](4000) NULL,
	[BucketFiveSort] [numeric](12, 0) NULL,
	[BucketTen] [nvarchar](4000) NULL,
	[BucketTenSort] [numeric](13, 0) NULL,
 CONSTRAINT [PK_DimDistribution] PRIMARY KEY CLUSTERED 
(
	[BucketID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
