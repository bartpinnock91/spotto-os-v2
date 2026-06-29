/* ============================================================================
   Groene kloof — queries achter rapport.md
   ----------------------------------------------------------------------------
   Bron:   mssql-comparison (Vergelijkingspanden referentie-DB, databricks-schema)
   Grein:  on-market-episode per woning = address_key + address_sequence_number
           (ReferencePropertiesSequences), nooit per publicatie.
   Prijs:  eerste vraagprijs van de episode (ROW_NUMBER op price_online_from ASC)
           uit ReferencePropertiesPublicationPrices. Vraagprijzen, geen transacties.
   €/m²:   op construction_area (bewoonbare opp).
   Periode: lente = maand 3-5; jaar uit sequence_start_date.
   Gebied:  Vlaanderen = postcode 1500-3999 OF 8000-9999.
            Provincies: Antwerpen 2000-2999; Vlaams-Brabant 1500-1999+3000-3499;
            Limburg 3500-3999; West-Vl 8000-8999; Oost-Vl 9000-9999.
   Enums:   property_type 1=huis, 2=appartement; transaction_type 1=koop.
            epc_label 1-7 = A+,A,B,C,D,E,F  -> A-B=(1,2,3) C-D=(4,5) E-F=(6,7).
            condition_state_type (domein-volgorde, zie query 7):
              0 onbekend, 1 te renoveren, 2 op te frissen, 3 goed onderhouden,
              4 zo goed als nieuw, 5 nieuw, 6 af te breken.

   Let op (MCP-eigenaardigheden):
   - query moet met SELECT beginnen (geen WITH); daarom geneste subqueries i.p.v. CTE's.
   - mediaan = PERCENTILE_CONT(0.5) WITHIN GROUP (...) OVER (PARTITION BY ...) + SELECT DISTINCT.

   NB: de samenstelling van het goedkoopste segment in rapport.md
   ("huizen < EUR 250k: 63% E/F, 8% A-B, nieuwbouw <1%") kwam oorspronkelijk uit
   de starters-woonladder-analyse; query 9 reproduceert ze met deze methode.
   ============================================================================ */


/* ----------------------------------------------------------------------------
   QUERY 1 — Huizen, mediane vraagprijs per m2 per energielabel, Vlaanderen
   Voedt: databijlage tabel 1 + kernclaim (A-B +6,0% vs E-F +3,8%; premie 34->37%).
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number, YEAR(s.sequence_start_date) AS yr
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5)
        AND YEAR(s.sequence_start_date) IN (2024,2025,2026)
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND rp.construction_area > 0 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat: A-B 2454/2526/2602 (n2026 2294); C-D 2130/2141/2210 (2580); E-F 1833/1846/1903 (1728). */


/* ----------------------------------------------------------------------------
   QUERY 2 — Huizen, mediane vraagprijs PER WONING per energielabel (2024 vs 2026)
   Voedt: databijlage tabel 2 + vermogenskloof-claim (A-B +EUR 39.500 vs E-F +EUR 5.000).
   Verschilt van query 1: aggregeert op price i.p.v. price/area; geen area-filter nodig.
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price) OVER (PARTITION BY yr, epc_group) AS median_price,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price
  FROM (
    SELECT ep.yr, ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number, YEAR(s.sequence_start_date) AS yr
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5)
        AND YEAR(s.sequence_start_date) IN (2024,2026)
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat: A-B 439.500 -> 479.000; C-D 375.000 -> 398.000; E-F 294.000 -> 299.000. */


/* ----------------------------------------------------------------------------
   QUERY 3 — CONTROLE grootte-mix: mediane construction_area per label per jaar
   Voedt: methodebox (area stabiel -> prijsstijging is geen grootte-effect).
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ca) OVER (PARTITION BY yr, epc_group) AS median_area,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT YEAR(s.sequence_start_date) AS yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    rp.construction_area AS ca
  FROM databricks.ReferencePropertiesSequences s
  JOIN databricks.ReferenceProperties rp ON rp.address_key = s.address_key
  WHERE MONTH(s.sequence_start_date) IN (3,4,5) AND YEAR(s.sequence_start_date) IN (2024,2026)
    AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    AND rp.property_type = 1 AND rp.construction_area > 0 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat: A-B 182->185; C-D 175->180; E-F 160->161 (stabiel). */


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
    SELECT ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5) AND YEAR(s.sequence_start_date) = 2026
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND rp.construction_area > 0 AND rp.condition_state_type IS NOT NULL
) final
ORDER BY cond;
/* Resultaat (cond: EUR/m2, med prijs): 1=1748/295k, 2=1916/332k, 3=2347/425k, 4=2750/535k, 5=2730/477k. */


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
      WHEN pc BETWEEN 2000 AND 2999 THEN 'Antwerpen'
      WHEN pc BETWEEN 1500 AND 1999 OR pc BETWEEN 3000 AND 3499 THEN 'Vlaams-Brabant'
      WHEN pc BETWEEN 3500 AND 3999 THEN 'Limburg'
      WHEN pc BETWEEN 8000 AND 8999 THEN 'West-Vlaanderen'
      WHEN pc BETWEEN 9000 AND 9999 THEN 'Oost-Vlaanderen' END AS prov,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, pr.price, ep.pc
    FROM (
      SELECT s.address_key, s.address_sequence_number, YEAR(s.sequence_start_date) AS yr, TRY_CAST(s.postcode AS INT) AS pc
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5)
        AND YEAR(s.sequence_start_date) IN (2024,2026)
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND rp.construction_area > 0 AND rp.epc_label IN (1,2,3,6,7)
) final
WHERE epc_group IS NOT NULL AND prov IS NOT NULL
ORDER BY prov, epc_group, yr;
/* Premie 2024->2026: Vl-Brabant 23->33; Oost-Vl 30->38; Limburg 40->48; Antw 30->34; West-Vl 52->45. */


