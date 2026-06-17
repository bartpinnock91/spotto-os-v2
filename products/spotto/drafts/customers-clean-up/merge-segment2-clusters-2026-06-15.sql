/*───────────────────────────────────────────────────────────────────────────
  Segment 2 — MERGE three dead clusters into one keeper each (no data loss)

  Listings (Publications/Questions/Users/RealtorProfiles) on the merged-away
  records are reassigned to the keeper FIRST, then the emptied records are
  deleted. Keeper = the record currently holding the most listings.

    Cluster          KEEP (survivor)                       Merge in -> delete
    ---------------  ------------------------------------  ------------------------------------
    Vastgoed Rosini  A390EB02 (211 pubs)                   C48F8490 (3 pubs)
    Vestra NV        7900CA09 "verkoop" (41 pubs)          78E7D5F9 "verhuur" (2 pubs)
    Capital Estates  D32E9D9B "Brussel" (10 pubs)          E7F8B255 "(oud)" (1 pub)
                                                           B0027800 "Dream Team" (0 pubs)

  No unique constraint exists on CustomerId in the reassigned tables, and the
  merged records hold 0 Users, so the only unique index (Users PersonId+OrgId)
  cannot collide. Safe to reassign.

  NOTE: keepers stay in their current (inactive/archived) status — this only
  consolidates the records; reactivating/renaming the survivor is a separate
  back-office action. The keeper's name is NOT changed (e.g. Vestra survivor
  keeps the "verkoop" name even though it now holds verhuur listings too).
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* Map: each record to merge away -> the keeper it folds into. */
    DECLARE @Merge TABLE (NonKeeperId uniqueidentifier PRIMARY KEY, KeeperId uniqueidentifier);
    INSERT INTO @Merge (NonKeeperId, KeeperId) VALUES
     ('C48F8490-0E6E-4B49-9CB4-B049009A8A97','A390EB02-05F6-4752-B2E5-AF9E00A0FCCA'), -- Rosini
     ('78E7D5F9-A981-4D77-B709-B00300814A9F','7900CA09-C10E-4A74-AD9D-B0030080DC3E'), -- Vestra verhuur -> verkoop
     ('E7F8B255-B47A-4E4F-8BA6-AF9E00957FB9','D32E9D9B-6CAC-4826-A80F-AFEE00CFDDF6'), -- Capital Estates (oud) -> Brussel
     ('B0027800-3C22-475C-83BA-AFEE00D0AE2C','D32E9D9B-6CAC-4826-A80F-AFEE00CFDDF6'); -- Capital Estates Dream Team -> Brussel

    /* Guards */
    IF (SELECT COUNT(*) FROM @Merge) <> 4
        THROW 50001, 'Guard failed: expected 4 merge rows.', 1;

    -- Keepers must exist and be organisations.
    IF EXISTS (SELECT 1 FROM @Merge m LEFT JOIN Customers c ON c.Id=m.KeeperId
               WHERE c.Id IS NULL OR c.CustomerType NOT IN (2,3))
        THROW 50002, 'Guard failed: a keeper is missing or not an organisation.', 1;

    -- Records to merge away must exist, be inactive/archived organisations,
    -- and must not themselves be a keeper.
    IF EXISTS (SELECT 1 FROM @Merge m LEFT JOIN Customers c ON c.Id=m.NonKeeperId
               WHERE c.Id IS NULL OR c.Status NOT IN (3,4) OR c.CustomerType NOT IN (2,3))
        THROW 50003, 'Guard failed: a merge-source is missing, active, or not an organisation.', 1;
    IF EXISTS (SELECT 1 FROM @Merge WHERE NonKeeperId IN (SELECT KeeperId FROM @Merge))
        THROW 50004, 'Guard failed: a record is both keeper and merge-source.', 1;

    /* 1) Reassign listings/history to the keeper. */
    UPDATE p SET p.CustomerId = m.KeeperId
      FROM Publications p    JOIN @Merge m ON p.CustomerId = m.NonKeeperId;
    UPDATE q SET q.CustomerId = m.KeeperId
      FROM Questions q       JOIN @Merge m ON q.CustomerId = m.NonKeeperId;
    UPDATE r SET r.CustomerId = m.KeeperId
      FROM RealtorProfiles r JOIN @Merge m ON r.CustomerId = m.NonKeeperId;
    UPDATE u SET u.CustomerId = m.KeeperId
      FROM Users u           JOIN @Merge m ON u.CustomerId = m.NonKeeperId;

    /* 2) Confirm the merge-sources are now empty of all listings/history. */
    IF EXISTS (SELECT 1 FROM Publications    t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM Questions       t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM RealtorProfiles t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
    OR EXISTS (SELECT 1 FROM Users           t JOIN @Merge m ON t.CustomerId = m.NonKeeperId)
        THROW 50005, 'Guard failed: a merge-source still has listings after reassign. Rolling back.', 1;

    /* 3) Drop the merged records' own feed/log rows. */
    DELETE t FROM CrmIntegrations            t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;
    DELETE t FROM PublicationImportProcesses t JOIN @Merge m ON t.CustomerId = m.NonKeeperId;

    /* 4) Delete the now-empty merge-source customers. */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @Merge m ON c.Id = m.NonKeeperId;
    SET @deleted = @@ROWCOUNT;

    IF @deleted <> 4
        THROW 50006, 'Guard failed: merge-source delete count <> 4. Rolling back.', 1;

    COMMIT TRAN;
    PRINT 'OK: merged 4 records into 3 keepers (listings reassigned, sources deleted).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
