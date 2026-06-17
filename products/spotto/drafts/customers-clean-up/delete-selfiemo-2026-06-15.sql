/*───────────────────────────────────────────────────────────────────────────
  DELETE the Sofiemo / Selfiemo duplicates (VAT 0680982263)

  Three records share this VAT:
    KEEP   Sofiemo        D031A649-4532-48F6-A727-AFEE00D73C84  Status 2 (Active)
    DELETE Sofiemo (oud)  484A4A41-9EE8-4ACD-8091-AF9E00F78684  Status 3 (Inactive)
    DELETE Selfiemo       229B344A-326D-463D-86A0-AFEE00D8096F  Status 4 (Archived)

  Both deletes carry no listings/history (0 Publications/Questions/Users/
  RealtorProfiles). Child rows removed first:
    - CrmIntegrations             (Selfiemo: 1)
    - PublicationImportProcesses  (Sofiemo (oud): ~393, Selfiemo: ~1143)

  NOTE: "Sofiemo (oud)" is NOT in the segment-1a batch script — it is deleted
  here instead.
───────────────────────────────────────────────────────────────────────────*/

SET XACT_ABORT ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    /* The two duplicates to delete (active Sofiemo D031A649 is NOT listed). */
    DECLARE @ToDelete TABLE (Id uniqueidentifier PRIMARY KEY);
    INSERT INTO @ToDelete (Id) VALUES
     ('484A4A41-9EE8-4ACD-8091-AF9E00F78684'),  -- Sofiemo (oud)
     ('229B344A-326D-463D-86A0-AFEE00D8096F');  -- Selfiemo

    /* Guards */
    IF (SELECT COUNT(*) FROM @ToDelete) <> 2
        THROW 50001, 'Guard failed: expected 2 ids.', 1;

    -- Every target must exist, be inactive/archived, and an organisation.
    IF EXISTS (
        SELECT 1 FROM @ToDelete d
        LEFT JOIN Customers c ON c.Id = d.Id
        WHERE c.Id IS NULL OR c.Status NOT IN (3,4) OR c.CustomerType NOT IN (2,3)
    )
        THROW 50002, 'Guard failed: a target is missing, active, or not an organisation.', 1;

    -- No target may carry real listings/history.
    IF EXISTS (SELECT 1 FROM Publications    t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Questions       t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM Users           t JOIN @ToDelete d ON t.CustomerId = d.Id)
    OR EXISTS (SELECT 1 FROM RealtorProfiles t JOIN @ToDelete d ON t.CustomerId = d.Id)
        THROW 50003, 'Guard failed: a target carries listings/history.', 1;

    /* Remove child rows. */
    DELETE t FROM CrmIntegrations            t JOIN @ToDelete d ON t.CustomerId = d.Id;
    DELETE t FROM PublicationImportProcesses t JOIN @ToDelete d ON t.CustomerId = d.Id;

    /* Delete the duplicates. */
    DECLARE @deleted int;
    DELETE c FROM Customers c JOIN @ToDelete d ON c.Id = d.Id;
    SET @deleted = @@ROWCOUNT;

    IF @deleted <> 2
        THROW 50004, 'Guard failed: customer delete count <> 2. Rolling back.', 1;

    COMMIT TRAN;
    PRINT 'OK: deleted ' + CAST(@deleted AS varchar(10)) + ' Sofiemo/Selfiemo duplicates (active Sofiemo kept).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ROLLED BACK: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
