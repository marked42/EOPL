# Chapter 7 Types

类型系统在程序**运行之前**通过分析代码中变量和表达式的类型，可以判断程序是否安全（safe）。类型系统接受的程序，在运行时保证没有错误，这样的类型系统称为**健壮的**（sound）。为了实现**健壮的**类型系统，一般采取**保守的**判断策略。因为类型系统缺少**运行时**信息并不能**准确**判断**任意程序**运行时是否正确，所以对于无法判断的程序采取**保守的**（conservative）的策略当做不正确的程序进行拒绝。保守的类型系统**只**接受（accept）保证正确的程序，不接受**无法保证正确**的程序。

编程语言支持的类型系统有类型检查和类型推导两种方式。

**类型检查**（type checking）要求编写的代码中变量、函数等包含完整的类型标注（type annotation），由类型检查器（type-checker）根据这些信息检查代码是否正确。

**类型推导**（type inference）允许代码省略部分类型标注，由类型检查器根据变量及表达式的使用自动推导相应的类型，在此基础上进行类型检查。

本章以`letrec`语言为基础添加了类型系统，`letrec`包含数字、布尔值、函数这三种类型的值（value），下面定义描述这些值的类型。

```eopl
(define-datatype type type?
  ; int
  (int-type)
  ; bool
  (bool-type)
  ; proc
  (proc-type (arg-type type?) (result-type type?))
  )
```

数字类型使用 $int$ 表示，布尔值类型使用 $bool$ 表示，函数类型使用箭头表示，箭头左侧是参数类型，右侧是返回类型。$int \rightarrow int$ 表示一个接受 $int$，返回 $int$ 的函数。函数类型参数类型和返回类型可以是数字或者布尔类型，也可以是嵌套的函数类型，例如 $(int \rightarrow int) \rightarrow int$。

每种表达式根据自身的含义有对应的**类型规则**（typing rule）。

| 表达式     | 定义        | 例子                    | 规则                                                                               |
| ---------- | ----------- | ----------------------- | ---------------------------------------------------------------------------------- |
| 数字       | `const-exp` | `1`                     | 数字是 $int$ 类型                                                                  |
| 变量       | `var-exp`   | `x`                     | 变量的类型是其引用的**值**的类型                                                   |
| 判断零     | `zero?-exp` | `zero?(e1)`             | `e1`必须是 $int$ 类型，整个表达式是 $bool$ 类型                                    |
| 数字减法   | `diff-exp`  | `diff(e1, e2)`          | `e1`、`e2`以及整个表达式都是 $int$ 类型                                            |
| if 表达式  | `if-exp`    | `if e1 else e2 then e3` | `e1`是 $bool$ 类型，`e2`、`e3`类型**相等**，而且是整个表达式的类型                 |
| let 表达式 | `let-exp`   | `let x = e1 in e2`      | 假设`e1`的类型是$t_1$，`x`也是 $t_1$，在此基础上推导出 `e2` 类型作为整个表达式类型 |
| 函数定义   | `proc-exp`  | `proc (x) e1`           | 假设`x`是 $t_x$，`e1` 是 $t_1$，整个表达式是函数类型 $t_x \rightarrow t_1$         |
| 函数调用   | `call-exp`  | `(e1 e2)`               | 假设`e2`是 $t_1$，整个表达式类型是$t_2$，那么`e1` 是$t_1 \rightarrow t_2$          |

类型系统进行的分析就是检查每个表达式是否满足其**对应的类型规则**。

## 类型检查

7.3 小结介绍了支持类型检查的语言[CHECKED](../ch7/7.3/checked)，以`letrec`为基础，为`proc`和`letrec`表达式添加类型支持。`proc`支持标注参数的类型，`letrec`支持标注参数和返回值的类型。

```eopl
proc (x : int) -(x,1)

letrec int double (x : int) = if zero?(x) then 0 else -((double -(x,1)), -2) in double

proc (f : (bool -> int)) proc (n : int) (f zero?(n))
```

