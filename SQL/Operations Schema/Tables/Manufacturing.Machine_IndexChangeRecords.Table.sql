USE [Operations]
GO
/****** Object:  Table [Manufacturing].[Machine_IndexChangeRecords]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Manufacturing].[Machine_IndexChangeRecords](
	[ID] [int] NOT NULL,
	[INDEX_ID] [int] NOT NULL,
	[MACHINE_ID] [int] NOT NULL,
	[DATE_TIME] [datetime] NOT NULL,
	[REC_TYPE] [varchar](1) NOT NULL,
	[PLANT] [varchar](3) NOT NULL,
	[SHIFT] [varchar](1) NOT NULL,
	[MACHINE_NUM] [varchar](2) NOT NULL,
	[ARM_NUMBER] [varchar](1) NOT NULL,
	[MACHINE_SIZE] [varchar](3) NOT NULL,
	[SPIDER_SIDE_1] [varchar](50) NULL,
	[SPIDER_SIDE_2] [varchar](50) NULL,
	[CYCLE_COUNT] [int] NULL,
	[DEAD_ARM] [int] NULL,
	[MISSED_CYCLE] [int] NULL,
	[REASON_CODE] [int] NULL,
	[MISSED_TIME] [int] NULL,
	[OVEN_TEMP] [real] NULL,
	[CYCLE_TIME] [int] NULL,
	[COOLER_1_FAN_DELAY] [int] NULL,
	[COOLER_1_FAN_TIME] [int] NULL,
	[COOLER_2_WATER_DELAY] [int] NULL,
	[WATER_TIME] [int] NULL,
	[COOLER_2_FAN_TIME] [int] NULL,
	[OUTSIDE_AIR_TEMP] [real] NULL,
	[CREATE_DATE] [datetime] NULL,
	[REASON_DESCRIPTION] [varchar](100) NULL,
	[OPERATOR] [varchar](50) NULL,
	[COMPUTER_NAME] [varchar](25) NULL,
	[SHIFT_DATE] [datetime] NULL,
	[INDEX_TIME] [int] NULL,
	[OPERATOR_NAME] [varchar](50) NULL,
	[TransDate] [date] NULL,
	[TransDateOffset] [date] NULL,
	[SHIFT_ID] [int] NULL,
 CONSTRAINT [PK_Machine_IndexChangeRecords] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
