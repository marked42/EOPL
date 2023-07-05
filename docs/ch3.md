# Chapter 3 Expressions

source language/defined language 指要设计和实现的语言。
implementation language/defining language 指编写源码使用的语言。
expressed values 指原语言中可能的表达式值类型
denoted values 指实现语言中用来表示 expressed values 的值

在对源语言进行解释执行的过程中，要识别 expressed values 的类型，然后映射到 denoted values，在实现语言中对 denoted values 进行
相应的运算，然后将运算结果包装为对应的 expressed values，映射回源语言。

$n$ 是 denoted value，$\lceil n \rceil$ 代表 expressed value 中对应的值。

$n$ 是 expressed value，$\lfloor n \rfloor$ 代表 denoted value 中对应的值。

## let-lang

**let 语句** 定义的若干个变量中，前边的变量对后续变量的初始化语句不可见，变量初始化语句不能使用 let 中定义的变量，只能使用外层变量。

```rkt
let x = 30
    in let x = -(x,1)
           y = -(x,2)
        in -(x,y)
```

`y = -(x,1)`中的`x`是外层的`x`，所以结果是`1`。

**`let*`**语句定义的若干个变量中，前边的变量对后续变量的初始化语句可见。

```rkt
let x = 30
    in let* x = -(x,1)
            y = -(x,2)
        in -(x,y)
```

`y = -(x,1)`中的`x`是内层的`x`，所以结果是`1`。

### 扩展运算符

在`let-lang`的基础上可以增加支持很多内置操作符（operator）取反运算（Exercise 3.5），整数四则运算（Exercise 3.7），数字比较运算（Exercise 3.8）等，
调整代码结构使用统一的一套逻辑方便实现（Exercise 3.11）。

### let* 表达式

### 列表（list）

Exercise 3.9
Exercise 3.10
Exercise 3.18

**unpack**类似于 ES 6 的解构，将一个列表中的元素绑定绑定到多个变量上。

```eopl
let u = 7
    in unpack x y = cons(u,cons(3,emptylist))
        in -(x,y)
```

计算结果是`4`。

## proc-lang

多参数 Exer 3.20 Currying Exer 3.21

### 递归函数与不动点

- [ ] fixed point Exer 3.23 - 3.25

### 简化环境

Exer 3.26

### 动态作用域（Dynamic scoping）

exer 3.28/exer 3.29

## letrec lang

Data strcture representation
Exer 3.34 procedural representation

3.32 / 3.33 多参数，多变量

### 缓存优化

Exercise 3.35

## lexical addressing

词法作用规则下，变量使用处与定义处相隔的环境层数与代码结构对应，这个偏移量在运行前就确定了。因此可以提前计算，并将变量使用处名称替换为
偏移量，这样就避免了在运行时再去逐层查找变量，可以变量查找从线性时间优化为常量时间。

最基本的情况中，每层环境（Environment）只定义一个变量数据，变量的就可以替换为一个非负整数偏移量，0 表示当前层环境；如果每层环境（Environment）
可以定义多个变量数据，那么变量可以由一个非负整数对定义`(env, offset)`，`env`代表环境的偏移量，`offset`表示环境中单个变量的偏移量。

为了实现 lexical addressing，需要对解释器进行改造，拆分为两个步骤。

第一步翻译，将源代码分析一遍，将涉及到的变量定义与使用的表达式类型`E`转换为一个新的对应类型表达式类型`E1`。`E`中的变量引用在`E1`中被替换为偏移量数据，`E`中的变量定义名称信息在`E1`中可以不再记录，因为在运行时已经不需要名称信息再去定位变量了。

第二步改造解释器，解释器中去除对于旧类型`E`的支持，因为翻译的过程中所有表达式类型`E`都被转换处理，结果中没有这种类型了；增加对于新类型`E1`的支持，`E1`的运行结果应该和旧解释其中`E`一致。

具体涉及到的修改：

1. 定义 static-env 在转换过程中用来计算变量偏移量。
1. 运行时的 env 可以去除变量名称信息，只记录变量值。
1. 涉及到变量定义和使用的表达式类型`E`需要增加对应新类型`E1`，其他的表达式类型只需要递归转换即可。当前版本涉及的表达式类型如下:
   1. var-exp -> nameless-var-exp
   1. let-exp -> nameless-let-exp
   1. proc-exp -> nameless-proc-exp

