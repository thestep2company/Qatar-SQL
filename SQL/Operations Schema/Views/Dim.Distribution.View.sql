USE [Operations]
GO
/****** Object:  View [Dim].[Distribution]    Script Date: 7/10/2025 11:43:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [Dim].[Distribution] AS 
WITH CTE AS (
		 SELECT Cast(-100.00 AS NUMERIC(5, 2)) AS num --Min value from your data
         UNION ALL
         SELECT Cast(num + 0.01 AS NUMERIC(5, 2))
         FROM   cte
         WHERE  num < Cast(100.0 AS NUMERIC(5, 2))) -- Max value from your data
SELECT Row_Number() OVER (ORDER BY num) AS BucketID
	
	,num AS BucketKey

	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num*20)-1)*.05, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num*20))*.05, '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num*20)*.05, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num*20)+1)*.05, '##0.00;(##0.00)') 
	 END AS BucketNickle
	,CASE WHEN num < 0 
		THEN CEILING(num*20)*.05 
		ELSE FLOOR(num*20)*.05 
	 END AS BucketNickelSort

	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num*10)-1)*.1, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num*10))*.1, '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num*10)*.1, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num*10)+1)*.1, '##0.00;(##0.00)') 
	 END AS BucketDime
	,CASE WHEN num < 0 
		THEN CEILING(num*10)*.1 
		ELSE FLOOR(num*10)*.1  
	 END AS BucketDimeSort
	
	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num*4)-1)*.25, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num*4))*.25, '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num*4)*.25, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num*4)+1)*.25, '##0.00;(##0.00)') 
	 END AS BucketQuarter
	,CASE WHEN num < 0 
		THEN CEILING(num*4)*.25 
		ELSE FLOOR(num*4)*.25 
	 END AS BucketQuarterSort
	
	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num*2)-1)*.5, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num*2))*.5, '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num*2)*.5, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num*2)+1)*.5, '##0.00;(##0.00)') 
	 END AS BucketHalf
	,CASE WHEN num < 0 
		THEN CEILING(num*2)*.5 
		ELSE FLOOR(num*2)*.5 
	 END AS BucketHalfSort
	
	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num)-1), '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num)), '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num), '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num)+1), '##0.00;(##0.00)') 
	 END AS BucketOne
	,CASE WHEN num < 0 
		THEN CEILING(num) 
		ELSE FLOOR(num) 
	 END AS BucketOneSort
	
	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num/5)-1)*5, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num/5)*5), '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num/5)*5, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num/5)*5+5), '##0.00;(##0.00)') 
	 END AS BucketFive
	,CASE WHEN num < 0 
		THEN CEILING(num/5)*5-5 
		ELSE FLOOR(num/5)*5+5 
	 END AS BucketFiveSort
	
	,CASE WHEN num < 0 
		THEN FORMAT((CEILING(num/10)-1)*10, '##0.00;(##0.00)') +'-'+FORMAT((CEILING(num/10)*10), '##0.00;(##0.00)') 
		ELSE FORMAT(FLOOR(num/10)*10, '##0.00;(##0.00)') +'-'+FORMAT((FLOOR(num/10)*10+10), '##0.00;(##0.00)') 
	 END AS BucketTen
	,CASE WHEN num < 0 
		THEN CEILING(num/10)*10-10 
		ELSE FLOOR(num/10)*10+10 
	 END AS BucketTenSort
FROM   cte
WHERE num <> 0
UNION
SELECT 0, 0, '0', 0, '0', 0, '0', 0, '0', 0, '0', 0, '0', 0, '0', 0
GO
