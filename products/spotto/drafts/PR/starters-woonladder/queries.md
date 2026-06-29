# Queries achter de starters-analyse

Alle SQL die de cijfers in [rapport.md](rapport.md) heeft geproduceerd. Bron: MCP `mssql-comparison` (Vergelijkingspanden referentie-DB, `databricks`-schema), read-only.

## Conventies (gelden voor alle queries hieronder)

- **Eenheid = on-market-episode per woning:** dedup op `address_key` + `address_sequence_number` via `ROW_NUMBER() ... ORDER BY price_online_from`, `rn = 1`. Nooit per publicatie tellen (die dubbeltellen ~1,5×).
- **Prijs = eerste vraagprijs van de episode** uit `ReferencePropertiesPublicationPrices` (`transaction_type = 1` = verkoop). Vraagprijzen, geen transactieprijzen.
- **€/m² = prijs / `construction_area`** (bewoonbare opp.; ~84–86% gevuld; null-area valt buiten de €/m²-mediaan).
- **Vlaanderen = NIS-prefix** `LEFT(statistical_sector_nis_level_4,2)` in
  `('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')`.
  Provincies: Antwerpen 11/12/13 · Vlaams-Brabant 23/24 · West-Vlaanderen 31–38 · Oost-Vlaanderen 41–46 · Limburg 71–73.
  Let op: ~3–4% van de lente-episodes heeft geen NIS en valt buiten dit filter (effect op de aandelen ≤1%).
- **Appartementen-kotfilter:** `(construction_area IS NULL OR construction_area >= 35)` — sluit studentenstudio's uit.
- **Lente = maart–mei**; jaar-op-jaar vergelijkt telkens dezelfde maanden.
- `property_type`: 1 = huis, 2 = appartement. `epc_label` 1–7 = A+,A,B,C,D,E,F (E/F = renovatieplicht). `new_build_type` 2 = nieuwbouw.

> **Let op — federated link:** de zwaarste queries (3 vensters + `PERCENTILE_CONT`-window) geven soms `QUERY_EXECUTION_FAILED` (time-out van de databricks-link). Oplossing: per jaar draaien (filter één venster, `PARTITION BY band` zonder `yr`) en de jaren samenvoegen. De resultaten hieronder zijn zo gegenereerd en gecontroleerd.

---

## 0. Validatie (methodologische basis)

**0a. Dubbeltelling publicaties vs. woningen** (onderbouwt de episode-dedup):

```sql
SELECT COUNT(*) AS publications, COUNT(DISTINCT address_key) AS distinct_addresses
FROM databricks.ReferencePropertiesPublications
WHERE transaction_type = 1 AND property_type = 1
  AND online_from >= '2026-03-01' AND online_from < '2026-06-01';
-- -> 18.773 publicaties op 12.029 woningen (1,56x): tel per episode, niet per publicatie.
```

**0b. Prijsdekking per episode** (99,5% van de episodes heeft een prijs):

```sql
SELECT
  COUNT(DISTINCT CONCAT(p.address_key,'|',p.address_sequence_number)) AS units,
  COUNT(DISTINCT CASE WHEN pp.price > 0 THEN CONCAT(p.address_key,'|',p.address_sequence_number) END) AS units_with_price
FROM databricks.ReferencePropertiesPublications p
LEFT JOIN databricks.ReferencePropertiesPublicationPrices pp
  ON pp.reference_properties_publication_id = p.reference_properties_publication_id AND pp.transaction_type = 1
WHERE p.transaction_type = 1 AND p.property_type = 1
  AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01';
-- -> 12.029 woningen, 11.968 met prijs.
```

---

## 1. Huizen — €/m² en aantal per prijsklasse (Vlaanderen, lentes 2024/2025/2026)

Voedt de databijlage-tabel "Mediane prijs per m² — huizen" én het aandeel betaalbaar aanbod (43%→36% = `(n[<250k]+n[250-350k]) / totaal`; 17%→13% = `n[<250k]/totaal`).

