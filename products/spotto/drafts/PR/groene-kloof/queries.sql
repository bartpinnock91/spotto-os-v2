/* ============================================================================
   Groene kloof — queries achter rapport.md
   ----------------------------------------------------------------------------
   Bron:   mssql-comparison (Vergelijkingspanden referentie-DB, databricks-schema)
   Grein:  on-market-episode per woning = address_key + address_sequence_number,
           nooit per publicatie (~1,56x dubbeltelling zonder dedup).
   Periode: lente = maart–mei; jaar uit online_from op ReferencePropertiesPublications
           (identiek aan starters-woonladder/queries.md).
           SQL: online_from >= 'YYYY-03-01' AND online_from < 'YYYY-06-01'
   Prijs:  eerste vraagprijs van de episode (ROW_NUMBER op price_online_from ASC)
           binnen de lentepublicaties, uit ReferencePropertiesPublicationPrices.
           Vraagprijzen, geen transacties.
   €/m²:   op construction_area (bewoonbare opp).
   Gebied:  Vlaanderen via NIS-prefix op statistical_sector_nis_level_4:
            ('11','12','13','23','24','31','32','33','34','35','36','37','38',
             '41','42','43','44','45','46','71','72','73')
            ~3–4% zonder NIS valt buiten.
            Provincies: Antwerpen 11/12/13 · Vl-Brabant 23/24 · West-Vl 31–38
                        · Oost-Vl 41–46 · Limburg 71–73
   Enums:   property_type op publicatie: 1=huis, 2=appartement; transaction_type 1=koop.
            epc_label 1-7 = A+,A,B,C,D,E,F  -> A-B=(1,2,3) C-D=(4,5) E-F=(6,7).
            condition_state_type (domein-volgorde, zie query 7):
              0 onbekend, 1 te renoveren, 2 op te frissen, 3 goed onderhouden,
              4 zo goed als nieuw, 5 nieuw, 6 af te breken.

   Let op (MCP-eigenaardigheden):
   - query moet met SELECT beginnen (geen WITH); daarom geneste subqueries i.p.v. CTE's.
   - mediaan = PERCENTILE_CONT(0.5) WITHIN GROUP (...) OVER (PARTITION BY ...) + SELECT DISTINCT.

   Resultaten gedraaid 2026-06-29 (online_from + NIS, zie commentaren per query).
   ============================================================================ */


/* ----------------------------------------------------------------------------
   QUERY 1 — Huizen, mediane vraagprijs per m2 per energielabel, Vlaanderen
   Voedt: databijlage tabel 1 + kernclaim (A-B vs E-F; premie 34->37%).
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 WHEN p.online_from < '2026-01-01' THEN 2025 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2025-03-01' AND p.online_from < '2025-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area > 0 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat 2026-06-29: A-B 2445/2536/2609 (n2026 3262); C-D 2108/2125/2194 (3525); E-F 1793/1799/1846 (2441). Premie 36%->41%. */


/* ----------------------------------------------------------------------------
   QUERY 2 — Huizen, mediane vraagprijs PER WONING per energielabel (2024 vs 2026)
   Voedt: databijlage tabel 2 + vermogenskloof-claim (A-B vs E-F in euro per woning).
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER (PARTITION BY yr, epc_group) AS median_price,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price
  FROM (
    SELECT ep.yr, ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat 2026-06-29: A-B 445.000 -> 485.000; C-D 375.000 -> 399.000; E-F 290.000 -> 299.000. */


/* ----------------------------------------------------------------------------
   QUERY 3 — CONTROLE grootte-mix: mediane construction_area per label per jaar
   Voedt: methodebox (area stabiel -> prijsstijging is geen grootte-effect).
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ca) OVER (PARTITION BY yr, epc_group) AS median_area,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    rp.construction_area AS ca
  FROM (
    SELECT ep.yr, ep.address_key
    FROM (
      SELECT p.address_key, p.address_sequence_number,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area > 0 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat 2026-06-29: A-B 188->194; C-D 182->189; E-F 163->165. */


/* ----------------------------------------------------------------------------
   QUERY 4 — Prijsladder naar staat van de woning (huizen, lente 2026)
   Voedt: databijlage tabel 3 + sectie "De markt rekent renovatiewerk af".
   ---------------------------------------------------------------------------- */
SELECT DISTINCT cond,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY cond) AS median_ppsqm,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER (PARTITION BY cond) AS median_price,
  AVG(CAST(epc AS FLOAT)) OVER (PARTITION BY cond) AS avg_epc_label,
  COUNT(*) OVER (PARTITION BY cond) AS n
