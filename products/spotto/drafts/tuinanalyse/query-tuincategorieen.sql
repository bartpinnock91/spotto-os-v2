-- ============================================================
-- TUINCATEGORIEEN v2 — feedback PR partner (juni 2026)
--
-- New segmentation based on perceeloppervlakte instead of the
-- wide has_garden/description definition (86% had a garden):
--   'Geen tuin'   = perceel < 300 m2 AND no garden parameter
--   'Kleine tuin' = perceel 300-600 m2
--   'Grote tuin'  = perceel >= 600 m2
--
-- Edge case the partner's definition leaves open: perceel < 300 m2
-- but WITH a garden parameter. Kept as a separate group below so
-- we can decide (merge into 'Kleine tuin' or exclude) based on
-- actual counts.
--
-- Plot size is not on the gold dim table; it comes from
-- silver.stg_spotto_publications.parcel_total_plot_square_meters,
-- joined via the sale publications. One property can have several
-- publications -> take MAX of the non-null values per address.
--
-- Population filters are identical to query.sql (houses, Flanders,
-- completed sale sequences 2023-2025, 1-730 days) so results are
-- comparable with the earlier tables. NOTE: the population is
-- larger than the original 51,862 because the old definition
-- silently excluded ~27k listings with unknown garden status
-- (no description, no garden param). The perceel-based split
-- classifies those too. Coverage check (run 2026-06-10): 93.4%
-- of 79,371 listings have a plot size; 32.7% <300, 26.7%
-- 300-600, 40.5% >=600 (median 474 m2).
-- ============================================================

-- ============================================================
-- QUERY 0: COVERAGE CHECK — run this first
-- What share of the ~52k analysis listings has a usable plot
-- size, and how are plot sizes distributed around the proposed
-- 300/600 m2 thresholds? If coverage is low or the thresholds
-- land in odd places, go back to the partner before continuing.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        -- cap at 10 ha to drop data-entry garbage
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        cp.address_key,
        pl.plot_m2
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    COUNT(*) AS total_listings,
    COUNT(plot_m2) AS listings_with_plot,
    ROUND(100.0 * COUNT(plot_m2) / COUNT(*), 1) AS pct_with_plot,
    ROUND(PERCENTILE(plot_m2, 0.25), 0) AS p25_plot_m2,
    ROUND(PERCENTILE(plot_m2, 0.5), 0) AS median_plot_m2,
    ROUND(PERCENTILE(plot_m2, 0.75), 0) AS p75_plot_m2,
    -- distribution around the proposed thresholds (share of KNOWN plots)
    ROUND(100.0 * SUM(CASE WHEN plot_m2 < 300 THEN 1 ELSE 0 END) / COUNT(plot_m2), 1) AS pct_below_300,
    ROUND(100.0 * SUM(CASE WHEN plot_m2 >= 300 AND plot_m2 < 600 THEN 1 ELSE 0 END) / COUNT(plot_m2), 1) AS pct_300_600,
    ROUND(100.0 * SUM(CASE WHEN plot_m2 >= 600 THEN 1 ELSE 0 END) / COUNT(plot_m2), 1) AS pct_above_600
FROM
    listings;

-- ============================================================
-- QUERY 1: CROSSTAB old vs new definition
-- Shows how the old 86% 'met tuin' redistributes over the new
-- perceel buckets, incl. the unknown-plot group. Sanity check
-- that the new classification behaves sensibly (e.g. almost all
-- 'grote tuin' should be wide-garden too).
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        -- third label makes the ~27k listings visible that the old
        -- analysis silently dropped (no description, no garden param)
        CASE
            WHEN cp.is_wide_garden THEN 'Met tuin (oude def)'
            WHEN NOT cp.is_wide_garden THEN 'Zonder tuin (oude def)'
            ELSE 'Onbekend (viel buiten oude analyse)'
        END AS old_definition,
        CASE
            WHEN pl.plot_m2 IS NULL THEN '0. Onbekend perceel'
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS new_category
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    new_category,
    old_definition,
    COUNT(*) AS total_listings,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_all
FROM
    listings
GROUP BY
    new_category,
    old_definition
ORDER BY
    new_category,
    old_definition;

-- ============================================================
-- QUERY 2: DOORLOOPTIJDEN per new tuincategorie
-- The actual item-2 exercise: days on market per perceel-based
-- category. Group 2 (tuin op klein perceel) stays separate here;
-- merge into 'Kleine tuin' or drop once we've seen the counts.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        -- NULL-safe: is_wide_garden is NULL when there is no description
        -- and no positive garden parameter; treat that as 'geen tuinsignaal'
        CASE
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    tuincategorie,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    tuincategorie
ORDER BY
    tuincategorie;

