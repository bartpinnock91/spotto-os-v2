WITH providers_deduped AS (
  SELECT
    LOWER(valid_immoconnect_organization_id) AS org_id,
    provider_name,
    picture_url,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(valid_immoconnect_organization_id)
      ORDER BY picture_url IS NULL, provider_name
    ) AS rn
  FROM dataplatform_oris_production.gold.dim_reference_properties_providers
  WHERE valid_immoconnect_organization_id IS NOT NULL
)
SELECT
  p.address_key,
  p.street_name,
  p.house_number,
  p.box_number,
  p.postcode,
  p.municipality_name,
  p.latitude,
  p.longitude,
  pub.source_publication_id AS publication_id,
  prov.provider_name AS agent_name,
  prov.picture_url AS agent_logo_url,
  pub.property_type,
  bp.PropertySubType AS property_subtype,
  pub.transaction_type,
  sp.price_value AS price,
  sp.price_type,
  sp.construction_square_meters AS available_surface_m2,
  sp.parcel_built_square_meters AS built_surface_m2,
  sp.parcel_total_plot_square_meters AS plot_surface_m2,
  sp.main_image_url AS photo_url,
  FILTER(FROM_JSON(sp.title_translations, 'ARRAY<STRUCT<LanguageCode:STRING, Value:STRING>>'), x -> x.LanguageCode = 'nl')[0].Value AS title,
  sp.available_from,
  pub.last_modified_on AS last_modified_at,
  pub.publication_url_dutch AS spotto_url
FROM dataplatform_oris_production.gold.dim_reference_properties p
JOIN dataplatform_oris_production.gold.dim_reference_properties_publications pub
  ON p.address_key = pub.address_key
LEFT JOIN providers_deduped prov
  ON LOWER(pub.immoconnect_organization_id) = prov.org_id
  AND prov.rn = 1
LEFT JOIN dataplatform_oris_production.silver.stg_spotto_publications sp
  ON pub.source_publication_id = sp.publication_id
LEFT JOIN dataplatform_oris_production.bronze.spotto_publications bp
  ON pub.source_publication_id = bp.Id
WHERE p.is_professional = TRUE
  AND pub.is_online = TRUE
  AND pub.property_type IN (4, 7, 9, 10, 11, 12, 13, 14)
ORDER BY p.street_name, p.house_number, pub.last_modified_on DESC