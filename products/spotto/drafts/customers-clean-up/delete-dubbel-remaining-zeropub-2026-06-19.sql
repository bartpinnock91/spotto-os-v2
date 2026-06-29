/*───────────────────────────────────────────────────────────────────────────
  DELETE 21 remaining "dubbel" duplicate customers that carry NO publications
  Date: 2026-06-19

  Source: dubbel-remaining-active-and-history-2026-06-19.csv, rows flagged Del,
  restricted (per decision) to those with 0 Publications. The 11 Del rows that
  still carry archived publications are NOT here -> handled separately via
  keeper carry-over. The contact-request rows (N78, Quares) and the pub-carrying
  no-twin rows (Quares, Immo Vesta arch) are also excluded.

  Each target was verified to have an ACTIVE surviving keeper holding the real
  data (same KBO/IC), EXCEPT the "no-twin" rows the user explicitly approved:
    AJC Advies, Sinjoor - Nove Vastgoed, Vastgoed de Vriese, J&E Holdings,
    De Boer & Partners Kalmthout, Immo ADV.

  NOTE - reversal: Immo ADV (51E92F4A) was kept as a canonical keeper by
  delete-segment2-canonical-2026-06-15.sql. Deleting it here removes the last
  record of that dead, listing-less cluster. Approved by user. 0 pubs/0 questions.

  This set MIXES Active (2) / Inactive (3) / Archived (4) customers, so unlike
  the segment scripts there is NO status guard. The hard guard instead is:
  every target must carry 0 Publications and 0 Questions (protects against drift
  where a record gained listings/contacts). Users (9 realtor stubs, negligible
  activity) and RealtorProfiles ARE present and cleared first.

  Child rows removed first (in dependency order):
    User-owned : ViewedPublications, FavoritePublications, PublicationSearches,
                 UserEvaluationCriteria, UserPublicationAppointment,
                 UserPublicationEvaluationNote, WebshopOrders
    Users      : 9 rows (AJC, C Plus, Immo Verbeeck, Janssen, J&E Holdings,
                 De Boer, DOMO x2, Immo ADV)
    Customer   : RealtorProfiles, CrmIntegrations, CustomerInvitations,
                 PublicationImportProcesses, PublicationImports, UserPublications,
                 UserPublicationOrders, CheckPublicationProcesses,
                 CheckPublicationsForCustomerProcesses

  Tolerant of concurrent deletes: a listed id already removed elsewhere is simply
  skipped. Aborts if any listed id still carries Publications or Questions.

  Single batch. XACT_ABORT + explicit transaction: any error rolls back.
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* 1) The approved delete set (21 zero-publication duplicates) --------- */
    DECLARE @ToDelete TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @ToDelete (Id) VALUES
     ('46C1E5A5-9156-4358-750C-08DD4D285ECE'),  -- C Plus                       (Archived, twin Cplus 171 pubs)
     ('A974469C-D512-4EAC-B590-AFA100F6BAEA'),  -- EST8                         (Active,   twin EST8 834 pubs)
     ('8F0DE5F2-D805-4830-BD9C-AFA100EF3DA8'),  -- Gorris Vastgoed              (Active,   twin Gorris 649 pubs)
     ('5CEBC0BB-7ECA-43F8-78A7-08DCD0DC6906'),  -- Homeway Eeklo                (Active,   empty establishment)
     ('B4B62272-3239-488B-B4A3-AFA101004F7E'),  -- Immo Assim                   (Active,   twin Immo Assim 110 pubs)
     ('3C1F7504-6253-464F-965A-AF9E009229D4'),  -- Immo Nulens                  (Active,   twin Immo Nulens 63 pubs)
     ('146AF6F4-87DD-42EB-4A99-08DCC34C5DE4'),  -- Immo Verbeeck                (Active,   twin Immo Verbeeck 58 pubs)
     ('6FE2BC96-FAAA-46E9-1EED-08DD4AA9F151'),  -- Janssen en Janssen           (Active,   twin Janssen 2664 pubs)
     ('E29D44FB-FA84-4A8B-A133-AFA100DB9D5E'),  -- Pantheon Vastgoed            (Active,   twin Pantheon 321 pubs)
     ('54EF56D9-9A5E-4D28-BD6D-AFA100E07887'),  -- Sem Vastgoed                 (Active,   twin Sem 127 pubs)
     ('07A781FC-2712-4820-BAFD-AFA100FE38B9'),  -- Agence Vanbeckevoort         (Archived, twin Vanbeckevoort 1538 pubs)
     ('770C2975-24AD-48CB-1640-08DE858B300E'),  -- Altro Vastgoed Edegem        (Archived, active branch keeper)
     ('11FC5580-8E6B-4E2C-A49F-08DE858B300E'),  -- Altro Vastgoed Hemiksem      (Archived, active branch keeper)
     ('8D9CAF1D-E0DB-42EC-58CC-08DE858B3009'),  -- Altro Vastgoed Oostende      (Archived, active branch keeper)
     ('506D860E-D4F2-4C2F-7E2A-08DD06A877BD'),  -- DOMO VASTGOED n.v.           (Archived, twin Domo 1374 pubs)
     ('E7C6FB23-C8F6-4E8C-869D-08DD1468615E'),  -- AJC Advies                   (Archived, no-twin, approved)
     ('094FF1BA-8836-4A10-9ED8-AF9E009C1694'),  -- Sinjoor - Nove Vastgoed      (no-twin, approved)
     ('F1112902-52B5-4C2C-8E4D-AFA100E02C75'),  -- Vastgoed de Vriese           (Active, no-twin, approved)
     ('2C7FDA75-1F21-44E9-8635-AFA200B51A0E'),  -- J&E Holdings                 (Inactive, keeper=Evimmo, approved)
     ('A3BA19CE-BF50-4F74-C0C6-08DD392C9C60'),  -- De Boer & Partners Kalmthout (Archived, no-twin, approved)
     ('51E92F4A-6D95-46FE-AC17-AFEB006B31B6');  -- Immo ADV                     (Archived, ex-canonical keeper, approved)

    /* 2) Safety guards --------------------------------------------------- */
    -- 2a. No LISTED target may be the wrong customer type. (Status not guarded:
    --     the set intentionally mixes Active/Inactive/Archived.)
    IF EXISTS (
        SELECT 1 FROM @ToDelete d
        JOIN Customers c ON c.Id = d.Id
        WHERE c.CustomerType NOT IN (2,3)
    )
        THROW 50001, 'Guard failed: a listed target is not an organisation. Aborting.', 1;

    -- 2b. No LISTED target may carry Publications or Questions (the real-data guard).
    IF EXISTS (SELECT 1 FROM Publications t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Questions    t JOIN @ToDelete d ON t.CustomerId = d.Id)
        THROW 50002, 'Guard failed: a listed target carries Publications/Questions. Aborting.', 1;

    /* 3) Clear USER-owned rows for the users of these customers ---------- */
    DELETE x FROM ViewedPublications          x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM FavoritePublications        x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM PublicationSearches         x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM UserEvaluationCriteria      x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM UserPublicationAppointment  x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM UserPublicationEvaluationNote x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;
    DELETE x FROM WebshopOrders               x JOIN Users u ON x.UserId=u.Id JOIN @ToDelete d ON u.CustomerId=d.Id;

    /* 4) Delete the Users (realtor stubs) -------------------------------- */
    DELETE u FROM Users u JOIN @ToDelete d ON u.CustomerId = d.Id;

    /* 5) Clear RealtorProfiles (NO_ACTION FK -> must precede customer) ---- */
    DELETE t FROM RealtorProfiles t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* 6) Clear remaining customer child rows ----------------------------- */
    DELETE t FROM CrmIntegrations            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CustomerInvitations        t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImportProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImports         t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublications           t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublicationOrders      t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationProcesses             t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationsForCustomerProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* 7) Delete the customers ------------------------------------------- */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @ToDelete d ON c.Id = d.Id;
    SET @deleted = @@ROWCOUNT;

    COMMIT TRAN;
    PRINT 'OK: deleted ' + CAST(@deleted AS varchar(10)) + ' of 21 zero-pub duplicates (+ their users/realtor profiles/child rows).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
