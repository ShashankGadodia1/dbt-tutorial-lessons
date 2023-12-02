{% macro generate_schema_name(custom_schema_name, node) -%}

		{# target.schema would be dbt_production or dbt_jack for example #}
    {%- set default_schema = target.schema -%}

		{#
			This is where we customise the function by adding
			"or target.schema != 'production'"
		#}
    {%- if custom_schema_name is none or target.schema != 'production' -%}

        {{ default_schema }}

    {%- else -%}

        {{ default_schema }}_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}

