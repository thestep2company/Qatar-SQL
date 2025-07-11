USE [Operations]
GO
/****** Object:  Table [xref].[Step2DirectOrderNotes]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[Step2DirectOrderNotes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Order Number] [varchar](25) NOT NULL,
	[Order Notes] [varchar](250) NOT NULL,
	[File Date] [datetime] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[ProductKey] [varchar](50) NULL,
	[CustomerKey] [varchar](50) NULL,
	[ReasonKey] [varchar](25) NULL,
	[Cleansed Order Note] [varchar](250) NULL,
 CONSTRAINT [PK_Step2DirectOrderNotes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [xref].[Step2DirectOrderNotes] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
