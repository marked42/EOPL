# Exercise 8.15

implement table as procedure, empty table implemented as a procedure always returning 0, meaning no corresponding value for any input; table with multiple mappings implemented as nested procedures. multi-argument procedure are implemented with curried procedure.

```opaque-types
module tables
    interface [
        opaque table
        empty: table
        add-to-table: (int -> (int -> (table -> table)))
        lookup-in-table: (int -> (table -> int))
    ]
    body [
        type table = (int -> int)
        empty = proc (x: int) 0
        add-to-table = proc (x: int) proc (y: int) proc (t: table)
                            proc (target: int)
                                if zero?(-(target, x))
                                then y
                                else (t target)
        lookup-in-table = proc (x: int) proc (t: table) (t x)
    ]
let empty = from tables take empty
    in let add-binding = from tables take add-to-table
        in let lookup = from tables take lookup-in-table
            in let table1 = (((add-binding 3) 300)
                             (((add-binding 4) 400)
                              (((add-binding 3) 600) empty)))
                in -(((lookup 4) table1), ((lookup 3) table1)) %= 100
```