-- ============================================================
-- QUERY 3: DOORLOOPTIJDEN per new tuincategorie PER SEIZOEN
-- Seasonal cut of query 2, since the press angle leans on the
-- spring effect. Watch total_listings per cell before quoting.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        -- NULL-safe: is_wide_garden is NULL when there is no description
        -- and no positive garden parameter; treat that as 'geen tuinsignaal'
        CASE
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    tuincategorie,
    listing_season,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    tuincategorie,
    listing_season
ORDER BY
    tuincategorie,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END;

-- ============================================================
-- QUERY 4: PRIJSEVOLUTIE per tuincategorie (partner item 3)
-- Did prices for any category rise faster/slower than the
-- Flemish average for houses? The 'ALLE HUIZEN' benchmark row
-- per year comes from GROUPING SETS and includes every house
-- in the population (also unknown plot), so it is the true
-- overall average to compare each category against.
--
-- Price per sequence = median asking price across that cycle's
-- sale publications, sanity-filtered 50k-5M. price_per_m2 uses
-- living area (construction_square_meters, 30-1000 m2) to
-- correct for composition shifts between years.
--
-- CAVEATS for interpretation:
-- * These are ASKING prices, not transaction prices.
-- * Only completed cycles count (same as the other tables), so
--   late-2025 starts skew toward faster sellers.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
seq_prices AS (
    -- median asking price + living area per sale cycle
    SELECT
        pub.address_key,
        pub.address_sequence_number,
        PERCENTILE(sp.price_value, 0.5) AS price,
        PERCENTILE(
            CASE
                WHEN sp.construction_square_meters BETWEEN 30 AND 1000
                THEN sp.construction_square_meters
            END, 0.5
        ) AS living_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.price_value BETWEEN 50000 AND 5000000
    GROUP BY
        pub.address_key,
        pub.address_sequence_number
),
listings AS (
    SELECT
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN pl.plot_m2 IS NULL THEN '0. Onbekend perceel'
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        sq.price,
        CASE
            WHEN sq.living_m2 IS NOT NULL THEN sq.price / sq.living_m2
        END AS price_per_m2
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
        JOIN seq_prices sq
            ON seq.address_key = sq.address_key
            AND seq.address_sequence_number = sq.address_sequence_number
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
    listing_year,
    COALESCE(tuincategorie, 'ALLE HUIZEN (Vlaams benchmark)') AS tuincategorie,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(price, 0.5), 0) AS median_price,
    ROUND(AVG(price), 0) AS avg_price,
    ROUND(PERCENTILE(price_per_m2, 0.5), 0) AS median_price_per_m2
FROM
    listings
GROUP BY
    GROUPING SETS (
        (listing_year, tuincategorie),
        (listing_year)
    )
ORDER BY
    listing_year,
    tuincategorie;

