#### Exercise 1

| Expression       | Type Variable |
| ---------------- | ------------- |
| x                | $t_x$         |
| proc (x) -(x, 3) | $t_0$         |
| -(x, 3)          | $t_1$         |

| Expression       | Equations                  |
| ---------------- | -------------------------- |
| proc (x) -(x, 3) | $t_0= t_x \rightarrow t_1$ |
| -(x, 3)          | $t_1 = int$                |
|                  | $t_x = int$                |

| Equations                  | Substitution |
| -------------------------- | ------------ |
| $t_0= t_x \rightarrow t_1$ |              |
| $t_1 = int$                |              |
| $t_x = int$                |              |

| Equations   | Substitution               |
| ----------- | -------------------------- |
| $t_1 = int$ | $t_0= t_x \rightarrow t_1$ |
| $t_x = int$ |                            |

| Equations   | Substitution               |
| ----------- | -------------------------- |
| $t_1 = int$ | $t_0= t_x \rightarrow t_1$ |
| $t_x = int$ |                            |

| Equations   | Substitution               |
| ----------- | -------------------------- |
| $t_x = int$ | $t_0= t_x \rightarrow int$ |
|             | $t_1 = int$                |

| Equations | Substitution               |
| --------- | -------------------------- |
|           | $t_0= int \rightarrow int$ |
|           | $t_1 = int$                |
|           | $t_x = int$                |

#### Exercise 2

| Expression                    | Type Variable |
| ----------------------------- | ------------- |
| x                             | $t_x$         |
| f                             | $t_f$         |
| proc (f) proc (x) -((f x), 1) | $t_0$         |
| proc (x) -((f x), 1)          | $t_1$         |
| -((f x), 1)                   | $t_2$         |
| (f x)                         | $t_3$         |

| Expression                    | Equations                   |
| ----------------------------- | --------------------------- |
| proc (f) proc (x) -((f x), 1) | $t_0 = t_f \rightarrow t_1$ |
| proc (x) -((f x), 1)          | $t_1 = t_x \rightarrow t_2$ |
| -((f x), 1)                   | $t_2 = int $                |
|                               | $t_3 = int $                |
| (f x)                         | $t_f = t_x \rightarrow t_3$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_f \rightarrow t_1$ |               |
| $t_1 = t_x \rightarrow t_2$ |               |
| $t_2 = int $                |               |
| $t_3 = int $                |               |
| $t_f = t_x \rightarrow t_3$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_1 = t_x \rightarrow t_2$ | $t_0 = t_f \rightarrow t_1$ |
| $t_2 = int $                |                             |
| $t_3 = int $                |                             |
| $t_f = t_x \rightarrow t_3$ |                             |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
| $t_2 = int $                | $t_0 = t_f \rightarrow (t_x \rightarrow t_2)$ |
| $t_3 = int $                | $t_1 = t_x \rightarrow t_2$                   |
| $t_f = t_x \rightarrow t_3$ |                                               |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
| $t_3 = int $                | $t_0 = t_f \rightarrow (t_x \rightarrow int)$ |
| $t_f = t_x \rightarrow t_3$ | $t_1 = t_x \rightarrow int$                   |
|                             | $t_2 = int$                                   |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
| $t_f = t_x \rightarrow t_3$ | $t_0 = t_f \rightarrow (t_x \rightarrow int)$ |
|                             | $t_1 = t_x \rightarrow int$                   |
|                             | $t_2 = int$                                   |
|                             | $t_3 = int$                                   |

| Equations | Substitutions                                                   |
| --------- | --------------------------------------------------------------- |
|           | $t_0 = (t_x \rightarrow int) \rightarrow (t_x \rightarrow int)$ |
|           | $t_1 = t_x \rightarrow int$                                     |
|           | $t_2 = int$                                                     |
|           | $t_3 = int$                                                     |
|           | $t_f = t_x \rightarrow int$                                     |

#### Exercise 3

| Expression | Type Variable |
| ---------- | ------------- |
| x          | $t_x$         |
| proc (x) x | $t_0$         |

| Expression | Equations                   |
| ---------- | --------------------------- |
| proc (x) x | $t_0 = t_x \rightarrow t_x$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_x \rightarrow t_x$ |               |

| Equations | Substitutions               |
| --------- | --------------------------- |
|           | $t_0 = t_x \rightarrow t_x$ |

#### Exercise 4

| Expression              | Type Variable |
| ----------------------- | ------------- |
| x                       | $t_x$         |
| y                       | $t_y$         |
| proc (x) proc (y) (x y) | $t_0$         |
| proc (y) (x y)          | $t_1$         |
| (x y)                   | $t_2$         |

| Expression              | Equations                   |
| ----------------------- | --------------------------- |
| proc (x) proc (y) (x y) | $t_0 = t_x \rightarrow t_1$ |
| proc (y) (x y)          | $t_1 = t_y \rightarrow t_2$ |
| (x y)                   | $t_x = t_y \rightarrow t2 $ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_x \rightarrow t_1$ |               |
| $t_1 = t_y \rightarrow t_2$ |               |
| $t_x = t_y \rightarrow t_2$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_1 = t_y \rightarrow t_2$ | $t_0 = t_x \rightarrow t_1$ |
| $t_x = t_y \rightarrow t_2$ |                             |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
| $t_x = t_y \rightarrow t_2$ | $t_0 = t_x \rightarrow (t_y \rightarrow t_2)$ |
|                             | $t_1 = t_y \rightarrow t_2$                   |

| Equations | Substitutions                                                   |
| --------- | --------------------------------------------------------------- |
|           | $t_0 = (t_y \rightarrow t_2) \rightarrow (t_y \rightarrow t_2)$ |
|           | $t_1 = t_y \rightarrow t_2$                                     |
|           | $t_x = t_y \rightarrow t_2$                                     |

#### Exercise 5

| Expression     | Type Variable |
| -------------- | ------------- |
| x              | $t_x$         |
| proc (x) (x 3) | $t_0$         |
| (x 3)          | $t_1$         |

| Expression     | Equations                   |
| -------------- | --------------------------- |
| proc (x) (x 3) | $t_0 = t_x \rightarrow t_1$ |
| (x 3)          | $t_x = int \rightarrow t_1$ |

| Equations                   | Substitution |
| --------------------------- | ------------ |
| $t_0 = t_x \rightarrow t_1$ |              |
| $t_x = int \rightarrow t_1$ |              |

| Equations                   | Substitution                |
| --------------------------- | --------------------------- |
| $t_x = int \rightarrow t_1$ | $t_0 = t_x \rightarrow t_1$ |

