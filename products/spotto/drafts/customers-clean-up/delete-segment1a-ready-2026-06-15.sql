/*───────────────────────────────────────────────────────────────────────────
  Segment 1a cleanup — DELETE the 65 "ready" duplicate customers
  Source: segment1a-duplicate-customers-cleanup-2026-06-15.csv (SuggestedAction = DELETE)

  These are inactive/archived organisational customers (CustomerType 2/3,
  Status 3/4) that exactly duplicate an ACTIVE customer (same VAT or Immo
  Connect org-id) and carry NO listings/history (0 Publications, Questions,
  Users, RealtorProfiles).

  Excluded from this set (handled separately):
    - 38 CARRY-OVER records (have history to reassign first)
    - The Sofiemo/Selfiemo duplicates -> see delete-selfiemo-2026-06-15.sql

  Child rows that DO exist for some of these 65 and are removed first:
    - CrmIntegrations              (feed config)
    - PublicationImportProcesses   (import-job history)

  Run as a single batch. XACT_ABORT + explicit transaction: any error rolls
  everything back. The guard block aborts if the set ever resolves to a record
  that is active or that carries real load (protects against data drift).
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* 1) The approved delete set ----------------------------------------- */
    DECLARE @ToDelete TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @ToDelete (Id) VALUES
     ('46DA394C-8F93-4DA8-28B4-08DCA7FF8BFA'),('25C14679-2196-45FB-A295-AF9C00E78526'),('F84787AA-049A-4021-A3CE-AFB200EDD31F'),
     ('F4988C55-9F0B-4666-9796-AFA300CA4099'),('F79AD973-44DA-4ECA-B9E9-AFA20103D11E'),('CE79E369-4DA2-4CF0-890F-AFA300C8BAC4'),
     ('7AA850F3-4F3B-482F-8C5C-AFA300BD7E5A'),('1266E910-56B9-4C41-B411-AFA1008CCEC6'),('E62E3144-B315-4CB4-89C8-AFA2009FE236'),
     ('DCCE490C-9E75-4C87-AC47-AFA300C8FAF2'),('920E8CBA-A41E-4C5F-B5A8-AFA300C93B93'),('B1C90FA3-3E5F-41AC-9CE6-AFA100DC680A'),
     ('38C438D6-CADE-4D6F-9EA1-AFA300CD728F'),('F921A555-C347-4844-B396-AFA1008C8C40'),('32D8E23D-112C-444D-9834-AFA300CE76BC'),
     ('81B33098-DE4E-4374-A88A-AF9B00FA928B'),('88272318-B61C-4550-922C-AF9B00FB20EE'),('5792AA79-3453-4EE4-8831-AFA300CEB7EB'),
     ('A5A013E7-AEC7-4447-923D-AFA200A26731'),('A46A9F57-DC04-4D0B-9A8B-AFC800FBD3B9'),('6BAA2317-BEEE-4CA8-A37F-AFA200892782'),
     ('B0B0F995-137C-4638-A4CB-AF9E00DC8875'),('2295EEC4-5E4B-4A0F-BEFC-AFA1009916F2'),('A7D3FF20-C4F2-4329-BAD6-AF9B00BDCCD7'),
     ('EED96DFE-F016-4DEC-B772-AFE200DE7FA4'),('D643430E-A18D-4475-8620-AF9E010934FB'),('64389A07-33BA-4A48-9421-AF9E0090A70C'),
     ('FC160204-3652-437F-8C23-AF9E00AEBC08'),('5DE606EE-D089-4487-A661-AF9E00D6257A'),('65EE16EE-A53D-4882-B82A-AFA200F15066'),
     ('F6541B4C-2986-4B94-8045-AFA20106D5D8'),('6BE0ABEC-E53E-4DD3-82E4-AFA300CDB37B'),('F30421C3-558A-42FE-8401-AFA1008EA743'),
     ('F8E4F5B0-41AF-44A5-80FB-AFA300CBD429'),('D69E0D81-75AB-42A0-9DA4-AFA300CC56F7'),('CFE6152A-04BF-4857-8151-AFA300CCF0FA'),
     ('9EE1E5CE-118C-4E23-BF84-AFA300985F47'),('73FBC4E8-0CBB-48E8-A253-AFA300CDF487'),('89313142-F6F3-4E0E-991B-AFA100F73C3A'),
     ('917ADFBE-A811-41AF-9D35-AFA200F24626'),('02542B8E-370D-4290-B3F3-AFA300A951C7'),('B1BB41EF-F303-400E-9FB8-AFAE00934E9A'),
     ('D598DD3F-02B0-49A2-8915-AFA300C83790'),('4A8A2708-A463-46F0-B88B-AF9E00DFB8CE'),('4CAF8C40-7D55-4443-BF3A-AF9C00D8BFEC'),
     ('8C874DCD-324E-4ED1-9DC0-AF9C00D7B2EC'),('D369D993-442C-4117-BCE3-AFA300BCBA37'),('E7E4145F-48F7-4348-BA71-AFA300C9BDD0'),
     ('E2571E25-BBF9-41B3-AF6C-AFA300C9FFAE'),('BF3D581D-4FDB-47CE-9F7A-AF9E00D7DBB1'),('22AE73F1-7EFD-4740-9A01-AFA2008C546E'),
     ('672B6255-E0CE-4F4E-9E37-AFA200B5AAFA'),('FE9C6A56-9DBD-451A-BAB0-AFA100DCACCB'),('2E7C4384-AB31-45A8-90CD-AFA200A8F411'),
     ('46C28848-8D78-41FC-A53F-AF9B0101A399'),('EA392ECB-91BD-497A-9D4D-AF9C00E38487'),('C687386A-120C-41F9-AA42-AF9C00F5B49F'),
     ('01C84343-6D87-4D45-8379-B00C0093624E'),('56A8BDBB-115F-4609-94D0-AFA200AB4651'),('75C4DC8F-57EE-4182-9C16-AFA300BD3C86'),
     ('BEA30B9F-0629-4F6E-BC37-AFA30099641E'),('373B76DE-2973-472D-930F-AF9C00D5EB3E'),('84E5E629-6A87-463B-82BA-AFA300BCFB87'),
     ('4546072B-292A-482B-A945-AFA300BDBF39'),('D65858CC-3013-4BD4-BAC9-AF9E00DEF26D');

    /* 2) Safety guards --------------------------------------------------- */
    -- 2a. Exactly 65 ids supplied
    IF (SELECT COUNT(*) FROM @ToDelete) <> 65
        THROW 50001, 'Guard failed: expected 65 ids in delete set.', 1;

    -- 2b. Every target must still be an inactive/archived organisational customer.
    --     Aborts if any id is missing, active (Status 1/2), or not CustomerType 2/3.
    IF EXISTS (
        SELECT 1 FROM @ToDelete d
        LEFT JOIN Customers c ON c.Id = d.Id
        WHERE c.Id IS NULL
           OR c.Status NOT IN (3,4)
           OR c.CustomerType NOT IN (2,3)
    )
        THROW 50002, 'Guard failed: a target is missing, active, or not an organisation. Aborting.', 1;

    -- 2c. No target may carry real listings/history.
    IF EXISTS (SELECT 1 FROM Publications     t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Questions        t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Users            t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM RealtorProfiles  t JOIN @ToDelete d ON t.CustomerId = d.Id)
        THROW 50003, 'Guard failed: a target carries Publications/Questions/Users/RealtorProfiles. Aborting.', 1;

    /* 3) Remove child rows that reference these customers ---------------- */
    DELETE t FROM CrmIntegrations            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImportProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;
    -- Defensive: these are empty for the current set but cleared in case of drift.
    DELETE t FROM PublicationImports                    t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublications                      t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublicationOrders                t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CustomerInvitations                  t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationProcesses            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationsForCustomerProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* 4) Delete the customers ------------------------------------------- */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @ToDelete d ON c.Id = d.Id;
    SET @deleted = @@ROWCOUNT;

    IF @deleted <> 65
        THROW 50004, 'Guard failed: customer delete count <> 65. Rolling back.', 1;

    COMMIT TRAN;
    PRINT 'OK: deleted ' + CAST(@deleted AS varchar(10)) + ' customers + their CrmIntegrations / import-process rows.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