-- ============================================================
-- QUERY 5: PRIJSEVOLUTIE per tuincategorie BINNEN EPC-BAND
-- (partner item 4 — "gewogen gemiddeldes, op basis van een
--  gelijk EPC")
--
-- Robustness check on query 4: the geen-tuin segment grew
-- +12.9% (2023-2025) vs +7.4% benchmark. If city houses are
-- increasingly renovated before sale, that growth could be a
-- QUALITY shift, not pure appreciation. Slicing growth within
-- EPC bands compares like-for-like; the epc_mix output shows
-- whether the mix itself moved.
--
-- EPC is taken PER SALE CYCLE from that cycle's own
-- publications (energy_efficiency_epc_label_name in silver),
-- so a house renovated and resold within 2023-2025 carries its
-- old label on the old cycle and its new label on the new one.
-- Fallback: gold.dim_reference_properties.epc_label (address
-- level = latest known) for cycles whose publications carry no
-- EPC. Quick value-format check (run first):
--   SELECT energy_efficiency_epc_label_name, COUNT(*)
--   FROM dataplatform_oris_production.silver.stg_spotto_publications
--   GROUP BY 1 ORDER BY 2 DESC;
--   SELECT epc_label, COUNT(*)
--   FROM dataplatform_oris_production.gold.dim_reference_properties
--   WHERE property_type = 1
--   GROUP BY 1 ORDER BY 2 DESC;
-- If labels are not plain 'A+'/'A'/'B'/... adjust the band CASE.
-- Bands follow the earlier Spotto EPC analysis, split finer:
-- A-B / C-D / E-F (A+, A++ count as A).
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        UPPER(TRIM(p.epc_label)) AS epc_label,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
seq_prices AS (
    SELECT
        pub.address_key,
        pub.address_sequence_number,
        PERCENTILE(sp.price_value, 0.5) AS price,
        PERCENTILE(
            CASE
                WHEN sp.construction_square_meters BETWEEN 30 AND 1000
                THEN sp.construction_square_meters
            END, 0.5
        ) AS living_m2,
        -- per-cycle EPC: best (MIN) label across this cycle's pubs
        MIN(UPPER(TRIM(sp.energy_efficiency_epc_label_name))) AS epc_label_cycle
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.price_value BETWEEN 50000 AND 5000000
    GROUP BY
        pub.address_key,
        pub.address_sequence_number
),
listings AS (
    SELECT
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN pl.plot_m2 IS NULL THEN '0. Onbekend perceel'
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        CASE
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('A++', 'A+', 'A', 'B') THEN 'A-B'
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('C', 'D') THEN 'C-D'
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('E', 'F') THEN 'E-F'
        END AS epc_band,
        sq.price,
        CASE
            WHEN sq.living_m2 IS NOT NULL THEN sq.price / sq.living_m2
        END AS price_per_m2
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
        JOIN seq_prices sq
            ON seq.address_key = sq.address_key
            AND seq.address_sequence_number = sq.address_sequence_number
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
-- 5a: price evolution within (category x EPC band)
SELECT
    tuincategorie,
    epc_band,
    listing_year,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(price, 0.5), 0) AS median_price,
    ROUND(PERCENTILE(price_per_m2, 0.5), 0) AS median_price_per_m2
FROM
    listings
WHERE
    epc_band IS NOT NULL
    AND tuincategorie <> '0. Onbekend perceel'
GROUP BY
    tuincategorie,
    epc_band,
    listing_year
ORDER BY
    tuincategorie,
    epc_band,
    listing_year;

-- ============================================================
-- QUERY 5b: EPC-MIX per tuincategorie per jaar
-- Same CTEs as 5a, standalone runnable. Shows whether the
-- quality mix shifted: if the geen-tuin segment's A-B share
-- jumped between 2023 and 2025, part of its +12.9% price
-- growth is renovation, not appreciation. Feeds Tabel 6 in
-- persbericht V2.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        UPPER(TRIM(p.epc_label)) AS epc_label,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
seq_prices AS (
    SELECT
        pub.address_key,
        pub.address_sequence_number,
        PERCENTILE(sp.price_value, 0.5) AS price,
        -- per-cycle EPC: best (MIN) label across this cycle's pubs
        MIN(UPPER(TRIM(sp.energy_efficiency_epc_label_name))) AS epc_label_cycle
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.price_value BETWEEN 50000 AND 5000000
    GROUP BY
        pub.address_key,
        pub.address_sequence_number
),
listings AS (
    SELECT
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN pl.plot_m2 IS NULL THEN '0. Onbekend perceel'
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        CASE
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('A++', 'A+', 'A', 'B') THEN 'A-B'
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('C', 'D') THEN 'C-D'
            WHEN COALESCE(sq.epc_label_cycle, cp.epc_label) IN ('E', 'F') THEN 'E-F'
        END AS epc_band
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
        JOIN seq_prices sq
            ON seq.address_key = sq.address_key
            AND seq.address_sequence_number = sq.address_sequence_number
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
    tuincategorie,
    listing_year,
    COUNT(*) AS total_listings,
    ROUND(100.0 * SUM(CASE WHEN epc_band = 'A-B' THEN 1 ELSE 0 END) / COUNT(epc_band), 1) AS pct_ab,
    ROUND(100.0 * SUM(CASE WHEN epc_band = 'C-D' THEN 1 ELSE 0 END) / COUNT(epc_band), 1) AS pct_cd,
    ROUND(100.0 * SUM(CASE WHEN epc_band = 'E-F' THEN 1 ELSE 0 END) / COUNT(epc_band), 1) AS pct_ef,
    ROUND(100.0 * COUNT(epc_band) / COUNT(*), 1) AS pct_epc_known
FROM
    listings
WHERE
    tuincategorie <> '0. Onbekend perceel'
GROUP BY
    tuincategorie,
    listing_year
ORDER BY
    tuincategorie,
    listing_year;

-- ============================================================
-- QUERY 6: RENOVATIE-CHECK — hoe vaak komt herverkoop (al dan
-- niet met EPC-verbetering) voor binnen 2023-2025?
-- One summary row:
--   * addresses_total      = unique addresses in the analysis
--   * addresses_resold     = addresses with >= 2 completed cycles
--   * resold_epc_known     = resold AND per-cycle EPC known on
--                            first and last cycle
--   * resold_epc_improved  = label got better between cycles
--                            (the renovate-and-flip case)
--   * resold_epc_worsened  = label got worse (re-inspection,
--                            data noise)
-- If resold_epc_improved is a handful, the address-level EPC
-- shortcut would have been harmless; if it is sizeable, the
-- per-cycle fix in query 5 was necessary.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
cycle_epc AS (
    SELECT
        pub.address_key,
        pub.address_sequence_number,
        MIN(UPPER(TRIM(sp.energy_efficiency_epc_label_name))) AS epc_label_cycle
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
    GROUP BY
        pub.address_key,
        pub.address_sequence_number
),
cycles AS (
    SELECT
        cp.address_key,
        seq.sequence_start_date,
        -- rank: lower = better label
        CASE ce.epc_label_cycle
            WHEN 'A++' THEN 1
            WHEN 'A+' THEN 2
            WHEN 'A' THEN 3
            WHEN 'B' THEN 4
            WHEN 'C' THEN 5
            WHEN 'D' THEN 6
            WHEN 'E' THEN 7
            WHEN 'F' THEN 8
            WHEN 'G' THEN 9
        END AS epc_rank
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        LEFT JOIN cycle_epc ce
            ON seq.address_key = ce.address_key
            AND seq.address_sequence_number = ce.address_sequence_number
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
),
per_address AS (
    SELECT
        address_key,
        COUNT(*) AS n_cycles,
        MIN_BY(epc_rank, sequence_start_date) AS first_epc_rank,
        MAX_BY(epc_rank, sequence_start_date) AS last_epc_rank
    FROM
        cycles
    GROUP BY
        address_key
)
SELECT
    COUNT(*) AS addresses_total,
    SUM(CASE WHEN n_cycles >= 2 THEN 1 ELSE 0 END) AS addresses_resold,
    ROUND(100.0 * SUM(CASE WHEN n_cycles >= 2 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_resold,
    SUM(CASE
        WHEN n_cycles >= 2 AND first_epc_rank IS NOT NULL AND last_epc_rank IS NOT NULL
        THEN 1 ELSE 0
    END) AS resold_epc_known,
    SUM(CASE
        WHEN n_cycles >= 2 AND last_epc_rank < first_epc_rank
        THEN 1 ELSE 0
    END) AS resold_epc_improved,
    SUM(CASE
        WHEN n_cycles >= 2 AND last_epc_rank > first_epc_rank
        THEN 1 ELSE 0
    END) AS resold_epc_worsened
FROM
    per_address;

-- ============================================================
-- QUERY 7: DOORLOOPTIJD per tuincategorie PER PROVINCIE
-- Regional hook for local press pickup (same role as the
-- province table in persbericht V1, now on the new categories).
-- Province from NIS prefix: 1 = Antwerpen, 23/24 = Vlaams-
-- Brabant, 3 = West-Vlaanderen, 4 = Oost-Vlaanderen, 7 = Limburg.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        CASE
            WHEN LEFT(p.statistical_sector_nis_level_4, 1) = '1' THEN 'Antwerpen'
            WHEN LEFT(p.statistical_sector_nis_level_4, 2) IN ('23', '24') THEN 'Vlaams-Brabant'
            WHEN LEFT(p.statistical_sector_nis_level_4, 1) = '3' THEN 'West-Vlaanderen'
            WHEN LEFT(p.statistical_sector_nis_level_4, 1) = '4' THEN 'Oost-Vlaanderen'
            WHEN LEFT(p.statistical_sector_nis_level_4, 1) = '7' THEN 'Limburg'
        END AS province,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        cp.province,
        CASE
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    province,
    tuincategorie,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    province,
    tuincategorie
ORDER BY
    province,
    tuincategorie;

-- ============================================================
-- QUERY 8: DOORLOOPTIJD per tuincategorie, CENTRUMSTAD vs REST
-- Partner follow-up (juni 2026): is "compacte tuin verkoopt het
-- snelst" niet gewoon een stadseffect (kleine percelen liggen in
-- steden waar de vraag hoog is)?
-- Same 13 centrumsteden as the V1 analysis. GROUPING SETS adds
-- the 'Heel Vlaanderen' row per category, so the output gives
-- exactly the requested three cuts in one table. The
-- total_listings column doubles as the composition check (how
-- urban is each category).
-- Read it like this: if 'compacte tuin' is still the fastest
-- category WITHIN 'Rest van Vlaanderen', the claim survives; if
-- the ranking flattens outside the cities, it was a stadseffect
-- and the persbericht needs reframing.
-- ============================================================
WITH centrumsteden AS (
    SELECT * FROM (
        VALUES
            ('Antwerpen'), ('Gent'), ('Brugge'), ('Leuven'),
            ('Mechelen'), ('Aalst'), ('Hasselt'), ('Kortrijk'),
            ('Oostende'), ('Roeselare'), ('Genk'),
            ('Sint-Niklaas'), ('Turnhout')
    ) AS c(stad)
),
classified_properties AS (
    SELECT
        p.address_key,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM centrumsteden c
                WHERE p.municipality_name LIKE c.stad || '%'
            ) THEN 'Centrumstad'
            ELSE 'Rest van Vlaanderen'
        END AS location_type,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
listings AS (
    SELECT
        cp.location_type,
        CASE
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
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
    COALESCE(location_type, 'Heel Vlaanderen') AS location_type,
    tuincategorie,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    GROUPING SETS (
        (location_type, tuincategorie),
        (tuincategorie)
    )
ORDER BY
    location_type,
    tuincategorie;

-- ============================================================
-- QUERY 9: PRIJSEVOLUTIE per tuincategorie, CENTRUMSTAD vs REST
-- Same split for the price trend: does 'geen tuin +12,9%' hold
-- outside the centrumsteden, or is the growth concentrated in
-- the cities? Median asking price + price per m2 living area
-- per (location x category x year); 'Heel Vlaanderen' rows via
-- GROUPING SETS.
-- ============================================================
WITH centrumsteden AS (
    SELECT * FROM (
        VALUES
            ('Antwerpen'), ('Gent'), ('Brugge'), ('Leuven'),
            ('Mechelen'), ('Aalst'), ('Hasselt'), ('Kortrijk'),
            ('Oostende'), ('Roeselare'), ('Genk'),
            ('Sint-Niklaas'), ('Turnhout')
    ) AS c(stad)
),
classified_properties AS (
    SELECT
        p.address_key,
        CASE
            WHEN EXISTS (
                SELECT 1 FROM centrumsteden c
                WHERE p.municipality_name LIKE c.stad || '%'
            ) THEN 'Centrumstad'
            ELSE 'Rest van Vlaanderen'
        END AS location_type,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1 AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
plot_sizes AS (
    SELECT
        pub.address_key,
        MAX(sp.parcel_total_plot_square_meters) AS plot_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.parcel_total_plot_square_meters BETWEEN 1 AND 100000
    GROUP BY
        pub.address_key
),
seq_prices AS (
    SELECT
        pub.address_key,
        pub.address_sequence_number,
        PERCENTILE(sp.price_value, 0.5) AS price,
        PERCENTILE(
            CASE
                WHEN sp.construction_square_meters BETWEEN 30 AND 1000
                THEN sp.construction_square_meters
            END, 0.5
        ) AS living_m2
    FROM
        dataplatform_oris_production.gold.dim_reference_properties_publications pub
        JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
            ON pub.source_publication_id = sp.publication_id
    WHERE
        pub.transaction_type = 1
        AND sp.price_value BETWEEN 50000 AND 5000000
    GROUP BY
        pub.address_key,
        pub.address_sequence_number
),
listings AS (
    SELECT
        cp.location_type,
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN pl.plot_m2 >= 600 THEN '4. Grote tuin (>=600 m2)'
            WHEN pl.plot_m2 >= 300 THEN '3. Kleine tuin (300-600 m2)'
            WHEN COALESCE(cp.is_wide_garden, FALSE) THEN '2. Tuin op klein perceel (<300 m2, wel tuinsignaal)'
            ELSE '1. Geen tuin (<300 m2, geen tuinsignaal)'
        END AS tuincategorie,
        sq.price,
        CASE
            WHEN sq.living_m2 IS NOT NULL THEN sq.price / sq.living_m2
        END AS price_per_m2
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq
            ON cp.address_key = seq.address_key
        JOIN plot_sizes pl
            ON cp.address_key = pl.address_key
        JOIN seq_prices sq
            ON seq.address_key = sq.address_key
            AND seq.address_sequence_number = sq.address_sequence_number
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
    COALESCE(location_type, 'Heel Vlaanderen') AS location_type,
    tuincategorie,
    listing_year,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(price, 0.5), 0) AS median_price,
    ROUND(PERCENTILE(price_per_m2, 0.5), 0) AS median_price_per_m2
FROM
    listings
GROUP BY
    GROUPING SETS (
        (location_type, tuincategorie, listing_year),
        (tuincategorie, listing_year)
    )
ORDER BY
    location_type,
    tuincategorie,
    listing_year;
