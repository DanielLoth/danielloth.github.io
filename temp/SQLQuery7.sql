UPDATE  dbo.SessionDetail
SET
        TenantId = @@SPID,
        CanReadAnyRow =
            ISNULL(
                CONVERT(BIT, IS_ROLEMEMBER('db_datareader')),
                ISNULL(
                    CONVERT(BIT, IS_ROLEMEMBER('dbo')),
                    IS_SRVROLEMEMBER('sysadmin')))
WHERE
        SessionNumber = @@SPID;