environment representation

*env-as-list*

represent environment as list, each element of list is an environment record, which is either `('empty-env)` or `(extend-env var val)`.

*exer 2.5*

represent environment as list, empty environment is empty list, each element of list is an environment record, which is a pair of var and val `(var . val)`

*exer 2.11*

ribcage representation, represent environment as a list, empty environment is empty list, each element of list is an environment record, which is a pair of vars and vals `(vars . vals)`.

*env-as-proc*

procedural representation
