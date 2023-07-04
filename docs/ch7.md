# Chapter 7 Types

type errors & other run time errors (division by zero), non-termination

## 7.1 Value and Their Types

## 7.3 CHECKED: A Type-Checked Language

为函数表达式和`letrec`表达式添加类型支持。

```
proc (Identifier : Type) Expression

letrec Type Identifier (Identifier : Type) = Expression
  in Expression
```

支持的类型定义

```
(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  )
```

更新语法定义

更新解释器中函数表达式和`letrec`表达式。

增加`type-of-program`在解释器开始运行时进行类型检查。

1. 7.5
1. 数据类型 pair (7.8) / list (7.9) / ref (7.10) / mutable-pair (7.11)

## 7.4 INFERRED: A Language with Type Inference

类型推导过程

1. 为每一个变量和表达式赋予一个类型 `t`。
2. 根据每个表达式的类型要求建立类型约束关系
3. 使用替换的方式求解约束
   1. 每个求解的替换，左侧是类型变量，右侧是类型值
   2. 每次添加一个新的等式，首先将等式右边的类型表达式中存在的已绑定的类型变量替换，产生一个新的绑定，然后用新的绑定替换之前绑定中的类型值，消除等式右侧的新绑定。
   3. 如果新的等式就是已经出现过的绑定，递归求解，可能产生新的等式。

直到所有的等式处理完成，中间过程中如果出现`int = bool`等错误情况，表明类型推到出错。
或者最后的替换表达式中 break no-occurrent invariant，也表明类型表达式出错。

The no-occurrence invariant

> No variable bound in the substitution occurs in any of the right-hand sides of the substitution.

得到等式`t1 = t2`的过程中，`t2`中自由变量类型，已经被替换为`substitution`中的值，所以只需要将`subst`中所有等式右侧
值中的`t1`替换为`t2`就可以保持 no-occurrence invariant。

### Constant Time Substitution Extension (Exercise 7.17 / 7.18)

当前的`extend-subst`函数对$\sigma$扩展，增加一个新的变量等式$t_{new} = tv_{new}$时，需要对$\sigma$中已经存在的所有等式的右侧进行更新，将$t_{new}$替换为$tv_{new}$，维持`no-occurrence`不变量。`extend-subst`的时间复杂度跟$\sigma$的大小有关。

通过抛弃`no-occurrence`不变量，可以将`extend-subst`改进为常量时间复杂度，实现比较简单，直接拼接列表。

```scheme
(define (extend-subst subst tvar ty)
  (cons
   (cons tvar ty)
   subst
   )
  )
```

类型替换的工作被转移到`apply-subst-to-type`中，在`tvar-type`中得到变量`ty`在`subst`中对应的类型值`tmp`，因为已经没有`no-occurrence`的保证，所以`tmp`可能包含`subst`中的等式左边的变量，所以对`tmp`递归调用`apply-subst-to-type`，最终将输入类型`ty`展开得到的结果中不包含`subst`中的已知变量。

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

考虑$tmp = t_1$，`subst`中包含$t_1 = t_1 \rightarrow t_2$，这样`t_1`会被无限展开，`apply-subst-to-type`形成死循环，这种情况在上述实现中会出现么？

每次`unifier`函数还是进行`no-occurrence?`的检查，保证变量不能递归包含自身，这样$t_1 = t_1 \rightarrow t_2$这种直接递归的等式不会被添加到`subst`中。

那么是否可能出现间接循环引用的情况$t_1 = t_2 \quad t_2 = t_1$？

考虑只包含一个等式的`subst` $t_1 = t_2$，$tmp_1$被替换后展开了所有的$t_1$，因此只可能包含$t_2$，同时`no-occurrence?`检查保证了$t_2$不可能包含自身，所以$t_2$只可能包含其他的类型$t_i (i > 2)$。

所以得到的`subst`中只可能出现$t_i = f(t_j) (i < j)$，形成一个拓扑排序，不可能出现直接或者间接的循环引用。

#### Cache Optimization

`apply-subst-to-type`递归调用自身的过程中，对于同一个类型变量会多次调用，可以做缓存优化，使得同一个类型变量只展开一次。

$
t_1 = t_2 \rightarrow t_3 \\
t_2 = int \\
t_3 = int
$

$t_1$的展开结果是$int \rightarrow int$，结果保存在`subst`列表中。

首先将`subst`中的元素从`pair`类型（`(t1 . type)`）修改为可变的`mpair`类型，这样可以更新`t1`对应的类型`type`，为了标记`type`是否已经被展开，将`type`修改为一个`(symbol . type)`的类型。`(original . type)`代表`type`是原始值，没有展开；`(cache . type)`代表`type`是展开过得值，直接使用。

这个技巧在实现惰性求值（`thunk`）和`call-by-need`中都有使用。

### Exercise 7.27

当前的类型推导过程在`type-of`中收集类型等式，在`unifier`中对等式求解，二者**交替**进行。[Wand 的方法](https://web.cs.ucla.edu/~palsberg/course/cs239/reading/wand87.pdf)将这两步拆分开，第一步收集所有的类型等式（equations），然后再使用 unification 算法求解所有等式。

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

等式收集完成后`unify`统一求解，然后替换`ty`获得整个表达式的类型。

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

### Polymorphism

当前的类型推导中不支持多态，下面代码中`f`的三处使用分别接受了`bool/int`类型的参数，当`f`第一次使用时被推导为$bool \rightarrow bool$，再接受到`int`类型时就会报错。

```
let f = proc (x : ?) x in if (f zero?(0)) then (f 11) else (f 22)
```

#### Exercise 7.28

最简单的方法是将`let var = e1 in e2`表达式进行转换，将`e2`中引用了使用到`x`的地方替换为`e1`，这样`e1`有多份拷贝，每个可以有不同的类型。

转换方法使用环境变量的形式，记录了`let`表达式中`var`变量对应的表达式`e1`，这样可以在`e2`中查询替换，支持嵌套的`let`表达式。

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

#### Value Restriction (Exercise 7.30)
