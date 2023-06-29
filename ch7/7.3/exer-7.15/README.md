# Exercise 7.15

## Rules

```eopl
(letrec-exp vars exps body)
```

$$
\frac{
    (typeof \; exp1 \; tenv) = t_1
    \quad
    ...
    \quad
    (typeof \; expn \; tenv) = t_n
    \quad
    (typeof \; body \; [var_n=t_n]...[var_1=t_1]tenv) = t_{body}
    }{(typeof \; (letrec\textrm{-} exp \; vars \; exps \; body) \; tenv) = t_{body}}
$$

## Exercise 1

```eopl
letrec ? f(x: ?) = if zero?(x) then 0 else -((f -(x,1)), -2)
    in f
```

| Expression                                                        | Type Variable |
| ----------------------------------------------------------------- | ------------- |
| f                                                                 | $t_f$         |
| x                                                                 | $t_x$         |
| letrec ? f(x: ?) = if zero?(x) then 0 else -((f -(x,1)), -2) in f | $t_0$         |
| if zero?(x) then 0 else -((f -(x,1)), -2)                         | $t_1$         |
| zero?(x)                                                          | $t_2$         |
| -((f -(x,1)), -2)                                                 | $t_3$         |
| (f -(x,1))                                                        | $t_4$         |
| -(x,1)                                                            | $t_5$         |

| Expression                                                        | Equations                   |
| ----------------------------------------------------------------- | --------------------------- |
| letrec ? f(x: ?) = if zero?(x) then 0 else -((f -(x,1)), -2) in f | $t_f = t_x \rightarrow t_1$ |
|                                                                   | $t_0 = t_f$                 |
| if zero?(x) then 0 else -((f -(x,1)), -2)                         | $t_2 = bool$                |
|                                                                   | $t_1 = int$                 |
|                                                                   | $t_1 = t_3$                 |
| zero?(x)                                                          | $t_2 = bool$                |
|                                                                   | $t_x = int$                 |
| -((f -(x,1)), -2)                                                 | $t_3 = int$                 |
|                                                                   | $t_4 = int$                 |
| (f -(x,1))                                                        | $t_f = t_5 \rightarrow t_4$ |
| -(x,1)                                                            | $t_x = int$                 |
|                                                                   | $t_5 = int$                 |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_f = t_x \rightarrow t_1$ |               |
| $t_0 = t_f$                 |               |
| $t_2 = bool$                |               |
| $t_1 = int$                 |               |
| $t_1 = t_3$                 |               |
| $t_2 = bool$                |               |
| $t_x = int$                 |               |
| $t_3 = int$                 |               |
| $t_4 = int$                 |               |
| $t_f = t_5 \rightarrow t_4$ |               |
| $t_x = int$                 |               |
| $t_5 = int$                 |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow t_1$ |
| $t_0 = t_f$                 |                             |
| $t_2 = bool$                |                             |
| $t_1 = int$                 |                             |
| $t_1 = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow t_1$ |
| $t_0 = t_x \rightarrow t_1$ |                             |
| $t_2 = bool$                |                             |
| $t_1 = int$                 |                             |
| $t_1 = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow t_1$ |
|                             | $t_0 = t_x \rightarrow t_1$ |
| $t_2 = bool$                |                             |
| $t_1 = int$                 |                             |
| $t_1 = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow t_1$ |
|                             | $t_0 = t_x \rightarrow t_1$ |
|                             | $t_2 = bool$                |
| $t_1 = int$                 |                             |
| $t_1 = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow int$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
| $t_1 = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow int$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
| $int = t_3$                 |                             |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow int$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
|                             | $t_3 = int$                 |
| $t_2 = bool$                |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_x \rightarrow int$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
|                             | $t_3 = int$                 |
| $bool = bool$               |                             |
| $t_x = int$                 |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = int \rightarrow int$ |
|                             | $t_0 = int \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
|                             | $t_3 = int$                 |
|                             | $t_x = int$                 |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = int \rightarrow int$ |
|                             | $t_0 = int \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
|                             | $t_3 = int$                 |
|                             | $t_x = int$                 |
| $int = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = int \rightarrow int$ |
|                             | $t_0 = int \rightarrow int$ |
|                             | $t_2 = bool$                |
|                             | $t_1 = int$                 |
|                             | $t_3 = int$                 |
|                             | $t_x = int$                 |
| $int = int$                 |                             |
| $t_f = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                 |                             |
| $t_5 = int$                 |                             |