| Equations | Substitution                                  |
| --------- | --------------------------------------------- |
|           | $t_0 = (int \rightarrow t_1) \rightarrow t_1$ |
|           | $t_x = int \rightarrow t_1$                   |

#### Exercise 6

| Expression     | Type Variable |
| -------------- | ------------- |
| x              | $t_x$         |
| proc (x) (x x) | $t_0$         |
| (x x)          | $t_1$         |

| Expression     | Equations                   |
| -------------- | --------------------------- |
| proc (x) (x x) | $t_0 = t_x \rightarrow t_1$ |
| (x x)          | $t_x = t_x \rightarrow t_1$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_x \rightarrow t_1$ |               |
| $t_x = t_x \rightarrow t_1$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_x = t_x \rightarrow t_1$ | $t_0 = t_x \rightarrow t_1$ |

| Equations | Substitutions                                 |
| --------- | --------------------------------------------- |
|           | $t_0 = (t_x \rightarrow t_1) \rightarrow t_1$ |
|           | $t_x = t_x \rightarrow t_1$                   |

break on-occurrence invariant

#### Exercise 7

| Expression                    | Type Variable |
| ----------------------------- | ------------- |
| x                             | $t_x$         |
| proc (x) if x then 88 else 99 | $t_0$         |
| if x then 88 else 99          | $t_1$         |

| Expression                    | Equations                    |
| ----------------------------- | ---------------------------- |
| proc (x) if x then 88 else 99 | $t_0 = t_x \rightarrow t_1 $ |
| if x then 88 else 99          | $t_x = bool $                |
|                               | $t_1 = int $                 |
|                               | $t_1 = int $                 |

| Expression                   | Equations |
| ---------------------------- | --------- |
| $t_0 = t_x \rightarrow t_1 $ |           |
| $t_x = bool $                |           |
| $t_1 = int $                 |           |
| $t_1 = int $                 |           |

| Equations                    | Substitutions |
| ---------------------------- | ------------- |
| $t_0 = t_x \rightarrow t_1 $ |               |
| $t_x = bool $                |               |
| $t_1 = int $                 |               |
| $t_1 = int $                 |               |

| Equations     | Substitutions                |
| ------------- | ---------------------------- |
| $t_x = bool $ | $t_0 = t_x \rightarrow t_1 $ |
| $t_1 = int $  |                              |
| $t_1 = int $  |                              |

| Equations    | Substitutions                 |
| ------------ | ----------------------------- |
| $t_1 = int $ | $t_0 = bool \rightarrow t_1 $ |
| $t_1 = int $ | $t_x = bool $                 |

| Equations    | Substitutions                 |
| ------------ | ----------------------------- |
| $t_1 = int $ | $t_0 = bool \rightarrow int $ |
|              | $t_x = bool $                 |
|              | $t_1 = int$                   |

| Equations | Substitutions                 |
| --------- | ----------------------------- |
|           | $t_0 = bool \rightarrow int $ |
|           | $t_x = bool $                 |
|           | $t_1 = int$                   |
|           | $t_1 = int$                   |

#### Exercise 8

| Expression                            | Type Variable |
| ------------------------------------- | ------------- |
| x                                     | $t_x$         |
| y                                     | $t_y$         |
| proc (x) proc (y) if x then y else 99 | $t_0$         |
| proc (y) if x then y else 99          | $t_1$         |
| if x then y else 99                   | $t_2$         |

| Expression                            | Equations                   |
| ------------------------------------- | --------------------------- |
| proc (x) proc (y) if x then y else 99 | $t_0 = t_y \rightarrow t_1$ |
| proc (y) if x then y else 99          | $t_1 = t_y \rightarrow t_2$ |
| if x then y else 99                   | $t_x = bool $               |
|                                       | $t_2 = t_y$                 |
|                                       | $t_2 = int$                 |

| Expression                  | Equations |
| --------------------------- | --------- |
| $t_0 = t_y \rightarrow t_1$ |           |
| $t_1 = t_y \rightarrow t_2$ |           |
| $t_x = bool $               |           |
| $t_2 = t_y$                 |           |
| $t_2 = int$                 |           |

| Equations     | Substitutions                                 |
| ------------- | --------------------------------------------- |
| $t_x = bool $ | $t_0 = t_y \rightarrow (t_y \rightarrow t_2)$ |
| $t_2 = t_y$   | $t_1 = t_y \rightarrow t_2$                   |
| $t_2 = int$   |                                               |

| Equations   | Substitutions                                 |
| ----------- | --------------------------------------------- |
| $t_2 = t_y$ | $t_0 = t_y \rightarrow (t_y \rightarrow t_2)$ |
| $t_2 = int$ | $t_1 = t_y \rightarrow t_2$                   |
|             | $t_x = bool $                                 |

| Equations   | Substitutions                                 |
| ----------- | --------------------------------------------- |
| $t_2 = int$ | $t_0 = t_y \rightarrow (t_y \rightarrow t_y)$ |
|             | $t_1 = t_y \rightarrow t_y$                   |
|             | $t_x = bool $                                 |
|             | $t_2 = t_y$                                   |

| Equations   | Substitutions                                 |
| ----------- | --------------------------------------------- |
| $t_y = int$ | $t_0 = t_y \rightarrow (t_y \rightarrow t_y)$ |
|             | $t_1 = t_y \rightarrow t_y$                   |
|             | $t_x = bool $                                 |
|             | $t_2 = t_y$                                   |

| Equations | Substitutions                                 |
| --------- | --------------------------------------------- |
|           | $t_0 = int \rightarrow (int \rightarrow int)$ |
|           | $t_1 = int \rightarrow int$                   |
|           | $t_x = bool $                                 |
|           | $t_2 = int$                                   |
|           | $t_y = int$                                   |

#### Exercise 9

| Expression                         | Type Variable |
| ---------------------------------- | ------------- |
| p                                  | $t_p$         |
| (proc (p) if p then 88 else 99 33) | $t_0$         |
| proc (p) if p then 88 else 99      | $t_1$         |
| if p then 88 else 99               | $t_2$         |

