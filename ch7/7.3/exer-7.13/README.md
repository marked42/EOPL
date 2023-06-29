# Exercise 7.13

## Rules

```eopl
let var = exp1 in body
```

$$
\frac{
    (typeof \; exp1 \; tenv) = t_1
    \quad
    (typeof \; body \; [var=t_1]tenv) = t_2
    }{(typeof \; (let\textrm{-} exp \; var \; exp1 \; body) \; tenv) = t_2}
$$

## Exercise 1

```eopl
let x = 4 in (x 3)
```

| Expression         | Type Variable |
| ------------------ | ------------- |
| x                  | $t_x$         |
| let x = 4 in (x 3) | $t_0$         |
| (x 3)              | $t_1$         |

| Expression         | Equations                  |
| ------------------ | -------------------------- |
| let x = 4 in (x 3) | $t_x = int$                |
|                    | $t_0 = t_1$                |
| (x 3)              | $t_x = int \rightarrow t1$ |

| Equations                  | Substitutions |
| -------------------------- | ------------- |
| $t_x = int$                |               |
| $t_0 = t_1$                |               |
| $t_x = int \rightarrow t1$ |               |

| Equations                  | Substitutions |
| -------------------------- | ------------- |
|                            | $t_x = int$   |
| $t_0 = t_1$                |               |
| $t_x = int \rightarrow t1$ |               |

| Equations                  | Substitutions |
| -------------------------- | ------------- |
|                            | $t_x = int$   |
|                            | $t_0 = t_1$   |
| $t_x = int \rightarrow t1$ |               |

| Equations                  | Substitutions |
| -------------------------- | ------------- |
|                            | $t_x = int$   |
|                            | $t_0 = t_1$   |
| $int = int \rightarrow t1$ |               |

$int = int \rightarrow t1$ cannot be true

## Exercise 2

```eopl
let f = proc(z) z in proc (x) -((f x), 1)
```

| Expression                                | Type Variable |
| ----------------------------------------- | ------------- |
| f                                         | $t_f$         |
| z                                         | $t_z$         |
| x                                         | $t_x$         |
| let f = proc(z) z in proc (x) -((f x), 1) | $t_0$         |
| proc(z) z                                 | $t_1$         |
| proc (x) -((f x), 1)                      | $t_2$         |
| -((f x), 1)                               | $t_3$         |
| (f x)                                     | $t_4$         |

| Expression                                | Equations                   |
| ----------------------------------------- | --------------------------- |
| let f = proc(z) z in proc (x) -((f x), 1) | $t_f = t_1$                 |
|                                           | $t_0 = t_2$                 |
| proc(z) z                                 | $t_1 = t_z \rightarrow t_z$ |
| proc (x) -((f x), 1)                      | $t_2 = t_x \rightarrow t_3$ |
| -((f x), 1)                               | $t_3 = int$                 |
|                                           | $t_4 = int$                 |
| (f x)                                     | $t_f = t_x \rightarrow t_4$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_f = t_1$                 |               |
| $t_0 = t_2$                 |               |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_2 = t_x \rightarrow t_3$ |               |
| $t_3 = int$                 |               |
| $t_4 = int$                 |               |
| $t_f = t_x \rightarrow t_4$ |               |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
|                             | $t_f = t_1$   |
| $t_0 = t_2$                 |               |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_2 = t_x \rightarrow t_3$ |               |
| $t_3 = int$                 |               |
| $t_4 = int$                 |               |
| $t_f = t_x \rightarrow t_4$ |               |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
|                             | $t_f = t_1$   |
|                             | $t_0 = t_2$   |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_2 = t_x \rightarrow t_3$ |               |
| $t_3 = int$                 |               |
| $t_4 = int$                 |               |
| $t_f = t_x \rightarrow t_4$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_z \rightarrow t_z$ |
|                             | $t_0 = t_2$                 |
|                             | $t_1 = t_z \rightarrow t_z$ |
| $t_2 = t_x \rightarrow t_3$ |                             |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_x \rightarrow t_4$ |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_z \rightarrow t_z$ |
|                             | $t_0 = t_x \rightarrow t_3$ |
|                             | $t_1 = t_z \rightarrow t_z$ |
|                             | $t_2 = t_x \rightarrow t_3$ |
| $t_3 = int$                 |                             |
| $t_4 = int$                 |                             |
| $t_f = t_x \rightarrow t_4$ |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_z \rightarrow t_z$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_1 = t_z \rightarrow t_z$ |
|                             | $t_2 = t_x \rightarrow int$ |
|                             | $t_3 = int$                 |
| $t_4 = int$                 |                             |
| $t_f = t_x \rightarrow t_4$ |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_f = t_z \rightarrow t_z$ |
|                             | $t_0 = t_x \rightarrow int$ |
|                             | $t_1 = t_z \rightarrow t_z$ |
|                             | $t_2 = t_x \rightarrow int$ |
|                             | $t_3 = int$                 |
|                             | $t_4 = int$                 |
| $t_f = t_x \rightarrow t_4$ |                             |

