{% snapshot snapshot__distribution_centers %}

{{
	config(
		target_schema='dbt_snapshots',
		unique_key='id',
		strategy='check',
		check_cols=['name', 'latitude', 'longitude'],
		invalidate_hard_deletes=True
	)
}}

-- Strategy is of two type -
-- #1.check
-- check_cols=['col1','col2']
-- #2.timestamp
-- updated_at=['delta_cols']

SELECT
	id,
	name,
	latitude,
	longitude

FROM {{ source('thelook_ecommerce', 'distribution_centers') }}

{% endsnapshot %}