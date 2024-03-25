{% macro get_snowflake_refresh_warehouse() %}
  {% set relation = adapter.get_relation(this.database, this.schema, this.table) %}
  {% if target.name == 'prd' %}
    {% set suffix = 'PRD' %}
  {% else %}
    {% set suffix = 'DEV' %}
  {% endif %}
  {% if flags.FULL_REFRESH %}
    {% set size = '4XL' %}
  {% else %}
    {% set size = 'XS' %}
  {% endif %}
  {% set warehouse = 'TRANSFORMING_' ~ size ~ '_' ~ suffix %}
  {{ return(warehouse) }}
{% endmacro %}

