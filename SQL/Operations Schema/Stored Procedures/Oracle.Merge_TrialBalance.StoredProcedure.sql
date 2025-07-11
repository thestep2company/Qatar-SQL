USE [Operations]
GO
/****** Object:  StoredProcedure [Oracle].[Merge_TrialBalance]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE PROCEDURE [Oracle].[Merge_TrialBalance] AS BEGIN
 
		 CREATE TABLE #TrialBalance (
			[JE_HDR_ID] [numeric](15, 0) NOT NULL,
			[CATEGORY] [nvarchar](25) NOT NULL,
			[SOURCE] [nvarchar](25) NOT NULL,
			[PERIOD] [nvarchar](15) NOT NULL,
			[JE_HDR_NAME] [nvarchar](100) NOT NULL,
			[JE_HDR_CREATED] [datetime2](7) NULL,
			[JE_HDR_CREATED_BY] [nvarchar](302) NULL,
			[JE_HDR_EFF_DATE] [datetime2](7) NOT NULL,
			[JE_HDR_POSTED_DATE] [datetime2](7) NULL,
			[JE_BATCH_ID] [numeric](15, 0) NULL,
			[JE_BATCH_NAME] [nvarchar](100) NOT NULL,
			[JE_BATCH_PERIOD] [nvarchar](15) NULL,
			[HDR_TOTAL_ACCT_DR] [float] NULL,
			[HDR_TOTAL_ACCT_CR] [float] NULL,
			[LINE_NUMBER] [numeric](15, 0) NOT NULL,
			[CODE_COMBINATION] [nvarchar](207) NULL,
			[ACCOUNT] [nvarchar](25) NULL,
			[CURRENCY] [nvarchar](15) NOT NULL,
			[ENTERED_DR] [float] NULL,
			[ENTERED_CR] [float] NULL,
			[ACCT_DEBIT] [float] NULL,
			[ACCT_CREDIT] [float] NULL,
			[ENDING_BALANCE] [float] NULL,
			[LINE_DESCRIPTION] [nvarchar](240) NULL,
			[VENDOR_NUM] [nvarchar](240) NULL,
			[Fingerprint] [varchar](32) NOT NULL
		)

		 INSERT INTO #TrialBalance
		 (
			   [JE_HDR_ID]
			  ,[CATEGORY]
			  ,[SOURCE]
			  ,[PERIOD]
			  ,[JE_HDR_NAME]
			  ,[JE_HDR_CREATED]
			  ,[JE_HDR_CREATED_BY]
			  ,[JE_HDR_EFF_DATE]
			  ,[JE_HDR_POSTED_DATE]
			  ,[JE_BATCH_ID]
			  ,[JE_BATCH_NAME]
			  ,[JE_BATCH_PERIOD]
			  ,[HDR_TOTAL_ACCT_DR]
			  ,[HDR_TOTAL_ACCT_CR]
			  ,[LINE_NUMBER]
			  ,[CODE_COMBINATION]
			  ,[ACCOUNT]
			  ,[CURRENCY]
			  ,[ENTERED_DR]
			  ,[ENTERED_CR]
			  ,[ACCT_DEBIT]
			  ,[ACCT_CREDIT]
			  ,[ENDING_BALANCE]
			  ,[LINE_DESCRIPTION]
			  ,[VENDOR_NUM]
			  ,[FINGERPRINT]
		)
		 SELECT [JE_HDR_ID]
			  ,[CATEGORY]
			  ,[SOURCE]
			  ,[PERIOD]
			  ,[JE_HDR_NAME]
			  ,[JE_HDR_CREATED]
			  ,[JE_HDR_CREATED_BY]
			  ,[JE_HDR_EFF_DATE]
			  ,[JE_HDR_POSTED_DATE]
			  ,[JE_BATCH_ID]
			  ,[JE_BATCH_NAME]
			  ,[JE_BATCH_PERIOD]
			  ,[HDR_TOTAL_ACCT_DR]
			  ,[HDR_TOTAL_ACCT_CR]
			  ,[LINE_NUMBER]
			  ,[CODE_COMBINATION]
			  ,[ACCOUNT]
			  ,[CURRENCY]
			  ,[ENTERED_DR]
			  ,[ENTERED_CR]
			  ,[ACCT_DEBIT]
			  ,[ACCT_CREDIT]
			  ,[ENDING_BALANCE]
			  ,[LINE_DESCRIPTION]
			  ,[VENDOR_NUM]
			  ,'XXXXXXXXXXXXX' AS [Fingerprint] 
		 FROM OPENQUERY(PROD,'
			select	   gljeh.je_header_id                                   JE_Hdr_Id,
					   gljeh.je_category                                    Category,
					   gljeh.je_source                                      Source,
					   gljeh.period_name                                    Period,
					   gljeh.name                                           JE_Hdr_Name,
					   trunc(gljeh.date_created)                            JE_Hdr_Created,
					   papf1.last_name ||'', ''|| papf1.first_name          JE_Hdr_Created_By,
					   gljeh.default_effective_date							JE_Hdr_Eff_Date,
					   gljeh.posted_date									JE_Hdr_Posted_Date,
					   gljeh.je_batch_id                                    JE_Batch_Id,
					   gljeb.name                                           JE_Batch_Name,
					   gljeb.default_period_name                            JE_Batch_Period,
					   gljeh.running_total_accounted_dr                     Hdr_Total_Acct_DR,
					   gljeh.running_total_accounted_cr                     Hdr_Total_Acct_CR,
					   gljel.je_line_num                                    Line_Number,
			   
					   to_char(glcc.segment1)||''.''||to_char(glcc.segment2)||''.''||
					   to_char(glcc.segment3)||''.''||to_char(glcc.segment4)||''.''||
					   to_char(glcc.segment5)||''.''||to_char(glcc.segment6)||''.''||
					   to_Char(glcc.segment7)||''.''||to_char(glcc.segment8)  Code_Combination,
					   glcc.segment4										Account,
					   gljeh.currency_code                                  Currency,
					   gljel.entered_dr                                     Entered_DR,
					   gljel.entered_cr                                     Entered_CR,
					   gljel.accounted_dr                                   Acct_Debit,
					   gljel.accounted_cr                                   Acct_Credit,
					   NVL(gljel.accounted_dr,0)-NVL(gljel.accounted_cr,0)	Ending_Balance,
					   gljel.description                                    Line_Description,
					   gljel.attribute2										Vendor_Num
				  from gl.gl_je_lines                                       gljel,
					   gl.gl_je_headers                                     gljeh,
					   gl.gl_je_batches                                     gljeb,
					   gl.gl_code_combinations                              glcc,
					   fnd_user                                             fusr1,
					   (select distinct person_id, last_name, first_name
						  from hr.per_all_people_f
					   )                                                    papf1
				 where 1 = 1
				   and gljeh.je_header_id                                   = gljel.je_header_id
				   and gljeh.posted_date                                    is not null
				   and (gljeh.default_effective_date                        >= trunc(sysdate) - 70 --to_date(''20221127'',''YYYYMMDD'')
				   OR gljeh.posted_date										>= trunc(sysdate) - 70)
				   and gljeb.je_batch_id                                    = gljeh.je_batch_id
				   and glcc.code_combination_id                             = gljel.code_combination_id
				   and fusr1.user_id                                        = gljeh.created_by
				   and papf1.person_id(+)                                   = fusr1.employee_id
		'
		)

		/*
			DECLARE @columnList VARCHAR(MAX) = dbo.getHashField ('TrialBalance','Oracle') SELECT @columnList
		*/
		UPDATE #TrialBalance
		SET Fingerprint = 
			SUBSTRING(LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
				--replace @columnList result here
				  CAST(ISNULL([JE_HDR_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([CATEGORY],'') AS VARCHAR(25)) +  CAST(ISNULL([SOURCE],'') AS VARCHAR(25)) +  CAST(ISNULL([PERIOD],'') AS VARCHAR(15)) +  CAST(ISNULL([JE_HDR_NAME],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_HDR_CREATED],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_HDR_CREATED_BY],'') AS VARCHAR(302)) +  CAST(ISNULL([JE_HDR_EFF_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_HDR_POSTED_DATE],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_BATCH_ID],'0') AS VARCHAR(100)) +  CAST(ISNULL([JE_BATCH_NAME],'') AS VARCHAR(100)) +  CAST(ISNULL([JE_BATCH_PERIOD],'') AS VARCHAR(15)) +  CAST(ISNULL([HDR_TOTAL_ACCT_DR],'0') AS VARCHAR(100)) +  CAST(ISNULL([HDR_TOTAL_ACCT_CR],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_NUMBER],'0') AS VARCHAR(100)) +  CAST(ISNULL([CODE_COMBINATION],'') AS VARCHAR(207)) +  CAST(ISNULL([ACCOUNT],'') AS VARCHAR(25)) +  CAST(ISNULL([CURRENCY],'') AS VARCHAR(15)) +  CAST(ISNULL([ENTERED_DR],'0') AS VARCHAR(100)) +  CAST(ISNULL([ENTERED_CR],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCT_DEBIT],'0') AS VARCHAR(100)) +  CAST(ISNULL([ACCT_CREDIT],'0') AS VARCHAR(100)) +  CAST(ISNULL([ENDING_BALANCE],'0') AS VARCHAR(100)) +  CAST(ISNULL([LINE_DESCRIPTION],'') AS VARCHAR(240)) +  CAST(ISNULL([VENDOR_NUM],'') AS VARCHAR(240)) 
				 --CAST(ISNULL(JE_HDR_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(CATEGORY,'') AS VARCHAR(25)) +  CAST(ISNULL(SOURCE,'') AS VARCHAR(25)) +  CAST(ISNULL(PERIOD,'') AS VARCHAR(15)) +  CAST(ISNULL(JE_HDR_NAME,'') AS VARCHAR(100)) +  CAST(ISNULL(JE_HDR_CREATED,'') AS VARCHAR(100)) +  CAST(ISNULL(JE_HDR_CREATED_BY,'') AS VARCHAR(302)) +  CAST(ISNULL(JE_HDR_EFF_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(JE_HDR_POSTED_DATE,'') AS VARCHAR(100)) +  CAST(ISNULL(JE_BATCH_ID,'0') AS VARCHAR(100)) +  CAST(ISNULL(JE_BATCH_NAME,'') AS VARCHAR(100)) +  CAST(ISNULL(JE_BATCH_PERIOD,'') AS VARCHAR(15)) +  CAST(CAST(ISNULL(HDR_TOTAL_ACCT_DR,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(CAST(ISNULL(HDR_TOTAL_ACCT_CR,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(ISNULL(LINE_NUMBER,'0') AS VARCHAR(100)) +  CAST(ISNULL(CODE_COMBINATION,'') AS VARCHAR(207)) +  CAST(ISNULL(ACCOUNT,'') AS VARCHAR(25)) +  CAST(ISNULL(CURRENCY,'') AS VARCHAR(15)) +  CAST(CAST(ISNULL(ENTERED_DR,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(CAST(ISNULL(ENTERED_CR,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(CAST(ISNULL(ACCT_DEBIT,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(CAST(ISNULL(ACCT_CREDIT,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(CAST(ISNULL(ENDING_BALANCE,'0') AS BIGINT)*100 AS VARCHAR(100)) +  CAST(ISNULL(LINE_DESCRIPTION,'') AS VARCHAR(240)) 
			),1)),3,32)

		--expire records outside the merge

		INSERT INTO Oracle.[TrialBalance] (
			   [JE_HDR_ID]
			  ,[CATEGORY]
			  ,[SOURCE]
			  ,[PERIOD]
			  ,[JE_HDR_NAME]
			  ,[JE_HDR_CREATED]
			  ,[JE_HDR_CREATED_BY]
			  ,[JE_HDR_EFF_DATE]
			  ,[JE_HDR_POSTED_DATE]
			  ,[JE_BATCH_ID]
			  ,[JE_BATCH_NAME]
			  ,[JE_BATCH_PERIOD]
			  ,[HDR_TOTAL_ACCT_DR]
			  ,[HDR_TOTAL_ACCT_CR]
			  ,[LINE_NUMBER]
			  ,[CODE_COMBINATION]
			  ,[ACCOUNT]
			  ,[CURRENCY]
			  ,[ENTERED_DR]
			  ,[ENTERED_CR]
			  ,[ACCT_DEBIT]
			  ,[ACCT_CREDIT]
			  ,[ENDING_BALANCE]
			  ,[LINE_DESCRIPTION]
			  ,[VENDOR_NUM]
			  ,[Fingerprint]
		)
			SELECT 
				    a.[JE_HDR_ID]
				  ,a.[CATEGORY]
				  ,a.[SOURCE]
				  ,a.[PERIOD]
				  ,a.[JE_HDR_NAME]
				  ,a.[JE_HDR_CREATED]
				  ,a.[JE_HDR_CREATED_BY]
				  ,a.[JE_HDR_EFF_DATE]
				  ,a.[JE_HDR_POSTED_DATE]
				  ,a.[JE_BATCH_ID]
				  ,a.[JE_BATCH_NAME]
				  ,a.[JE_BATCH_PERIOD]
				  ,a.[HDR_TOTAL_ACCT_DR]
				  ,a.[HDR_TOTAL_ACCT_CR]
				  ,a.[LINE_NUMBER]
				  ,a.[CODE_COMBINATION]
				  ,a.[ACCOUNT]
				  ,a.[CURRENCY]
				  ,a.[ENTERED_DR]
				  ,a.[ENTERED_CR]
				  ,a.[ACCT_DEBIT]
				  ,a.[ACCT_CREDIT]
				  ,a.[ENDING_BALANCE]
				  ,a.[LINE_DESCRIPTION]
				  ,a.[VENDOR_NUM]
				  ,a.[Fingerprint]
			FROM (
				MERGE Oracle.[TrialBalance] b
				USING (SELECT * FROM #TrialBalance) a
				ON a.JE_HDR_ID = b.JE_HDR_ID AND a.LINE_NUMBER = b.LINE_NUMBER AND b.CurrentRecord = 1 --swap with business key of table
				WHEN NOT MATCHED --BY TARGET 
				THEN INSERT (
					   [JE_HDR_ID]
					  ,[CATEGORY]
					  ,[SOURCE]
					  ,[PERIOD]
					  ,[JE_HDR_NAME]
					  ,[JE_HDR_CREATED]
					  ,[JE_HDR_CREATED_BY]
					  ,[JE_HDR_EFF_DATE]
					  ,[JE_HDR_POSTED_DATE]
					  ,[JE_BATCH_ID]
					  ,[JE_BATCH_NAME]
					  ,[JE_BATCH_PERIOD]
					  ,[HDR_TOTAL_ACCT_DR]
					  ,[HDR_TOTAL_ACCT_CR]
					  ,[LINE_NUMBER]
					  ,[CODE_COMBINATION]
					  ,[ACCOUNT]
					  ,[CURRENCY]
					  ,[ENTERED_DR]
					  ,[ENTERED_CR]
					  ,[ACCT_DEBIT]
					  ,[ACCT_CREDIT]
					  ,[ENDING_BALANCE]
					  ,[LINE_DESCRIPTION]
					  ,[VENDOR_NUM]
					  ,[Fingerprint]
				)
				VALUES (
					   a.[JE_HDR_ID]
					  ,a.[CATEGORY]
					  ,a.[SOURCE]
					  ,a.[PERIOD]
					  ,a.[JE_HDR_NAME]
					  ,a.[JE_HDR_CREATED]
					  ,a.[JE_HDR_CREATED_BY]
					  ,a.[JE_HDR_EFF_DATE]
					  ,a.[JE_HDR_POSTED_DATE]
					  ,a.[JE_BATCH_ID]
					  ,a.[JE_BATCH_NAME]
					  ,a.[JE_BATCH_PERIOD]
					  ,a.[HDR_TOTAL_ACCT_DR]
					  ,a.[HDR_TOTAL_ACCT_CR]
					  ,a.[LINE_NUMBER]
					  ,a.[CODE_COMBINATION]
					  ,a.[ACCOUNT]
					  ,a.[CURRENCY]
					  ,a.[ENTERED_DR]
					  ,a.[ENTERED_CR]
					  ,a.[ACCT_DEBIT]
					  ,a.[ACCT_CREDIT]
					  ,a.[ENDING_BALANCE]
					  ,a.[LINE_DESCRIPTION]
					  ,a.[VENDOR_NUM]
					  ,a.[Fingerprint]
				)
				--Existing records that have changed are expired
				WHEN MATCHED AND a.Fingerprint<>b.Fingerprint
				THEN UPDATE SET b.EndDate=GETDATE()
					,b.CurrentRecord=0
				OUTPUT 
					   a.[JE_HDR_ID]
					  ,a.[CATEGORY]
					  ,a.[SOURCE]
					  ,a.[PERIOD]
					  ,a.[JE_HDR_NAME]
					  ,a.[JE_HDR_CREATED]
					  ,a.[JE_HDR_CREATED_BY]
					  ,a.[JE_HDR_EFF_DATE]
					  ,a.[JE_HDR_POSTED_DATE]
					  ,a.[JE_BATCH_ID]
					  ,a.[JE_BATCH_NAME]
					  ,a.[JE_BATCH_PERIOD]
					  ,a.[HDR_TOTAL_ACCT_DR]
					  ,a.[HDR_TOTAL_ACCT_CR]
					  ,a.[LINE_NUMBER]
					  ,a.[CODE_COMBINATION]
					  ,a.[ACCOUNT]
					  ,a.[CURRENCY]
					  ,a.[ENTERED_DR]
					  ,a.[ENTERED_CR]
					  ,a.[ACCT_DEBIT]
					  ,a.[ACCT_CREDIT]
					  ,a.[ENDING_BALANCE]
					  ,a.[LINE_DESCRIPTION]
					  ,a.[VENDOR_NUM]
					  ,a.[Fingerprint]
					  ,$Action AS Action
			) a
			WHERE Action = 'Update'
			;

		DROP TABLE #TrialBalance

END
GO
