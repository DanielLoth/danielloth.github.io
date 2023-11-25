DROP TABLE IF EXISTS dbo.SessionDetail;
GO

WITH
        lv0 AS (SELECT 0 g UNION ALL SELECT 0),
        lv1 AS (SELECT 0 g FROM lv0 a CROSS JOIN lv0 b),
        lv2 AS (SELECT 0 g FROM lv1 a CROSS JOIN lv1 b),
        lv3 AS (SELECT 0 g FROM lv2 a CROSS JOIN lv2 b),
        lv4 AS (SELECT 0 g FROM lv3 a CROSS JOIN lv3 b),
        lv5 AS (SELECT 0 g FROM lv4 a CROSS JOIN lv4 b),
        Number (Number) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM lv5)
SELECT TOP 32767
        ISNULL(CONVERT(SMALLINT, Number-1), 0) AS SessionNumber,
        ISNULL(CONVERT(BIT, 0), 0) AS CanReadAnyRow,
        ISNULL(CONVERT(INT, @@SPID), 0) AS TenantId
INTO    dbo.SessionDetail
FROM    Number
WHERE   Number <= 32767;

GO

ALTER TABLE dbo.SessionDetail
ADD CONSTRAINT UC_SessionDetail_PK
PRIMARY KEY CLUSTERED (SessionNumber);

SELECT * FROM dbo.SessionDetail;