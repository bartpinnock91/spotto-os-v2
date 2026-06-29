/*───────────────────────────────────────────────────────────────────────────
  MERGE 15 "dubbel" duplicates into their keeper, then delete the emptied source
  Date: 2026-06-19
  Source flags: carryover-worklist-2026-06-19.csv, column carry-over = 'y'

  Listings/history on each duplicate are REASSIGNED to the keeper first, then the
  emptied duplicate is deleted. No data loss. Modelled on
  merge-segment2-clusters-2026-06-15.sql.

  Reassigned to keeper (by CustomerId): Publications, Questions, RealtorProfiles,
  Users, UserPublications, UserPublicationOrders. (ViewedPublications /
  FavoritePublications key off UserId, so they follow the moved Users
  automatically.)

  Volume moved: ~1,871 publications, 47 contact-requests, 3 users,
  2 realtor profiles, 16 user-publications, 1 user-publication-order.

  User unique-index (PersonId+OrgId) checked: each of the 3 source users
  (Boo'Fort, Imtek, Verlinden) has a PersonId distinct from its keeper's users,
  so reassignment cannot collide.

    Source (deleted)                         ->  Keeper (survivor)
    ---------------------------------------      --------------------------------------
    Immo-Consult            757p 3q          ->  C21 Immo Consult        (LOW: see note)
    N78 Vastgoed            563p 19q 1rp     ->  Group N - N78
    Quares                  226p 25q 1rp     ->  Quares Residential Agency
    Depotter                159p             ->  Depotter (active)
    B & B Swolfs             55p             ->  sharp & wolf
    Immobiliën Johan Telen   44p             ->  Immobiliën Johan Telen (active)
    Immo Vesta arch          25p             ->  Immo Vesta (active)   (MEDIUM: KBO differs)
    Agence Dermul            17p             ->  Agence Dermul (active)
    t Huys Vastgoed          12p             ->  t Huys Vastgoed (active)
    Agence Boo'Fort           5p 1u          ->  Agence Boo'fort (active)
    Imtek Vastgoed            3p 1u          ->  Imtek (active)
    Verlinden Vastgoedgroep   2p 1u          ->  Verlinden Vastgoedgroep (active)
    Immo D'Hondt Beheer       1p             ->  Immo D'Hondt Beheer (active)
    Immo Atelier              1p             ->  Immo Atelier (active)
    Immo3000 - arch           1p             ->  Immo3000 (active)

  LEFT BE (carry-over = 'n', not in this script): Albert - Loppem, Acasa Loppem
  (Albert/Loppem franchise tangle — keeper unconfirmed).

  NOTE - Immo-Consult: segment2 earlier flagged Immo-Consult/Solvas as "distinct
  offices, left alone", and Solvas Aalter shares its KBO 0441178170. You approved
  C21 Immo Consult (0ff13149) as keeper in the worklist; proceeding on that.

  Single batch. XACT_ABORT + explicit transaction: any error rolls everything back.
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* Map: each duplicate (deleted) -> the keeper it folds into. */
    DECLARE @Merge TABLE (NonKeeperId uniqueidentifier PRIMARY KEY, KeeperId uniqueidentifier);
    INSERT INTO @Merge (NonKeeperId, KeeperId) VALUES
     ('74BBA98A-E01E-4968-A4A1-AF9B0097FD8B','0FF13149-63BF-49EC-B131-AFCC0101A76A'), -- Immo-Consult -> C21 Immo Consult
     ('89A92DD0-0968-4651-BFF7-AFA1009A22A6','9E024947-3771-4547-B293-AFDD008A03A9'), -- N78 Vastgoed -> Group N - N78
     ('F46DD3D4-136A-47FB-9FFB-AF9C00CA410C','135F39F0-BEE5-4C7B-62B1-08DD8C79F777'), -- Quares -> Quares Residential Agency
     ('D2B02552-DA03-4AE6-8255-AFCC0104DBB9','75C83880-491E-43E1-A4B9-AF9B00D0D9ED'), -- Depotter
     ('95F542DA-19D2-4A01-82A3-AFD900C49DF6','3790EA23-BE0C-4CD2-A4CC-AFA200F82930'), -- B & B Swolfs -> sharp & wolf
     ('25ADB3FD-1C19-42F0-97DA-AF9E00937CB5','AF6206EC-4C9C-4673-9A69-AF9E00B62AC5'), -- Immobilien Johan Telen
     ('BD9497DD-2600-418B-99D0-AFA300C97D34','4AF91CC4-6C85-48C2-AEDD-AFA200F496C2'), -- Immo Vesta arch -> Immo Vesta
     ('324B8722-FA2C-43BC-8EF2-AFA300827FEA','F3D5C7EE-FF91-4F6A-BD1F-AFA30081D9C5'), -- Agence Dermul
     ('56611200-A8B2-4C29-B594-AFA300CCAFAD','E8D8EBAE-5285-4C0D-A0B5-AFA200EEEBE1'), -- t Huys Vastgoed
     ('EA4D2BA6-5DAC-4FB1-A1F0-AFC50105C233','81EE153C-399C-48B5-BB41-AFA30084E752'), -- Agence Boo'Fort
     ('7B4F6F43-D54B-48A4-B086-AFE200E25B0A','58C670D1-C241-4EDD-92FE-AFA200B770F4'), -- Imtek Vastgoed -> Imtek
     ('965E36C7-05FF-4A15-83EC-AFCD007F58F4','D61BB184-78DD-469A-9263-AFCC00F7EC18'), -- Verlinden Vastgoedgroep
     ('D5E4CC53-01DE-40A2-A78A-B0070163D8CA','A54D1756-98D5-4171-ADDC-AFCC01073ECC'), -- Immo D'Hondt Beheer
     ('88DEF998-6277-46E6-9EEA-AFA200A57B9C','2FAF3D0A-4D37-42B2-B795-AFA100B9C464'), -- Immo Atelier
     ('C9EBC9FB-9F8C-4AD3-BDF2-AF9E008E0AB6','1A462BD0-30F8-4A01-B02E-AF9D00ACA123'); -- Immo3000 - arch -> Immo3000

    /* Guards ------------------------------------------------------------- */
    IF (SELECT COUNT(*) FROM @Merge) <> 15
        THROW 50001, 'Guard failed: expected 15 merge rows.', 1;

    -- Keepers must exist and be organisations.
    IF EXISTS (SELECT 1 FROM @Merge m LEFT JOIN Customers c ON c.Id=m.KeeperId
               WHERE c.Id IS NULL OR c.CustomerType NOT IN (2,3))
        THROW 50002, 'Guard failed: a keeper is missing or not an organisation.', 1;

    -- Sources must exist, be inactive/archived, and not be a keeper.
    -- CustomerType 1 (Private) is permitted here: Imtek Vastgoed is type 1, a
    -- legit duplicate whose listings fold into the type-2 Imtek keeper.
    IF EXISTS (SELECT 1 FROM @Merge m LEFT JOIN Customers c ON c.Id=m.NonKeeperId
               WHERE c.Id IS NULL OR c.Status NOT IN (3,4) OR c.CustomerType NOT IN (1,2,3))
        THROW 50003, 'Guard failed: a merge-source is missing, active, or wrong customer type.', 1;
    IF EXISTS (SELECT 1 FROM @Merge WHERE NonKeeperId IN (SELECT KeeperId FROM @Merge))
        THROW 50004, 'Guard failed: a record is both keeper and merge-source.', 1;

    /* 1) Reassign listings/history to the keeper. */
    UPDATE p SET p.CustomerId = m.KeeperId
      FROM Publications p          JOIN @Merge m ON p.CustomerId = m.NonKeeperId;
    UPDATE q SET q.CustomerId = m.KeeperId
      FROM Questions q             JOIN @Merge m ON q.CustomerId = m.NonKeeperId;
    UPDATE r SET r.CustomerId = m.KeeperId
      FROM RealtorProfiles r       JOIN @Merge m ON r.CustomerId = m.NonKeeperId;
    UPDATE u SET u.CustomerId = m.KeeperId
      FROM Users u                 JOIN @Merge m ON u.CustomerId = m.NonKeeperId;
    UPDATE x SET x.CustomerId = m.KeeperId
      FROM UserPublications x      JOIN @Merge m ON x.CustomerId = m.NonKeeperId;
    UPDATE x SET x.CustomerId = m.KeeperId
      FROM UserPublicationOrders x JOIN @Merge m ON x.CustomerId = m.NonKeeperId;

    /* 2) Confirm every source is now empty of listings/history. */
    IF EXISTS (SELECT 1 FROM Publications          t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM Questions             t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM RealtorProfiles       t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM Users                 t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM UserPublications      t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM UserPublicationOrders t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
        THROW 50005, 'Guard failed: a merge-source still has listings/history after reassign. Rolling back.', 1;

    /* 3) Drop the sources own feed/log/transient rows. */
    DELETE t FROM CrmIntegrations            t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM PublicationImportProcesses t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM PublicationImports         t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM CustomerInvitations        t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM CheckPublicationProcesses             t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM CheckPublicationsForCustomerProcesses t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;

    /* 4) Delete the now-empty merge-source customers. */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @Merge m ON c.Id = m.NonKeeperId;
    SET @deleted = @@ROWCOUNT;

    IF @deleted <> 15
        THROW 50006, 'Guard failed: merge-source delete count <> 15. Rolling back.', 1;

    COMMIT TRAN;
    PRINT 'OK: merged 15 duplicates into their keepers (listings/history reassigned, sources deleted).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