```sql
SELECT DISTINCT band, yr,
  COUNT(*) OVER (PARTITION BY band, yr) AS n,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppm2) OVER (PARTITION BY band, yr) AS median_ppm2
FROM (
  SELECT
    CASE WHEN rp.construction_area > 0 THEN ep.price / rp.construction_area END AS ppm2,
    CASE WHEN ep.online_from < '2025-01-01' THEN 2024 WHEN ep.online_from < '2026-01-01' THEN 2025 ELSE 2026 END AS yr,
    CASE WHEN ep.price < 250000 THEN '1 <250k' WHEN ep.price < 350000 THEN '2 250-350k'
         WHEN ep.price < 500000 THEN '3 350-500k' WHEN ep.price < 750000 THEN '4 500-750k' ELSE '5 750k+' END AS band,
    CASE WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN
      ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
      THEN 'VL' ELSE 'X' END AS reg
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, pr.price,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    WHERE p.transaction_type = 1 AND p.property_type = 1
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2025-03-01' AND p.online_from < '2025-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep
  JOIN databricks.ReferenceProperties rp ON rp.address_key = ep.address_key
  WHERE ep.rn = 1
) base
WHERE reg = 'VL'
ORDER BY band, yr;
```

## 2. Appartementen — €/m² en aantal per prijsklasse (Vlaanderen, kotfilter, 2024/2025/2026)

Voedt de databijlage-tabel "Mediane prijs per m² — appartementen" (instap +5,7%, n (2026) per klasse).

```sql
SELECT DISTINCT band, yr,
  COUNT(*) OVER (PARTITION BY band, yr) AS n,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppm2) OVER (PARTITION BY band, yr) AS median_ppm2
FROM (
  SELECT
    CASE WHEN rp.construction_area > 0 THEN ep.price / rp.construction_area END AS ppm2,
    CASE WHEN ep.online_from < '2025-01-01' THEN 2024 WHEN ep.online_from < '2026-01-01' THEN 2025 ELSE 2026 END AS yr,
    CASE WHEN ep.price < 250000 THEN '1 <250k' WHEN ep.price < 350000 THEN '2 250-350k'
         WHEN ep.price < 500000 THEN '3 350-500k' WHEN ep.price < 750000 THEN '4 500-750k' ELSE '5 750k+' END AS band,
    CASE WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN
      ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
      THEN 'VL' ELSE 'X' END AS reg
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, pr.price,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    WHERE p.transaction_type = 1 AND p.property_type = 2
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2025-03-01' AND p.online_from < '2025-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep
  JOIN databricks.ReferenceProperties rp ON rp.address_key = ep.address_key
  WHERE ep.rn = 1 AND (rp.construction_area IS NULL OR rp.construction_area >= 35)
) base
WHERE reg = 'VL'
ORDER BY band, yr;
```

## 3. Huizen — EPC E/F, A–B en nieuwbouw per prijsklasse (Vlaanderen, lente 2026)

Voedt de tabel "Energielabel en nieuwbouw naar prijsklasse" (63% E/F en 8% A–B onder €250k; aandelen op woningen met gekend label = `has_epc`).

```sql
SELECT band, COUNT(*) AS total,
  SUM(CASE WHEN epc IN (6,7) THEN 1 ELSE 0 END) AS ef,
  SUM(CASE WHEN epc IN (1,2,3) THEN 1 ELSE 0 END) AS ab,
  SUM(CASE WHEN epc BETWEEN 1 AND 7 THEN 1 ELSE 0 END) AS has_epc,
  SUM(CASE WHEN nb = 2 THEN 1 ELSE 0 END) AS newbuild
FROM (
  SELECT ep.epc, ep.nb,
    CASE WHEN ep.price < 250000 THEN '1 <250k' WHEN ep.price < 350000 THEN '2 250-350k'
         WHEN ep.price < 500000 THEN '3 350-500k' WHEN ep.price < 750000 THEN '4 500-750k' ELSE '5 750k+' END AS band
  FROM (
    SELECT p.address_key, p.address_sequence_number, pr.price,
      rp.epc_label AS epc, rp.new_build_type AS nb, rp.statistical_sector_nis_level_4 AS nis,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
    WHERE p.transaction_type = 1 AND p.property_type = 1
      AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'
  ) ep
  WHERE ep.rn = 1 AND LEFT(ep.nis,2) IN
    ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
) base
GROUP BY band
ORDER BY band;
```