### letrec

exer 3.40 关于 letrec-exp 的处理

```eopl
letrec p-name (b-var)
  = p-body
    in body
```

假设`p-name`函数之前的环境变量是`env`，那么 `p-body` 和 `body` 对应的环境变量分别如下。

```eopl
body -> (p-name env)
p-body -> (b-var p-name env)
```

首先修改`environment`定义记录变量类型，这样能区分普通变量和`letrec-exp`定义的变量。

```scheme
(define (extend-senv type var senv)
  (cons (list type var) senv)
  )

(define (extend-senv-normal var senv)
  (extend-senv 'normal var senv)
)

(define (extend-senv-letrec var senv)
  (extend-senv 'letrec var senv)
)
```

然后可以根据变量类型将其转换为`nameless-var-exp`或者`nameless-letrec-var-exp`。

```scheme
(var-exp (var)
         ; new stuf
         (let* ([index (apply-senv senv var)] [type (car (list-ref senv index))])
          (cond
            [(eqv? type 'normal) (nameless-var-exp index)]
            [(eqv? type 'letrec) (nameless-letrec-var-exp index)]
            [else (eopl:error 'value-of-exp "unsupported var ~s of type ~s, only allow 'normal/letrec" var type)]
            )
          )
         )
```

将`letrec-exp`转换为`nameless-letrec-exp`，注意其中`body`所在的环境变量包含了`p-name`；`p-body`所在的环境同时包含了`p-name`和`b-var`。

```eopl
(let ([proc-env (extend-senv-letrec p-name senv)])
  (nameless-letrec-exp
    ; both p-body and body remembers current senv in their env
    ; handle recursive variable behavior in interpreter logic
    (translation-of-exp p-body (extend-senv-normal b-var proc-env))
    (translation-of-exp body proc-env)
  )
)
```

然后在解释器部分处理关于递归变量`p-name`的访问，其中`nameless-letrec-exp`对应的新环境变量`new-env`需要在`env`的基础上新增一个
对应`p-name`的函数值`the-proc`，其中`(procedure p-body env)`中使用环境变量由于`letrec`表达式的递归语意，应该就是`new-env`本身，
但是这样形成了循环引用，在`letrec-lang`中我们使用了`extend-env-rec`来打破循环引用。同样的处理方式，在`procedure`中先使用`env`，
然后在变量访问逻辑中来处理`letrec`的递归语意。

```scheme
; new stuff
(nameless-letrec-exp (p-body body)
                      (let ([the-proc (proc-val (procedure p-body env))])
                      (value-of-exp body (extend-nameless-env the-proc env))
                      )
                     )
```

访问`nameless-letrec-var-exp`代表的递归变量`p-name`时，同样应该返回一个`procedure`，它的`body`保存在`p-name`对应的值中。
`letrec`的递归语意要求这个`procedure`对应的环境变量应该包含`p-name`，从当前的环境量`env`中找到以`p-name`开头的尾部环境变量，
就是需要的部分。

```scheme
(nameless-letrec-var-exp (num)
                          ; list-tail find tail part of list starting from target element
                          (let ([new-nameless-env (list-tail env num)])
                          ; so car of new-nameless-env is the-proc corresponding to letrec-var
                          (let ([the-proc (expval->proc (car new-nameless-env))])
                            ; cases requires to "procedure.rkt" to load eagerly
                            (cases proc the-proc
                              (procedure (body saved-env)
                                ; environment of procedure body is new-nameless-env with first var being
                                ; the-proc itself
                                (proc-val (procedure body new-nameless-env))
                                )
                              (else (eopl:error 'value-of-exp "expect a procedure, got ~s" the-proc))
                              )
                            )
                          )
                         )
```

#### Exer 3.42

简化环境

#### Exer 3.43 / Exer 3.44

Lexical Addressing 优化的思想是根据源代码的静态结构，将一些运算从运行时提前到编译时进行，生成更高效的代码，提高运行效率。
习题 3.43 使用编译时优化的方法，将`let`语句声明的函数在调用处展开，这样在运行时能够节省*函数变量*的访问操作。

```scheme
let x = 3
  in let f = proc (y) -(y,x)
    in (f 13)
```