| Expression                         | Equations                   |
| ---------------------------------- | --------------------------- |
| (proc (p) if p then 88 else 99 33) | $t_1 = int \rightarrow t_0$ |
| proc (p) if p then 88 else 99      | $t_1 = t_p \rightarrow t_2$ |
| if p then 88 else 99               | $t_p = bool $               |
|                                    | $t_2 = int $                |
|                                    | $t_2 = int $                |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_1 = int \rightarrow t_0$ |               |
| $t_1 = t_p \rightarrow t_2$ |               |
| $t_p = bool $               |               |
| $t_2 = int $                |               |
| $t_2 = int $                |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_1 = t_p \rightarrow t_2$ | $t_1 = int \rightarrow t_0$ |
| $t_p = bool $               |                             |
| $t_2 = int $                |                             |
| $t_2 = int $                |                             |

| Equations                                   | Substitutions               |
| ------------------------------------------- | --------------------------- |
| $int \rightarrow t_0 = t_p \rightarrow t_2$ | $t_1 = int \rightarrow t_0$ |
| $t_p = bool $                               |                             |
| $t_2 = int $                                |                             |
| $t_2 = int $                                |                             |

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $ t_0 = t_2 $ | $t_1 = int \rightarrow t_0$ |
| $ t_p = int $ |                             |
| $t_p = bool $ |                             |
| $t_2 = int $  |                             |
| $t_2 = int $  |                             |

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $ t_p = int $ | $t_1 = int \rightarrow t_2$ |
| $t_p = bool $ | $ t_0 = t_2 $               |
| $t_2 = int $  |                             |
| $t_2 = int $  |                             |

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $t_p = bool $ | $t_1 = int \rightarrow t_2$ |
| $t_2 = int $  | $ t_0 = t_2 $               |
| $t_2 = int $  | $ t_p = int $               |

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $int = bool $ | $t_1 = int \rightarrow t_2$ |
| $t_2 = int $  | $ t_0 = t_2 $               |
| $t_2 = int $  | $ t_p = int $               |

`int = bool`, error, p should be bool, got number

#### Exercise 10

| Expression                                 | Type Variable |
| ------------------------------------------ | ------------- |
| p                                          | $t_p$         |
| z                                          | $t_z$         |
| (proc (p) if p then 88 else 88 proc (z) z) | $t_0$         |
| proc (p) if p then 88 else 88              | $t_1$         |
| if p then 88 else 88                       | $t_2$         |
| proc (z) z                                 | $t_3$         |

| Expression                                 | Equations                   |
| ------------------------------------------ | --------------------------- |
| (proc (p) if p then 88 else 88 proc (z) z) | $t_1 = t_3 \rightarrow t_0$ |
| proc (p) if p then 88 else 88              | $t_1 = t_p \rightarrow t_2$ |
| if p then 88 else 88                       | $t_p = bool$                |
|                                            | $t_2 = int$                 |
| proc (z) z                                 | $t_3 = t_z \rightarrow t_z$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_1 = t_3 \rightarrow t_0$ |               |
| $t_1 = t_p \rightarrow t_2$ |               |
| $t_p = bool$                |               |
| $t_2 = int$                 |               |
| $t_3 = t_z \rightarrow t_z$ |               |

| Equations                                   | Substitutions               |
| ------------------------------------------- | --------------------------- |
| $t_3 \rightarrow t_0 = t_p \rightarrow t_2$ | $t_1 = t_3 \rightarrow t_0$ |
| $t_p = bool$                                |                             |
| $t_2 = int$                                 |                             |
| $t_3 = t_z \rightarrow t_z$                 |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_3 = t_p $                | $t_1 = t_3 \rightarrow t_0$ |
| $t_0 = t_2$                 |                             |
| $t_p = bool$                |                             |
| $t_2 = int$                 |                             |
| $t_3 = t_z \rightarrow t_z$ |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_0 = t_2$                 | $t_1 = t_p \rightarrow t_0$ |
| $t_p = bool$                | $t_3 = t_p $                |
| $t_2 = int$                 |                             |
| $t_3 = t_z \rightarrow t_z$ |                             |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_p = bool$                | $t_1 = t_p \rightarrow t_2$ |
| $t_2 = int$                 | $t_3 = t_p $                |
| $t_3 = t_z \rightarrow t_z$ | $t_0 = t_2$                 |

| Equations                   | Substitutions                |
| --------------------------- | ---------------------------- |
| $t_2 = int$                 | $t_1 = bool \rightarrow t_2$ |
| $t_3 = t_z \rightarrow t_z$ | $t_3 = bool $                |
|                             | $t_0 = t_2$                  |
|                             | $t_p = bool$                 |

| Equations                   | Substitutions                |
| --------------------------- | ---------------------------- |
| $t_3 = t_z \rightarrow t_z$ | $t_1 = bool \rightarrow int$ |
|                             | $t_3 = bool $                |
|                             | $t_0 = int$                  |
|                             | $t_p = bool$                 |
|                             | $t_2 = int$                  |

| Equations                    | Substitutions                |
| ---------------------------- | ---------------------------- |
| $bool = t_z \rightarrow t_z$ | $t_1 = bool \rightarrow int$ |
|                              | $t_3 = bool $                |
|                              | $t_0 = int$                  |
|                              | $t_p = bool$                 |
|                              | $t_2 = int$                  |

error, p should be bool, got proc (z) z

#### Exercise 11

| Expression                                                                   | Type Variable |
| ---------------------------------------------------------------------------- | ------------- |
| f                                                                            | $t_f$         |
| g                                                                            | $t_g$         |
| p                                                                            | $t_p$         |
| x                                                                            | $t_x$         |
| proc (f) proc (g) proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1) | $t_0$         |
| proc (g) proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1)          | $t_1$         |
| proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1)                   | $t_2$         |
| proc (x) if (p (f x)) then (g 1) else -((f x), 1)                            | $t_3$         |
| if (p (f x)) then (g 1) else -((f x), 1)                                     | $t_4$         |
| (p (f x))                                                                    | $t_5$         |
| (f x)                                                                        | $t_6$         |
| (g 1)                                                                        | $t_7$         |
| -((f x), 1)                                                                  | $t_8$         |
| (f x)                                                                        | $t_9$         |

