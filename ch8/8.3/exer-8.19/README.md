# Solution

finish `from-int-maker` first, then create two modules `inst1-from-int` and `inst2-from-int`, generate
`three1` using `(from inst1-from-int take from-int 3)`, `three2` with `(from inst1-from-int take from-int 3)`

```proc-modules
module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
        ])
    body
        module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
module ints1
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]
module ints2
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,3)
        pred = proc(x : t) -(x,-3)
        is-zero = proc (x : t) zero?(x)
    ]
module inst1-to-int
    interface [
        to-int: (from inst1 take t -> int)
    ]
    body
        (to-int-maker inst1)
module inst2-to-int
    interface [
        to-int: (from inst2 take t -> int)
    ]
    body
        (to-int-maker inst2)

module from-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            from-int: (int -> from ints take t)
        ])
    body
      module-proc (ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            from-int = let zero = from ints take zero
                        in let succ = from ints take succ
                            in letrec int from-int (x: int) = if zero?(x) then zero else (succ (from-int -(x,1)))
                                in from-int
        ]
module inst1-from-int
    interface [
        from-int: (int -> from inst1 take t)
    ]
    body
        (from-int-maker inst1)
module inst2-from-int
    interface [
        from-int: (int -> from inst2 take t)
    ]
    body
        (from-int-maker inst2)
let three1 = (from inst1-from-int take from-int 3)
in let three2 = (from inst2-from-int take from-int 3)
in -((from inst1-to-int take to-int three1), (from inst2-to-int take to-int three2))
```
