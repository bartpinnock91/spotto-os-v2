-- ============================================================
-- PR FINDING 1: Overall garden advantage in Flanders
-- "In Flanders, a house with a garden sells about a month faster"
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    garden_group
ORDER BY
    garden_group;

-- ============================================================
-- PR FINDING 2: Seasonal breakdown
-- "In spring, the garden advantage peaks at 37%"
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    listing_season,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    listing_season,
    garden_group
ORDER BY
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END,
    garden_group;

-- ============================================================
-- PR FINDING 3: Centrumsteden vs rest of Flanders (with seasons)
-- "Outside Flemish cities, a house with a garden listed in spring
--  sells 6 weeks faster"
-- ============================================================
WITH centrumsteden AS (
    SELECT
        *
    FROM
        (
            VALUES
                ('Antwerpen'),
                ('Gent'),
                ('Brugge'),
                ('Leuven'),
                ('Mechelen'),
                ('Aalst'),
                ('Hasselt'),
                ('Kortrijk'),
                ('Oostende'),
                ('Roeselare'),
                ('Genk'),
                ('Sint-Niklaas'),
                ('Turnhout')
        ) AS c(stad)
),
classified_properties AS (
    SELECT
        p.address_key,
        CASE
            WHEN EXISTS (
                SELECT
                    1
                FROM
                    centrumsteden c
                WHERE
                    p.municipality_name LIKE c.stad || '%'
            ) THEN 'Centrumstad'
            ELSE 'Rest of Flanders'
        END AS location_type,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        cp.location_type,
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    location_type,
    listing_season,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    location_type,
    listing_season,
    garden_group
ORDER BY
    location_type,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END,
    garden_group;

-- ============================================================
-- PR FINDING 4: Year-over-year acceleration (2023-2025)
-- "The market has sped up dramatically — garden houses now sell
--  in under 7 weeks in spring 2025"
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market,
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    listing_year,
    listing_season,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    listing_year,
    listing_season,
    garden_group
ORDER BY
    listing_year,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END,
    garden_group;

-- ============================================================
-- PR FINDING 5: Row houses in centrumsteden — outdoor space impact
-- "A row house in a Flemish city without any outdoor space takes
--  5 weeks longer to sell in spring"
-- ============================================================
WITH centrumsteden AS (
    SELECT
        *
    FROM
        (
            VALUES
                ('Antwerpen'),
                ('Gent'),
                ('Brugge'),
                ('Leuven'),
                ('Mechelen'),
                ('Aalst'),
                ('Hasselt'),
                ('Kortrijk'),
                ('Oostende'),
                ('Roeselare'),
                ('Genk'),
                ('Sint-Niklaas'),
                ('Turnhout')
        ) AS c(stad)
),
row_houses AS (
    SELECT
        p.address_key,
        CASE
            WHEN (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' THEN '1. Has Garden'
            WHEN p.has_terrace = TRUE
            OR LOWER(p.detailed_description_nl_raw) LIKE '%terras%' THEN '2. Terrace Only'
            ELSE '3. Neither'
        END AS outdoor_space
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
        AND EXISTS (
            SELECT
                1
            FROM
                centrumsteden c
            WHERE
                p.municipality_name LIKE c.stad || '%'
        )
        AND (
            p.number_of_facades = 2
            OR LOWER(p.detailed_description_nl_raw) LIKE '%rijwoning%'
            OR LOWER(p.detailed_description_nl_raw) LIKE '%rijhuis%'
            OR LOWER(p.detailed_description_nl_raw) LIKE '%herenhuis%'
            OR LOWER(p.detailed_description_nl_raw) LIKE '%gesloten bebouwing%'
        )
),
listings AS (
    SELECT
        rh.outdoor_space,
        seq.sequence_duration_days AS days_on_market,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season
    FROM
        row_houses rh
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON rh.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
)
SELECT
    outdoor_space,
    listing_season,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    outdoor_space,
    listing_season
ORDER BY
    outdoor_space,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END;

-- ============================================================
-- PR FINDING 6: Garden advantage WITHIN building type
-- Controls for the main confounder (row vs semi vs detached):
-- a no-garden house skews to dense-urban rijwoningen, so we slice
-- by facade count to check the garden gap holds like-for-like.
-- NOTE: number_of_facades is sparsely filled (~30% of listings),
-- so treat this as a robustness check, not the headline figure.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        CASE
            WHEN p.number_of_facades <= 2 THEN '1. Gesloten (rijwoning)'
            WHEN p.number_of_facades = 3 THEN '2. Halfopen'
            WHEN p.number_of_facades >= 4 THEN '3. Open (vrijstaand)'
        END AS facade_type,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
        AND p.number_of_facades IS NOT NULL
),
listings AS (
    SELECT
        cp.facade_type,
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
        AND cp.facade_type IS NOT NULL
)
SELECT
    facade_type,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(AVG(days_on_market), 1) AS avg_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    facade_type,
    garden_group
ORDER BY
    facade_type,
    garden_group;

-- ============================================================
-- PR FINDING 7: Censoring-proof market-speed trend
-- "Share of listings sold within N days, by year"
--
-- WHY THIS METRIC: median days-on-market is biased downward for
-- recent years because slow-selling listings haven't closed yet
-- (right-censoring). A fixed-window outcome ("sold within 90 days?")
-- is fully observed for EVERY 2023-2025 cohort -- even a listing
-- started in Dec 2025 has had >90 days of observation by the
-- mid-2026 refresh -- so censoring does NOT distort it.
--
-- CAVEAT: 2023 is the platform's first year (data from March 2023);
-- coverage was still ramping up, so read 2023 figures with care.
-- Denominator = ALL listings started in the period (incl. those
-- that never sold), which is the correct base for "% sold within N".
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        YEAR(seq.sequence_start_date) AS listing_year,
        CASE
            WHEN MONTH(seq.sequence_start_date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(seq.sequence_start_date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(seq.sequence_start_date) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS listing_season,
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        CASE
            WHEN seq.sequence_end_date IS NOT NULL
            AND seq.sequence_duration_days BETWEEN 1
            AND 60 THEN 1
            ELSE 0
        END AS sold_60,
        CASE
            WHEN seq.sequence_end_date IS NOT NULL
            AND seq.sequence_duration_days BETWEEN 1
            AND 90 THEN 1
            ELSE 0
        END AS sold_90,
        CASE
            WHEN seq.sequence_end_date IS NOT NULL
            AND seq.sequence_duration_days BETWEEN 1
            AND 120 THEN 1
            ELSE 0
        END AS sold_120
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    listing_year,
    listing_season,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(100.0 * SUM(sold_60) / COUNT(*), 1) AS pct_sold_60d,
    ROUND(100.0 * SUM(sold_90) / COUNT(*), 1) AS pct_sold_90d,
    ROUND(100.0 * SUM(sold_120) / COUNT(*), 1) AS pct_sold_120d
FROM
    listings
GROUP BY
    listing_year,
    listing_season,
    garden_group
ORDER BY
    listing_year,
    CASE
        listing_season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Autumn' THEN 3
        WHEN 'Winter' THEN 4
    END,
    garden_group;

-- ============================================================
-- PR FINDING 8: Garden advantage PER PROVINCE
-- Local angle: lets regional press report "their" province.
-- Province derived from the NIS prefix:
--   1 = Antwerpen, 23/24 = Vlaams-Brabant, 3 = West-Vlaanderen,
--   4 = Oost-Vlaanderen, 7 = Limburg.
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
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        cp.province,
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market
    FROM
        classified_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    province,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    province,
    garden_group
ORDER BY
    province,
    garden_group;

-- ============================================================
-- PR FINDING 9: Garden advantage PER CENTRUMSTAD
-- Same idea, drilled down to the 13 Flemish centrumsteden.
-- NOTE: the "No Garden" group per city can be small -- read the
-- total_listings column before quoting any single city.
-- ============================================================
WITH centrumsteden AS (
    SELECT
        *
    FROM
        (
            VALUES
                ('Antwerpen'),
                ('Gent'),
                ('Brugge'),
                ('Leuven'),
                ('Mechelen'),
                ('Aalst'),
                ('Hasselt'),
                ('Kortrijk'),
                ('Oostende'),
                ('Roeselare'),
                ('Genk'),
                ('Sint-Niklaas'),
                ('Turnhout')
        ) AS c(stad)
),
city_properties AS (
    SELECT
        p.address_key,
        c.stad,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
        JOIN centrumsteden c ON p.municipality_name LIKE c.stad || '%'
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
),
listings AS (
    SELECT
        cp.stad,
        CASE
            WHEN cp.is_wide_garden THEN 'Wide Garden'
            ELSE 'No Garden'
        END AS garden_group,
        seq.sequence_duration_days AS days_on_market
    FROM
        city_properties cp
        JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
    WHERE
        seq.sequence_end_date IS NOT NULL
        AND seq.sequence_duration_days BETWEEN 1
        AND 730
        AND YEAR(seq.sequence_start_date) BETWEEN 2023
        AND 2025
        AND EXISTS (
            SELECT
                1
            FROM
                dataplatform_oris_production.gold.dim_reference_properties_publications pub
            WHERE
                pub.address_key = seq.address_key
                AND pub.address_sequence_number = seq.address_sequence_number
                AND pub.transaction_type = 1
        )
        AND (
            cp.is_wide_garden
            OR cp.is_no_garden
        )
)
SELECT
    stad,
    garden_group,
    COUNT(*) AS total_listings,
    ROUND(PERCENTILE(days_on_market, 0.5), 0) AS median_days,
    ROUND(PERCENTILE(days_on_market, 0.25), 0) AS p25_days,
    ROUND(PERCENTILE(days_on_market, 0.75), 0) AS p75_days
FROM
    listings
GROUP BY
    stad,
    garden_group
ORDER BY
    stad,
    garden_group;

-- ============================================================
-- PR FINDING 10: Exact sample size & period (for methodology)
-- Confirms the headline base count and the real date window of
-- the analysis, so the press text can state precise figures.
-- ============================================================
WITH classified_properties AS (
    SELECT
        p.address_key,
        (
            p.has_garden = TRUE
            AND p.garden_area BETWEEN 1
            AND 10000
        )
        OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%' AS is_wide_garden,
        NOT (
            (
                p.has_garden = TRUE
                AND p.garden_area BETWEEN 1
                AND 10000
            )
            OR LOWER(p.detailed_description_nl_raw) LIKE '%tuin%'
        ) AS is_no_garden
    FROM
        dataplatform_oris_production.gold.dim_reference_properties p
    WHERE
        p.property_type = 1
        AND p.is_in_belgium = TRUE
        AND LEFT(p.statistical_sector_nis_level_4, 1) IN ('1', '2', '3', '4', '7')
        AND LEFT(p.statistical_sector_nis_level_4, 2) NOT IN ('21', '25')
)
SELECT
    COUNT(*) AS total_listings,
    MIN(seq.sequence_start_date) AS earliest_start,
    MAX(seq.sequence_start_date) AS latest_start,
    MIN(seq.sequence_end_date) AS earliest_end,
    MAX(seq.sequence_end_date) AS latest_end
FROM
    classified_properties cp
    JOIN dataplatform_oris_production.gold.dim_reference_properties_sequences seq ON cp.address_key = seq.address_key
WHERE
    seq.sequence_end_date IS NOT NULL
    AND seq.sequence_duration_days BETWEEN 1
    AND 730
    AND YEAR(seq.sequence_start_date) BETWEEN 2023
    AND 2025
    AND EXISTS (
        SELECT
            1
        FROM
            dataplatform_oris_production.gold.dim_reference_properties_publications pub
        WHERE
            pub.address_key = seq.address_key
            AND pub.address_sequence_number = seq.address_sequence_number
            AND pub.transaction_type = 1
    )
    AND (
        cp.is_wide_garden
        OR cp.is_no_garden
    );