上面的代码使用这个优化思路可以转换如下，注意`f`在`(f 3)`被展开为其引用的函数表达式。

```eopl
let x = 3
  in let f = proc (y) -(y,x)
    in (proc (y) -(y, x) 13)
```

上面的优化有两个核心点：

变量引用的表达式是函数表达式时，需要展开为函数表达式本身。

由于函数表达式被展开，函数体中使用的外部变量`x`的索引需要调整一个偏移量。原始的变量`x`的索引是`1`，意思是它引用了上两层`let x = 3`的定义，
新的`x`的变量同样引用了`let x = 3`，索引是`2`。前后两个索引差值为`1`，代表了两个位置中间的环境变量。也就是`f`的定义和展开处包含的一层环境变量`let f`，而函数体在两处`x`索引查询中都存在，所以对偏移量没有影响。

转换的具体实现过程如下。

首先将环境变量列表的元素从单个变量名重构为一个`(var . val)`的键值对，`var`代表变量名称，`val`代表变量内容，`let`表达式定义的变量是函数时，`val`记录函数表达式的定义，这样才能在后续处理变量引用时找到这个定义并进行展开；其他变量的`val`值保存为`false`即可，这样可以使用`if`表达式区分两种情况。

对`let-exp`进行转换，在`exp1`是函数表达式时，将`exp1`中的外部变量（也就是引用了`let-exp`外层定义的变量）转换为`intermediary-nameless-var-exp`进行区分，方便在后续展开时添加偏移量。转换得到的函数定义表达式`proc-exp-with-intermediary-var`需要再次
进行转换，将函数体中的普通表达式转换为对应的`nameless`版本，得到`new-proc-exp`，这个值保存到环境变量中，后续展开时使用。`let-exp`中的`exp1`表达式不进行特殊处理，实际上因为所有的函数都展开了，运行时`exp1`并不会使用到，所以可以进一步优化（Exer 3.44）。

```scheme
(let-exp (var exp1 body)
          (nameless-let-exp
            ; translate proc as always, not used anymore when interpreted
            (translation-of-exp exp1 senv)
            ; when exp1 is a proc, transform its internal vars which references external definitions
            ; to intermediary-nameless-var-exp, remember this new-proc-exp in environment for later use.
            (if (is-proc-exp? exp1)
                (let* ([proc-exp-with-intermediary-var (var-exp->intermediary-nameless-var-exp exp1 senv 0)]
                      [new-proc-exp (translation-of-exp proc-exp-with-intermediary-var senv)])
                  (translation-of-exp body (extend-senv var new-proc-exp senv)))
                (translation-of-exp body (extend-senv-normal var senv)))))
```

外部变量的识别可以通过比较变量的索引`index`进行，在`exp1`处使用索引为`0`（记作`limit`）的变量就代表引用了`let-exp`外层的变量定义。对`exp1`进行`exp1`，遇到一层*变量定义*就将`limit`加`1`，这样变量索引`index`如果大于等于`limit`就表示这个变量是外部变量。

```scheme
(define (intermediary-nameless-var-exp->nameless-var-exp exp offset)
  (cases expression exp
    ; ...
    (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)])
                     (if (>= depth limit)
                         (intermediary-nameless-var-exp depth)
                         exp
                         )
                     )
             )
    (let-exp (var exp1 body)
             (let-exp
              var
              (var-exp->intermediary-nameless-var-exp exp1 senv)
              (var-exp->intermediary-nameless-var-exp body (extend-senv-normal var senv) (+ limit 1))
              )
             )
    (proc-exp (var body)
              (proc-exp
               var
               (var-exp->intermediary-nameless-var-exp body (extend-senv-normal var senv) (+ limit 1))
               )
              )
    ; ...
    (else (eopl:error 'intermediary-nameless-var-exp->nameless-var-exp "unsupported expression type ~s" exp))
    )
  )
```

`intermediary-nameless-var-exp->nameless-var-exp` 只对涉及*变量引用*的表达式`var-exp`和*变量定义*的表达式`let-exp/proc-exp`进行处理，其他表达式类型只做递归处理，类型不变。