| Expression                                                                   | Equations                   |
| ---------------------------------------------------------------------------- | --------------------------- |
| proc (f) proc (g) proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1) | $t_0 = t_f \rightarrow t_1$ |
| proc (g) proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1)          | $t_1 = t_g \rightarrow t_2$ |
| proc (p) proc (x) if (p (f x)) then (g 1) else -((f x), 1)                   | $t_2 = t_p \rightarrow t_3$ |
| proc (x) if (p (f x)) then (g 1) else -((f x), 1)                            | $t_3 = t_x \rightarrow t_4$ |
| if (p (f x)) then (g 1) else -((f x), 1)                                     | $t_5 = bool$                |
|                                                                              | $t_4 = t_7$                 |
|                                                                              | $t_4 = t_8$                 |
| (p (f x))                                                                    | $t_p = t_6 \rightarrow t_5$ |
| (f x)                                                                        | $t_f = t_x \rightarrow t_6$ |
| (g 1)                                                                        | $t_g = int \rightarrow t_7$ |
| -((f x), 1)                                                                  | $t_8 = int$                 |
|                                                                              | $t_9 = int$                 |
| (f x)                                                                        | $t_f = t_x \rightarrow t_9$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_f \rightarrow t_1$ |               |
| $t_1 = t_g \rightarrow t_2$ |               |
| $t_2 = t_p \rightarrow t_3$ |               |
| $t_3 = t_x \rightarrow t_4$ |               |
| $t_5 = bool$                |               |
| $t_4 = t_7$                 |               |
| $t_4 = t_8$                 |               |
| $t_p = t_6 \rightarrow t_5$ |               |
| $t_f = t_x \rightarrow t_6$ |               |
| $t_g = int \rightarrow t_7$ |               |
| $t_8 = int$                 |               |
| $t_9 = int$                 |               |
| $t_f = t_x \rightarrow t_9$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_1 = t_g \rightarrow t_2$ | $t_0 = t_f \rightarrow t_1$ |
| $t_2 = t_p \rightarrow t_3$ |                             |
| $t_3 = t_x \rightarrow t_4$ |                             |
| $t_5 = bool$                |                             |
| $t_4 = t_7$                 |                             |
| $t_4 = t_8$                 |                             |
| $t_p = t_6 \rightarrow t_5$ |                             |
| $t_f = t_x \rightarrow t_6$ |                             |
| $t_g = int \rightarrow t_7$ |                             |
| $t_8 = int$                 |                             |
| $t_9 = int$                 |                             |
| $t_f = t_x \rightarrow t_9$ |                             |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow t_2)$ |
| $t_2 = t_p \rightarrow t_3$ | $t_1 = t_g \rightarrow t_2$                   |
| $t_3 = t_x \rightarrow t_4$ |                                               |
| $t_5 = bool$                |                                               |
| $t_4 = t_7$                 |                                               |
| $t_4 = t_8$                 |                                               |
| $t_p = t_6 \rightarrow t_5$ |                                               |
| $t_f = t_x \rightarrow t_6$ |                                               |
| $t_g = int \rightarrow t_7$ |                                               |
| $t_8 = int$                 |                                               |
| $t_9 = int$                 |                                               |
| $t_f = t_x \rightarrow t_9$ |                                               |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow t_3))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow t_3)$                   |
| $t_3 = t_x \rightarrow t_4$ | $t_2 = t_p \rightarrow t_3$                                     |
| $t_5 = bool$                |                                                                 |
| $t_4 = t_7$                 |                                                                 |
| $t_4 = t_8$                 |                                                                 |
| $t_p = t_6 \rightarrow t_5$ |                                                                 |
| $t_f = t_x \rightarrow t_6$ |                                                                 |
| $t_g = int \rightarrow t_7$ |                                                                 |
| $t_8 = int$                 |                                                                 |
| $t_9 = int$                 |                                                                 |
| $t_f = t_x \rightarrow t_9$ |                                                                 |

| Equations                   | Substitutions                                                                     |
| --------------------------- | --------------------------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_4)))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_4))$                   |
|                             | $t_2 = t_p \rightarrow (t_x \rightarrow t_4)$                                     |
| $t_5 = bool$                | $t_3 = t_x \rightarrow t_4$                                                       |
| $t_4 = t_7$                 |                                                                                   |
| $t_4 = t_8$                 |                                                                                   |
| $t_p = t_6 \rightarrow t_5$ |                                                                                   |
| $t_f = t_x \rightarrow t_6$ |                                                                                   |
| $t_g = int \rightarrow t_7$ |                                                                                   |
| $t_8 = int$                 |                                                                                   |
| $t_9 = int$                 |                                                                                   |
| $t_f = t_x \rightarrow t_9$ |                                                                                   |

| Equations                   | Substitutions                                                                     |
| --------------------------- | --------------------------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_4)))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_4))$                   |
|                             | $t_2 = t_p \rightarrow (t_x \rightarrow t_4)$                                     |
|                             | $t_3 = t_x \rightarrow t_4$                                                       |
| $t_4 = t_7$                 | $t_5 = bool$                                                                      |
| $t_4 = t_8$                 |                                                                                   |
| $t_p = t_6 \rightarrow t_5$ |                                                                                   |
| $t_f = t_x \rightarrow t_6$ |                                                                                   |
| $t_g = int \rightarrow t_7$ |                                                                                   |
| $t_8 = int$                 |                                                                                   |
| $t_9 = int$                 |                                                                                   |
| $t_f = t_x \rightarrow t_9$ |                                                                                   |

| Equations                   | Substitutions                                                                     |
| --------------------------- | --------------------------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_7)))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_7))$                   |
|                             | $t_2 = t_p \rightarrow (t_x \rightarrow t_7)$                                     |
|                             | $t_3 = t_x \rightarrow t_7$                                                       |
|                             | $t_5 = bool$                                                                      |
| $t_4 = t_8$                 | $t_4 = t_7$                                                                       |
| $t_p = t_6 \rightarrow t_5$ |                                                                                   |
| $t_f = t_x \rightarrow t_6$ |                                                                                   |
| $t_g = int \rightarrow t_7$ |                                                                                   |
| $t_8 = int$                 |                                                                                   |
| $t_9 = int$                 |                                                                                   |
| $t_f = t_x \rightarrow t_9$ |                                                                                   |

| Equations                   | Substitutions                                                                     |
| --------------------------- | --------------------------------------------------------------------------------- |
| $t_7 = t_8$                 | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_7)))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_7))$                   |
|                             | $t_2 = t_p \rightarrow (t_x \rightarrow t_7)$                                     |
|                             | $t_3 = t_x \rightarrow t_7$                                                       |
|                             | $t_5 = bool$                                                                      |
|                             | $t_4 = t_7$                                                                       |
| $t_p = t_6 \rightarrow t_5$ |                                                                                   |
| $t_f = t_x \rightarrow t_6$ |                                                                                   |
| $t_g = int \rightarrow t_7$ |                                                                                   |
| $t_8 = int$                 |                                                                                   |
| $t_9 = int$                 |                                                                                   |
| $t_f = t_x \rightarrow t_9$ |                                                                                   |

