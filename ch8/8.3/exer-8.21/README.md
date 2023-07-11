# Solution

first implement several helper procedures.

1. `plus` implemented by using equation `(plus x y) = (plus (- x 1) (+ y 1))` `(plus 0 y) = y`
1. `diff` implemented by using equation `(diff x y) = (diff (- x 1) (- y 1))` `(diff x 0) = x`
1. `equal` implemented by using equation `(equal x y) = (zero (diff x y))`
1. `average` implemented by using equation `(average x y) = (average (+ x 1) (- y 1))` `(average x x) = x`

integer k represented by 2*k.

1. `zero` is `zero`
1. `succ` is original `succ` applied twice
1. `pred` is original `pred` applied twice
1. `is-zero` receives `x`, which is a representation of some 2 * k, get average of `zero` and `x`, which is `k`, and use
original `is-zero` to determine if `k` is zero.

```proc-modules
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            succ: (from ints take t -> from ints take t)
            pred: (from ints take t -> from ints take t)
            is-zero: (from ints take t -> bool)
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
            type t = from ints take t
            zero = from ints take zero

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average

            succ = proc (x: from ints take t) (from ints take succ (from ints take succ x))
            pred = proc (x: from ints take t) (from ints take pred (from ints take pred x))

            is-zero = proc (x: from ints take t) (from ints take is-zero ((average zero) x))
        ]

```
