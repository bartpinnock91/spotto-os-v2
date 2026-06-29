-- ============================================================
-- APPARTEMENTEN — feedback PR partner item 1 (juni 2026)
--
-- "Zou je voor ons ook de vergelijking kunnen maken voor de
--  doorlooptijden voor wat betreft appartementen? Die hebben
--  bijna zeker geen (private) tuin."
--
-- Same methodology as the house analysis (completed sale
-- sequences 2023-2025, Flanders, 1-730 days), but grouped by
-- property type: 1 = House, 2 = Apartment (gold-layer enum).
-- Houses are included in every output so the comparison sits
-- in one table; the garden categorisation does not apply here.
-- ============================================================

-- ============================================================
-- QUERY A1: doorlooptijd huizen vs appartementen (totaal)
-- ============================================================
WITH props AS (
    SELECT
        p.address_key,
        CASE p.property_type
            WHEN 1 THEN 'Huis'
            WHEN 2 THEN 'Appartement'
        END AS pand_type
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type IN (1, 2)
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        pr.pand_type,
        seq.sequence_duration_days AS days_on_market
    FROM
        props pr
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON pr.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1 AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023 AND 2025
        AND EXISTS (
            SELECT 1
            FROM dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    pand_type,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    pand_type
ORDER BY
    pand_type;

-- ============================================================
-- QUERY A2: doorlooptijd huizen vs appartementen PER SEIZOEN
-- The interesting check: houses with gardens peak in spring.
-- If apartments (no private garden) show NO spring effect,
-- that supports the garden-season story.
-- ============================================================
WITH props AS (
    SELECT
        p.address_key,
        CASE p.property_type
            WHEN 1 THEN 'Huis'
            WHEN 2 THEN 'Appartement'
        END AS pand_type
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type IN (1, 2)
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        pr.pand_type,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season,
        seq.sequence_duration_days AS days_on_market
    FROM
        props pr
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON pr.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1 AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023 AND 2025
        AND EXISTS (
            SELECT 1
            FROM dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    pand_type,
    listing_season,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    pand_type,
    listing_season
ORDER BY
    pand_type,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END;

-- ============================================================
-- QUERY A3: doorlooptijd huizen vs appartementen PER JAAR
-- Did apartments speed up as much as houses did 2023-2025?
-- Median per year of completed cycles; same censoring caveat
-- as the house tables (late-2025 starts skew fast).
-- ============================================================
WITH props AS (
    SELECT
        p.address_key,
        CASE p.property_type
            WHEN 1 THEN 'Huis'
            WHEN 2 THEN 'Appartement'
        END AS pand_type
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type IN (1, 2)
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        pr.pand_type,
        YEAR(seq.sequence_start_date) AS listing_year,
        seq.sequence_duration_days AS days_on_market
    FROM
        props pr
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON pr.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1 AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023 AND 2025
        AND EXISTS (
            SELECT 1
            FROM dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    pand_type,
    listing_year,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    pand_type,
    listing_year
ORDER BY
    pand_type,
    listing_year;

-- ============================================================
-- QUERY A4: DIAGNOSTIEK new_build_type
-- Goal: learn what the new_build_type enum values mean before
-- building the nieuwbouw robustness check. The value whose rows
-- combine a recent median construction_year with long median
-- days_on_market is the new-build segment.
-- ============================================================
WITH props AS (
    SELECT
        p.address_key,
        CASE p.property_type
            WHEN 1 THEN 'Huis'
            WHEN 2 THEN 'Appartement'
        END AS pand_type,
        p.new_build_type,
        p.construction_year
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type IN (1, 2)
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        pr.pand_type,
        pr.new_build_type,
        pr.construction_year,
        seq.sequence_duration_days AS days_on_market
    FROM
        props pr
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON pr.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1 AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023 AND 2025
        AND EXISTS (
            SELECT 1
            FROM dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    pand_type,
    new_build_type,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(construction_year, 0.5), 0) AS median_construction_year,
    ROUND(100.0 * COUNT(construction_year) / COUNT(*), 1) AS pct_year_known
FROM
    listings
GROUP BY
    pand_type,
    new_build_type
ORDER BY
    pand_type,
    new_build_type;

-- ============================================================
-- QUERY A5: ROBUUSTHEIDSCHECK appartementen — nieuwbouw & kust
-- Tests the two remaining objections against Tabel 4 ("geen
-- lentevoordeel voor appartementen"):
--   * nieuwbouw: 11% of apartment cycles vs 5% of houses, and
--     much slower (146-242d) -> could it explain the pattern?
--   * kust: second-home market with its own rhythm.
-- PropertyNewBuildType enum (verified in ImmoX source):
--   0 = Unknown, 1 = NoNewBuild,
--   2 = NewBuildProperty, 3 = NewBuildProject
-- Bestaand = type 1; Nieuwbouw = types 2 and 3; type 0/null
-- (<1%) is excluded. Kust = the 9 kustgemeenten by name
-- (Zeebrugge counts as Brugge and is not included).
-- 'Totaal' season rows come from GROUPING SETS.
-- The claim survives if BESTAANDE BINNENLAND-appartementen
-- still show no spring advantage.
-- ============================================================
WITH kustgemeenten AS (
    SELECT * FROM (
        VALUES
            ('Knokke-Heist'), ('Blankenberge'), ('De Haan'),
            ('Bredene'), ('Oostende'), ('Middelkerke'),
            ('Nieuwpoort'), ('Koksijde'), ('De Panne')
    ) AS k(gemeente)
),
props AS (
    SELECT
        p.address_key,
        CASE p.property_type
            WHEN 1 THEN 'Huis'
            WHEN 2 THEN 'Appartement'
        END AS pand_type,
        CASE
            WHEN p.new_build_type = 1 THEN 'Bestaand'
            WHEN p.new_build_type IN (2, 3) THEN 'Nieuwbouw'
        END AS bouwtype,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM kustgemeenten k
                WHERE p.municipality_name LIKE k.gemeente || '%'
            ) THEN 'Kust'
            ELSE 'Binnenland'
        END AS regio
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type IN (1, 2)
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        pr.pand_type,
        pr.bouwtype,
        pr.regio,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season,
        seq.sequence_duration_days AS days_on_market
    FROM
        props pr
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON pr.address_key = seq.address_key
    WHERE
        pr.bouwtype IS NOT NULL
        AND seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1 AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023 AND 2025
        AND EXISTS (
            SELECT 1
            FROM dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    pand_type,
    bouwtype,
    regio,
    COALESCE(listing_season, 'Totaal') AS listing_season,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    GROUPING SETS (
        (pand_type, bouwtype, regio, listing_season),
        (pand_type, bouwtype, regio)
    )
ORDER BY
    pand_type,
    bouwtype,
    regio,
    CASE
        listing_season
        WHEN 'Totaal' THEN 0
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END;