| Equations                   | Substitutions                                                                     |
| --------------------------- | --------------------------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_8)))$ |
|                             | $t_1 = t_g \rightarrow (t_p \rightarrow (t_x \rightarrow t_8))$                   |
|                             | $t_2 = t_p \rightarrow (t_x \rightarrow t_8)$                                     |
|                             | $t_3 = t_x \rightarrow t_8$                                                       |
|                             | $t_5 = bool$                                                                      |
|                             | $t_4 = t_8$                                                                       |
| $t_p = t_6 \rightarrow t_5$ | $t_7 = t_8$                                                                       |
| $t_f = t_x \rightarrow t_6$ |                                                                                   |
| $t_g = int \rightarrow t_7$ |                                                                                   |
| $t_8 = int$                 |                                                                                   |
| $t_9 = int$                 |                                                                                   |
| $t_f = t_x \rightarrow t_9$ |                                                                                   |

| Equations                   | Substitutions                                                                                        |
| --------------------------- | ---------------------------------------------------------------------------------------------------- |
|                             | $t_0 = t_f \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)))$ |
|                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8))$                   |
|                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)$                                     |
|                             | $t_3 = t_x \rightarrow t_8$                                                                          |
|                             | $t_5 = bool$                                                                                         |
|                             | $t_4 = t_8$                                                                                          |
|                             | $t_7 = t_8$                                                                                          |
| $t_f = t_x \rightarrow t_6$ | $t_p = t_6 \rightarrow bool$                                                                         |
| $t_g = int \rightarrow t_7$ |                                                                                                      |
| $t_8 = int$                 |                                                                                                      |
| $t_9 = int$                 |                                                                                                      |
| $t_f = t_x \rightarrow t_9$ |                                                                                                      |

| Equations                   | Substitutions                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| $t_g = int \rightarrow t_8$ | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)))$ |
|                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8))$                                     |
|                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)$                                                       |
|                             | $t_3 = t_x \rightarrow t_8$                                                                                            |
|                             | $t_5 = bool$                                                                                                           |
|                             | $t_4 = t_8$                                                                                                            |
|                             | $t_7 = t_8$                                                                                                            |
|                             | $t_p = t_6 \rightarrow bool$                                                                                           |
|                             | $t_f = t_x \rightarrow t_6$                                                                                            |
|                             |                                                                                                                        |
| $t_8 = int$                 |                                                                                                                        |
| $t_9 = int$                 |                                                                                                                        |
| $t_f = t_x \rightarrow t_9$ |                                                                                                                        |

| Equations                   | Substitutions                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
|                             | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)))$ |
|                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8))$                                     |
|                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow t_8)$                                                       |
|                             | $t_3 = t_x \rightarrow t_8$                                                                                            |
|                             | $t_5 = bool$                                                                                                           |
|                             | $t_4 = t_8$                                                                                                            |
|                             | $t_7 = t_8$                                                                                                            |
|                             | $t_p = t_6 \rightarrow bool$                                                                                           |
|                             | $t_f = t_x \rightarrow t_6$                                                                                            |
|                             | $t_g = int \rightarrow t_8$                                                                                            |
| $t_8 = int$                 |                                                                                                                        |
| $t_9 = int$                 |                                                                                                                        |
| $t_f = t_x \rightarrow t_9$ |                                                                                                                        |

| Equations                   | Substitutions                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
|                             | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)))$ |
|                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int))$                                     |
|                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)$                                                       |
|                             | $t_3 = t_x \rightarrow int$                                                                                            |
|                             | $t_5 = bool$                                                                                                           |
|                             | $t_4 = int$                                                                                                            |
|                             | $t_7 = int$                                                                                                            |
|                             | $t_p = t_6 \rightarrow bool$                                                                                           |
|                             | $t_f = t_x \rightarrow t_6$                                                                                            |
|                             | $t_g = int \rightarrow int$                                                                                            |
|                             | $t_8 = int$                                                                                                            |
| $t_9 = int$                 |                                                                                                                        |
| $t_f = t_x \rightarrow t_9$ |                                                                                                                        |

| Equations                   | Substitutions                                                                                                          |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
|                             | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)))$ |
|                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int))$                                     |
|                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)$                                                       |
|                             | $t_3 = t_x \rightarrow int$                                                                                            |
|                             | $t_5 = bool$                                                                                                           |
|                             | $t_4 = int$                                                                                                            |
|                             | $t_7 = int$                                                                                                            |
|                             | $t_p = t_6 \rightarrow bool$                                                                                           |
|                             | $t_f = t_x \rightarrow t_6$                                                                                            |
|                             | $t_g = int \rightarrow int$                                                                                            |
|                             | $t_8 = int$                                                                                                            |
|                             | $t_9 = int$                                                                                                            |
| $t_f = t_x \rightarrow t_9$ |                                                                                                                        |

| Equations                                   | Substitutions                                                                                                          |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| $t_x \rightarrow t_6 = t_x \rightarrow int$ | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)))$ |
|                                             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int))$                                     |
|                                             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)$                                                       |
|                                             | $t_3 = t_x \rightarrow int$                                                                                            |
|                                             | $t_5 = bool$                                                                                                           |
|                                             | $t_4 = int$                                                                                                            |
|                                             | $t_7 = int$                                                                                                            |
|                                             | $t_p = t_6 \rightarrow bool$                                                                                           |
|                                             | $t_f = t_x \rightarrow t_6$                                                                                            |
|                                             | $t_g = int \rightarrow int$                                                                                            |
|                                             | $t_8 = int$                                                                                                            |
|                                             | $t_9 = int$                                                                                                            |

| Equations   | Substitutions                                                                                                          |
| ----------- | ---------------------------------------------------------------------------------------------------------------------- |
| $t_6 = int$ | $t_0 = (t_x \rightarrow t_6) \rightarrow (t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)))$ |
|             | $t_1 = t_g \rightarrow ((t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int))$                                     |
|             | $t_2 = (t_6 \rightarrow bool) \rightarrow (t_x \rightarrow int)$                                                       |
|             | $t_3 = t_x \rightarrow int$                                                                                            |
|             | $t_5 = bool$                                                                                                           |
|             | $t_4 = int$                                                                                                            |
|             | $t_7 = int$                                                                                                            |
|             | $t_p = t_6 \rightarrow bool$                                                                                           |
|             | $t_f = t_x \rightarrow t_6$                                                                                            |
|             | $t_g = int \rightarrow int$                                                                                            |
|             | $t_8 = int$                                                                                                            |
|             | $t_9 = int$                                                                                                            |