处理完`let-exp`的定义后，接下来需要在`var-exp`中对使用了`let-exp`定义的函数的变量进行展开。查找变量的值`val`，真的话代表这是一个函数表达式，
需要返回函数表达式本身；否则就是一个普通变量，需要转换为`nameless-var-exp`。对于函数表达式`val`中的`intermediary-nameless-var-exp`需要添加索引偏移量，重新转换为`nameless-var-exp`。这个偏移量`gap-env-count`就是变量函数定义`f`的偏移层数，也就是索引深度`depth + 1`。`depth`/`gap-env-count`分别对应下标从`0`开始的数组的最后一个元素索引和元素个数，二者差值为`1`。

```scheme
(define (translation-of-exp exp senv)
  (cases expression exp
    (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)] [val (cdr pair)] [gap-env-count (+ 1 depth)])
                     ; when a var is references, if is a proc
                     (if val
                         ; adjust it's internal intermediary-nameless-var-exp index, should add the offset
                         ; of current var def and the location of the proc it references
                         (intermediary-nameless-var-exp->nameless-var-exp val gap-env-count)
                         (nameless-var-exp depth)
                         )
                     )
             )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
```

注意`translation-of-exp`函数会碰到`intermediary-nameless-var-exp`表达式的情况，直接返回即可，如果不添加这一句的话会跳转到`else`分支导致报错。

```scheme
(define (translation-of-exp exp senv)
  (cases expression exp
    ; translation-of-exp doesn't change intermediary-nameless-exp
    (intermediary-nameless-var-exp (num) exp)
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
```

`intermediary-nameless-var-exp->nameless-var-exp`对变量索引偏移量进行调整，注意该函数接受的是已经转换过的`nameless`版本。

```scheme
; transform intermediary-nameless-var-exp to nameless-var-exp and add offset to depth
(define (intermediary-nameless-var-exp->nameless-var-exp exp offset)
  (cases expression exp
    ; ...
    (nameless-var-exp (num) exp)
    (nameless-let-exp (exp1 body)
                      (nameless-let-exp
                       (intermediary-nameless-var-exp->nameless-var-exp exp1 offset)
                       (intermediary-nameless-var-exp->nameless-var-exp body offset)
                       )
                      )
    (nameless-proc-exp (body)
                       (nameless-proc-exp
                        (intermediary-nameless-var-exp->nameless-var-exp body offset)
                        )
                       )

    ; ...
    (intermediary-nameless-var-exp (num) (nameless-var-exp (+ num offset)))
    (else (eopl:error 'intermediary-nameless-var-exp->nameless-var-exp "unsupported expression type ~s" exp))
    )
  )
```

到这个步骤就完成了整个转换。

观察上述转换得到的代码可以发现`let f`的定义没有用到，可以移除（Exer 3.44）。

```eopl
let x = 3
  in let f = proc (y) -(y,x)
    in (proc (y) -(y, x) 13)
```

最终得到代码

```eopl
let x = 3
  in (proc (y) -(y, x) 13)
```

优化后的代码*运行时*不包含`let-exp`函数定义，这要求编译转换时知道偏移的环境变量中包含*非函数定义*的环境变量个数。

首先对`apply-senv`进行重构，之前返回的是索引深度和值的对`(depth . saved-val)`，修改为返回三个元素的列表`(non-proc-count proc-count val)`，其中`non-proc-count`代表非函数定义环境变量个数，`proc-count`代表函数定义环境变量的个数，二者之和`total-count`是总的个数，等于`depth + 1`。

```scheme
(define (apply-senv senv var)
  (let loop ([senv senv] [non-proc-count 0] [proc-count 0])
    (if (null? senv)
        (report-unbound-var var)
        (let* ([saved-var (caar senv)]
               [saved-val (cdar senv)]
               [non-proc-count (+ non-proc-count (if saved-val 0 1))]
               [proc-count (+ proc-count (if saved-val 1 0))])
          (if (eqv? saved-var var)
              (list
                non-proc-count
                proc-count
                saved-val
              )
              (loop
                (cdr senv)
                non-proc-count
                proc-count
                )
              )
          )
        )
    )
  )
```

然后更新`apply-senv`使用处的逻辑，之前的`depth`需要更新为`total-count - 1`，之前的`gap-env-count`需要替换为`total-count`，重构时不修改当前程序行为，所以使用`total-count`而不是`non-proc-count`。