## 4. Huizen — aandeel onder €350k per provincie (lentes 2024 en 2026) — *geverifieerd in deze sessie*

Voedt de tabel "Aandeel huizen onder €350.000 — per provincie" (aandeel = `under350 / total`).

```sql
SELECT prov, yr, COUNT(*) AS total, SUM(CASE WHEN price < 350000 THEN 1 ELSE 0 END) AS under350
FROM (
  SELECT ep.price,
    CASE WHEN ep.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
    CASE
      WHEN LEFT(ep.nis,2) IN ('11','12','13') THEN 'Antwerpen'
      WHEN LEFT(ep.nis,2) IN ('23','24') THEN 'Vlaams-Brabant'
      WHEN LEFT(ep.nis,2) IN ('31','32','33','34','35','36','37','38') THEN 'West-Vlaanderen'
      WHEN LEFT(ep.nis,2) IN ('41','42','43','44','45','46') THEN 'Oost-Vlaanderen'
      WHEN LEFT(ep.nis,2) IN ('71','72','73') THEN 'Limburg'
      ELSE 'X' END AS prov
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, pr.price, rp.statistical_sector_nis_level_4 AS nis,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
    WHERE p.transaction_type = 1 AND p.property_type = 1
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep
  WHERE ep.rn = 1
) base
WHERE prov <> 'X'
GROUP BY prov, yr
ORDER BY prov, yr;
-- Gecontroleerd: Antwerpen 33%->25%, Limburg 53%->41%, Oost-Vl 43%->38%, Vlaams-Brabant 31%->25%, West-Vl 54%->47%.
```

## 5. Appartementen — €/m² per provincie (kotfilter, lentes 2024 en 2026)

Voedt de tabel "Mediane prijs per m² — appartementen per provincie" (Vlaams-Brabant +11%, Antwerpen +8,7%, West-Vl −5,6%). Documenteer `n` per provincie/jaar in de bijlage.

```sql
SELECT DISTINCT prov, yr,
  COUNT(*) OVER (PARTITION BY prov, yr) AS n,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ppm2) OVER (PARTITION BY prov, yr) AS median_ppm2
FROM (
  SELECT
    CASE WHEN rp.construction_area > 0 THEN ep.price / rp.construction_area END AS ppm2,
    CASE WHEN ep.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr,
    CASE
      WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN ('11','12','13') THEN 'Antwerpen'
      WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN ('23','24') THEN 'Vlaams-Brabant'
      WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN ('31','32','33','34','35','36','37','38') THEN 'West-Vlaanderen'
      WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN ('41','42','43','44','45','46') THEN 'Oost-Vlaanderen'
      WHEN LEFT(rp.statistical_sector_nis_level_4,2) IN ('71','72','73') THEN 'Limburg'
      ELSE 'X' END AS prov
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, pr.price,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    WHERE p.transaction_type = 1 AND p.property_type = 2
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep
  JOIN databricks.ReferenceProperties rp ON rp.address_key = ep.address_key
  WHERE ep.rn = 1 AND (rp.construction_area IS NULL OR rp.construction_area >= 35)
) base
WHERE prov <> 'X'
ORDER BY prov, yr;
```

## 6. Stable-panel controle — aandeel betaalbaar + aanbodvolume (alleen kantoren actief in béíde jaren)

Voedt de methodebox: aandeel < €350k blijft 43,5% → 36,1% en het volume bleef ~stabiel (−1%) wanneer we enkel makelaars meetellen die in 2024 én 2026 actief waren. Sluit de onboarding/churn-vertekening uit.

