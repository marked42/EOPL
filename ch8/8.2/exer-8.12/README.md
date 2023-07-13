# Exercise 8.12

Example 8.13

```opaque-types
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
```

move `and` / `not` out.

```opaque-types
module mybool
     interface [
        opaque t
        true : t
        false : t
        to-bool : (t -> bool)
    ]
    body [
        type t = int
        true = 0
        false = 13
        to-bool = proc (x : t) zero?(x)
    ]
let true = from mybool take true
    in let false = from mybool take false
        in let and = proc (x: t) proc (y: t) if (to-bool x) then y else false
            in let not = proc (x: t) if (to-bool x) then false else true
                in ((and true) false)
```

`to-bool` cannot be moved out.
