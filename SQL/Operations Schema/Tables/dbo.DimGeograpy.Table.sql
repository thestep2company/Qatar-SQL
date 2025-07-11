USE [Operations]
GO
/****** Object:  Table [dbo].[DimGeograpy]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimGeograpy](
	[GeographyID] [int] IDENTITY(1,1) NOT NULL,
	[PostalCode] [nvarchar](30) NOT NULL,
	[State] [nvarchar](240) NULL,
	[Country] [nvarchar](30) NULL,
 CONSTRAINT [PK_DimGeograpy] PRIMARY KEY CLUSTERED 
(
	[GeographyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