```scheme
(define (translation-of-exp exp senv)
  (cases expression exp
    (var-exp (var) (let* ([record (apply-senv senv var)]
                          [non-proc-count (first record)]
                          [proc-count (second record)]
                          [total-count (+ non-proc-count proc-count)]
                          [val (third record)])
                     ; when a var is references, if is a proc
                     (if val
                         (intermediary-nameless-var-exp->nameless-var-exp val total-count)
                         (nameless-var-exp (- total-count 1))
                         )
                     )
             )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (var-exp->intermediary-nameless-var-exp exp senv limit)
  (cases expression exp
    ; ...
    (var-exp (var) (let* ([record (apply-senv senv var)]
                          [non-proc-count (first record)]
                          [proc-count (second record)]
                          [depth (- (+ non-proc-count proc-count) 1)]
                          )
                     (if (>= depth limit)
                         (intermediary-nameless-var-exp depth)
                         exp
                         )
                     )
             )
    ; ...
    (else (eopl:error 'var-exp->intermediary-nameless-var-exp "unsupported expression type ~s" exp))
    )
  )
```

重构完成后考虑添加去除函数定义`let-exp`的转换。首先处理`let-exp`，函数定义的情况下，直接返回`body`对应的表达式，这样`let-exp`的定义被去除。
但是注意`body`使用的环境变量`(extend-senv var new-proc-exp senv)`不变，因为环境变量要记录所有函数、非函数的所有变量进行分析。

```scheme
(define (translation-of-exp exp senv)
  (cases expression exp
    ; ...
    (let-exp (var exp1 body)
              ; when exp1 is a proc, transform its internal vars which references external definitions
              ; to intermediary-nameless-var-exp, remember this new-proc-exp in environment for later use.
              (if (is-proc-exp? exp1)
                (nameless-let-exp
                  ; translate proc as always, not used anymore when interpreted
                  (translation-of-exp exp1 senv)
                  (let* ([proc-exp-with-intermediary-var (var-exp->intermediary-nameless-var-exp exp1 senv 0)]
                        [new-proc-exp (translation-of-exp proc-exp-with-intermediary-var senv)]
                        )
                    (translation-of-exp body (extend-senv var new-proc-exp senv))
                    )
                  )
                (nameless-let-exp
                  ; translate proc as always, not used anymore when interpreted
                  (translation-of-exp exp1 senv)
                  (translation-of-exp body (extend-senv-normal var senv))
                  )
                )
             )
    ; ...
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
```

然后将函数体中外部变量进行转换处理，`var-exp`中`depth`有两处使用，第一处`depth`是作为识别外部变量的标记，外部变量的分析跟变量定义是函数、非函数 无关，所以`depth`含义未变化。第二个`depth`代表了外部变量在去除函数变量定义的情况下的索引值，替换为`(- non-proc-count 1)`。

```eopl
(define (var-exp->intermediary-nameless-var-exp exp senv limit)
  (cases expression exp
    ; ...
    (var-exp (var) (let* ([record (apply-senv senv var)]
                          [non-proc-count (first record)]
                          [proc-count (second record)]
                          [depth (- (+ non-proc-count proc-count) 1)]
                          )
                     (if (>= depth limit)
                         (intermediary-nameless-var-exp (- non-proc-count 1))
                         exp
                         )
                     )
             )
    ; ...
    (else (eopl:error 'var-exp->intermediary-nameless-var-exp "unsupported expression type ~s" exp))
    )
  )
```

最后对变量引用表达式`var-exp`的处理进行更新，由于编译去除了函数定义`let-exp`，所以运行时的环境变量偏移量只包括非函数变量定义，偏移从`total-count`要修改为`non-proc-count`。

```scheme
(define (translation-of-exp exp senv)
  (cases expression exp
    ; ...
    (var-exp (var) (let* ([record (apply-senv senv var)]
                          [non-proc-count (first record)]
                          [proc-count (second record)]
                          [total-count (+ non-proc-count proc-count)]
                          [val (third record)])
                     ; when a var is references, if is a proc
                     (if val
                         ; adjust it's internal intermediary-nameless-var-exp index, should add the offset
                         ; of current var def and the location of the proc it references
                         (intermediary-nameless-var-exp->nameless-var-exp val non-proc-count)
                         (nameless-var-exp (- non-proc-count 1))
                         )
                     )
             )
    ; ...
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
```
