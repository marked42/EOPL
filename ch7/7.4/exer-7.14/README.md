# Exercise 7.14

```eopl
letrec ? even(odd : ?) = proc (x : ?) if zero?(x) then 1 else (odd -(x,1))
    in letrec ? odd(x : bool) = if zero?(x) then 0 else ((even odd) -(x,1))
        in (odd 13)
```

`odd(x: bool)` should accepts an integer, but type annotations requires `bool`
