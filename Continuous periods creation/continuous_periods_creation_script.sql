-- define employment start date in every company
WITH _employment_start AS (
    SELECT [Person]
        ,[Company]
        ,[start_date]
        ,[end_date]
        ,CASE WHEN [Company] = LAG([Company]) OVER (PARTITION BY [Person] ORDER BY [StartDate])
            THEN 0
            ELSE 1
            END AS [employment_start]
    FROM employees
    )
-- define employment scopes using cumulative sum
, _scopes AS (
	SELECT [Person]
        ,[Company]
        ,[start_date]
        ,[end_date]
        ,[employment_start]
        ,SUM(employment_start) OVER(PARTITION BY [Person] ORDER BY [start_date] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [scope]
	FROM _employment_start
	)
-- finally group by necessary fields and get proper start and end employment dates
SELECT [Person]
	,[Company]
	,MIN([start_date]) AS [start_date]
	,MAX([end_date]) AS [end_date]
FROM _scopes
GROUP BY [Person]
	,[Company]
	,[scope]
;