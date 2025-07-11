USE [Operations]
GO
/****** Object:  Table [Step2].[AuditLog]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Step2].[AuditLog](
	[ID] [int] NOT NULL,
	[ChangeDate] [datetime] NULL,
	[FC_Year] [int] NULL,
	[Type] [varchar](2) NULL,
	[CustomerID] [varchar](8) NULL,
	[PartID] [varchar](25) NULL,
	[FC_Month] [int] NULL,
	[FC_Week] [int] NULL,
	[FC_Date] [datetime] NULL,
	[Orig_Qty] [int] NULL,
	[New_Qty] [int] NULL,
	[Orig_Dollars] [money] NULL,
	[New_Dollars] [money] NULL,
	[Orig_Price] [money] NULL,
	[Rev_Price] [money] NULL,
	[Record_Status] [char](1) NULL,
	[User_Added] [varchar](50) NULL,
	[Date_Added] [datetime] NULL,
	[StartDate] [datetime] NOT NULL,
 CONSTRAINT [PK_AuditLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Step2].[AuditLog] ADD  DEFAULT (getdate()) FOR [StartDate]
GO
