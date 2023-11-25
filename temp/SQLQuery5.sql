DROP SECURITY POLICY IF EXISTS dbo.SecurityPolicy;
GO
DROP FUNCTION IF EXISTS SecurityPredicate_fn;
GO

CREATE OR ALTER FUNCTION SecurityPredicate_fn(
	@TenantId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
	SELECT TOP 1 1 AS Result
	FROM (
		SELECT
				SessionNumber,
				CanReadAnyRow,
				TenantId
		FROM dbo.SessionDetail
		WHERE SessionNumber = @@SPID AND TenantId = @TenantId

		UNION ALL

		SELECT
				SessionNumber,
				CanReadAnyRow,
				TenantId
		FROM dbo.SessionDetail
		WHERE SessionNumber = @@SPID AND CanReadAnyRow = 1
	) s;

GO

CREATE OR ALTER FUNCTION SecurityPredicate_fn(
	@TenantId INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
	SELECT TOP 1 1 AS Result
	FROM (
		SELECT
				SessionNumber,
				CanReadAnyRow,
				TenantId
		FROM dbo.SessionDetail
		WHERE SessionNumber = @@spid
	) s
	where
		CanReadAnyRow = 1 or
		TenantId = @TenantId;

GO

CREATE SECURITY POLICY dbo.SecurityPolicy
ADD FILTER PREDICATE dbo.SecurityPredicate_fn(TenantId) ON dbo.BigTable,
ADD BLOCK PREDICATE dbo.SecurityPredicate_fn(TenantId) ON dbo.BigTable AFTER INSERT,
ADD BLOCK PREDICATE dbo.SecurityPredicate_fn(TenantId) ON dbo.BigTable AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON);

go
