/*───────────────────────────────────────────────────────────────────────────
  DELETE the 21 archived "dubbel" / IC-erkenning="1" duplicate customers
  Date: 2026-06-19

  Source: live scan of dbo.Customers for
      Remarks LIKE '%dubbel%' / '%double%' / '%duplic%'
   OR ImmoConnect_OrganizationId IN ('1','0')      ("1" = bogus IC placeholder)
   OR ImmoConnect_ParentOrganizationId IN ('1','0')

  This set = the matched rows that are ALL of:
    - Status 4 (Archived)
    - CustomerType 2/3 (organisation / establishment)
    - carry NO listings/history: 0 Publications, 0 Questions, 0 Users,
      0 RealtorProfiles

  NOT included (handled separately):
    - 26 archived + 3 inactive rows that DO carry history
      (Immo-Consult 757 pubs, N78 563, Acasa Loppem 320, Quares 226, ...)
      -> need carry-over/cascade decision first.
    - 30 Active (Status 2) rows -> archive before any delete.

  Child rows present for some targets and removed first:
    - CrmIntegrations             (Immo Hanssens, N3, Reypens, Som Genk,
                                   Sophie Eerdekens, Vastgoed Lanneer, Woonbureau)
    - PublicationImportProcesses  (Immo Snoeys 15, Immosign+ 6, Som enkel 34,
                                   Som Genk 4, Sophie Eerdekens 6, Topo-Immo 107,
                                   Woonbureau 3)

  Robustness: a sibling cleanup (segment2-canonical) ran concurrently this
  session. This script therefore does NOT hard-fail on a count mismatch — if a
  listed id was already removed elsewhere it is silently skipped. It DOES abort
  if any listed id resolves to an active row or one carrying real load.

  Run as a single batch. XACT_ABORT + explicit transaction: any error rolls
  everything back.
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* 1) The approved delete set (21 archived, zero-history duplicates) --- */
    DECLARE @ToDelete TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @ToDelete (Id) VALUES
     ('01CE5F97-4DF2-4DF2-A70A-B14F0091F3EF'),  -- Bastijns Projects        (IC=1)
     ('FF2688A2-8B90-4CB3-AE29-AFA200EF025D'),  -- Immo De Groot & Celen    (IC=1)
     ('EECED6C1-FCF3-490E-B260-AFB300B1A8C0'),  -- Immo Hanssens            (IC=1)
     ('678B05E6-1824-4B9C-802C-AFA30098A032'),  -- Philippe Puissant        (IC=1)
     ('762832F8-4B1F-4656-93EB-AF9C00C1C3E4'),  -- (oud) Immo van Hoye
     ('DCBA18C7-ADA3-48D8-883D-AF9E00D3CB17'),  -- Altro Vastgoed
     ('1BB17E9E-8E9A-4219-A134-AF9E00CE73DF'),  -- Engel & Voelkers Brugge
     ('6AEC18A0-1880-488E-864E-AFA200A550A5'),  -- euro fout
     ('2A091181-70BD-4585-9C49-AFA200BA5FAC'),  -- Immo Koen Dhont
     ('82B11130-47D9-41C6-821C-AF9E00F00D64'),  -- Immo Snoeys
     ('C19C223B-EC18-4710-8104-AFA300CD31B6'),  -- Immosign+
     ('7F95DBFF-7FBF-449A-8576-AFA300CFED88'),  -- J&E Holdings (archived dup)
     ('31C8F19B-2CF9-461F-9A84-AFA1009C30CB'),  -- N3 Vastgoed
     ('389E2C89-22AC-4F4F-B66A-AF9E00EF887A'),  -- Reypens Real Estate Mentor
     ('96F7B9BF-6CB3-4696-8D5F-AFA300A59540'),  -- Som Vastgoed enkel
     ('11F0FBE3-C6AE-4E83-8E42-AFA300BA1AD1'),  -- Som Vastgoed Genk
     ('EDD5E6B9-6BBC-4C46-BBFA-AFA300CF9891'),  -- Sophie Eerdekens
     ('31ECC374-E98A-442D-A9BA-AFA200B84296'),  -- Topo-Immo
     ('80595A34-AED4-49C0-A182-AF9E00F85751'),  -- Trevi Axus
     ('E1637027-884A-4722-94A2-AFA10088235C'),  -- Vastgoed Lanneer
     ('209CB229-6239-4C57-9608-AF9C00E747C9');  -- Woonbureau Lokeren

    /* 2) Safety guards --------------------------------------------------- */
    -- 2a. No LISTED target may be active or be the wrong customer type.
    --     (Rows already deleted by a sibling script are simply absent -> skipped,
    --      which is fine; we only forbid deleting something still active.)
    IF EXISTS (
        SELECT 1 FROM @ToDelete d
        JOIN Customers c ON c.Id = d.Id
        WHERE c.Status NOT IN (3,4)
           OR c.CustomerType NOT IN (2,3)
    )
        THROW 50001, 'Guard failed: a listed target is active or not an organisation. Aborting.', 1;

    -- 2b. No LISTED target may carry real listings/history.
    IF EXISTS (SELECT 1 FROM Publications    t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Questions       t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Users           t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM RealtorProfiles t JOIN @ToDelete d ON t.CustomerId = d.Id)
        THROW 50002, 'Guard failed: a listed target carries Publications/Questions/Users/RealtorProfiles. Aborting.', 1;

    /* 3) Remove child rows that reference these customers ---------------- */
    DELETE t FROM CrmIntegrations            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImportProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;
    -- Defensive: empty for the current set, cleared in case of drift.
    DELETE t FROM PublicationImports                     t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublications                       t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublicationOrders                 t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CustomerInvitations                   t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationProcesses             t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationsForCustomerProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* 4) Delete the customers ------------------------------------------- */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @ToDelete d ON c.Id = d.Id;
    SET @deleted = @@ROWCOUNT;

    COMMIT TRAN;
    PRINT 'OK: deleted ' + CAST(@deleted AS varchar(10)) + ' of 21 archived duplicates (skipped any already removed by a sibling script).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
