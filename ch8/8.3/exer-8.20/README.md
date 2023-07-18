# Solution

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
            plus = letrec plus = proc (x: from ints take t) proc (y: from ints take t)
                            if (zero x)
                            then y
                            else (succ (plus (pred x) y))
                        in plus
            times = letrec times = proc (x: from ints take t) proc (y: from ints take t)
                            if (zero x)
                            then 0
                            else ((plus ((times (pred x)) y)) y)
        ]
```