类型检查需要判断两个类型是否[相等](../ch7/7.3/checked/checker/type.rkt#L32)，函数类型可以**嵌套**，所以需要使用[equal?](https://docs.racket-lang.org/reference/Equality.html#%28def._%28%28quote._~23~25kernel%29._equal~3f%29%29)**递归**地判断两个类型是否相等。

```scheme
(define (check-equal-type! ty1 ty2 exp)
  (if (not (equal? ty1 ty2))
      (report-unequal-types ty1 ty2 exp)
      #f
      )
  )
```

解释器使用环境（Environment）记录**变量值**解释执行表达式，类型分析使用静态类型环境（Type Environment）记录**变量类型**，递归的检查每个表达式是否符合对应的类型规则。例如`if e1 then e2 else e3`必须满足`e1`是 $bool$ 类型，`e2`、`e3`类型相同，[对应代码](../ch7/7.3/checked/checker/main.rkt#L30)如下。

```scheme
(define (type-of exp tenv)
  (cases expression exp
    ...
    (if-exp (exp1 exp2 exp3)
            (let ([ty1 (type-of exp1 tenv)]
                  [ty2 (type-of exp2 tenv)]
                  [ty3 (type-of exp3 tenv)]
                  )
              (check-equal-type! ty1 (bool-type) exp1)
              (check-equal-type! ty2 ty3 exp)
              ty2
              )
            )
    )
  )
```

注意`letrec-exp`的类型检查，这里要考虑递归的语意，函数名称在函数体内部可见。跟解释器中不相同的是，这里的静态类型环境`tenv`和函数值本身不形成**互相引用**的关系，所以不需要一个类似[`extend-env-rec`](../ch3/3.4/letrec-lang/environment.rkt#L43)结构体特殊处理，使用同一个[`extend-env`](../ch7/7.3/checked/checker/type-environment.rkt#L27)即可。

```scheme
(define (type-of exp tenv)
  (cases expression exp
    ...
    (letrec-exp (p-result-type p-name b-var b-var-type p-body letrec-body)
                (let ([tenv-for-letrec-body (extend-tenv p-name (proc-type b-var-type p-result-type) tenv)])
                  (let ([p-body-type (type-of p-body (extend-tenv b-var b-var-type tenv-for-letrec-body))])
                    (check-equal-type! p-body-type p-result-type p-body)
                    (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    )
  )
```

函数的名称是`p-name`，类型是`(proc-type b-var-type p-result-type)`，在环境变量`tenv`的基础上添加`p-name`得到`tenv-for-letrec-body`，这个环境变量对应`letrec-body`表达式。`letrec-body`代表的函数体还可以看到函数参数`b-var`，在`tenv-for-letrec-body`基础上添加`b-var`变量，类型为`b-var-type`得到函数体对应的环境变量，在这个环境基础上推导出函数体`p-body`的类型`p-body-type`，最后检查`p-body-type`和函数的返回类型`p-result-type`是否相等。

练习题中包含了更多数据类型的支持，pair（7.8）、list（7.9）、ref（7.10）、MUTABLE-PAIRS（7.11）。

## 类型推导

类型推导允许省略部分类型标注，下面代码中使用`?`代替具体的类型。

```eopl
letrec ? foo (x : ?) = if zero?(x) then 1 else -(x, (foo -(x,1)))
  in foo
```

`(foo -(x,1))`中函数`foo`接受`-(x,1)`作为参数，`-(x,1)`是 $int$类型，所以函数的参数是 $int$ 类型。`foo`返回值是条件表达式，两个分支`1`和`-(x, (foo -(x,1)))`类型相等，都是 $int$，所以函数`foo`的返回类型是 $int$，最后推导出函数 `foo`的类型是 $int \rightarrow int$。

### 基本原理

7.4 小结介绍了支持类型推导的语言[INFERRED](../ch7/7.4/inferred)，类型推导的核心思路是每个**表达式**和**变量**都有类型，根据表达式本身的类型规则可以建立这些类型之间的关系，使用等式的方式表示。类型推导过程中`?`代表的未知类型使用**类型变量**（type variable） $t_i$ 表示，相当于解方程中的未知变量。类型推导的过程就是遍历所有表达式，对于每个表达式根据其类型规则建立等式，得到包含类型变量的方程组（equations），最终求解每个类型变量具体类型的过程。

例如表达式`if e1 then e2 else e3`可以建立如下类型等式，$t_{e1}$ 代表 `e1`的类型，$t_{e2}$ 代表`e2`的类型，$t_{e3}$ 代表`e3`的类型。

$$
t_{e1} = bool \\
t_{e2} = t_{e3}
$$

从一组等式中可以得到一组解，术语称之为**替换**（Substitution），替换等式的**左边**是**类型变量**，右边是变量的具体类型。

$$
t_{e1} = bool \\
t_{e2} = t_{e3}
$$

要求替换等式的**左侧**类型变量不能出现在任何替换等式**右侧**，如果出现这种情况说明方程还可以继续求解。

$$
t_{e1} = bool \\
t_{e2} = t_{e1}
$$

上面的替换等式中 $t_{e2}$ 等于 $t_{e1}$，而 $t_{e1}$ 是等式左侧的类型变量，可以将 $t_{e1}$ 替换为 $bool$，得到 $t_{e2} = bool$。

$$
t_{e1} = bool \\
t_{e2} = bool
$$

替换等式左侧类型变量不能出现在右侧的要求称为 **no-occurrence invariant**，保证了替换（Substitutions）是最终的解。

如果出现替换等式右侧**直接**使用了左侧类型变量的情况，继续将$t_1$替换为$t_1 \rightarrow int$会形成无限循环，**no-occurrence invariant** 不成立，这种情况表示有类型错误（type error）。

$$
t_1 = t_1 \rightarrow int
$$

如果等式求解的过程中推导除了**不能成立**的等式 $int = bool$，同样代表类型有错误。

### 类型推导过程

以表达式`(proc (p) if p then 88 else 99 33)`为例子说明类型的详细过程。

首先进行一个比较简单直观的推导，参数`p`的类型记作 $t_p$，`p`用在`if`表达式的条件处，推导出 $t_p = bool$，另外函数接受数字`33`作为实参，推导出 $t_p = int$，两个等式合并起来推导出 $int = bool$，这个等式不成立，所以整个表达式类型有错误。这个结论是正确的，因为我们传递数字`33`作为一个接受布尔类型参数的函数的实参，这个代码运行时不合法。

下面看一下类型推导的标准流程，首先为表达式和所有子表达式（包括变量）分配唯一的类型变量。第一列是表达式，第二列是对应的类型变量。这里参数`33`也是一个子表达式，但是它的类型是已知的，所以不为其分配类型变量。

| Variables & Expressions            | Type Variables |
| ---------------------------------- | -------------- |
| p                                  | $t_p$          |
| (proc (p) if p then 88 else 99 33) | $t_0$          |
| proc (p) if p then 88 else 99      | $t_1$          |
| if p then 88 else 99               | $t_2$          |

然后每一个表达式根据自身类型规则生成对应的类型等式。第一个表达式`(proc (p) if p then 88 else 99 33)`是**函数调用**表达式，函数`proc (p) if p then 88 else 99`的类型是 $t_1$，调用的参数`33`类型是 $int$，函数返回类型是整个表达式的类型 $t_0$，所以推导出 $t_1 = int \rightarrow t_0$。第二个表达式是**函数定义**表达式，函数的参数`p`的类型是 $t_p$，函数的返回值 `if p then 88 else 99`类型是 $t_2$，所以推导出 $t_1 = t_p \rightarrow t_2$。第三个表达式 `if p then 88 else 99`是`if`表达式，条件部分`p`的类型应该是 $bool$，推导出 $t_p = bool$，两个分支的返回类型应该相同，而且都等于整个表达式的类型 $t_2$，所以推导出 $t_2 = int$。

最终得到五个等式，每个表达式对应的等式是第二列同一行开始往下一行或者几行等式。一个表达式可以生成多个等式，下面包括两个 $t_2 = int$ 就是因为`if`表达式的类型 $t_2$ 分别等于左右分支的类型，都是 $int$。

| Expression                         | Equations                   |
| ---------------------------------- | --------------------------- |
| (proc (p) if p then 88 else 99 33) | $t_1 = int \rightarrow t_0$ |
| proc (p) if p then 88 else 99      | $t_1 = t_p \rightarrow t_2$ |
| if p then 88 else 99               | $t_p = bool $               |
|                                    | $t_2 = int $                |
|                                    | $t_2 = int $                |

得到类型等式后可以逐一进行求解，将等式放到第一列，已经求解的**替换等式**放到第二列。

| Equations                   | Substitutions |
| --------------------------- | ------------- |
| $t_1 = int \rightarrow t_0$ |               |
| $t_1 = t_p \rightarrow t_2$ |               |
| $t_p = bool $               |               |
| $t_2 = int $                |               |
| $t_2 = int $                |               |

第一个要求解的等式是$t_1 = int \rightarrow t_0$，等式左侧是**类型变量**，而且右侧不使用左侧变量，符合**no-occurrence invariant**的要求，该等式已经是一个合法的替换，可以从第一列**删除**，添加到替换等式列。如果要处理的等式**右侧**是一个变量的形式 $int \rightarrow t_0 = t_1$，可以交换左右侧进行处理。

| Equations                   | Substitutions               |
| --------------------------- | --------------------------- |
| $t_1 = t_p \rightarrow t_2$ | $t_1 = int \rightarrow t_0$ |
| $t_p = bool $               |                             |
| $t_2 = int $                |                             |
| $t_2 = int $                |                             |

处理下一个等式 $t_1 = t_p \rightarrow t_2$，这个等式中使用到了替换列中**已知的**类型变量 $t_1$。将使用到 $t_1$ 的地方全部替换后得到 $int \rightarrow t_0 = t_p \rightarrow t_2$。这样这个等式处理后得到的结果不包含 $t_1$，维持了**no-occurrence invariant**。

| Equations                                   | Substitutions               |
| ------------------------------------------- | --------------------------- |
| $int \rightarrow t_0 = t_p \rightarrow t_2$ | $t_1 = int \rightarrow t_0$ |
| $t_p = bool $                               |                             |
| $t_2 = int $                                |                             |
| $t_2 = int $                                |                             |

继续处理下一个等式 $int \rightarrow t_0 = t_p \rightarrow t_2$，对于这种等式左侧右侧都不是类型变量的情况，需要**递归**处理。当前的类型系统只支持数字、布尔和函数类型，不包含子类型和继承等特性。所以两个函数类型相等的情况只能推导出对应的**参数类型相同**，**返回值类型也相同**。所以得到两个新的等式 $int = t_p$ 和 $t_0 = t_2$，将之前的等式移除，替换为这两个新的等式。

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $ t_0 = t_2 $ | $t_1 = int \rightarrow t_0$ |
| $ t_p = int $ |                             |
| $t_p = bool $ |                             |
| $t_2 = int $  |                             |
| $t_2 = int $  |                             |

继续处理 $t_0 = t_2$，得到新变量 $t_0$ 的解，添加到替换列。但是观察到 $t_1 = int \rightarrow t_0$ 中等式右侧使用到了新添加的类型变量 $t_0$，这违反了**no-occurrence invariant**。

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $ t_p = int $ | $t_1 = int \rightarrow t_0$ |
| $t_p = bool $ | $ t_0 = t_2 $               |
| $t_2 = int $  |                             |
| $t_2 = int $  |                             |

将 $t_0$ 替换得到 $t_1 = int \rightarrow t_2$。

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $ t_p = int $ | $t_1 = int \rightarrow t_2$ |
| $t_p = bool $ | $ t_0 = t_2 $               |
| $t_2 = int $  |                             |
| $t_2 = int $  |                             |

然后是$t_p = int$，没有任何特殊处理，可以添加到替换列。

| Equations     | Substitutions               |
| ------------- | --------------------------- |
| $t_p = bool $ | $t_1 = int \rightarrow t_2$ |
| $t_2 = int $  | $ t_0 = t_2 $               |
| $t_2 = int $  | $ t_p = int $               |

继续处理 $t_p = bool$，将 $t_p$ 替换为已知的类型 $int$，得到新的等式 $int = bool$。这个无法成立的等式表明表达式存在类型错误，整个分析完成，这与我们直观分析的结论一致。标准的类型推导分析流程对于任何程序都是一样的，因此可以编写为程序来实现。

| Equations    | Substitutions               |
| ------------ | --------------------------- |
| $int = bool$ | $t_1 = int \rightarrow t_2$ |
| $t_2 = int $ | $ t_0 = t_2 $               |
| $t_2 = int $ | $ t_p = int $               |

### 具体实现

#### 可选类型

首先新增 `optional-type` 代表可选类型，可选类型可以包含具体类型 `a-type`，也可以包含`?`表示的**未知类型**。`proc-exp`和`letrec-exp`中使用`optional-type`标注参数和返回值类型。

```scheme
(define the-grammar
  '((program (expression) a-program)
    (expression ("proc" "(" identifier ":" optional-type")" expression) proc-exp)

    (expression ("letrec" optional-type identifier "(" identifier ":" optional-type ")" "=" expression "in" expression) letrec-exp)
    (optional-type ("?") no-type)
    (optional-type (type) a-type)
  )
)
```

类型分析的过程中，遇到`?`代表的可选类型时需要新建一个**全局唯一**的类型变量来代表这个类型。定义新的类型`tvar-type`代表类型变量 $t_i$，其中 $i$ 是变量唯一标识，使用一个全局递增的非负整数表示。函数[fresh-var-type](../ch7/7.4/inferred/inferrer/type.rt#L5)用来创建类型变量。

```scheme
(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  (tvar-type (sn integer?))
  )

(define sn 0)
(define (fresh-var-type)
  (set! sn (+ sn 1))
  (tvar-type sn)
  )
```

#### 替换列

替换列使用一个 list 表示，其中每个元素都是一对`tvar-type`和`type`组成，分别代表替换等式左边的类型变量和右边的类型。`empty-subst`创建空的替换列，`extend-subst`添加新的等式 $t_{var} = t_y$ 到替换列`subst`中，返回新的替换列表。

```scheme
(define (empty-subst) '())

; preserves no-occurrence of invariant
(define (extend-subst subst tvar ty)
  (cons
   (cons tvar ty)
   (map
    (lambda (p)
      (let ([oldlhs (car p)] [oldrhs (cdr p)])
        (cons oldlhs (apply-one-subst oldrhs tvar ty))
        )
      )
    subst)
   )
  )
```

`cons` 添加新变量`tvar`到`subst`的时候，为了维持**no-occurrence invariant**，使用`apply-one-subst`将`subst`已有的等式右侧中`tvar`替换为`ty`。[apply-one-subst](../ch7/7.4/inferred/inferrer/substitution.rkt#L6)通过对类型`ty0`的递归处理，找到其中使用的`tvar`，替换为`ty1`。

```scheme
(define (apply-one-subst ty0 tvar ty1)
  (cases type ty0
    (int-type () (int-type))
    (bool-type () (bool-type))
    (proc-type (arg-type result-type)
               (proc-type (apply-one-subst arg-type tvar ty1) (apply-one-subst result-type tvar ty1))
               )
    (tvar-type (sn)
               (if (equal? ty0 tvar) ty1 ty0)
               )
    )
  )
```

#### 表达式类型

对表达式的类型推导在 [type-of](../ch7/7.4/inferred/inferrer/main.rkt#L33)中，返回一个[an-answer](../ch7/7.4/inferred/inferrer/main.rkt#L14)结构，包含了表达式类型`result-type`和分析到当前表达式为止得到的`subst`两个字段。`type-of`中对表达式分析的过程中，替换列`subst`是不断更新的，这里使用了在函数间传递积累的形式实现，也可以实现为一个全局的数据，参考[Exercise 7.21](../ch7/7.4/exer-7.21/inferrer/substitution.rkt#L27)。对于`proc-exp`中使用`?`代表的可选类型`otype`调用`otype->type`进行转换，内部调用`fresh-var-type`生成一个新的`tvar-type`，使用这个新类型变量继续后续的推导。`letrec-exp`表达式中的可选类型是相同的方式处理。

```scheme
(define (type-of exp tenv subst)
  (cases expression exp
    (proc-exp (var otype body)
              (let ([var-type (otype->type otype)])
                (cases answer (type-of body (extend-tenv var var-type tenv) subst)
                  (an-answer (result-type subst)
                             (an-answer (proc-type var-type result-type) subst)
                             )
                  )
                )
              )
    ...
    (diff-exp (exp1 exp2)
              (cases answer (type-of exp1 tenv subst)
                (an-answer (ty1 subst1)
                           (let ([subst1 (unifier ty1 (int-type) subst1 exp1)])
                             (cases answer (type-of exp2 tenv subst1)
                               (an-answer (ty2 subst2)
                                          (let ([subst2 (unifier ty2 (int-type) subst2 exp2)])
                                            (an-answer (int-type) subst2)
                                            )
                                          )
                               )
                             )
                           )
                )
              )
  )
)
```

以`diff-exp`表达式为例看下表达式类型推到的具体过程。`diff-exp`中类型参数`exp1`的类型是`ty1`，根据规则得到类型等式 $t_{y1} = int$，使用`unifier`函数将这个等式添加到当前的`subst1`中，返回一组更新后的`subst2`；然后对`exp2`的类型等式进行处理，同样使用`unifier`对`subst2`继续添加新的等式。

#### unifier

`unifier`就是将一组新的等式求解并将得到的替换等式添加到当前`subst`的过程。

```scheme
(define (unifier ty1 ty2 subst exp)
  ; keeps no-occurrence invariant
  (let ([ty1 (apply-subst-to-type ty1 subst)] [ty2 (apply-subst-to-type ty2 subst)])
    (cond
      [(equal? ty1 ty2) subst]
      ; get new substitution
      [(tvar-type? ty1)
       (if (no-occurrence? ty1 ty2)
           (extend-subst subst ty1 ty2)
           (report-no-occurrence-violation ty1 ty2 exp)
           )
       ]
      ; get new substitution
      [(tvar-type? ty2)
       (if (no-occurrence? ty2 ty1)
           (extend-subst subst ty2 ty1)
           (report-no-occurrence-violation ty2 ty1 exp)
           )
       ]
      [(and (proc-type? ty1) (proc-type? ty2))
       ; more equations recursively
       (let ([subst (unifier (proc-type->arg-type ty1) (proc-type->arg-type ty2) subst exp)])
         (let ([subst (unifier (proc-type->result-type ty1) (proc-type->result-type ty2) subst exp)])
           subst
           )
         )
       ]
      [else (report-unification-failure ty1 ty2 exp)]
      )
    )
  )
```

首先使用 [apply-subst-to-type](../ch7/7.4/inferred/inferrer/substitution.rkt#L27)对类型等式 $t_{y1} = t_{y2}$ 两侧类型替换处理，消除已有的`subst`中所有已知类型变量，然后分情况处理。

1. `ty1`和`ty2`相等的情况，不添加新的等式，直接返回已有的`subst`。
1. `ty1`或者是`ty2`是类型变量的情况，说明得到一个类型变量的替换解，添加到`subst`中，这里要使用 [no-occurrence?](../ch7/7.4/inferred/inferrer/substitution.rkt#L58) 进行检测，保证**no-occurrence invariant**。
1. 对于两侧都是`proc-type`的情况，递归处理。
1. 其余情况表明出现了类型错误。

在完成类型推导分析后，得到最终的`subst`，这个表达式和任意子表达式的具体类型可以通过使用[subst](../ch7/7.4/inferred/inferrer/main.rkt#L25)得到。

```scheme
(define (type-of-program pgm)
  (reset-fresh-var)
  (cases program pgm
    (a-program (exp1)
               (let ([ans (type-of exp1 (init-tenv) (empty-subst))])
                 (cases answer ans
                   (an-answer (ty subst)
                              (apply-subst-to-type ty subst)
                              )
                   )
                 )
               )
    )
  )
```

#### 单元测试

类型 $t_1 \rightarrow t_1$ 和类型 $t_2 \rightarrow t_2$ 使用的类型变量编号不同，但都是表示参数和返回值类型**相同**的函数类型。在单元测试中为了方便比较两个类型是否相同，需要对类型变量进行重新统一编号。重新编号需要查找类型变量和替换类型变量两步实现。首先使用[canonical-subst](../ch7/7.4/inferred/inferrer/equal-up-to-gensyms.rkt#L27)遍历类型，找到所有类型变量，并为类型变量按顺序重新编号。也就是得到一个新旧类型变量对应的列表，$t_2$ 重新编号为 $t_1$。

$$
t_2 = t_1
$$

```scheme
(define (canonical-subst sexp)
  (let loop ([sexp sexp] [table '()])
    (cond
      [(null? sexp) table]
      [(tvar-type-sym? sexp)
       (cond
         [(assq sexp table) table]
         [else
          (cons (cons sexp (counter->tvar-symbol (length table))) table)
          ]
         )
       ]
      [(pair? sexp)
       (loop (cdr sexp) (loop (car sexp) table))
       ]
      [else table]
      )
    )
  )
```

然后[apply-subst-to-sexp](../ch7/7.4/inferred/inferrer/equal-up-to-gensyms.rkt#L27)将类型替换为重新变量过的类型变量。将替换列表引用到类型上。类型 $t_2 \rightarrow t_2$ 替换 $t_2$ 为 $t_1$，得到 $t_1 \rightarrow t_1$。

```scheme

(define (apply-subst-to-sexp subst sexp)
  (cond
    [(null? sexp) sexp]
    [(tvar-type-sym? sexp)
     (cdr (assq sexp subst))
     ]
    [(pair? sexp)
     (cons
      (apply-subst-to-sexp subst (car sexp))
      (apply-subst-to-sexp subst (cdr sexp))
      )
     ]
    [else sexp]
    )
  )
```

### 替换列表优化

#### 单向引用

当前的`extend-subst`函数对 `subst` 扩展，增加一个新的变量等式$t_{new} = tv_{new}$时，需要对 `subst` 中已经存在的所有等式的右侧进行更新，将$t_{new}$替换为$tv_{new}$，维持`no-occurrence`不变量。`extend-subst`的时间复杂度跟 `subst` 的大小有关。通过抛弃**no-occurrence**不变量，可以将`extend-subst`改进为常量时间复杂度（Exercise 7.17 / 7.18）。

考虑下面的替换列，虽然 $t_1$ 的右侧 $int \rightarrow t_2$ 使用了类型变量 $t_2$，不满足**no-occurrence invariant**，但是只存在单向引用，不存在循环引用，$t_1$ 使用了 $t_2$，$t_2$ 使用了 $t_3$。通过两步替换仍然可以得到 $t_1 = int \rightarrow (int \rightarrow int)$。也就是使用**只存在单向引用**这样一个比**no-occurrence invariant**更**弱一点**的条件，也能表示合法的替换列。

$$
t_1 = int \rightarrow t_2 \\
t_2 = int \rightarrow t_3 \\
t_3 = int
$$

这种方案的优点在于列表的拼接可以从线性时间复杂度优化为常量时间复杂度，`extend-subst`实现为直接拼接列表。

```scheme
(define (extend-subst subst tvar ty)
  (cons
   (cons tvar ty)
   subst
   )
  )
```

在`unifier`中仍然需要使用[apply-subst-to-type](../ch7/7.4/exer-7.21/inferrer/unifier.rkt#L8)来保证新得到的等式中不包含已知类型变量。
因为等式中已知的旧类型变量都被替换，所以只会出现旧的类型变量引用新的类型变量，而不会出现新的类型变量使用旧的类型变量，这样就满足了**单向引用**的条件。
对于一个类型变量自引用的情况，仍然需要使用`no-occurrence?`进行检查排除。

```scheme
(define (unifier ty1 ty2 subst exp)
  (let ([ty1 (apply-subst-to-type ty1 subst)] [ty2 (apply-subst-to-type ty2 subst)])
    (cond
      [(equal? ty1 ty2) subst]
      [(tvar-type? ty1)
       (if (no-occurrence? ty1 ty2)
           (extend-subst subst ty1 ty2)
           (report-no-occurrence-violation ty1 ty2 exp)
           )
       ]
       ...
      )
    )
  )
```

由于使用了**只有单向引用**的条件，在[apply-subst-to-type](../ch7/7.4/exer-7.21/inferrer/substitution.rkt#L27)中，得到类型变量`ty`在`subst`中对应的等式`tmp`后，等式右侧可能包含替换列中的类型变量，所以需要递归调用`apply-subst-to-type`对等式右侧也就是`(cdr tmp)`进行展开，最终得到的结果类型中不包含`subst`中的已知类型变量。

```scheme
(define (apply-subst-to-type ty subst)
  (cases type ty
    ...
    (tvar-type (sn)
               (let ([tmp (assoc ty subst)])
                 ; no-occurrence invariant is not needed anymore, cause any var at left side in subst
                 ; will be repeatedly replaced with corresponding type at right side, until ty contains
                 ; no vars in subst or a type error is found during this replacement.
                 (if tmp (apply-subst-to-type (cdr tmp) subst) ty)
                 )
               )
    )
  )
```

#### 缓存优化

`apply-subst-to-type`递归调用自身的过程中，对于同一个类型变量会多次展开，可以做缓存优化，使得同一个类型变量只展开一次。

$$
t_1 = t_2 \rightarrow t_3 \\
t_2 = int \\
t_3 = int
$$

$t_1$ 的展开结果是 $int \rightarrow int$，结果保存在`subst`列表中。

首先将`subst`中的元素从`pair`类型`(t1 . type)`修改为可变的`mpair`类型，这样可以更新`t1`对应的类型`type`，为了标记`type`是否已经被展开，将`type`修改为一个`(symbol . type)`的类型。`(original . type)`代表`type`是原始类型没有展开；`(cache . type)`代表`type`是展开过的类型，可以直接使用。

这个技巧在实现惰性求值`thunk`和`call-by-need`中都有使用。

### Wand 的方法（Exercise 7.27）

当前的类型推导过程在`type-of`中收集类型等式，在`unifier`中对等式求解，二者**交替**进行，逐步更新替换列`subst`。[Wand 的方法](https://web.cs.ucla.edu/~palsberg/course/cs239/reading/wand87.pdf)将这两步拆分开，第一步收集所有的类型等式（equations），然后再使用 unification 算法统一求解所有等式，避免了更新`subst`过程中的复制操作。

```scheme
(define (type-of exp tenv equations)
  (cases expression exp
    (const-exp (num) (an-answer (int-type) equations))
    (var-exp (var) (an-answer (apply-tenv tenv var) equations))
    (diff-exp (exp1 exp2)
              (cases answer (type-of exp1 tenv equations)
                (an-answer (ty1 equations)
                           ; collect equations only
                           (let ([equations (extend-equations ty1 (int-type) equations exp1)])
                             (cases answer (type-of exp2 tenv equations)
                               (an-answer (ty2 equations)
                                          (let ([equations (extend-equations ty2 (int-type) equations exp2)])
                                            (an-answer (int-type) equations)
                                            )
                                          )
                               )
                             )
                           )
                )
              )
    ...
  )
)
```

等式收集完成后[unify](../ch7/7.4/exer-7.27/inferrer/unifier.rkt#L7)统一求解，然后替换类型`ty`获得表达式的具体类型。

```scheme
(define (type-of-program pgm)
  (reset-fresh-var)
  (cases program pgm
    (a-program (exp1)
               (let ([ans (type-of exp1 (init-tenv) (empty-equations))])
                 (cases answer ans
                   (an-answer (ty equations)
                              ; solve equations
                              (apply-subst-to-type ty (unify equations))
                              )
                   )
                 )
               )
    )
  )
```

### 参数化多态（Polymorphism）

当前的类型推导中不支持多态，下面代码中`f`的三处使用分别接受了$bool$ 和 $int$ 类型的参数，当`f`第一次使用时`(f zero?(0))`被推导为 $bool \rightarrow bool$，再次使用 `(f 11)` 接收 $int$ 类型时类型推导会报错。

```eopl
let f = proc (x : ?) x in if (f zero?(0)) then (f 11) else (f 22)
```

但是实际上恒等函数`proc (x) x`可以接受任意参数类型，运行时都不会出错。允许恒等函数有多个不同参数类型，被称为参数化多态。当前的类型推导不够准确，不支持函数的参数化多态。函数以字面值的形式直接使用的话，每个函数都是独立的类型。只有函数使用`let`表达式赋值给变量，然后一个函数变量**多处**使用时才出现需要支持多态的情况，所以也被称为 Let 多态（[Let-polymorphism](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system#Let-polymorphism_2)）。

#### 多份实例（Exercise 7.28）

支持多态最简单的方法是将`let x = e1 in e2`表达式进行[转换](../ch7/7.4/exer-7.28/transformer.rkt#L7)，将`e2`中使用到`x`的地方替换为`e1`，这样`e1`有多份拷贝，每个可以有**不同的**类型。转换方法使用环境变量的形式，记录`let`表达式中`x`变量对应的表达式`e1`，这样可以在`e2`中查询替换，转换支持嵌套的`let`表达式。

```scheme
(define (transform-let-exp exp)
  (let loop ([exp exp] [env (init-env)])
    (cases expression exp
      (var-exp (var1)
              (let ([val (apply-env env var1)])
                (if (expression? val)
                  val
                  exp
                  )
                )
              )
      (let-exp (var exp1 body)
              (loop body (extend-env var (loop exp1 env) env))
              )
      ...
      (else (eopl:error 'loop "unsupported expression type ~s" exp))
      )
    )
)
```

#### Algorithm W (Exercise 7.29)

[Hindley-Milner](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system#The_Hindley%E2%80%93Milner_type_system)类型系统通过定义多态类型（polytype）解决了一个函数只能有一个类型的问题。将[恒等函数 F](https://en.wikipedia.org/wiki/Identity_function)（`proc (x) x`）的类型定义如下为多态类型。

$$
F: \forall a . a \rightarrow a
$$

含义是对于**所有的**类型 $a$，函数 $F$ 类型是 $a \rightarrow a$，$F$ 不是一个具体的类型，而是一组类型。

$$
int \rightarrow int \\
bool \rightarrow bool \\
(int \rightarrow int) \rightarrow (int \rightarrow int) \\
...
$$

给一个具体的类型 $a = int$，可以把类型 $F$ **实例化**（instantiate）为具体类型 $int \rightarrow int$，反之可以将具体类型**泛化**（generalize）为多态类型。

对`let x = e1 in e2`进行类型推导时，将`e1`推导为多态类型，然后在任何使用`x`的地方，将多态类型实例化为具体的类型，这些类型之间互相独立，这样实现了多态类型的支持。

将`int-type`和`bool-type`称为单一类型（monotype），因为这些类型不可能包含类型变量`tvar-type`，所以不能泛化。定义类型`generic-type`表示多态类型，包含了一个具体的类型`mono`和这个类型的若干类型变量参数`vars`，这里直接使用`tvar-type`记录类型参数。

```eopl
(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  (tvar-type (sn integer?))
  ; support polymorphic function only
  (generic-type (mono type?) (vars (list-of tvar-type?)))
  )
```

为了实现类型泛化，需要找到具体类型中的自由变量，自由变量是可以被替换的。这里自由变量使用类型变量表示，所以直接查找类型变量即可。

```scheme
(define (free-vars ty)
  (let loop ([ty ty])
    (cases type ty
      (tvar-type (sn) (list ty))
      (proc-type (arg-type result-type)
                 (append
                  (loop arg-type)
                  (loop result-type)
                  )
                 )
      (else '())
      )
    )
  )
```

当前类型系统中只有`proc-type`类型能包含参数，所以类型泛化函数`generalize`只能对`proc-type`进行泛化处理。

```scheme
(define (generalize ty)
  (cases type ty
    (proc-type (arg-type result-type)
               (generic-type ty (free-vars ty))
               )
    (else ty)
    )
  )
```

实例化的实现就是把`generic-type`中的`mono`包含的类型变量**替换**即可，这里使用一组新的**独立的**类型变量替换旧的类型变量。

$$
t_1 = t_1^{'} \\
... \\
t_n = t_n^{'}
$$

`fresh-var-type`每次调用生成新的类型变量。

```scheme
(define (instantiate-type ty)
  (cases type ty
    (generic-type (mono vars)
                  (replace-var-type mono (map (lambda (var) (cons var (fresh-var-type))) vars))
                  )
    (else ty)
    )
  )
```

然后在`let-exp`中使用类型泛化，在变量使用处`var-exp`使用类型实例化，其余的类型推导逻辑和之前一致。

```scheme
(define (type-of exp tenv subst)
  (cases expression exp
    ; instantiate generic type when referencing var
    (var-exp (var) (an-answer (instantiate-type (apply-tenv tenv var)) subst))
    ; let-polymorphism, generalize exp1 type, type of var will be instantiated when used
    (let-exp (var exp1 body)
             (cases answer (type-of exp1 tenv subst)
               (an-answer (exp1-type subst)
                          (type-of body (extend-tenv var (generalize exp1-type) tenv) subst)
                          )
               )
             )
    ...
  )
)
```

#### Value Restriction (Exercise 7.30)

在支持引用类型的情况下，变量`f`是函数 $\forall a. a \rightarrow a$ 的引用类型，`setref`将`f`更新为 $int \rightarrow int$ 的引用类型，之后再接收布尔类型的参数`zero?(1)`的话，**运行时**会出错。

```eopl
let f = newref(proc (x : ?) x)
  in let g = setref(f, proc (x: int) -(x,1))
    in (deref(f) zero?(1))
```

但是上面的代码由于多态支持能够**通过**类型检查，`deref(f)`处函数`f`被实例化为新的类型，跟`setref(f, proc (x: int) -(x, 1))`中的函数`f`的类型是互相独立的。

出现这种情况的原因在于引用是具有**副作用**（Side Effects）的，同一个引用**只能有一个**类型，跟多态类型冲突。通过限制`let x = e1 in e2`表达式中`e1`只能是不具有副作用的值（value）来避免出现上述情况的方法称为**值约束**（value restriction）。

当前语言中只有`ref-exp`表达式不是值，在类型推导逻辑[type-of](../ch7/7.4/exer-7.30/inferrer/main.rkt#L88)中增加检查，只将值类型推导为多态类型，这样类型检查器就能够检测出上述代码中的类型错误。

```scheme
(define (type-of exp tenv subst)
  (cases expression exp
    ; let-polymorphism, generalize exp1 type, type of var will be instantiated when used
    (let-exp (var exp1 body)
             (cases answer (type-of exp1 tenv subst)
               (an-answer (exp1-type subst)
                          ; generalize only value type
                          (if (is-value-type? exp1-type)
                              (type-of body (extend-tenv var (generalize exp1-type) tenv) subst)
                              (type-of body (extend-tenv var exp1-type tenv) subst)
                              )
                          )
               )
             )
  )
)
```
