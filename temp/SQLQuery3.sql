USE Dan;
GO

DROP TABLE IF EXISTS dbo.BigTable;
GO

WITH lv0 AS (SELECT 0 g UNION ALL SELECT 0)
    ,lv1 AS (SELECT 0 g FROM lv0 a CROSS JOIN lv0 b)
    ,lv2 AS (SELECT 0 g FROM lv1 a CROSS JOIN lv1 b)
    ,lv3 AS (SELECT 0 g FROM lv2 a CROSS JOIN lv2 b)
    ,lv4 AS (SELECT 0 g FROM lv3 a CROSS JOIN lv3 b)
	,lv5 AS (SELECT 0 g FROM lv4 a CROSS JOIN lv4 b)
    ,Number (Number) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM lv5)
SELECT
	ISNULL(ABS(CONVERT(INT, CONVERT(BINARY(8), NEWID()))) % 32767, 0) as TenantId,
	ISNULL(Number, 0) as Number
INTO BigTable
FROM Number
WHERE
	Number <= 20000000;

GO

ALTER TABLE BigTable
ADD CONSTRAINT UC_BigTable_PK
PRIMARY KEY CLUSTERED (TenantId, Number);

GO

--EXEC sp_help 'dbo.BigTable';