| Equations                                   | Substitutions               |
| ------------------------------------------- | --------------------------- |
|                                             | $t_f = int \rightarrow int$ |
|                                             | $t_0 = int \rightarrow int$ |
|                                             | $t_2 = bool$                |
|                                             | $t_1 = int$                 |
|                                             | $t_3 = int$                 |
|                                             | $t_x = int$                 |
| $int \rightarrow int = t_5 \rightarrow t_4$ |                             |
| $t_x = int$                                 |                             |
| $t_5 = int$                                 |                             |

| Equations    | Substitutions               |
| ------------ | --------------------------- |
|              | $t_f = int \rightarrow int$ |
|              | $t_0 = int \rightarrow int$ |
|              | $t_2 = bool$                |
|              | $t_1 = int$                 |
|              | $t_3 = int$                 |
|              | $t_x = int$                 |
| $int = t_5 $ |                             |
| $int = t_4$  |                             |
| $t_x = int$  |                             |
| $t_5 = int$  |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = int \rightarrow int$ |
|             | $t_0 = int \rightarrow int$ |
|             | $t_2 = bool$                |
|             | $t_1 = int$                 |
|             | $t_3 = int$                 |
|             | $t_x = int$                 |
|             | $t_5 = int$                 |
| $int = t_4$ |                             |
| $t_x = int$ |                             |
| $t_5 = int$ |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = int \rightarrow int$ |
|             | $t_0 = int \rightarrow int$ |
|             | $t_2 = bool$                |
|             | $t_1 = int$                 |
|             | $t_3 = int$                 |
|             | $t_x = int$                 |
|             | $t_5 = int$                 |
|             | $t_4 = int$                 |
| $t_x = int$ |                             |
| $t_5 = int$ |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = int \rightarrow int$ |
|             | $t_0 = int \rightarrow int$ |
|             | $t_2 = bool$                |
|             | $t_1 = int$                 |
|             | $t_3 = int$                 |
|             | $t_x = int$                 |
|             | $t_5 = int$                 |
|             | $t_4 = int$                 |
| $int = int$ |                             |
| $t_5 = int$ |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = int \rightarrow int$ |
|             | $t_0 = int \rightarrow int$ |
|             | $t_2 = bool$                |
|             | $t_1 = int$                 |
|             | $t_3 = int$                 |
|             | $t_x = int$                 |
|             | $t_5 = int$                 |
|             | $t_4 = int$                 |
| $t_5 = int$ |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = int \rightarrow int$ |
|             | $t_0 = int \rightarrow int$ |
|             | $t_2 = bool$                |
|             | $t_1 = int$                 |
|             | $t_3 = int$                 |
|             | $t_x = int$                 |
|             | $t_5 = int$                 |
|             | $t_4 = int$                 |
| $int = int$ |                             |

| Equations | Substitutions               |
| --------- | --------------------------- |
|           | $t_f = int \rightarrow int$ |
|           | $t_0 = int \rightarrow int$ |
|           | $t_2 = bool$                |
|           | $t_1 = int$                 |
|           | $t_3 = int$                 |
|           | $t_x = int$                 |
|           | $t_5 = int$                 |
|           | $t_4 = int$                 |

## Exercise 2

```eopl
letrec ? even (x1 : ?) = if zero?(x1) then 1 else (odd -(x1,1))
       ? odd (x2 : ?) = if zero?(x2) then 0 else (even -(x2,1))
    in (odd 13)
```

| Expression                              | Type Variable |
| --------------------------------------- | ------------- |
| even                                    | $t_even$      |
| x1                                      | $t_{x1}$      |
| if zero?(x1) then 1 else (odd -(x1,1))  | $t_1$         |
| zero?(x1)                               | $t_2$         |
| (odd -(x1,1))                           | $t_3$         |
| -(x1,1)                                 | $t_4$         |
| odd                                     | $t_{odd}$     |
| x2                                      | $t_{x2}$      |
| if zero?(x2) then 1 else (even -(x2,1)) | $t_5$         |
| zero?(x2)                               | $t_6$         |
| (even -(x2,1))                          | $t_7$         |
| -(x2,1)                                 | $t_8$         |

