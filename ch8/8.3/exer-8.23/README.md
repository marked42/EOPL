# Solution

```proc-modules
module mybool
    interface [
        opaque t
        true : t
        false : t
        and : (t -> (t -> t))
        not : (t -> t)
        to-bool : (t -> bool)
    ]
    body [
        type t = int
        true = 0
        false = 13
        and = proc (x : t) proc (y : t) if zero?(x) then y else false
        not = proc (x : t) if zero?(x) then false else true
        to-bool = proc (x : t) zero?(x)
    ]
let true = from mybool take true
    in let false = from mybool take false
        in let and = from mybool take and
            in ((and true) false)

module table-of
    interface
        ((bool: [
            opaque t
            false: t
        ]) => [
            opaque table
            empty: table
            add-to-table: (int -> (from bool take t -> (table -> table)))
            lookup-in-table: (int -> (table -> from bool take t))
        ])
    body
        module-proc (bool: [
            opaque t
            false: t
        ])
        [
            type table = (int -> from bool take t)
            empty = proc (x: int) from bool take false
            add-to-table = proc (x: int) proc (y: from bool take t) proc (t: table)
                                proc (target: int)
                                    if zero?(-(target, x))
                                    then y
                                    else (t target)
            lookup-in-table = proc (x: int) proc (t: table) (t x)
        ]

module mybool-tables
    interface [
        opaque table
        empty : table
        add-to-table : (int -> (from mybool take t -> (table -> table)))
        lookup-in-table : (int -> (table -> from mybool take t))
    ]
    body
        (table-of mybool)

1
```
