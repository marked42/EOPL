# Exercise 8.14

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

this implementation treats `0` as `true`, other integers as `false`, so `(to-bool 2)` is `false`.

Exercise 8.14

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
        true = 1
        false = 0
        and = proc (x : t) proc (y : t) if zero?(x) then false else y
        not = proc (x : t) if zero?(x) then true else false
        to-bool = proc (x : t) if zero?(x) then zero?(1) else zero?(0)
    ]
```

this implementation treats `0` as `false`, other integers as `true`, so `(to-bool 2)` is `true`.

these two implementations uses different integer representations without overlapping.

to-bool1

| F        | T   | F        |
| -------- | --- | -------- |
| negative | 0   | positive |

to-bool2

| T        | F   | T        |
| -------- | --- | -------- |
| negative | 0   | positive |
