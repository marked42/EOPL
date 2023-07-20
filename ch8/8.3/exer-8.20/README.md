# Solution

refer to [sum-prod-maker](../../../base/test.rkt#1256)

```proc-modules
module sum-prod-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            plus: (from ints take t -> (from ints take t -> from ints take t))
            times: (from ints take t -> (from ints take t -> from ints take t))
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
            plus = letrec (from ints take t -> from ints take t) plus (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then y
                            else ((plus (from ints take pred x)) (from ints take succ y))
                        in plus
            times = letrec (from ints take t -> from ints take t) times (x: from ints take t) = proc (y: from ints take t)
                            if (from ints take is-zero x)
                            then from ints take zero
                            else ((plus ((times (from ints take pred x)) y)) y)
                        in times
        ]
```
