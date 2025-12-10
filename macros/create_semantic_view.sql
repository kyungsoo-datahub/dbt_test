{% materialization semantic_view, adapter='snowflake' %}
    {%- set target_relation = this -%}
    
    -- This macro enables "CREATE OR REPLACE SEMANTIC VIEW" syntax
    {% call statement('main') -%}
        CREATE OR REPLACE SEMANTIC VIEW {{ target_relation }}
        {{ sql }}
    {%- endcall %}

    {{ return({'relations': [target_relation]}) }}
{% endmaterialization %}