| Equations                                   | Substitutions               |
| ------------------------------------------- | --------------------------- |
|                                             | $t_f = t_z \rightarrow t_z$ |
|                                             | $t_0 = t_x \rightarrow int$ |
|                                             | $t_1 = t_z \rightarrow t_z$ |
|                                             | $t_2 = t_x \rightarrow int$ |
|                                             | $t_3 = int$                 |
|                                             | $t_4 = int$                 |
| $t_z \rightarrow t_z = t_x \rightarrow int$ |                             |

| Equations    | Substitutions               |
| ------------ | --------------------------- |
|              | $t_f = t_z \rightarrow t_z$ |
|              | $t_0 = t_x \rightarrow int$ |
|              | $t_1 = t_z \rightarrow t_z$ |
|              | $t_2 = t_x \rightarrow int$ |
|              | $t_3 = int$                 |
|              | $t_4 = int$                 |
| $t_z = t_x $ |                             |
| $t_z = int$  |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = t_x \rightarrow t_x$ |
|             | $t_0 = t_x \rightarrow int$ |
|             | $t_1 = t_x \rightarrow t_x$ |
|             | $t_2 = t_x \rightarrow int$ |
|             | $t_3 = int$                 |
|             | $t_4 = int$                 |
|             | $t_z = t_x $                |
| $t_z = int$ |                             |

| Equations   | Substitutions               |
| ----------- | --------------------------- |
|             | $t_f = t_x \rightarrow t_x$ |
|             | $t_0 = t_x \rightarrow int$ |
|             | $t_1 = t_x \rightarrow t_x$ |
|             | $t_2 = t_x \rightarrow int$ |
|             | $t_3 = int$                 |
|             | $t_4 = int$                 |
|             | $t_z = t_x$                 |
| $t_x = int$ |                             |

| Equations | Substitutions               |
| --------- | --------------------------- |
|           | $t_f = int \rightarrow int$ |
|           | $t_0 = int \rightarrow int$ |
|           | $t_1 = int \rightarrow int$ |
|           | $t_2 = int \rightarrow int$ |
|           | $t_3 = int$                 |
|           | $t_4 = int$                 |
|           | $t_z = int$                 |
|           | $t_x = int$                 |

## Exercise 3

```eopl
let p = zero?(1) in if p then 88 else 99
```

| Expression                               | Type Variable |
| ---------------------------------------- | ------------- |
| p                                        | $t_p$         |
| let p = zero?(1) in if p then 88 else 99 | $t_0$         |
| zero?(1)                                 | $t_1$         |
| if p then 88 else 99                     | $t_2$         |

| Expression                               | Equations    |
| ---------------------------------------- | ------------ |
| let p = zero?(1) in if p then 88 else 99 | $t_p = t_1$  |
|                                          | $t_0 = t_2$  |
| zero?(1)                                 | $t_1 = bool$ |
| if p then 88 else 99                     | $t_p = bool$ |
|                                          | $t_2 = int$  |
|                                          | $t_2 = int$  |

| Equations    | Substitutions |
| ------------ | ------------- |
| $t_p = t_1$  |               |
| $t_0 = t_2$  |               |
| $t_1 = bool$ |               |
| $t_p = bool$ |               |
| $t_2 = int$  |               |
| $t_2 = int$  |               |

