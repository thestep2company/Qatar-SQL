USE [Operations]
GO
/****** Object:  Table [xref].[CancelReason]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [xref].[CancelReason](
	[Cancelation Description] [varchar](50) NULL,
	[Cancelation Category] [varchar](50) NULL
) ON [PRIMARY]
GO
