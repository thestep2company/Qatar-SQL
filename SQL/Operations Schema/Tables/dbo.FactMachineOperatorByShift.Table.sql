USE [Operations]
GO
/****** Object:  Table [dbo].[FactMachineOperatorByShift]    Script Date: 7/10/2025 11:43:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactMachineOperatorByShift](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DateID] [int] NOT NULL,
	[ShiftID] [int] NOT NULL,
	[MachineID] [int] NOT NULL,
	[OperatorID] [int] NOT NULL,
	[LocationID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