| Equations | Substitutions                                                                                                          |
| --------- | ---------------------------------------------------------------------------------------------------------------------- |
|           | $t_0 = (t_x \rightarrow int) \rightarrow (t_g \rightarrow ((int \rightarrow bool) \rightarrow (t_x \rightarrow int)))$ |
|           | $t_1 = t_g \rightarrow ((int \rightarrow bool) \rightarrow (t_x \rightarrow int))$                                     |
|           | $t_2 = (int \rightarrow bool) \rightarrow (t_x \rightarrow int)$                                                       |
|           | $t_3 = t_x \rightarrow int$                                                                                            |
|           | $t_5 = bool$                                                                                                           |
|           | $t_4 = int$                                                                                                            |
|           | $t_7 = int$                                                                                                            |
|           | $t_p = int \rightarrow bool$                                                                                           |
|           | $t_f = t_x \rightarrow int$                                                                                            |
|           | $t_g = int \rightarrow int$                                                                                            |
|           | $t_8 = int$                                                                                                            |
|           | $t_9 = int$                                                                                                            |
|           | $t_6 = int$                                                                                                            |

#### Exercise 12

| Expression                                                  | Type Variable |
| ----------------------------------------------------------- | ------------- |
| x                                                           | $t_x$         |
| p                                                           | $t_p$         |
| f                                                           | $t_f$         |
| proc (x) proc (p) proc (f) if (p x) then -(x, 1) else (f p) | $t_0$         |
| proc (p) proc (f) if (p x) then -(x, 1) else (f p)          | $t_1$         |
| proc (f) if (p x) then -(x, 1) else (f p)                   | $t_2$         |
| if (p x) then -(x, 1) else (f p)                            | $t_3$         |
| (p x)                                                       | $t_4$         |
| -(x, 1)                                                     | $t_5$         |
| (f p)                                                       | $t_6$         |

| Expression                                                  | Equations                   |
| ----------------------------------------------------------- | --------------------------- |
| proc (x) proc (p) proc (f) if (p x) then -(x, 1) else (f p) | $t_0 = t_x \rightarrow t_1$ |
| proc (p) proc (f) if (p x) then -(x, 1) else (f p)          | $t_1 = t_p \rightarrow t_2$ |
| proc (f) if (p x) then -(x, 1) else (f p)                   | $t_2 = t_f \rightarrow t_3$ |
| if (p x) then -(x, 1) else (f p)                            | $t_4 = bool$                |
|                                                             | $t_3 = t_5$                 |
|                                                             | $t_3 = t_6$                 |
| (p x)                                                       | $t_p = t_x \rightarrow t_4$ |
| -(x, 1)                                                     | $t_5 = int$                 |
|                                                             | $t_x = int$                 |
| (f p)                                                       | $t_f = t_p \rightarrow t_6$ |

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_0 = t_x \rightarrow t_1$ |               |
| $t_1 = t_p \rightarrow t_2$ |               |
| $t_2 = t_f \rightarrow t_3$ |               |
| $t_4 = bool$                |               |
| $t_3 = t_5$                 |               |
| $t_3 = t_6$                 |               |
| $t_p = t_x \rightarrow t_4$ |               |
| $t_5 = int$                 |               |
| $t_x = int$                 |               |
| $t_f = t_p \rightarrow t_6$ |               |

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
|                             | $t_0 = t_x \rightarrow t_1$ |
| $t_1 = t_p \rightarrow t_2$ |                             |
| $t_2 = t_f \rightarrow t_3$ |                             |
| $t_4 = bool$                |                             |
| $t_3 = t_5$                 |                             |
| $t_3 = t_6$                 |                             |
| $t_p = t_x \rightarrow t_4$ |                             |
| $t_5 = int$                 |                             |
| $t_x = int$                 |                             |
| $t_f = t_p \rightarrow t_6$ |                             |

| Equations                   | Substitutions                                 |
| --------------------------- | --------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow t_2)$ |
|                             | $t_1 = t_p \rightarrow t_2$                   |
| $t_2 = t_f \rightarrow t_3$ |                                               |
| $t_4 = bool$                |                                               |
| $t_3 = t_5$                 |                                               |
| $t_3 = t_6$                 |                                               |
| $t_p = t_x \rightarrow t_4$ |                                               |
| $t_5 = int$                 |                                               |
| $t_x = int$                 |                                               |
| $t_f = t_p \rightarrow t_6$ |                                               |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_3))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_3)$                   |
|                             | $t_2 = t_f \rightarrow t_3$                                     |
| $t_4 = bool$                |                                                                 |
| $t_3 = t_5$                 |                                                                 |
| $t_3 = t_6$                 |                                                                 |
| $t_p = t_x \rightarrow t_4$ |                                                                 |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_3))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_3)$                   |
|                             | $t_2 = t_f \rightarrow t_3$                                     |
|                             | $t_4 = bool$                                                    |
| $t_3 = t_5$                 |                                                                 |
| $t_3 = t_6$                 |                                                                 |
| $t_p = t_x \rightarrow t_4$ |                                                                 |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_3))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_3)$                   |
|                             | $t_2 = t_f \rightarrow t_3$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = t_5$                                                     |
| $t_3 = t_6$                 |                                                                 |
| $t_p = t_x \rightarrow t_4$ |                                                                 |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
| $t_5 = t_6$                 | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_5))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_5)$                   |
|                             | $t_2 = t_f \rightarrow t_5$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = t_5$                                                     |
| $t_p = t_x \rightarrow t_4$ |                                                                 |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_6))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_6)$                   |
|                             | $t_2 = t_f \rightarrow t_6$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = t_6$                                                     |
|                             | $t_5 = t_6$                                                     |
| $t_p = t_x \rightarrow t_4$ |                                                                 |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                    | Substitutions                                                   |
| ---------------------------- | --------------------------------------------------------------- |
| $t_p = t_x \rightarrow bool$ | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_6))$ |
|                              | $t_1 = t_p \rightarrow (t_f \rightarrow t_6)$                   |
|                              | $t_2 = t_f \rightarrow t_6$                                     |
|                              | $t_4 = bool$                                                    |
|                              | $t_3 = t_6$                                                     |
|                              | $t_5 = t_6$                                                     |
|                              |                                                                 |
| $t_5 = int$                  |                                                                 |
| $t_x = int$                  |                                                                 |
| $t_f = t_p \rightarrow t_6$  |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_6))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_6)$                   |
|                             | $t_2 = t_f \rightarrow t_6$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = t_6$                                                     |
|                             | $t_5 = t_6$                                                     |
|                             | $t_p = t_x \rightarrow bool$                                    |
| $t_5 = int$                 |                                                                 |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
| $t_6 = int$                 | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow t_6))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow t_6)$                   |
|                             | $t_2 = t_f \rightarrow t_6$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = t_6$                                                     |
|                             | $t_5 = t_6$                                                     |
|                             | $t_p = t_x \rightarrow bool$                                    |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = t_x \rightarrow (t_p \rightarrow (t_f \rightarrow int))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow int)$                   |
|                             | $t_2 = t_f \rightarrow int$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = int$                                                     |
|                             | $t_5 = int$                                                     |
|                             | $t_p = t_x \rightarrow bool$                                    |
|                             | $t_6 = int$                                                     |
| $t_x = int$                 |                                                                 |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations                   | Substitutions                                                   |
| --------------------------- | --------------------------------------------------------------- |
|                             | $t_0 = int \rightarrow (t_p \rightarrow (t_f \rightarrow int))$ |
|                             | $t_1 = t_p \rightarrow (t_f \rightarrow int)$                   |
|                             | $t_2 = t_f \rightarrow int$                                     |
|                             | $t_4 = bool$                                                    |
|                             | $t_3 = int$                                                     |
|                             | $t_5 = int$                                                     |
|                             | $t_p = int \rightarrow bool$                                    |
|                             | $t_6 = int$                                                     |
|                             | $t_x = int$                                                     |
| $t_f = t_p \rightarrow t_6$ |                                                                 |

