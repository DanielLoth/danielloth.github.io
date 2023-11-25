UPDATE dbo.SessionDetail
SET
	TenantId = @@SPID,
	CanReadAnyRow = ISNULL(CONVERT(BIT, IS_ROLEMEMBER('db_datareader')), ISNULL(CONVERT(BIT, IS_ROLEMEMBER('dbo')), IS_SRVROLEMEMBER('sysadmin')))
WHERE
	SessionNumber = @@SPID;

	select * from dbo.SessionDetail where SessionNumber = @@spid;

--set showplan_text off;

set statistics io, time on;


--(1 row affected)
--Table 'BigTable'. Scan count 13, logical reads 62532, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'SessionDetail'. Scan count 0, logical reads 65534, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

--(1 row affected)


SELECT  COUNT(1) AS NumRows
FROM    dbo.BigTable
where TenantId = @@SPID;

SELECT  top 5 *
FROM    dbo.BigTable;
