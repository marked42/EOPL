Code

```racket
let fact = proc (n) add1(n)
    in let fact = proc (n)
                        if zero?(n)
                        then 1
                        else *(n, (fact -(n,1)))
            in (fact 5)
```

`(fact 5)` returns `120` under dynamic scoping, because `fact` in `(fact -(n, 1))` refers `fact`
at line 2, thus forming a recursive procedure. run `racket test.rkt` under `./dynamic` to test this.

`(fact 5)` returns `25` under lexical scoping, because `fact` in `(fact -(n, 1))` refers `fact`
at line 1 which is just `add1`, so `*(n, (fact -(n,1)))` is `*(5, add1(-(5,1)))` equals to `25`. run `racket test.rkt` under `./lexical` to test this.

Mutually recursive even/odd under dynamic binding.

```
let even = proc (x) if zero?(x) then 1 else (odd -(x,1))
    odd  = proc (x) if zero?(x) then 0 else (even -(x,1))
    in (odd 13)
```
