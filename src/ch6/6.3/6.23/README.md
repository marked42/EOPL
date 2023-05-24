# if-exp

`if`表达式中then/else分支会使用相同的`k-exp`（`proc (var%1) var%1`），当`if`表达式嵌套时，`k-exp`出现的次数是2^N。
将`k-exp`绑定到一个变量上避免重复。

```
if 0 then if 1 then (p x1) else (p y1) else if 2 then (p x2) else (p y2)
```

重复出现四次

```
if 0 then if 1 then (p x1 proc (var%1) var%1) else (p y1 proc (var%1) var%1) else if 2 then (p x2 proc (var%1) var%1) else (p y2 proc (var%1) var%1)
```

绑定到新变量`k%00`

```
let k%00 = proc (var%1) var%1
in if 0 then if 1 then (p x1 k%00) else (p y1 k%00) else if 2 then (p x2 k%00) else (p y2 k%00)
```