```sql
SELECT yr, COUNT(*) AS total, SUM(CASE WHEN price < 350000 THEN 1 ELSE 0 END) AS under350
FROM (
  SELECT ep.price, ep.org, CASE WHEN ep.online_from < '2025-01-01' THEN 2024 ELSE 2026 END AS yr
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, p.immoconnect_organization_id AS org, pr.price,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
    WHERE p.transaction_type = 1 AND p.property_type = 1
      AND LEFT(rp.statistical_sector_nis_level_4,2) IN
        ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep WHERE ep.rn = 1
) b
WHERE b.org IN (
  SELECT DISTINCT p.immoconnect_organization_id FROM databricks.ReferencePropertiesPublications p
  JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
  WHERE p.transaction_type = 1 AND p.property_type = 1
    AND LEFT(rp.statistical_sector_nis_level_4,2) IN
      ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
    AND p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01'
)
AND b.org IN (
  SELECT DISTINCT p.immoconnect_organization_id FROM databricks.ReferencePropertiesPublications p
  JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
  WHERE p.transaction_type = 1 AND p.property_type = 1
    AND LEFT(rp.statistical_sector_nis_level_4,2) IN
      ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
    AND p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'
)
GROUP BY yr ORDER BY yr;
-- Gecontroleerd: 2024 = 8.757 woningen, 3.807 onder 350k (43,5%); 2026 = 8.654, 3.126 (36,1%).
```

## 7. Woninggrootte per prijsklasse — controle op grootte-mix (methodebox)

Voedt de methodebox-zin dat de €/m²-stijging bij instapappartementen geen grootte-effect is (mediane grootte ≈ 78 m², stabiel). `ptype` 1 = huis, 2 = appartement.

```sql
SELECT DISTINCT ptype, band, yr,
  COUNT(*) OVER (PARTITION BY ptype, band, yr) AS n,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY area) OVER (PARTITION BY ptype, band, yr) AS median_area
FROM (
  SELECT ep.ptype, ep.area,
    CASE WHEN ep.online_from < '2025-01-01' THEN 2024 WHEN ep.online_from < '2026-01-01' THEN 2025 ELSE 2026 END AS yr,
    CASE WHEN ep.price < 250000 THEN '1 <250k' WHEN ep.price < 350000 THEN '2 250-350k'
         WHEN ep.price < 500000 THEN '3 350-500k' WHEN ep.price < 750000 THEN '4 500-750k' ELSE '5 750k+' END AS band
  FROM (
    SELECT p.address_key, p.address_sequence_number, p.online_from, p.property_type AS ptype, pr.price, rp.construction_area AS area,
      ROW_NUMBER() OVER (PARTITION BY p.address_key, p.address_sequence_number, p.property_type ORDER BY pr.price_online_from) AS rn
    FROM databricks.ReferencePropertiesPublications p
    JOIN databricks.ReferencePropertiesPublicationPrices pr
      ON pr.reference_properties_publication_id = p.reference_properties_publication_id AND pr.transaction_type = 1
    JOIN databricks.ReferenceProperties rp ON rp.address_key = p.address_key
    WHERE p.transaction_type = 1 AND p.property_type IN (1,2)
      AND LEFT(rp.statistical_sector_nis_level_4,2) IN
        ('11','12','13','23','24','31','32','33','34','35','36','37','38','41','42','43','44','45','46','71','72','73')
      AND ((p.online_from >= '2024-03-01' AND p.online_from < '2024-06-01')
        OR (p.online_from >= '2025-03-01' AND p.online_from < '2025-06-01')
        OR (p.online_from >= '2026-03-01' AND p.online_from < '2026-06-01'))
  ) ep
  WHERE ep.rn = 1 AND ep.area > 0 AND (ep.ptype = 1 OR ep.area >= 35)
) base
ORDER BY ptype, band, yr;
-- Gecontroleerd: appartementen <250k = 78 / 79,5 / 78 m² (stabiel); appartementen 750k+ = 115 -> 137 m² (vertekent die €/m²-daling).
```

---

*De externe referentiecijfers in het rapport (notaris-barometer, Statbel, Vlaams Parlement) komen niet uit deze DB; zie de bronlinks in [rapport.md](rapport.md).*
