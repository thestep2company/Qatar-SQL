USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_TrialBalanceEndingBalance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Oracle].[Merge_TrialBalanceEndingBalance] AS BEGIN
		 
		CREATE TABLE #TrialBalanceEndingBalance(
				[PERIOD_YEAR] [numeric](15, 0) NULL,
				[PERIOD_NUM] [numeric](15, 0) NULL,
				[SEGMENT1] [nvarchar](25) NULL,
				[SEGMENT2] [nvarchar](25) NULL,
				[SEGMENT3] [nvarchar](25) NULL,
				[SEGMENT4] [nvarchar](25) NULL,
				[CODE_COMBINATION] [nvarchar](181) NULL,
				[STARTING_BALANCE] [float] NULL,
				[ENDING_BALANCE] [float] NULL,
				[Fingerprint] [VARCHAR](32) NOT NULL,
		)

		 INSERT INTO #TrialBalanceEndingBalance
		 (
			   [PERIOD_YEAR]
			  ,[PERIOD_NUM]
			  ,[SEGMENT1]
			  ,[SEGMENT2]
			  ,[SEGMENT3]
			  ,[SEGMENT4]
			  ,[CODE_COMBINATION]
			  ,[STARTING_BALANCE]
			  ,[ENDING_BALANCE]
			  ,[Fingerprint]
		)
		 SELECT [PERIOD_YEAR]
			  ,[PERIOD_NUM]
			  ,[SEGMENT1]
			  ,[SEGMENT2]
			  ,[SEGMENT3]
			  ,[SEGMENT4]
			  ,[CODE_COMBINATION]
			  ,[STARTING_BALANCE]
			  ,[ENDING_BALANCE]
			  ,'XXXXXXXXXXXXX' AS [Fingerprint] 
		FROM OPENQUERY(PROD,'
			SELECT PERIOD_YEAR, PERIOD_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, gcc.CONCATENATED_SEGMENTS AS CODE_COMBINATION
				,SUM(NVL(gb.begin_balance_dr,0)-NVL(gb.begin_balance_cr,0)) Starting_balance
				,SUM(NVL(gb.begin_balance_dr,0)-NVL(gb.begin_balance_cr,0) + (NVL(gb.period_net_Dr,0) - NVL(gb.period_net_cr,0))) Ending_Balance
			FROM gl.GL_BALANCES gb,
				gl_code_combinations_kfv gcc
			WHERE gb.code_combination_id = gcc.code_combination_id 
				AND Period_YEAR*100+Period_Num >= 202501 AND gb.Actual_flag = ''A''
				AND gb.currency_code = (SELECT currency_code FROM gl_ledgers WHERE ledger_id = gb.ledger_id)
				AND SEGMENT4 < ''3000''
			GROUP BY PERIOD_YEAR, PERIOD_NUM, SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, gcc.CONCATENATED_SEGMENTS  
			'
		)


		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('TrialBalanceEndingBalance','Oracle') SELECT @columnList
		*/
		UPDATE #TrialBalanceEndingBalance
		SET Fingerprint = 
				SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  CAST(ISNULL(PERIOD_YEAR,'0') AS VARCHAR(100)) +  CAST(ISNULL(PERIOD_NUM,'0') AS VARCHAR(100)) +  CAST(ISNULL(SEGMENT1,'') AS VARCHAR(25)) +  CAST(ISNULL(SEGMENT2,'') AS VARCHAR(25)) +  CAST(ISNULL(SEGMENT3,'') AS VARCHAR(25)) +  CAST(ISNULL(SEGMENT4,'') AS VARCHAR(25)) +  CAST(ISNULL(CODE_COMBINATION,'') AS VARCHAR(181)) +  CAST(ISNULL(STARTING_BALANCE,'0') AS VARCHAR(100)) +  CAST(CAST(ISNULL(ENDING_BALANCE,'0')*100 AS BIGINT) AS VARCHAR(100)) 
				 ),1)),3,32) 

		--expire records outside the merge

		INSERT INTO Oracle.[TrialBalanceEndingBalance] (
			   [PERIOD_YEAR]
			  ,[PERIOD_NUM]
			  ,[SEGMENT1]
			  ,[SEGMENT2]
			  ,[SEGMENT3]
			  ,[SEGMENT4]
			  ,[CODE_COMBINATION]
			  ,[STARTING_BALANCE]
			  ,[ENDING_BALANCE]
			  ,[Fingerprint]
		)
			SELECT 
			  a.[PERIOD_YEAR]
			  ,a.[PERIOD_NUM]
			  ,a.[SEGMENT1]
			  ,a.[SEGMENT2]
			  ,a.[SEGMENT3]
			  ,a.[SEGMENT4]
			  ,a.[CODE_COMBINATION]
			  ,a.[STARTING_BALANCE]
			  ,a.[ENDING_BALANCE]
			  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.[TrialBalanceEndingBalance] b
				USING (SELECT * FROM #TrialBalanceEndingBalance) a
				ON a.[PERIOD_YEAR] = b.[PERIOD_YEAR] AND a.[PERIOD_NUM] = b.[PERIOD_NUM] AND a.[CODE_COMBINATION] = b.[CODE_COMBINATION] AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
				   [PERIOD_YEAR]
				  ,[PERIOD_NUM]
				  ,[SEGMENT1]
				  ,[SEGMENT2]
				  ,[SEGMENT3]
				  ,[SEGMENT4]
				  ,[CODE_COMBINATION]
				  ,[STARTING_BALANCE]
				  ,[ENDING_BALANCE]
				  ,[Fingerprint]
				)
				VALUES (
				   a.[PERIOD_YEAR]
				  ,a.[PERIOD_NUM]
				  ,a.[SEGMENT1]
				  ,a.[SEGMENT2]
				  ,a.[SEGMENT3]
				  ,a.[SEGMENT4]
				  ,a.[CODE_COMBINATION]
				  ,a.[STARTING_BALANCE]
				  ,a.[ENDING_BALANCE]
				  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
				   a.[PERIOD_YEAR]
				  ,a.[PERIOD_NUM]
				  ,a.[SEGMENT1]
				  ,a.[SEGMENT2]
				  ,a.[SEGMENT3]
				  ,a.[SEGMENT4]
				  ,a.[CODE_COMBINATION]
				  ,a.[STARTING_BALANCE]
				  ,a.[ENDING_BALANCE]
				  ,a.[Fingerprint]
				  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #TrialBalanceEndingBalance

END
GO