/* ----------------------------------------------------------------------------
   QUERY 6 — Appartementen, mediane vraagprijs per m2 per label (kotfilter >=35 m2)
   Voedt: databijlage tabel 5 + sectie "Bij appartementen speelt het anders".
   Identiek aan query 1 maar property_type=2 en construction_area >= 35.
   ---------------------------------------------------------------------------- */
SELECT DISTINCT yr, epc_group,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppsqm) OVER (PARTITION BY yr, epc_group) AS median_ppsqm,
  COUNT(*) OVER (PARTITION BY yr, epc_group) AS n
FROM (
  SELECT e.yr,
    CASE WHEN rp.epc_label IN (1,2,3) THEN 'A-B' WHEN rp.epc_label IN (4,5) THEN 'C-D' WHEN rp.epc_label IN (6,7) THEN 'E-F' END AS epc_group,
    e.price / rp.construction_area AS ppsqm
  FROM (
    SELECT ep.yr, ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number, YEAR(s.sequence_start_date) AS yr
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5)
        AND YEAR(s.sequence_start_date) IN (2024,2025,2026)
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 2 AND rp.construction_area >= 35 AND rp.epc_label BETWEEN 1 AND 7
) final
ORDER BY epc_group, yr;
/* Resultaat: A-B 3350/3376/3499; C-D 2838/3000/2990; E-F 2524/2641/2932 (E-F n2026 = 109, te dun). */


/* ----------------------------------------------------------------------------
   QUERY 7 — Ontcijfering condition_state_type (staat van de woning)
   Voedt: methodebox + enum-mapping bovenaan. Domein-volgorde bevestigd door
   correlatie met EPC/bouwjaar (en met broncode ConditionStateType.cs).
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
    SELECT ep.yr, ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number, YEAR(s.sequence_start_date) AS yr
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5)
        AND YEAR(s.sequence_start_date) IN (2024,2026)
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND rp.construction_area > 0 AND rp.epc_label IN (1,2,3,6,7)
) final
WHERE epc_group IS NOT NULL
ORDER BY band, epc_group, yr;
/* Premie 2024->2026 per band: <100 40->39; 100-150 32->40; 150-220 40->44; 220+ 49->56. */


/* ----------------------------------------------------------------------------
   QUERY 9 — Samenstelling goedkoopste aanbod: huizen < EUR 250k, lente 2026, Vlaanderen
   Voedt: databijlage tabel "Staat van het goedkoopste aanbod" + openingssectie.
   EPC-aandelen op woningen met gekend label (n_epc_known); nieuwbouw op het totaal.
   ---------------------------------------------------------------------------- */
SELECT
  COUNT(*) AS n_total,
  SUM(CASE WHEN epc BETWEEN 1 AND 7 THEN 1 ELSE 0 END) AS n_epc_known,
  SUM(CASE WHEN epc IN (6,7) THEN 1 ELSE 0 END) AS n_ef,
  SUM(CASE WHEN epc IN (1,2,3) THEN 1 ELSE 0 END) AS n_ab,
  SUM(CASE WHEN nb = 2 THEN 1 ELSE 0 END) AS n_newbuild
FROM (
  SELECT rp.epc_label AS epc, rp.new_build_type AS nb
  FROM (
    SELECT ep.address_key, pr.price
    FROM (
      SELECT s.address_key, s.address_sequence_number
      FROM databricks.ReferencePropertiesSequences s
      WHERE MONTH(s.sequence_start_date) IN (3,4,5) AND YEAR(s.sequence_start_date) = 2026
        AND ( TRY_CAST(s.postcode AS INT) BETWEEN 1500 AND 3999 OR TRY_CAST(s.postcode AS INT) BETWEEN 8000 AND 9999 )
    ) ep
    JOIN (
      SELECT p.address_key, p.address_sequence_number, pp.price,
             ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pp.price_online_from ASC) AS rn
      FROM databricks.ReferencePropertiesPublications p
      JOIN databricks.ReferencePropertiesPublicationPrices pp
        ON pp.reference_properties_publication_id = p.reference_properties_publication_id
      WHERE p.transaction_type = 1 AND pp.transaction_type = 1 AND pp.price > 0
    ) pr ON pr.address_key = ep.address_key AND pr.address_sequence_number = ep.address_sequence_number AND pr.rn = 1
  ) e
  JOIN databricks.ReferenceProperties rp ON rp.address_key = e.address_key
  WHERE rp.property_type = 1 AND e.price < 250000
) final;
/* Resultaat: n_total 936, n_epc_known 914, n_ef 572 (63%), n_ab 69 (8%), n_newbuild 6 (<1%). */