| Expression                              | Equations                        |
| --------------------------------------- | -------------------------------- |
| if zero?(x1) then 1 else (odd -(x1,1))  | $t_2 = bool$                     |
|                                         | $t_1 = int$                      |
|                                         | $t_1 = t_3$                      |
| zero?(x1)                               | $t_2 = bool$                     |
|                                         | $t_{x1} = int$                   |
| (odd -(x1,1))                           | $t_{odd} = t_4 \rightarrow t_3$  |
| -(x1,1)                                 | $t_4 = int$                      |
|                                         | $t_{x1} = int$                   |
| if zero?(x2) then 1 else (even -(x2,1)) | $t_6 = bool$                     |
|                                         | $t_5 = int$                      |
|                                         | $t_5 = t_7$                      |
| zero?(x2)                               | $t_6 = bool$                     |
|                                         | $t_{x2} = int$                   |
| (even -(x2,1))                          | $t_{even} = t_8 \rightarrow t_7$ |
| -(x2,1)                                 | $t_8 = int$                      |
|                                         | $t_{x2} = int$                   |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
| $t_2 = bool$                     |               |
| $t_1 = int$                      |               |
| $t_1 = t_3$                      |               |
| $t_2 = bool$                     |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
| $t_1 = int$                      |               |
| $t_1 = t_3$                      |               |
| $t_2 = bool$                     |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
|                                  | $t_1 = int$   |
| $t_1 = t_3$                      |               |
| $t_2 = bool$                     |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
|                                  | $t_1 = int$   |
| $int = t_3$                      |               |
| $t_2 = bool$                     |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
|                                  | $t_1 = int$   |
|                                  | $t_3 = int$   |
| $t_2 = bool$                     |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
|                                  | $t_1 = int$   |
|                                  | $t_3 = int$   |
| $bool = bool$                    |               |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions |
| -------------------------------- | ------------- |
|                                  | $t_2 = bool$  |
|                                  | $t_1 = int$   |
|                                  | $t_3 = int$   |
| $t_{x1} = int$                   |               |
| $t_{odd} = t_4 \rightarrow t_3$  |               |
| $t_4 = int$                      |               |
| $t_{x1} = int$                   |               |
| $t_6 = bool$                     |               |
| $t_5 = int$                      |               |
| $t_5 = t_7$                      |               |
| $t_6 = bool$                     |               |
| $t_{x2} = int$                   |               |
| $t_{even} = t_8 \rightarrow t_7$ |               |
| $t_8 = int$                      |               |
| $t_{x2} = int$                   |               |

| Equations                        | Substitutions  |
| -------------------------------- | -------------- |
|                                  | $t_2 = bool$   |
|                                  | $t_1 = int$    |
|                                  | $t_3 = int$    |
|                                  | $t_{x1} = int$ |
| $t_{odd} = t_4 \rightarrow t_3$  |                |
| $t_4 = int$                      |                |
| $t_{x1} = int$                   |                |
| $t_6 = bool$                     |                |
| $t_5 = int$                      |                |
| $t_5 = t_7$                      |                |
| $t_6 = bool$                     |                |
| $t_{x2} = int$                   |                |
| $t_{even} = t_8 \rightarrow t_7$ |                |
| $t_8 = int$                      |                |
| $t_{x2} = int$                   |                |