FROM (
  SELECT rp.condition_state_type AS cond, rp.epc_label AS epc, e.price, e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area > 0 AND rp.condition_state_type IS NOT NULL
) final
ORDER BY cond;
/* Resultaat 2026-06-29 (cond: EUR/m2, med prijs): 1=1718/295k, 2=1869/329k, 3=2323/429k, 4=2748/549k, 5=2737/472k. */


/* ----------------------------------------------------------------------------
   QUERY 5 — Premie A-B vs E-F per m2, per provincie (huizen, 2024 vs 2026)
   Voedt: databijlage tabel 4 + sectie "Waar de kloof het sterkst groeit".
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, prov, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, prov, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, prov, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE
      WHEN LEFT(e.nis,2) IN ('11','12','13') THEN 'Antwerpen'
      WHEN LEFT(e.nis,2) IN ('23','24') THEN 'Vlaams-Brabant'
      WHEN LEFT(e.nis,2) IN ('31','32','33','34','35','36','37','38') THEN 'West-Vlaanderen'
      WHEN LEFT(e.nis,2) IN ('41','42','43','44','45','46') THEN 'Oost-Vlaanderen'
      WHEN LEFT(e.nis,2) IN ('71','72','73') THEN 'Limburg'
      ELSE 'X' END AS prov,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, ep.price, ep.nis
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        rp.statistical_sector_nis_level_4 AS nis,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area > 0 AND rp.epc_label IN (1,2,3,6,7)
) final
WHERE epc_group IS NOT NULL AND prov <> 'X'
ORDER BY prov, epc_group, yr;
/* Resultaat 2026-06-29 premie 2024->2026: Vl-Brabant 28->34; Oost-Vl 32->44; Limburg 39->50; Antw 33->36; West-Vl 54->56.
   n per cel (A-B / E-F), 2024 -> 2026:
     Vl-Brabant     A-B 439->568, E-F 581->540
     Oost-Vl        A-B 779->758, E-F 773->582
     Limburg        A-B 546->605, E-F 452->402
     Antwerpen      A-B 527->816, E-F 374->466
     West-Vl        A-B 645->689, E-F 528->557   (alle cellen >=374, geen dunne segmenten) */


/* ----------------------------------------------------------------------------
   QUERY 6 — Appartementen, mediane vraagprijs per m2 per label (kotfilter >=35 m2)
   Voedt: databijlage tabel 5 + sectie "Bij appartementen speelt het anders".
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 WHEN p.online_from < '2026-01-01' THEN 2025 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 2 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2025-03-01' AND p.online_from < '2025-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area >= 35 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat 2026-06-29: A-B 3361/3371/3468; C-D 2858/2862/2957; E-F 2532/2586/2764 (E-F n2026 = 179). */


/* ----------------------------------------------------------------------------
   QUERY 7 — Ontcijfering condition_state_type (staat van de woning)
   Voedt: methodebox + enum-mapping bovenaan. Domein-volgorde bevestigd door
   correlatie met EPC/bouwjaar (en met broncode ConditionStateType.cs).
   Geen periode-filter: globale verdeling op referentie-eigenschappen.
   ---------------------------------------------------------------------------- */
SELECT rp.condition_state_type,
  COUNT(*) AS n,
  AVG(CAST(rp.epc_label AS FLOAT)) AS avg_epc_label,
  AVG(CAST(rp.construction_year AS FLOAT)) AS avg_byear
FROM databricks.ReferenceProperties rp
WHERE rp.property_type = 1
GROUP BY rp.condition_state_type
ORDER BY rp.condition_state_type;
/* 1=te renoveren (EPC ~6,4), 2=op te frissen (~6,0), 3=goed (~4,2),
   4=zo goed als nieuw (~3,5), 5=nieuw (~2,0), 6=af te breken (n klein). */


/* ----------------------------------------------------------------------------
   QUERY 8 — CONTROLE hedonisch light: premie per grootteband (huizen, 2024 vs 2026)
   Voedt: analyse-notities (verbreding overleeft binnen groottebanden, behalve <100 m2).
   Niet als tabel in rapport.md; onderbouwt dat de kloof geen puur compositie-effect is.
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, band, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, band, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, band, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.construction_area < 100 THEN '1 <100' WHEN rp.construction_area < 150 THEN '2 100-150' WHEN rp.construction_area < 220 THEN '3 150-220' ELSE '4 220+' END AS band,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        CASE WHEN p.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
        AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
          OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.construction_area > 0 AND rp.epc_label IN (1,2,3,6,7)
) final
WHERE epc_group IS NOT NULL
ORDER BY band, epc_group, yr;
/* Resultaat 2026-06-29 premie per band 2024->2026: <100 61->51; 100-150 34->42; 150-220 41->48; 220+ 51->63. */


