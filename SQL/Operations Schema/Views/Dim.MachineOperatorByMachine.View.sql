USE [Operations]
GO
/****** Object:  View [Dim].[MachineOperatorByMachine]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Dim].[MachineOperatorByMachine] AS
SELECT Date, Shift,Machine, Operator FROM xref.MachineOperator WHERE CurrentRecord = 1
GO