| Equations | Substitutions                                                   |
| --------- | --------------------------------------------------------------- |
|           | $t_0 = int \rightarrow (t_p \rightarrow (t_f \rightarrow int))$ |
|           | $t_1 = t_p \rightarrow (t_f \rightarrow int)$                   |
|           | $t_2 = t_f \rightarrow int$                                     |
|           | $t_4 = bool$                                                    |
|           | $t_3 = int$                                                     |
|           | $t_5 = int$                                                     |
|           | $t_p = int \rightarrow bool$                                    |
|           | $t_6 = int$                                                     |
|           | $t_x = int$                                                     |
|           | $t_f = (int \rightarrow bool) \rightarrow int$                  |

#### Exercise 13

| Expression                                                                 | Type Variable |
| -------------------------------------------------------------------------- | ------------- |
| f                                                                          | $t_f$         |
| d                                                                          | $t_d$         |
| x                                                                          | $t_x$         |
| z                                                                          | $t_z$         |
| n                                                                          | $t_n$         |
| proc (f) let d = proc (x) proc (z) ((f (x x)) z) in proc (n) ((f (d d)) n) | $t_0$         |
| let d = proc (x) proc (z) ((f (x x)) z) in proc (n) ((f (d d)) n)          | $t_1$         |
| proc (x) proc (z) ((f (x x)) z)                                            | $t_2$         |
| proc (z) ((f (x x)) z)                                                     | $t_3$         |
| ((f (x x)) z)                                                              | $t_4$         |
| (f (x x))                                                                  | $t_5$         |
| (x x)                                                                      | $t_6$         |
| proc (n) ((f (d d)) n)                                                     | $t_7$         |
| ((f (d d)) n)                                                              | $t_8$         |
| (f (d d))                                                                  | $t_9$         |
| (d d)                                                                      | $t_{10}$      |

| Expression                                                                 | Equations                      |
| -------------------------------------------------------------------------- | ------------------------------ |
| proc (f) let d = proc (x) proc (z) ((f (x x)) z) in proc (n) ((f (d d)) n) | $t_0 = t_f \rightarrow t_1$    |
| let d = proc (x) proc (z) ((f (x x)) z) in proc (n) ((f (d d)) n)          | $t_d = t_2$                    |
|                                                                            | $t_1 = t_7$                    |
| proc (x) proc (z) ((f (x x)) z)                                            | $t_2 = t_x \rightarrow t_3$    |
| proc (z) ((f (x x)) z)                                                     | $t_3 = t_z \rightarrow t_4$    |
| ((f (x x)) z)                                                              | $t_5 = t_z \rightarrow t_4$    |
| (f (x x))                                                                  | $t_f = t_6 \rightarrow t_5$    |
| (x x)                                                                      | $t_x = t_x \rightarrow t_6$    |
| proc (n) ((f (d d)) n)                                                     | $t_7 = t_n \rightarrow t_8$    |
| ((f (d d)) n)                                                              | $t_9 = t_n \rightarrow t_8$    |
| (f (d d))                                                                  | $t_f = t_{10} \rightarrow t_9$ |
| (d d)                                                                      | $t_d = t_d \rightarrow t_{10}$ |

| Equations                      | Substitutions |
| ------------------------------ | ------------- |
| $t_0 = t_f \rightarrow t_1$    |               |
| $t_d = t_2$                    |               |
| $t_1 = t_7$                    |               |
| $t_2 = t_x \rightarrow t_3$    |               |
| $t_3 = t_z \rightarrow t_4$    |               |
| $t_5 = t_z \rightarrow t_4$    |               |
| $t_f = t_6 \rightarrow t_5$    |               |
| $t_x = t_x \rightarrow t_6$    |               |
| $t_7 = t_n \rightarrow t_8$    |               |
| $t_9 = t_n \rightarrow t_8$    |               |
| $t_f = t_{10} \rightarrow t_9$ |               |
| $t_d = t_d \rightarrow t_{10}$ |               |

| Equations                      | Substitutions               |
| ------------------------------ | --------------------------- |
|                                | $t_0 = t_f \rightarrow t_1$ |
| $t_d = t_2$                    |                             |
| $t_1 = t_7$                    |                             |
| $t_2 = t_x \rightarrow t_3$    |                             |
| $t_3 = t_z \rightarrow t_4$    |                             |
| $t_5 = t_z \rightarrow t_4$    |                             |
| $t_f = t_6 \rightarrow t_5$    |                             |
| $t_x = t_x \rightarrow t_6$    |                             |
| $t_7 = t_n \rightarrow t_8$    |                             |
| $t_9 = t_n \rightarrow t_8$    |                             |
| $t_f = t_{10} \rightarrow t_9$ |                             |
| $t_d = t_d \rightarrow t_{10}$ |                             |