/* ----------------------------------------------------------------------------
   QUERY 9 — Samenstelling goedkoopste aanbod: huizen < EUR 250k, lente 2026, Vlaanderen
   Voedt: databijlage tabel "Staat van het goedkoopste aanbod" + openingssectie.
   Identiek aan starters-woonladder/queries.md §3 (band <250k).
   EPC-aandelen op woningen met gekend label (n_epc_known); nieuwbouw op het totaal.
   ---------------------------------------------------------------------------- */
SELECT
  COUNT(*) AS n_total,
  SUM(CASE WHEN epc BETWEEN 1 AND 7 THEN 1 ELSE 0 END) AS n_epc_known,
  SUM(CASE WHEN epc IN (6,7) THEN 1 ELSE 0 END) AS n_ef,
  SUM(CASE WHEN epc IN (1,2,3) THEN 1 ELSE 0 END) AS n_ab,
  SUM(CASE WHEN nb = 2 THEN 1 ELSE 0 END) AS n_newbuild
FROM (
  SELECT rp.epc_label AS epc, rp.new_build_type AS nb, e.price
  FROM (
    SELECT ep.address_key, ep.price
    FROM (
      SELECT p.address_key, p.address_sequence_number, pr.price,
        ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pr
        ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
      JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
      WHERE p.transaction_type = 1 AND p.property_type = 1 AND pr.price > 0
        AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'
        AND LEFT(rp.statistical_sector_nis_level_4,2) IN
          ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
    ) ep
    WHERE ep.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE e.price < 250000
) final;
/* Resultaat 2026-06-29: n_total 1411, n_epc_known 1392, n_ef 890 (64%), n_ab 93 (7%), n_newbuild 3. */


/* ----------------------------------------------------------------------------
   QUERY 10 — RECONCILIATIE: episode-overlap online_from vs sequence_start_date (huizen, lente 2026)
   Meet hoeveel episodes de oude en nieuwe methode verschillend selecteren.
   Draaien na harmonisatie; resultaten niet in rapport.md.
   ---------------------------------------------------------------------------- */
SELECT
  SUM(CASE WHEN in_online = 1 AND in_seq = 1 THEN 1 ELSE 0 END) AS n_both,
  SUM(CASE WHEN in_online = 1 AND in_seq = 0 THEN 1 ELSE 0 END) AS n_online_only,
  SUM(CASE WHEN in_online = 0 AND in_seq = 1 THEN 1 ELSE 0 END) AS n_sequence_only
FROM (
  SELECT
    COALESCE(o.ep_key, s.ep_key) AS ep_key,
    CASE WHEN o.ep_key IS NOT NULL THEN 1 ELSE 0 END AS in_online,
    CASE WHEN s.ep_key IS NOT NULL THEN 1 ELSE 0 END AS in_seq
  FROM (
    SELECT DISTINCT CONCAT(p.address_key,'|',p.address_sequence_number) AS ep_key
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
    WHERE p.transaction_type = 1 AND p.property_type = 1
      AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'
      AND LEFT(rp.statistical_sector_nis_level_4,2) IN
        ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
  ) o
  FULL OUTER JOIN (
    SELECT DISTINCT CONCAT(s.address_key,'|',s.address_sequence_number) AS ep_key
    FROM databricks.ReferencePropertiesSequences s
    WHERE MONTH(s.sequence_start_date) IN (3,4,5) AND YEAR(s.sequence_start_date) = 2026
      AND (TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999)
  ) s ON o.ep_key = s.ep_key
) base;
/* Resultaat 2026-06-29: n_both 7922, n_online_only 3538, n_sequence_only 12265.
   LET OP — geen zuivere periode-vergelijking: de sequence-kant gebruikt postcode i.p.v. NIS
   EN heeft geen property_type-filter (telt dus ook appartementen/grond), terwijl de online-kant
   enkel huizen telt. Daardoor is n_sequence_only sterk opgeblazen. Lees dit niet als
   "de online_from-methode laat 12k huizen vallen". Voor een echte periode-isolatie:
   beide kanten op NIS + property_type=1 brengen. Diagnostiek, niet in rapport.md. */
