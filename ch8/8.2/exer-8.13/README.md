# Exercise 8.13

implements arithmetic using a representation in which the integer k is represented as 5 \* k + 3

```opaque-types
module ints
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 3
        step = 5
        succ = proc(x : t) -(x,-(0, step))
        pred = proc(x : t) -(x,step)
        is-zero = proc (x : t) zero?(-(x,zero))
    ]
let z = from ints take zero
    in let s = from ints take succ
        in (s (s z))
```