| Equations    | Substitutions |
| ------------ | ------------- |
|              | $t_p = t_1$   |
| $t_0 = t_2$  |               |
| $t_1 = bool$ |               |
| $t_p = bool$ |               |
| $t_2 = int$  |               |
| $t_2 = int$  |               |

| Equations    | Substitutions |
| ------------ | ------------- |
|              | $t_p = t_1$   |
|              | $t_0 = t_2$   |
| $t_1 = bool$ |               |
| $t_p = bool$ |               |
| $t_2 = int$  |               |
| $t_2 = int$  |               |

| Equations    | Substitutions |
| ------------ | ------------- |
|              | $t_p = bool$  |
|              | $t_0 = t_2$   |
|              | $t_1 = bool$  |
| $t_p = bool$ |               |
| $t_2 = int$  |               |
| $t_2 = int$  |               |

| Equations     | Substitutions |
| ------------- | ------------- |
|               | $t_p = bool$  |
|               | $t_0 = t_2$   |
|               | $t_1 = bool$  |
| $bool = bool$ |               |
| $t_2 = int$   |               |
| $t_2 = int$   |               |

| Equations   | Substitutions |
| ----------- | ------------- |
|             | $t_p = bool$  |
|             | $t_0 = int$   |
|             | $t_1 = bool$  |
|             | $t_2 = int$   |
| $t_2 = int$ |               |

| Equations   | Substitutions |
| ----------- | ------------- |
|             | $t_p = bool$  |
|             | $t_0 = int$   |
|             | $t_1 = bool$  |
|             | $t_2 = int$   |
| $int = int$ |               |

| Equations | Substitutions |
| --------- | ------------- |
|           | $t_p = bool$  |
|           | $t_0 = int$   |
|           | $t_1 = bool$  |
|           | $t_2 = int$   |

## Exercise 4

```eopl
let p = proc(z) z in if p then 88 else 99
```

| Expression                                | Type Variable |
| ----------------------------------------- | ------------- |
| p                                         | $t_p$         |
| z                                         | $t_z$         |
| let p = proc(z) z in if p then 88 else 99 | $t_0$         |
| proc(z) z                                 | $t_1$         |
| if p then 88 else 99                      | $t_2$         |

| Expression                                | Equations                   |
| ----------------------------------------- | --------------------------- |
| let p = proc(z) z in if p then 88 else 99 | $t_p = t_1$                 |
|                                           | $t_0 = t_2$                 |
| proc(z) z                                 | $t_1 = t_z \rightarrow t_z$ |
| if p then 88 else 99                      | $t_p = bool$                |
|                                           | $t_2 = int$                 |
|                                           | $t_2 = int$                 |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_p = t_1$                 |               |
| $t_0 = t_2$                 |               |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_p = bool$                |               |
| $t_2 = int$                 |               |
| $t_2 = int$                 |               |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
|                             | $t_p = t_1$   |
| $t_0 = t_2$                 |               |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_p = bool$                |               |
| $t_2 = int$                 |               |
| $t_2 = int$                 |               |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
|                             | $t_p = t_1$   |
|                             | $t_0 = t_2$   |
| $t_1 = t_z \rightarrow t_z$ |               |
| $t_p = bool$                |               |
| $t_2 = int$                 |               |
| $t_2 = int$                 |               |

| Equations    | Substitutions               |
| ------------ | --------------------------- |
|              | $t_p = t_z \rightarrow t_z$ |
|              | $t_0 = t_2$                 |
|              | $t_1 = t_z \rightarrow t_z$ |
| $t_p = bool$ |                             |
| $t_2 = int$  |                             |
| $t_2 = int$  |                             |

| Equations                    | Substitutions               |
| ---------------------------- | --------------------------- |
|                              | $t_p = t_z \rightarrow t_z$ |
|                              | $t_0 = t_2$                 |
|                              | $t_1 = t_z \rightarrow t_z$ |
| $t_z \rightarrow t_z = bool$ |                             |
| $t_2 = int$                  |                             |
| $t_2 = int$                  |                             |

$t_z \rightarrow t_z = bool$ type error
