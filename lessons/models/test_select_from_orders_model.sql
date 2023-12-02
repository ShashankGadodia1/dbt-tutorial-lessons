/*

Access

There are 3 levels of access:

Private: only other models in the same group can ref this model
Protected (default): only other models in the same group or dbt project can ref this model
Public: any other model - in the same group, project, or separate dbt project can ref this model
e.g. If you tried to ref a model in dbt_packages/dbt_utils (there aren’t any, but just for this
example let’s say there are) that wasn’t set to public access you would get an error

This model will not execute if access type is private to sales group.
In this case it is accessible from other sales group model.

Access is defined at a model level, and currently cannot be defined on a project or folder level.

Groups can be defined at project level or folder level as well as model level in YML and SQL.

*/
{{
	config(
		group="sales"
	)
}}
select * from {{ref("orders")}}