| Equations                        | Substitutions  |
| -------------------------------- | -------------- |
|                                  | $t_2 = bool$   |
|                                  | $t_1 = int$    |
|                                  | $t_3 = int$    |
|                                  | $t_{x1} = int$ |
| $t_{odd} = t_4 \rightarrow int$  |                |
| $t_4 = int$                      |                |
| $t_{x1} = int$                   |                |
| $t_6 = bool$                     |                |
| $t_5 = int$                      |                |
| $t_5 = t_7$                      |                |
| $t_6 = bool$                     |                |
| $t_{x2} = int$                   |                |
| $t_{even} = t_8 \rightarrow t_7$ |                |
| $t_8 = int$                      |                |
| $t_{x2} = int$                   |                |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = t_4 \rightarrow int$ |
| $t_4 = int$                      |                                 |
| $t_{x1} = int$                   |                                 |
| $t_6 = bool$                     |                                 |
| $t_5 = int$                      |                                 |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
| $t_{x1} = int$                   |                                 |
| $t_6 = bool$                     |                                 |
| $t_5 = int$                      |                                 |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
| $int = int$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_5 = int$                      |                                 |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
| $t_6 = bool$                     |                                 |
| $t_5 = int$                      |                                 |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
| $t_5 = int$                      |                                 |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
| $t_5 = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
| $int = t_7$                      |                                 |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
|                                  | $t_7 = int$                     |
| $t_6 = bool$                     |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
|                                  | $t_7 = int$                     |
| $bool = bool$                    |                                 |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
|                                  | $t_7 = int$                     |
| $t_{x2} = int$                   |                                 |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
|                                  | $t_7 = int$                     |
|                                  | $t_{x2} = int$                  |
| $t_{even} = t_8 \rightarrow t_7$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations                        | Substitutions                   |
| -------------------------------- | ------------------------------- |
|                                  | $t_2 = bool$                    |
|                                  | $t_1 = int$                     |
|                                  | $t_3 = int$                     |
|                                  | $t_{x1} = int$                  |
|                                  | $t_{odd} = int \rightarrow int$ |
|                                  | $t_4 = int$                     |
|                                  | $t_6 = bool$                    |
|                                  | $t_5 = int$                     |
|                                  | $t_7 = int$                     |
|                                  | $t_{x2} = int$                  |
| $t_{even} = t_8 \rightarrow int$ |                                 |
| $t_8 = int$                      |                                 |
| $t_{x2} = int$                   |                                 |

| Equations      | Substitutions                    |
| -------------- | -------------------------------- |
|                | $t_2 = bool$                     |
|                | $t_1 = int$                      |
|                | $t_3 = int$                      |
|                | $t_{x1} = int$                   |
|                | $t_{odd} = int \rightarrow int$  |
|                | $t_4 = int$                      |
|                | $t_6 = bool$                     |
|                | $t_5 = int$                      |
|                | $t_7 = int$                      |
|                | $t_{x2} = int$                   |
|                | $t_{even} = t_8 \rightarrow int$ |
| $t_8 = int$    |                                  |
| $t_{x2} = int$ |                                  |

| Equations      | Substitutions                    |
| -------------- | -------------------------------- |
|                | $t_2 = bool$                     |
|                | $t_1 = int$                      |
|                | $t_3 = int$                      |
|                | $t_{x1} = int$                   |
|                | $t_{odd} = int \rightarrow int$  |
|                | $t_4 = int$                      |
|                | $t_6 = bool$                     |
|                | $t_5 = int$                      |
|                | $t_7 = int$                      |
|                | $t_{x2} = int$                   |
|                | $t_{even} = int \rightarrow int$ |
|                | $t_8 = int$                      |
| $t_{x2} = int$ |                                  |

| Equations   | Substitutions                    |
| ----------- | -------------------------------- |
|             | $t_2 = bool$                     |
|             | $t_1 = int$                      |
|             | $t_3 = int$                      |
|             | $t_{x1} = int$                   |
|             | $t_{odd} = int \rightarrow int$  |
|             | $t_4 = int$                      |
|             | $t_6 = bool$                     |
|             | $t_5 = int$                      |
|             | $t_7 = int$                      |
|             | $t_{x2} = int$                   |
|             | $t_{even} = int \rightarrow int$ |
|             | $t_8 = int$                      |
| $int = int$ |                                  |

| Equations | Substitutions                    |
| --------- | -------------------------------- |
|           | $t_2 = bool$                     |
|           | $t_1 = int$                      |
|           | $t_3 = int$                      |
|           | $t_{x1} = int$                   |
|           | $t_{odd} = int \rightarrow int$  |
|           | $t_4 = int$                      |
|           | $t_6 = bool$                     |
|           | $t_5 = int$                      |
|           | $t_7 = int$                      |
|           | $t_{x2} = int$                   |
|           | $t_{even} = int \rightarrow int$ |
|           | $t_8 = int$                      |

## Exercise 3

```eopl
letrec ? even (odd : ?) = proc (x) if zero?(x) then 1 else (odd -(x,1))
    in letrec ? odd (x : ?) = if zero?(x) then 0 else ((even odd) -(x,1))
        in (odd 13)
```

$odd: int \rightarrow int$
$even: (int \rightarrow int) \rightarrow (int \rightarrow int)$
