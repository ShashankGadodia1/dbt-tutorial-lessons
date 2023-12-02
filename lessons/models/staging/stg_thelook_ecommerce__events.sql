{#

	Possible valuye for on schema changes:
	1. ignore: Default behavior (see below).
	2. fail: Triggers an error message when the source and target schemas diverge
	3. append_new_columns: Append new columns to the existing table. Note that this setting does
	not remove columns from the existing table that are not present in the new data.
	4. sync_all_columns: Adds any new columns to the existing table, and removes any columns that
	are now missing. Note that this is inclusive of data type changes. On BigQuery, changing column
	types requires a full table scan; be mindful of the trade-offs when implementing.

	If we do not provide unique key then it will duplicate data.

	An optional incremental_strategy config is provided in some adapters that controls the code
	that dbt uses to build incremental models.

data platform adapte-->default strategy-->additional supported strategies
dbt-postgres	append	merge , delete+insert
dbt-redshift	append	merge, delete+insert
dbt-bigquery	merge	insert_overwrite
dbt-spark	append	merge (Delta only) insert_overwrite
dbt-databricks	append	merge (Delta only) insert_overwrite
dbt-snowflake	merge	append, delete+insert
dbt-trino	append	merge delete+insert

Partitioned Table:
This is more of a BigQuery specific topic, but it’s useful nonetheless.
Partitions allow you to reduce the amount of data you query (quicker and cheaper to run)
by storing a table in chunks (partitions) based on a timestamp/date column.
There’s also the concept of a “cluster” in BigQuery, which is similar but allows other column
types such as a string. The scope of all of this is way outside the course as it’s very BigQuery
specific, but you can read more here.
Essentially, all you need to know for partitioning is:
When you query a partitioned table, and filter the table on the column it’s partitioned by,
it’s quicker and cheaper to do so vs. scanning the whole table
But, it takes longer to drop & replace the table as a result of the partitioning process
I suggest you use partitioning for very large tables that are exposed to end users in BI tools -
e.g. mart tables. We partition our stg_ecommerce__events table in this course just for demonstration.

{
  "field": "<field name>",
  "data_type": "<timestamp | date | datetime | int64>",
  "granularity": "<hour | day | month | year>"

  # Only required if data_type is "int64"
  "range": {
    "start": <int>,
    "end": <int>,
    "interval": <int>
  }
}
#}
{{
	config(
		materialized='incremental',
		unique_key='event_id',
		on_schema_change='sync_all_columns',
		incremental_strategy='merge',
		partition_by={
			"field": "created_date",
			"data_type": "date",
			"granularity": "day",
      		"time_ingestion_partitioning": true
		}
	)
}}
with source as (
	select *
	from {{ source('thelook_ecommerce','events') }}
 where created_at <= '2023-01-01'
)
SELECT
	id AS event_id,
	user_id,
	sequence_number,
	session_id,
	created_at,
	ip_address,
	city,
	state,
	postal_code,
	browser,
	traffic_source,
	uri AS web_link,
	event_type,
	timestamp_trunc(created_at, day) as created_date
	{# Look in macros/macro_get_brand_name.sql to see how this function is defined
	,{{ target.schema }}.get_brand_name(uri) AS brand_name#}
FROM source
{# Only runs this filter on an incremental run #}
{% if is_incremental() %}
{# The {{ this }} macro is essentially a {{ ref('') }} macro that allows for a circular reference #}
WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
{% endif %}