USE [Operations]
GO
/****** Object:  Table [dbo].[SSASProcessingLog]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SSASProcessingLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Job] [varchar](50) NOT NULL,
	[Step] [varchar](50) NOT NULL,
	[TimeStamp] [datetime] NOT NULL,
	[RecordCount] [int] NOT NULL,
	[Processed] [int] NULL,
 CONSTRAINT [PK_SSASProcessingLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