| Equations                      | Substitutions               |
| ------------------------------ | --------------------------- |
|                                | $t_0 = t_f \rightarrow t_1$ |
|                                | $t_d = t_2$                 |
| $t_1 = t_7$                    |                             |
| $t_2 = t_x \rightarrow t_3$    |                             |
| $t_3 = t_z \rightarrow t_4$    |                             |
| $t_5 = t_z \rightarrow t_4$    |                             |
| $t_f = t_6 \rightarrow t_5$    |                             |
| $t_x = t_x \rightarrow t_6$    |                             |
| $t_7 = t_n \rightarrow t_8$    |                             |
| $t_9 = t_n \rightarrow t_8$    |                             |
| $t_f = t_{10} \rightarrow t_9$ |                             |
| $t_d = t_d \rightarrow t_{10}$ |                             |

| Equations                      | Substitutions               |
| ------------------------------ | --------------------------- |
|                                | $t_0 = t_f \rightarrow t_7$ |
|                                | $t_d = t_2$                 |
|                                | $t_1 = t_7$                 |
| $t_2 = t_x \rightarrow t_3$    |                             |
| $t_3 = t_z \rightarrow t_4$    |                             |
| $t_5 = t_z \rightarrow t_4$    |                             |
| $t_f = t_6 \rightarrow t_5$    |                             |
| $t_x = t_x \rightarrow t_6$    |                             |
| $t_7 = t_n \rightarrow t_8$    |                             |
| $t_9 = t_n \rightarrow t_8$    |                             |
| $t_f = t_{10} \rightarrow t_9$ |                             |
| $t_d = t_d \rightarrow t_{10}$ |                             |

| Equations                      | Substitutions                 |
| ------------------------------ | ----------------------------- |
|                                | $t_0 = t_f \rightarrow t_7$   |
|                                | $t_d = (t_x \rightarrow t_3)$ |
|                                | $t_1 = t_7$                   |
|                                | $t_2 = t_x \rightarrow t_3$   |
| $t_3 = t_z \rightarrow t_4$    |                               |
| $t_5 = t_z \rightarrow t_4$    |                               |
| $t_f = t_6 \rightarrow t_5$    |                               |
| $t_x = t_x \rightarrow t_6$    |                               |
| $t_7 = t_n \rightarrow t_8$    |                               |
| $t_9 = t_n \rightarrow t_8$    |                               |
| $t_f = t_{10} \rightarrow t_9$ |                               |
| $t_d = t_d \rightarrow t_{10}$ |                               |

| Equations                      | Substitutions                                   |
| ------------------------------ | ----------------------------------------------- |
|                                | $t_0 = t_f \rightarrow t_7$                     |
|                                | $t_d = (t_x \rightarrow (t_z \rightarrow t_4))$ |
|                                | $t_1 = t_7$                                     |
|                                | $t_2 = t_x \rightarrow (t_z \rightarrow t_4)$   |
|                                | $t_3 = t_z \rightarrow t_4$                     |
| $t_5 = t_z \rightarrow t_4$    |                                                 |
| $t_f = t_6 \rightarrow t_5$    |                                                 |
| $t_x = t_x \rightarrow t_6$    |                                                 |
| $t_7 = t_n \rightarrow t_8$    |                                                 |
| $t_9 = t_n \rightarrow t_8$    |                                                 |
| $t_f = t_{10} \rightarrow t_9$ |                                                 |
| $t_d = t_d \rightarrow t_{10}$ |                                                 |

| Equations                      | Substitutions                                   |
| ------------------------------ | ----------------------------------------------- |
|                                | $t_0 = t_f \rightarrow t_7$                     |
|                                | $t_d = (t_x \rightarrow (t_z \rightarrow t_4))$ |
|                                | $t_1 = t_7$                                     |
|                                | $t_2 = t_x \rightarrow (t_z \rightarrow t_4)$   |
|                                | $t_3 = t_z \rightarrow t_4$                     |
|                                | $t_5 = t_z \rightarrow t_4$                     |
| $t_f = t_6 \rightarrow t_5$    |                                                 |
| $t_x = t_x \rightarrow t_6$    |                                                 |
| $t_7 = t_n \rightarrow t_8$    |                                                 |
| $t_9 = t_n \rightarrow t_8$    |                                                 |
| $t_f = t_{10} \rightarrow t_9$ |                                                 |
| $t_d = t_d \rightarrow t_{10}$ |                                                 |

| Equations                      | Substitutions                                                   |
| ------------------------------ | --------------------------------------------------------------- |
|                                | $t_0 = (t_6 \rightarrow (t_z \rightarrow t_4)) \rightarrow t_7$ |
|                                | $t_d = (t_x \rightarrow (t_z \rightarrow t_4))$                 |
|                                | $t_1 = t_7$                                                     |
|                                | $t_2 = t_x \rightarrow (t_z \rightarrow t_4)$                   |
|                                | $t_3 = t_z \rightarrow t_4$                                     |
|                                | $t_5 = t_z \rightarrow t_4$                                     |
|                                | $t_f = t_6 \rightarrow (t_z \rightarrow t_4)$                   |
| $t_x = t_x \rightarrow t_6$    |                                                                 |
| $t_7 = t_n \rightarrow t_8$    |                                                                 |
| $t_9 = t_n \rightarrow t_8$    |                                                                 |
| $t_f = t_{10} \rightarrow t_9$ |                                                                 |
| $t_d = t_d \rightarrow t_{10}$ |                                                                 |

| Equations                      | Substitutions                                                   |
| ------------------------------ | --------------------------------------------------------------- |
|                                | $t_0 = (t_6 \rightarrow (t_z \rightarrow t_4)) \rightarrow t_7$ |
|                                | $t_d = (t_x \rightarrow (t_z \rightarrow t_4))$                 |
|                                | $t_1 = t_7$                                                     |
|                                | $t_2 = t_x \rightarrow (t_z \rightarrow t_4)$                   |
|                                | $t_3 = t_z \rightarrow t_4$                                     |
|                                | $t_5 = t_z \rightarrow t_4$                                     |
|                                | $t_f = t_6 \rightarrow (t_z \rightarrow t_4)$                   |
|                                | $t_x = t_x \rightarrow t_6$                                     |
| $t_7 = t_n \rightarrow t_8$    |                                                                 |
| $t_9 = t_n \rightarrow t_8$    |                                                                 |
| $t_f = t_{10} \rightarrow t_9$ |                                                                 |
| $t_d = t_d \rightarrow t_{10}$ |                                                                 |

$t_x = t_x \rightarrow t_6$ breaks no-occurrence invariant
