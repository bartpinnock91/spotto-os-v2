/*───────────────────────────────────────────────────────────────────────────
  Segment 2 — keep ONE canonical record per cluster, delete the rest

  Scope: 26 dead clusters (no active account anywhere in the cluster).
  Every cluster keeps exactly one canonical record (26 keepers); the other
  28 records are deleted.

  Excluded and handled elsewhere:
    - 3 merge clusters  -> merge-segment2-clusters-2026-06-15.sql
    - 3 out-of-scope clusters (distinct offices, left alone):
        452704542 C21 Via Plus/leiestreek, 441178170 Immo-Consult/Solvas,
        471403865 Malines Group/Mechelen

  Canonical chosen as: the record holding the listings; for the 7 history-less
  clusters, the Inactive (Status 3) record over the Archived one, else the one
  with more import-job history.

  Keepers (NOT deleted), 26:
    with history (19):
      3E47733F BCA Bouwt Beter     | 856F17FD Verlimmo        | 1065F813 Walbers Immo
      B9B9122E Els Lenaerts Vastgd | 26071C62 RG Immo         | 11C27C0B Immo Tinis
      27EA7620 Domus Innova        | E7AEAF6E immo Lombaert   | 1286BFA7 B-Home
      51E92F4A Immo ADV            | 3B75BF67 Axel Lenaerts   | B0A4E894 Gijbels Vastgoed
      6E657B28 Immo Het Zekerhuis  | 71F040A2 Michele V.Damme | 90E44637 Hero Vastgoed
      8BA60C44 Immo Berquin        | 15564D3F Aktimmo         | C0B83EA0 B-Casa Immo
      96853593 Goeman Wichelen
    history-less (7):
      F30A76B4 Broker | ECA35EF3 Kantoor Geebelen | 6D3CCDC4 Wilfra
      3C323E9D Century 21 Immoway | 604C2FCC Immo Casteleyn | BBC84076 Immosim
      A3814EA0 Huize Jansen

  The 28 records deleted carry no Publications/Questions/Users. Two hold one
  (redundant) RealtorProfile each, cleared first. Otherwise only CRM config /
  import-job logs.
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* Records to delete (28) — every non-canonical record in the 26 clusters. */
    DECLARE @ToDelete TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @ToDelete (Id) VALUES
     ('C22BCECE-4DB5-4FB7-B27A-AF9C00F33E0B'),('E1085E00-414F-493F-806B-AFAE0091D3B3'),('44FFEDC1-BA72-4CBA-8AA4-AF9E00A13D96'),
     ('DE92B4DF-5945-4ADA-B132-AF9E00D6D3C9'),('F6405094-F0A6-4C83-A123-AFA300CC1500'),('EA9AC62B-BA3B-495D-9959-AFA300CB931E'),
     ('4C55BDF8-F7FC-412E-8D96-AF9E00A88284'),('1CE5D6E3-956E-48D6-BE34-AFA1009C73EB'),('20CC078A-4F1D-4CD6-A0D5-AFA20098E976'),
     ('27F5F891-1BB2-4955-B071-AFA2009AC8AA'),('D2466C86-005F-41B5-840B-AFA200A02401'),('414BF9F8-BAA2-4C56-AECD-AFA100852125'),
     ('25015665-10E1-44C0-956D-AFA2009D2312'),('4964DCF7-0827-4BFA-9272-AFFF008C9B2D'),('9095C476-5428-4732-A71D-AFA300A375B0'),
     ('262E647E-ABCD-4A5D-AF8F-AF9E00D3B6CB'),('F480B40A-29A8-4C22-9D64-AFA300CE35AD'),('78944A5A-DCC4-40DF-AD16-AF9E00BABD1C'),
     ('EAFF368E-A1F7-4417-9593-AFA200CDB192'),('66AE4999-08F7-45CA-BFBC-AFA10097845F'),('D8745F99-E105-4A43-A40B-AF9E00D279C9'),
     ('437F9BA4-3C8A-45B1-BF17-AFA300C87815'),('118D64CF-74D7-4194-BD35-AFA300CAE079'),('C9C27FE9-6460-402C-9464-AFA300CB3113'),
     ('D91DAD0C-7005-4C78-9CB2-AF9E00D9A1C0'),('3B8DDEC8-487C-4877-9AF8-AFDD00AE3812'),('AD12A6D6-5B83-430E-A7CE-AF9E00D5167B'),
     ('8B61039B-2C4C-4D0C-AD63-AF9E009DAEC2');

    /* The 26 canonical keepers — must survive. */
    DECLARE @Keepers TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @Keepers (Id) VALUES
     ('3E47733F-9221-4DEF-B339-AFD500A828AF'),('856F17FD-7611-464F-863D-AFAE0090F491'),('1065F813-10EC-475C-A89A-AF9E00D67B7F'),
     ('B9B9122E-8BD6-411D-9777-AFA200F0619F'),('26071C62-E951-4311-94F5-AFA100A6A1BC'),('11C27C0B-9EAF-435A-8E95-AFC500A8BA1B'),
     ('27EA7620-AF27-448B-AF9C-B00D00808E2A'),('E7AEAF6E-C84C-4CC2-9639-AFC300E31E7B'),('1286BFA7-700D-49C6-9A9C-AFA100B6B34F'),
     ('51E92F4A-6D95-46FE-AC17-AFEB006B31B6'),('3B75BF67-B049-4999-8CB0-AF9B00FC378D'),('B0A4E894-DC68-482A-B9D1-AFA200B44DB2'),
     ('6E657B28-DEE8-473A-901D-AF9C00D9B08B'),('71F040A2-FF48-4DA7-8AC6-B03900CB8731'),('90E44637-6931-4952-8529-AF9E00AD9BD5'),
     ('8BA60C44-8D99-44A8-9CEE-AF9D010508AB'),('15564D3F-AB8B-49A6-89E6-AFA20102C954'),('C0B83EA0-38BC-4960-BE54-AFA200F0FC77'),
     ('96853593-06D7-4C6B-BF6F-AFDD00AD55A9'),
     ('F30A76B4-B954-457F-B32F-AF9E00A9386F'),('ECA35EF3-4A7D-4DAE-8899-AFA200EFAE4F'),('6D3CCDC4-B08F-415E-AA55-AF9D00AA6C87'),
     ('3C323E9D-9ECA-4FD6-A3F4-AF9E0094BF27'),('604C2FCC-80FB-43EA-8FFC-AFA2009CCBA6'),('BBC84076-647A-4766-BB3F-AF9E00B5B4B7'),
     ('A3814EA0-F4F0-4E6D-9BAA-AF9E00D5D5FB');

    /* Guards */
    IF (SELECT COUNT(*) FROM @ToDelete) <> 28
        THROW 50001, 'Guard failed: expected 28 delete ids.', 1;

    -- A keeper must never appear in the delete set.
    IF EXISTS (SELECT 1 FROM @ToDelete WHERE Id IN (SELECT Id FROM @Keepers))
        THROW 50002, 'Guard failed: a keeper is in the delete set.', 1;

    -- Every keeper must still exist (else we would orphan a cluster's canonical).
    IF EXISTS (SELECT 1 FROM @Keepers k LEFT JOIN Customers c ON c.Id=k.Id WHERE c.Id IS NULL)
        THROW 50003, 'Guard failed: a canonical keeper is missing. Aborting.', 1;

    -- Every delete target must be an inactive/archived organisation.
    IF EXISTS (SELECT 1 FROM @ToDelete d LEFT JOIN Customers c ON c.Id=d.Id
               WHERE c.Id IS NULL OR c.Status NOT IN (3,4) OR c.CustomerType NOT IN (2,3))
        THROW 50004, 'Guard failed: a delete target is missing, active, or not an organisation.', 1;

    -- No delete target may carry listings/contacts/accounts. (RealtorProfiles is
    -- allowed and cleared below; only redundant duplicate profiles exist here.)
    IF EXISTS (SELECT 1 FROM Publications t JOIN @ToDelete d ON t.CustomerId=d.Id)
    OR EXISTS (SELECT 1 FROM Questions    t JOIN @ToDelete d ON t.CustomerId=d.Id)
    OR EXISTS (SELECT 1 FROM Users        t JOIN @ToDelete d ON t.CustomerId=d.Id)
        THROW 50005, 'Guard failed: a delete target carries Publications/Questions/Users. Aborting.', 1;

    /* Remove child rows that reference these customers. */
    DELETE t FROM RealtorProfiles            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CrmIntegrations            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImportProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;
    -- Defensive (empty for the current set):
    DELETE t FROM CustomerInvitations                   t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublications                       t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM UserPublicationOrders                 t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImports                     t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationProcesses             t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM CheckPublicationsForCustomerProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* Delete the non-canonical customers. */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @ToDelete d ON c.Id = d.Id;
    SET @deleted = @@ROWCOUNT;

    IF @deleted <> 28
        THROW 50006, 'Guard failed: customer delete count <> 28. Rolling back.', 1;

    COMMIT TRAN;
    PRINT 'OK: deleted ' + CAST(@deleted AS varchar(10)) + ' non-canonical records across 26 clusters (26 keepers retained).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
