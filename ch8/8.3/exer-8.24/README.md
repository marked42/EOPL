# Solution

cannot simply rename parameter name operand identifier name in result type like `(m1 m2)`, because operand can be non identifier `(m2 m3)` in `(m1 (m2 m3))`. First find interface type of operand, which may be identifier or any other expression representing a module, then we can know module interface, replace qualified-type `from mod take name` in result type of application module body by type definition of `name` in module interface.

type `from ints take t` in module body result type should be replaced with operand interface type `type t = int`.

Refer to [replace-iface](../exer-8.26/checker/main.rkt#L63).

```proc-modules
module ints1-to-int
    interface [
        to-int: (int -> int)
    ]
    body
        (module-proc (ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
        [
        type t = int
        zero = 0
        pred = proc(x : t) -(x,5)
        succ = proc(x : t) -(x,-5)
        is-zero = proc (x : t) zero?(x)
    ])
1
```
