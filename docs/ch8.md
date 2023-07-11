# Chapter 8 Module

大型项目需要语言支持模块机制，通过模块将项目拆分为多个高内聚、低耦合的部分。模块之间存在依赖关系，这种依赖关系最好**显式地**声明。一个模块依赖另外一个模块的抽象（abstraction）而不是实现（implementation），通过模块的抽象边界（abstraction boundaries）可以将实现细节封装在模块内部，在抽象不变的情况下，内部实现可以自由调整。

## 简单模块（Simple Module）

### 模块语法

本节介绍一个简单的模块系统的设计和实现，具体的语法参考下边的例子。`module`关键字声明一个模块，后面是模块的名称，`interface`关键字后边是模块接口的声明，一对方括号内的若干个名称及其类型；`body`关键字后边是模块主体部分，一对方括号内若干赋值等式，等式右边是支持的任意表达式。

在模块声明之后是整个程序的主体部分，可以是任意的合法表达式。模块声明的变量统一导出到模块名称下，使用`from m1 take a`的语法访问，`m1`是模块名称，`a`是具体的变量。

模块的实现中变量类型必须和接口中类型**相同**，接口中声明的变量实现中不能**缺少**，实现中可以包含接口中未声明的变量，例如变量`x`，这属于模块的实现细节。模块主体中变量采用和 `let*` 语句一样的作用域规则，前边的变量可以被后续变量初始化语句使用。

```simple-modules
module m1
  interface [
    a : int
    b : int
    c : int
  ]
  body [
    a = 33
    x = -(a,1) %= 32
    b = -(a,x) %= 1
    c = -(x,b) %= 31
  ]
let a = 10
      in -(-(from m1 take a, from m1 take b), a)
```

程序中可以包含多个模块。模块作用域也采用和`let*`一样的规则，前边的模块可以在后边模块的主体部分使用，在程序主体表达式中可以使用所有模块。

```simple-modules
module m1
  interface [u : int]
  body [u = 44]
module m2
  interface [v : int]
  body [v = -(from m1 take u,11)] %= 33
-(from m1 take u, from m2 take v) %= 11

```

为了实现方便，要求模块的接口和实现变量**顺序一致**。下面的顺序不一致的情况，类型检查会报错。

```simple-modules
module m1
  interface [u : int v : int]
  body [v = 33 u = 44]
from m1 take u
```

可以修改实现使得声明顺序不影响类型检查（[Exer 8.8](../ch8/8.1/exer-8.8)）。

### 实现

#### 基础数据结构

模块定义（module-definition）包括名称（m-name）、接口（expected-interface）、主体（m-body）三部分。接口是名称、类型对（declaration）的列表，主体是名称、表达式对（definition）的列表。

```scheme
(define-datatype module-definition module-definition?
  (a-module-definition (m-name symbol?) (expected-interface interface?) (m-body module-body?))
  )

(define-datatype interface interface?
  (simple-interface (declarations (list-of declaration?)))
  )

(define-datatype declaration declaration?
  (var-declaration (var-name symbol?) (ty type?))
  )

(define-datatype module-body module-body?
  (definitions-module-body (definitions (list-of definition?)))
  )

(define-datatype definition definition?
  (val-definition (var-name symbol?) (exp expression?))
  )
```

运行时模块主体部分是名称和值（value）的对的列表，可以直接使用`environment`来记录，用一个新定义的数据结构`typed-module`包起来。

```scheme
(define-datatype typed-module typed-module?
  (simple-module (bindings environment?))
  )
```

整个模块被封装在模块名称代表的变量中，模块名称可以被访问，需要在环境变量中需要保存，定义模块对应的结构。

```scheme
(define-datatype environment environment?
  ...
  (extend-env-with-module
   (m-name symbol?)
   (m-val typed-module?)
   (saved-env environment?)
   )
  )
```

这样形成普通环境变量`extend-env`和模块`extend-env-with-module`环境变量交替嵌套的情况，限定变量 `from m1 take a`（qualified variable）沿着环境变量查找模块`m1`，然后在模块中查找变量`a`。

```scheme
(define (lookup-qualified-var-in-env m-name var-name env)
  (let ([m-val (lookup-module-name-in-env m-name env)])
    (cases typed-module m-val
      (simple-module (bindings)
                     (apply-env bindings var-name)
                     )
      )
    )
  )

(define (lookup-module-name-in-env m-name env)
  (cases environment env
    (extend-env (var val saved-env)
                (lookup-module-name-in-env m-name saved-env)
                )
    (extend-env-rec (p-name b-var p-body saved-env)
                    (lookup-module-name-in-env m-name saved-env)
                    )
    (extend-env-with-module (this-m-name m-val saved-env)
                            (if (equal? m-name this-m-name)
                                m-val
                                (lookup-module-name-in-env m-name saved-env)
                                )
                            )
    (else (eopl:error 'lookup-module-name-in-env "fail to find module name ~s" m-name))
    )
  )
```

#### 模块加载

模块采用**立即加载**的方式，在碰到模块定义的时候`add-module-definitions-to-env`将多个模块顺序加载，递归实现满足`let*`的作用域规则，得到包含模块定义的的环境变量。

```scheme
(define (value-of-program prog)
  (cases program prog
    (a-program (m-defs body)
               ; lode multiple module into environment
               (let ([env (add-module-definitions-to-env m-defs (empty-env))])
                 (value-of-exp body env)
                 )
               )
    )
  )

(define (add-module-definitions-to-env defs env)
  (if (null? defs)
      env
      (cases module-definition (car defs)
        (a-module-definition (m-name expected-interface m-body)
                             (add-module-definitions-to-env
                              (cdr defs)
                              (extend-env-with-module
                               m-name
                               (value-of-module-body m-body env)
                               env
                               )
                              )
                             )
        )
      )
  )
```

`value-of-module-body`对单个模块加载，调用`definitions-to-env`将模块中多个变量顺序求值，递归的实现使用`let*`的作用域规则。

```scheme
(define (value-of-module-body m-body env)
  (cases module-body m-body
    (definitions-module-body (definitions)
      (simple-module (definitions-to-env definitions env))
      )
    )
  )

(define (definitions-to-env defs env)
  (if (null? defs)
      env
      (cases definition (car defs)
        (val-definition (var-name exp)
                        (definitions-to-env
                          (cdr defs)
                          ; let* scoping rule
                          (extend-env var-name (value-of-exp exp env) env)
                          )
                        )
        )
      )
  )
```

#### 类型检查

程序运行前需要对模块进行类型检查，模块的主体部分类型必须满足其接口声明。静态类型环境中同样需要定义新的环境类型`extend-tenv-with-module`保存模块的类型信息，[lookup-qualified-var-in-tenv](../ch8/8.1/simple-modules/checker/type-environment.rkt#L32)查询模块中类型变量。

```scheme
(define-datatype type-environment type-environment?
  ...
  (extend-tenv-with-module
   (name symbol?)
   (interface interface?)
   (saved-tenv type-environment?)
   )
  )
```

在[type-of-program](../ch8/8.1/simple-modules/checker/main.rkt#L17)中使用`add-module-to-definitions-to-tenv`对模块顺序分析。单个模块类型分析使用`interface-of`推导模块主体的类型，将定义（definition）转换为声明（declaration），得到推导的接口`simple-interface`。

```scheme
(define (interface-of m-body tenv)
  (cases module-body m-body
    (definitions-module-body (definitions)
      (simple-interface (definitions-to-declarations definitions tenv))
      )
    )
  )

(define (definitions-to-declarations definitions tenv)
  (if (null? definitions)
      '()
      (cases definition (car definitions)
        (val-definition (var-name exp)
                        (let ([ty (type-of exp tenv)])
                          (cons
                           (var-declaration var-name ty)
                           (definitions-to-declarations
                             (cdr definitions)
                             ; let* scoping rule
                             (extend-tenv var-name ty tenv)
                             )
                           )
                          )
                        )
        )
      )
  )
```

然后调用`<:iface`检查模块的实际类型`actual-interface`和声明的接口`expected-interface`是否一致。

```scheme
(define (add-module-definitions-to-tenv defs tenv)
  (if (null? defs)
      tenv
      (cases module-definition (car defs)
        (a-module-definition (m-name expected-interface m-body)
                             (let ([actual-interface (interface-of m-body tenv)])
                               (if (<:iface actual-interface expected-interface tenv)
                                   (let ([new-tenv (extend-tenv-with-module m-name expected-interface tenv) ])
                                     (add-module-definitions-to-tenv (cdr defs) new-tenv)
                                     )
                                   (report-module-doesnt-satisfy-iface m-name expected-interface actual-interface)
                                   )
                               )
                             )
        )
      )
  )
```

接口类型检查`<:iface`内部是对两组声明的检查`<:decls`，**递归实现**检查`decl2`是`decl1`的**子序列**，要求同一个名称对应的类型相等`equal?`。

```scheme
(define (<:iface iface1 iface2 tenv)
  (cases interface iface1
    (simple-interface (declarations1)
                      (cases interface iface2
                        (simple-interface (declarations2)
                                          (<:decls declarations1 declarations2 tenv)
                                          )
                        )
                      )
    )
  )

(define (<:decls declarations1 declarations2 tenv)
  (cond
    [(null? declarations2) #t]
    [(null? declarations1) #f]
    (else (let* ([decl1 (car declarations1)]
                 [name1 (decl->name decl1)]
                 [decl2 (car declarations2)]
                 [name2 (decl->name decl2)]
                 )
            (if (eqv? name1 name2)
                (and
                 (equal? (decl->type decl1) (decl->type decl2))
                 (<:decls (cdr declarations1) (cdr declarations2) tenv)
                 )
                (<:decls (cdr declarations1) declarations2 tenv)
                )
            )
          )
    )
  )
```

### 功能拓展

上述模块的语法及实现比较简单，还有很多可以改进的地方。

1. 禁止出现同名的模块（Exer 8.1）
2. 模块主体中的所有变量当前在环境变量中都可见，没有在接口中声明的变量属于实现细节，应该对外不可见（Exer 8.2）
3. 模块变量的语法可以从`from m take v`修改成其他形式`m.v`（Exer 8.3）
4. 当前模块只支持使用`[x = v]`的定义变量，可以支持使用`let`和`letrec`定义变量（Exer 8.5）
5. 支持局部模块，在模块主体中再定义子模块（Exer 8.6）
6. 支持模块作为普通变量导出（Exer 8.7）
7. 显式地声明模块之间的依赖关系（Exer 8.9）
8. 支持模块动态加载（8.10）
9. 支持模块主体中使用可选类型，接口类型检查使用类型推导的方式（8.11）。

#### 封装细节（Exer 8.2）

在模块加载时[value-of-module-body](../ch8/8.1/exer-8.2/interpreter.rkt#L48)，正常对模块主体的变量顺序求值，但是只将模块**声明中包含**的变量保存到环境变量中，方便后续访问。在[definitions-to-env](../ch8/8.1/exer-8.2/interpreter.rkt#L69)中使用`env`、`visible-env`两个环境变量，`env`包含内部实现的所有变量，求值的时候使用；`visible-env`只包含接口声明的环境变量，导出使用。

```scheme
(define (definitions-to-env defs decls env)
  (let ([visible-names (list->set (map decl->name decls))])
    (let loop ([defs defs] [env env] [visible-env env])
      (if (null? defs)
          visible-env
          (cases definition (car defs)
            (val-definition (var-name exp)
                            (loop
                             (cdr defs)
                             ; let* scoping rule
                             (extend-env var-name (value-of-exp exp env) env)
                             ; only add declared names to module environment
                             (if (set-member? visible-names var-name)
                                 (extend-env var-name (value-of-exp exp env) visible-env)
                                 visible-env
                                 )
                             )
                            )
            )
          )
      )
    )
  )
```

#### 局部模块（Exer 8.6）

局部模块支持在模块内部定义模块，`m2`只在`m1`中可见。

```simple-modules
module m1
  interface [u : int v : int]
  body
    module m2
      interface [v : int]
      body [v = 33]
    [u = 44 v = -(from m2 take v, 1)]
```

局部模块主体属于模块内部细节，对外部不可见，相当于在模块内部增加了多一层的模块环境。只需要在模块加载`value-of-module-body`调用[add-module-definitions-to-env](../ch8/8.1/exer-8.6/interpreter.rkt#L59)加载局部模块更新环境`env`即可。

```scheme
(define (value-of-module-body m-body env)
  (cases module-body m-body
    (definitions-module-body (modules definitions)
      (let ([env (add-module-definitions-to-env modules env)])
        (simple-module (definitions-to-env definitions env))
        )
      )
    )
  )
```

#### 导出模块（Exer 8.7）

支持在一个模块内把另外一个模块当做普通变量导出，模块也作为一个值存在。

```simple-modules
module m1
  interface [
    u : int
    n : [v : int]
  ]
  body
    module m2
      interface [v : int]
      body [v = 33]
    [
      u = 44
      n = m2
    ]
from m1 take n take v
```

首先定义[module-val](../ch8/8.1/exer-8.7/value.rkt#L19)代表模块值，[module-type](../ch8/8.1/exer-8.7/checker/type.rkt#L11)代表模块值的类型。模块当做普通值处理后，对应的环境`extend-env-with-module`和`extend-tenv-with-module`也不需要了。对于`from m1 take n take v`中对于`m1`查询当成普通变量对待，使用[get-qualified-var-mod](../ch8/8.1/exer-8.7/module.rkt#L53)将一层或者多层的嵌套模块属性提取出来，要求`val`必须是模块值。

```scheme
(define (value-of-exp exp env)
  (cases expression env
    ...
    (qualified-var-exp (m-name var-names)
                       (let ([val (apply-env env m-name)])
                         (get-qualified-var-mod val var-names)
                         )
                       )
    )
  )
```

对模块类型检查的是否处理类型，`module-type`是一个普通类型，需要注意的是模块接口（`interface`）和模块类型使用相同的语法，理论上可以使用同一个数据结构描述。但是这里沿用了接口（`simple-interface`），新增了模块类型（`module-type`），接口只在模块定义的**最顶层**使用，内部变量类型可能嵌套了一层或者多层的模块类型。内部模块的类型使用了`simple-interface`表示，类型检查的时候[definitions-to-declarations](../ch8/8.1/exer-8.7/checker/main.rkt#L64)需要转换处理。在访问`from m1 take n take v`的类型变量时[definitions-to-declarations](../ch8/8.1/exer-8.7/checker/main.rkt#L179)，同样需要兼容处理。

#### 依赖声明（Exer 8.9）

使用`depends-on`显式声明依赖的模块，在当前模块中只导入声明依赖的模块，未导入的模块不可见，在模块`m5`中只有`m1`/`m3`可见。

```simple-modules
module m1
  interface [a : int b : int]
  body [a = 1 b = 2]
module m2
  interface [a : int b : int]
  body [a = 3 b = 4]
module m3
  interface [a : int b : int]
  body [a = 5 b = 6]
module m4
  interface [a : int b : int]
  body [a = 7 b = 8]
module m5
  interface [a : int b : int]
  body
    m1, m3
    [
        a = -(from m3 take a, from m1 take a) %= 4
        b = -(from m3 take b, from m1 take b) %= 4
    ]
-(from m5 take a, from m5 take b) %= 0
```

实现起来比较简单，[value-of-module-body](../ch8/8.1/exer-8.9/checker/main.rkt#L179)只要在环境变量中过滤掉未声明的模块即可。类型推导中实现逻辑类似。

```scheme
(define (value-of-module-body m-body env)
  (cases module-body m-body
    (definitions-module-body (dependencies definitions)
      (let ([visible-env (keep-only-dependencies dependencies env)])
        (simple-module (definitions-to-env definitions visible-env))
        )
      )
    )
  )
```

[keep-only-dependencies](../ch8/8.1/exer-8.9/checker/environment.rkt#L83)环境变量的过滤通过递归实现，遍历所有环境变量，未声明依赖的模块环境剔除。

```scheme
(define (keep-only-dependencies dependencies env)
  (cases environment env
    (empty-env () env)
    (extend-env (var val saved-env)
                (extend-env var val (keep-only-dependencies dependencies saved-env))
                )
    (extend-env-rec (p-name b-var p-body saved-env)
                    (extend-env-rec p-name b-var p-body (keep-only-dependencies dependencies saved-env))
                    )
    (extend-env-with-module (m-name m-val saved-env)
                            (if (member m-name dependencies)
                              (extend-env-with-module m-name m-val (keep-only-dependencies dependencies saved-env))
                              (keep-only-dependencies dependencies saved-env)
                              )
                            )
  )
)
```

#### 动态加载（Exer 8.10）

模块定义的时候不立即加载，使用`import`语句动态加载模块。这里使用语法`import [m3, m1]`，模块中的`import`语句是可选的。

```simple-modules
module m1
    interface []
    body [x = print(1)]
module m2
    interface []
    body [x = print(2)]
module m3
    interface []
    body
        import [m2]
        [x = print(3)]
import [m3,m1]
33
```

`import m1` 有两种可能，导入一个名称为`m1`的模块；或者`import`是空语句，`m1` 是变量名，方括号是为了避免 LL(1)语法冲突。

模块名称的变量在模块定义的时候已经保存在环境中了，`import`的作用是对模块进行求值，并将环境变量中保存的模块定义更新为模块值，参考[import-modules!](../ch8/8.1/exer-8.10/interpreter.rkt#L40)。

```scheme
(define (import-modules! import-decl env)
  (let ([names (import-declaration->names import-decl)])
    (map (lambda (name)
        (let* ([val (apply-env env name)]
               [mod (expval->module val)]
               [m-body (mcar mod)]
               [mod-val (mcdr mod)]
               )
          (if (eqv? mod-val 'uninitialized)
              (set-mcdr! mod (value-of-module-body m-body env))
              #f
          )
        )
    ) names)
  )
)
```

#### 类型推导（Exer 8.11）

支持模块主体中使用可选类型，下面代码中函数`proc (x: ?) x`的类型推导与标注类型`f: (int -> bool)`推导不成立。

```simple-modules
module m
    interface [f : (int -> bool)]
    body [f = proc (x : ?) x]
1
```

需要修改类型检查函数[<:decls](../ch8/8.1/exer-8.10/checker/main.rkt#L94)，使用类型推导算法`unifier`，类型推导失败说明模块主体不符合接口声明。

```scheme
(define (<:decls declarations1 declarations2 tenv)
  (let loop ([declarations1 declarations1] [declarations2 declarations2] [subst '()])
    (cond
      [(null? declarations2) #t]
      [(null? declarations1) #f]
      (else (let* ([decl1 (car declarations1)]
                   [name1 (decl->name decl1)]
                   [decl2 (car declarations2)]
                   [name2 (decl->name decl2)]
                   )
              (if (eqv? name1 name2)
                  (loop (cdr declarations1) (cdr declarations2) (unifier (decl->type decl1) (decl->type decl2) subst (var-exp name1)))
                  (loop (cdr declarations1) declarations2 subst)
                  )
              )
            )
      )
    )
  )
```

## 导出类型模块

### 两种类型

简单模块中只支持定义并导出值，新增模块语法支持定义和导出**类型**，包括透明类型（transparent type）和不透明类型（opaque type）两种。

在模块中使用透明类型，模块 `m1` 中定义了透明类型`t`代表类型`int`，在模块**内部或者外部**使用类型`t`的效果等同于替换为`int`。函数定义中`from m1 take t`就是`int`类型，所以表达式`-(x,0)`类型正确。

```transparent-types
module m1
  interface [
    transparent t = int
    z : t
    s : (t -> t)
    is-z? : (t -> bool)
  ]
  body [
    type t = int
    z = 33
    s = proc (x : t) -(x,-1)
    is-z? = proc (x : t) zero?(-(x,z))
  ]
proc (x : from m1 take t)
  (from m1 take is-z? -(x,0))
```

同样的例子使用不透明类型来定义。

```opaque-types
module m1
  interface [
    opaque t
    z : t
    s : (t -> t)
    is-z? : (t -> bool)
  ]
  body [
    type t = int
    z = 33
    s = proc (x : t) -(x,-1)
    is-z? = proc (x : t) zero?(-(x,z))
  ]
proc (x : from m1 take t)
  (from m1 take is-z? -(x,0))
```

不透明类型在模块外部通过`from m1 take t`的形式使用，与透明类型的差异之处在于外部代码是无法知道`t`对应的具体类型的，`t`的具体类型作为实现细节被封装在**模块内部**，因此表达式`-(x,0)`无法通过类型检查，因为只能知道`x`的类型是`from m1 take t`，不知道`t`内部的实际类型。不透明类型相比于透明类型提供了更完善的**抽象**机制。

对于不透明类型的数据只能通过模块导出的函数去操作，将`is-z? -(x,0)`修改为`is-z? x`即可通过类型检查。

```opaque-types
module m1
  interface [
    opaque t
    z:t
    s : (t -> t)
    is-z? : (t -> bool)
  ]
  body [
    type t = int
    z = 33
    s = proc (x : t) -(x,-1)
    is-z? = proc (x : t) zero?(-(x,z))
  ]
proc (x : from m1 take t)
  (from m1 take is-z? x)
```

透明类型和不透明类型的作用域都采用`let*`规则。

### `tables` 模块

使用不透明类型来实现一个`tables`模块，模块的效果和环境记录（Environment）类似，保存了一组键值对。这里采用函数形式实现（Procedural Representation），使用柯里化（Currying）的技巧实现多参数函数（[Exer 8.15](../ch8/8.2/exer-8.15/README.md)）。

```opaque-types
module tables
    interface [
        opaque table
        empty: table
        add-to-table: (int -> (int -> (table -> table)))
        lookup-in-table: (int -> (table -> int))
    ]
    body [
        type table = (int -> int)
        empty = proc (x: int) 0
        add-to-table = proc (x: int) proc (y: int) proc (t: table)
                            proc (target: int)
                                if zero?(-(target, x))
                                then y
                                else (t target)
        lookup-in-table = proc (x: int) proc (t: table) (t x)
    ]
let empty = from tables take empty
    in let add-binding = from tables take add-to-table
        in let lookup = from tables take lookup-in-table
            in let table1 = (((add-binding 3) 300)
                             (((add-binding 4) 400)
                              (((add-binding 3) 600) empty)))
                in -(((lookup 4) table1), ((lookup 3) table1)) %= 100
```

空的`table`实现为一个接受任意数字`int`都返回`0`的函数，`add-to-table`实现为闭包函数。

### 实现

#### 语法更新

为了支持透明类型和不透明类型，首先对类型语法进行扩展。模块中的类型标注可以使用标识符`t`代表已经定义的类型，例如`is-z? : (t -> bool)`，定义`named-type`类型。

```scheme
; parser.rkt
(type (identifier) named-type)

; type.rkt
(named-type (name symbol?))
```

在模块外部，不透明类型只能使用`from m1 take t`的形式使用，不能被展开，被当做和`int`、`bool`一样的**基础**类型处理，定义`qualified-type`支持。

```scheme
; parser.rkt
(type (m-name t-name) qualified-type)

; type.rkt
(qualified-type (m-name symbol?) (t-name symbol?))
```

模块中增加透明类型声明（[transparent-type-declaration](../ch8/8.2/opaque-types/parser.rkt#L25)）和不透明类型声明（[opaque-type-declaration](../ch8/8.2/opaque-types/parser.rkt#L24)）支持两种类型定义。

```scheme
(transparent-type-declaration (var-name symbol?))

(opaque-type-declaration (var-name symbol?) (ty type?))
```

模块主体中增加类型定义（[type-definition](../ch8/8.2/opaque-types/module.rkt#L36)）。

```scheme
(type-definition (var-name symbol?) (ty type?))
```

新增类型导出对于解释器部分的逻辑没有影响，只要更新对应数据结构字段并忽略处理即可（[type-definition](../ch8/8.2/opaque-types/interpreter.rkt#L75)）。主要的修改在类型检查器部分。

#### 类型展开

新增的限定类型（qualified type） `from m1 take t` 当做基础类型处理，`named-type`在类型检查过程中需要被展开为实际的类型，便于进行类型检查。在对模块主体中定义语句顺序处理过程中，类型定义需要记录在环境中，方便后续使用。

```opaque-types
module m1
  interface [
    opaque t
    z : t
    s : (t -> t)
    is-z? : (t -> bool)
  ]
  body [
    type t = int
    z = 33
    s = proc (x : t) -(x,-1)
    is-z? = proc (x : t) zero?(-(x,z))
  ]
```

`type t = int`定义了`t`是`int`类型，为变量`s`推导类型时需要知道这个信息，定义`extend-tenv-with-type`将类型定义`type t = int`保存到环境中。

```scheme
(define-datatype type-environment type-environment?
  (extend-tenv-with-type
   (name symbol?)
   (ty type?)
   (saved-tenv type-environment?)
  )
)
```

变量`s`的类型标注为`(t -> int)`，同样需要在环境变量中记录。这里有两个选择，可以将`s`的类型直接保存为`(t -> int)`；也可以将`t`先展开为`int`，将`s`的类型记录为`(int -> int)`。两种做法表达的信息量是相同的，未展开的类型需要在每处使用时临时展开，会多次展开；这里定义[expand-type](../ch8/8.2/opaque-types/checker/expand.rkt#L7)函数将类型展开后保存到环境中，展开一次，后续直接使用。

```scheme
(define (expand-type ty tenv)
  (cases type ty
    (int-type () (int-type))
    (bool-type () (bool-type))
    (proc-type (arg-type result-type)
               (proc-type (expand-type arg-type tenv) (expand-type result-type tenv))
               )
    (named-type (name)
                (lookup-type-name-in-tenv name tenv)
                )
    (qualified-type (m-name t-name)
                    (lookup-qualified-type-in-tenv m-name t-name tenv)
                    )
    )
  )
```

在`type-of`函数的定义中，在对环境变量扩展的地方同样需要调用`expand-type`对类型展开，`type-of`也返回展开的类型，参考对`proc-exp`的处理。 `type-of`中对于`expand-type`的调用处比较多，容易遗漏出错，将对于`expand-type`的调用封装到新建环境变量[extend-tenv-auto-expansion](../ch8/8.2/exer-8.18/checker/main.rkt#L17)的过程中，可以使代码更简单健壮（[Exer 8.18](../ch8/8.2/exer-8.18)）。

```scheme
(define (type-of exp tenv)
  (cases expression exp
    ; ...
    (proc-exp (var var-type body)
              (let* ([expanded-var-type (expand-type var-type tenv)]
                     [result-type (type-of body (extend-tenv var expanded-var-type tenv))])
                (proc-type expanded-var-type result-type)
                )
              )
  )
)
```

#### 接口展开

模块接口定义的不透明类型，在模块外部引用只能是`from m1 take t`的形式，参考下面函数参数`x`的类型标注。

```opaque-types
module m1
  interface [
    opaque t
    z : t
    s : (t -> t)
    is-z? : (t -> bool)
  ]
  body [
    type t = int
    z = 33
    s = proc (x : t) -(x,-1)
    is-z? = proc (x : t) zero?(-(x,z))
  ]
(proc (x : from m1 take t) (from m1 take is-z? x) from m1 take z)
```

所以使用模块`m1`对环境变量扩展时，记录的不透明类型`opaque t`应该转换为透明类型`transparent t = from m1 take t`，不透明类型被展开使用。
在将模块主体转换为模块定义的代码逻辑中，使用[extend-tenv-with-module](../ch8/8.2/opaque-types/checker/main.rkt#L26)将模块记录到环境变量中，对应值是**展开**的接口`expanded-iface`。后续模块主体内、其他模块以及整个程序的主表达式访问模块`m1`看到就都是被展开过的类型。

```scheme
(define (add-module-definitions-to-tenv defs tenv)
  ; ...
  (let* ([expanded-iface (expand-iface m-name expected-interface tenv)]
         [new-tenv (extend-tenv-with-module m-name expanded-iface tenv)])
    (add-module-definitions-to-tenv (cdr defs) new-tenv)
    )
)
```

接口定义使用`let*`作用域，其中可能定义多个不透明类型，所以每展开一个类型就将这个信息保存到环境中，对后续声明可见。采用递归的方式实现[expand-iface](../ch8/8.2/opaque-types/checker/expand.rkt#L31)。

```scheme
(define (expand-declarations m-name declarations tenv)
  (if (null? declarations)
    '()
    (cases declaration (car declarations)
      (opaque-type-declaration (t-name)
        (let* ([expanded-type (qualified-type m-name t-name)]
               [new-tenv (extend-tenv-with-type t-name expanded-type tenv)])
          (cons
            (transparent-type-declaration t-name expanded-type)
            (expand-declarations m-name (cdr declarations) new-tenv)
          )
        )
      )
      (transparent-type-declaration (t-name ty)
        (let* ([expanded-type (expand-type ty tenv)]
               [new-tenv (extend-tenv-with-type t-name expanded-type tenv)])
          (cons
            (transparent-type-declaration t-name expanded-type)
            (expand-declarations m-name (cdr declarations) new-tenv)
          )
        )
      )
      (var-declaration (var-name ty)
        (let* ([expanded-type (expand-type ty tenv)])
          (cons
            (var-declaration var-name expanded-type)
            (expand-declarations m-name (cdr declarations) tenv)
          )
        )
      )
    )
  )
)
```

`transparent-type-declaration`类型不变，更新`tenv`为`new-tenv`；`var-declaration`类型不变，而且没有定义新类型，继续使用`tenv`。

#### 主体类型推导

模块主体中增加了类型定义语法（type-definition），对应的类型推导[interface-of](../ch8/8.2/opaque-types/checker/expand.rkt#L61)逻辑需要更新，将类型定义转换为透明类型声明。模块主体的也是用`let*`作用域规则，同样使用递归方式更新`tenv`并将`type-definition`转换为透明类型。

```scheme
(define (definitions-to-declarations definitions tenv)
  (if (null? definitions)
      '()
      (cases definition (car definitions)
        ; ...
        (type-definition (var-name ty)
                         (let ([new-env (extend-tenv-with-type var-name (expand-type ty tenv) tenv)])
                          (cons
                            (transparent-type-declaration var-name ty)
                            (definitions-to-declarations (cdr definitions) new-env)
                          )
                         )
                         )
        )
      )
  )
```

#### 接口类型检查

`interface-of`推导模块主体的接口得到`expected-interface`，其中包括变量声明和透明类型声明两种，不包括不透明类型声明。模块接口定义声明中变量声明、透明类型、不透明类型三种都有。接口声明使用了`let*`作用域规则，为了判断推导得到的主体接口与声明接口兼容，同样需要一个更新的`tenv`记录已经定义的类型。

下面例子中，应该记录`transparent t = int`的信息，这样左侧`y`的类型`t`就能展开为`int`，判断出实现类型符合接口声明。

```opaque-types
[
  transparent t = int
  x : bool               <  [ y : int ]
  y : t
]
```

对于环境的扩展应该使用模块主体推导的接口，因为推导得到的类型是展开过的，不包含不透明类型。下面是一个包含不透明类型的例子。

```opaque-types
[                                     [
  transparent t = int                     opaque t
  transparent u = (t -> t)    <:          transparent u = (t -> int)
  f : (t -> u)                            f : (t -> (int -> int))
]                                     ]
```

接口类型判断调用`<:decls`，仍然顺序判断。对于同名的声明，调用`<:decl`判断单个声明类型是否兼容。`declarations1`中每个定义都扩展使用`extend-tenv-with-declaration`扩展`tenv`。

```scheme
(define (<:decls declarations1 declarations2 tenv)
  (cond
    [(null? declarations2) #t]
    [(null? declarations1) #f]
    (else (let* ([decl1 (car declarations1)]
                 [name1 (declaration->name decl1)]
                 [decl2 (car declarations2)]
                 [name2 (declaration->name decl2)]
                 )
            (if (eqv? name1 name2)
                (and
                 (<:decl (car declarations1) (car declarations2) tenv)
                 (<:decls (cdr declarations1) (cdr declarations2) (extend-tenv-with-declaration (car declarations1) tenv))
                 )
                (<:decls (cdr declarations1) declarations2 (extend-tenv-with-declaration (car declarations1) tenv))
                )
            )
          )
    )
  )
```

[<:decl](../ch8/8.2/opaque-types/checker/main.rkt#L114)单个声明类型判断有三种情况。

1. 都是变量声明，而且类型相同。
1. 都是透明类型声明，而且类型相同。
1. 左边是透明类型，右边是不透明类型。右边不透明类型，可以实例化为任何一个具体类型，所以左边是透明类型的情况下，类型是兼容的。

这里的跟书上的情况稍有不同，因为`declarations1`是推导得来的，只可能包括变量声明和透明类型，所以左边不可能是不透明类型。当前实现中在`<:decl`和[extend-tenv-with-declaration](../ch8/8.2/opaque-types/checker/expand.rkt#L73)排除了这种情况。

```scheme
(define (<:decl decl1 decl2 tenv)
  (or
    (and
      (var-declaration? decl1)
      (var-declaration? decl2)
      (equiv-type? (declaration->type decl1) (declaration->type decl2) tenv)
    )
    (and
      (transparent-type-declaration? decl1)
      (transparent-type-declaration? decl2)
      (equiv-type? (declaration->type decl1) (declaration->type decl2) tenv)
    )
    (and
      (transparent-type-declaration? decl1)
      (opaque-type-declaration? decl2)
    )
    ; code different from the book
    ; (and
    ;  (opaque-type-declaration? decl1)
    ;  (opaque-type-declaration? decl2)
    ; )
  )
)
```

## 顺序无关

[习题 8.17](../ch8/8.2/exer-8.17/checker/main.rkt#L93)要求实现接口检查时，允许接口声明与实现**顺序不一致**。在简单模块中顺序无关的实现比较简单，只要检查接口中的每个声明在实现中类型都相同即可。但是这里因为环境需要按照模块主体中声明（`declarations1`）顺序叠加，所以也必须使按照这个顺序检查，不能像简单模块那样使用接口顺序（`declarations2`）检查。

按照模块主体顺序检查，如果在接口声明中没找到**同名**定义，那么对此项类型不做要求；如果找到同名定义，要求类型相同；如果类型不相同检查不通过，所有声明类型检查都通过才算接口类型通过。

注意这里有个额外的逻辑，因为是按照模块主体的顺序进行检查，所以对于接口有定义但是无实现的情况会遗漏掉，这种情况下类型检查也不通过。

```scheme
(define (<:decls declarations1 declarations2 tenv)
  (cond
    [(null? declarations2) #t]
    ; missing implementation
    [(ormap (lambda (decl2) (not (findf (lambda (decl1) (eqv? (declaration->name decl1) (declaration->name decl2))) declarations1))) declarations2) #f]
    [else
     (let loop ([declarations1 declarations1] [tenv tenv])
       (if (null? declarations1)
           #t
           (let* ([decl1 (car declarations1)]
                  [name1 (declaration->name decl1)]
                  [decl2 (findf (lambda (decl2) (eqv? (declaration->name decl2) name1)) declarations2)])
             (if decl2
                 (if (<:decl decl1 decl2 tenv)
                     (loop (cdr declarations1) (extend-tenv-with-declaration decl1 tenv))
                     #f
                     )
                 #t
                 )
             )
           )
       )
     ]
    )
  )
```

## 函数模块

当前的模块设计中，模块之间的依赖隐式或者显式（Exer 8.9）地指定，模块之间的依赖是**固定的**，无法将被依赖的模块替换成具有相同接口不同实现的其他模块。设计新的语法支持函数模块（module procedure），也称为参数化模块（parameterized module）。

下面例子中定义函数模块`to-int-maker`，模块主体部分使用了类似函数的定义，`module-proc`关键字开头，指定函数参数`ints`及其类型，函数体和之前的模块主体定义相同。模块主体中使用`ints`参数而不是具体的模块，这样将对于具体模块的依赖修改为了对于抽象接口的依赖。

```proc-modules
module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
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
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
```

定义新的模块`ints1-to-int`，在模块主体中使用和函数调用相同的语法，第一个参数`to-int-maker`是参数化模块，第二个参数`ints1`模块符合参数`ints`代表的接口。

```proc-modules
module ints1
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]

module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
```

### 实现

#### 新类型定义

首先定义新的接口类型`proc-interface`描述函数模块的接口类型，记录了函数接口的参数名称、类型和返回类型。

```scheme
(define-datatype interface interface?
  ; ...
  (proc-interface (param-name symbol?) (param-iface interface?) (result-iface interface?))
  )
```

定义新的模块主体类型，支持函数模块主体定义、函数模块调用。

```scheme
(define-datatype module-body module-body?
  ; ...
  (proc-module-body (m-name symbol?) (m-type interface?) (m-body module-body?))
  (var-module-body (m-name symbol?))
  (app-module-body (rator symbol?) (rand symbol?))
  )
```

#### 运行时求值

为了在**运行时**支持函数模块，需要定义新的模块类型`proc-module`，包括函数模块定义的参数名、函数体和环境变量信息，类似于普通函数。

```scheme
(define-datatype typed-module typed-module?
  ; ...
  (proc-module (b-var symbol?) (body module-body?) (saved-env environment?))
  )
```

[value-of-module-body](../ch8/8.3/proc-modules/interpreter.rkt.#L57)在对运行时对新的模块主体类型求值，`proc-module-body`类型生成对应`proc-module`，`app-module-body`类型应用函数模块，生成具体的模块，函数调用必须是`proc-module`类型。`app-module-body`的操作符和操作数都是用标识符语法（identifier），定义辅助类型`var-module-body`方便模块主体求值处理。

```scheme
(define (value-of-module-body m-body env)
  (cases module-body m-body
    ; ...
    (var-module-body (m-name)
                     (lookup-module-name-in-env m-name env)
                     )
    (proc-module-body (m-name m-type m-body)
                      (proc-module m-name m-body env)
                      )
    (app-module-body (rator rand)
                     (let ([rator-val (lookup-module-name-in-env rator env)]
                           [rand-val (lookup-module-name-in-env rand env)])
                       (cases typed-module rator-val
                         (proc-module (m-name m-body env)
                                      (value-of-module-body m-body (extend-env-with-module m-name rand-val env))
                                      )
                         (else (report-bad-module-app rator-val))
                         )
                       )
                     )
    )
  )
```

#### 类型推导

类型检查中需要更新对于模块类型的推导[interface-of](../ch8/8.3/proc-modules/checker/main.rkt.#L37)。`proc-module-body`对应生成`proc-interface`，对于操作数的接口类型`rand-iface`因为型后续会被引用，所以需要展开为基础类型`expanded-iface`。

```proc-modules
(define (interface-of m-body tenv)
  (cases module-body m-body
    ; ...
    (var-module-body (m-name)
                     (lookup-module-name-in-tenv tenv m-name)
                     )
    (proc-module-body (rand-name rand-iface m-body)
                      (let* ([expanded-iface (expand-iface rand-name rand-iface tenv)]
                             [new-env (extend-tenv-with-module rand-name expanded-iface tenv)]
                             [body-iface (interface-of m-body new-env)])
                        (proc-interface rand-name rand-iface body-iface)
                        )
                      )
    (app-module-body (rator-id rand-id)
                     (let ([rator-iface (lookup-module-name-in-tenv tenv rator-id)]
                           [rand-iface (lookup-module-name-in-tenv tenv rand-id)])
                       (cases interface rator-iface
                         (simple-interface (decls)
                                           (report-attempt-to-apply-simple-module rator-id)
                                           )
                         (proc-interface (param-name param-iface result-iface)
                                         (if (<:iface rand-iface param-iface tenv)
                                             (rename-in-iface result-iface param-name rand-id)
                                             (report-bad-module-application-error param-iface rand-iface m-body)
                                             )
                                         )
                         )
                       )
                     )
  )
)
```

`app-module-body`的接口类型检查要求操作符`rator-id`引用的模块类型必须是`proc-interface`，操作数类型`rand-iface`必须满足接口参数`param-iface`。
推导得到的接口返回类型`result-iface`中，需要接口中使用的形参名称替换为实参名称。

```proc-modules
module ints1
    interface [
        opaque t
        zero : t
        succ : (t -> t)
        pred : (t -> t)
        is-zero : (t -> bool)
    ]
    body [
        type t = int
        zero = 0
        succ = proc(x : t) -(x,-5)
        pred = proc(x : t) -(x,5)
        is-zero = proc (x : t) zero?(x)
    ]

module to-int-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            to-int: (from ints take t -> int)
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
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]

module ints1-to-int
    interface [
        to-int: (from ints1 take t -> int)
    ]
    body
        (to-int-maker ints1)
```

函数模块`to-int-maker`定义中接口参数名称是`ints`，使用在返回值类型中`(from ints take t -> int)`。在模块`ints1-to-int`中调用了`(to-int-maker ints1)`，返回类型应该使用`ints1`替换接口返回类型`(from ints take t -> int)`的`ints`，得到类型`(from ints1 take t -> int)`，和模块`ints1-to-int`的接口定义一致。

函数[rename-in-iface](../ch8/8.3/proc-modules/checker/renaming.rkt.#L7)递归地处理接口（interface）、声明（declaration）、类型（type）等结构，将受限类型中的名称进行替换。注意`proc-interface`、`opaque-type-declaration`、`transparent-type-declaration`定义了新的类型变量，可能与要替换的名称重名，重名的情况不需要替换，类似于自由变量的替换处理逻辑。

```scheme
(define (rename-in-iface iface old new)
  (cases interface iface
    (simple-interface (decls)
                      (simple-interface (rename-in-decls decls old new))
                      )
    (proc-interface (param-name param-iface result-iface)
                    (proc-interface
                     param-name
                     (rename-in-iface param-iface old new)
                     ; param-name shadows old in result-iface
                     (if (eqv? param-name old)
                         result-iface
                         (rename-in-iface result-iface old new)
                         )
                     )
                    )
    )
  )
```

最终在`qualified-type`类型中使用`rename-name`进行名称替换。

```scheme
(define (rename-in-type ty old new)
  (cases type ty
    (proc-type (arg-type result-type)
               (proc-type (rename-in-type arg-type old new) (rename-in-type result-type old new))
               )
    (named-type (name)
                (named-type (rename-name name old new))
                )
    (qualified-type (m-name t-name)
                    (qualified-type (rename-name m-name old new) t-name)
                    )
    (else ty)
    )
  )

(define (rename-name name old new)
  (if (eqv? name old) new old)
  )
```

#### 类型检查

新增了`proc-interface`类型需要更新接口类型检查`<:iface`逻辑，两种接口`simple-interface`、`proc-interface`之间是不兼容的，重点看下如何检查两个`proc-interface`是否兼容。

检查函数接口`iface1`是否和`iface2`兼容，也就是说`iface1`类型能否当做`iface2`使用。`iface1`能当做`iface2`使用，要求`iface2`能接受的参数类型`iface1`也能**接受**，也就是说`iface1`的参数类型`param-iface1`应该包括`iface2`的参数类型`param-iface2`，这叫做函数的参数类型是**逆变的**（contravariant）。`iface1`能当做`iface2`使用，要求所有使用了`iface2`调用的地方，能替换为`iface1`的调用，也就是说`iface1`的返回值的类型`result-iface1`应该在`iface2`返回类型`result-iface2`的范围内，称之为函数返回类型是协变的（covariant）。

接口返回类型检查时使用的环境变量，应该包括函数参数代表的接口类型，返回类型中的参数名称替换成统一个名称`new-name`方便对比返回类型，这个处理类似第七章类型检查中的[canonical-subst](./ch7.md#L443)处理。

```scheme
(define (<:iface iface1 iface2 tenv)
  (cases interface iface1
    ; ...
    (proc-interface (param-name1 param-iface1 result-iface1)
                    (cases interface iface2
                      ; ...
                      (proc-interface (param-name2 param-iface2 result-iface2)
                                      (let* ([new-name (fresh-module-name param-name1)]
                                             [result-iface1 (rename-in-iface result-iface1 param-name1 new-name)]
                                             [result-iface2 (rename-in-iface result-iface2 param-name2 new-name)])
                                        (and
                                         ; parameter type contra-variant
                                         (<:iface param-iface2 param-iface1 tenv)
                                         ; result type covariant
                                         (<:iface result-iface1 result-iface2
                                                  (extend-tenv-with-module
                                                   new-name
                                                   (expand-iface new-name param-iface1 tenv)
                                                   tenv
                                                   ))
                                         )
                                        )
                                      )
                      )
                    )
    )
)
```

### double-ints-maker

习题 8.21 基于表示整数`k`任意`ints`模块定义新的`double-ints`模块，`double-ints`模块内部使用`2*k`表示整数`k`。

```proc-modules
module double-ints-maker
    interface
        ((ints: [
            opaque t
            zero: t
            succ: (t -> t)
            pred: (t -> t)
            is-zero: (t -> bool)
        ]) => [
            opaque t
            zero: from ints take t
            succ: (from ints take t -> from ints take t)
            pred: (from ints take t -> from ints take t)
            is-zero: (from ints take t -> bool)
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
            type t = from ints take t
            zero = from ints take zero

            diff = letrec (from ints take t -> from ints take t) diff (x: from ints take t) = proc (y: from ints take t)
                                if (from ints take is-zero y)
                                then x
                                else ((diff (from ints take pred x)) (from ints take pred y))
                        in diff

            equal = proc (x: from ints take t) proc (y: from ints take t)
                        if (from ints take is-zero ((diff x) y))
                        then zero?(0) %= true
                        else zero?(1) %= false

            average = letrec (from ints take t -> from ints take t) average (x: from ints take t) = proc (y: from ints take t)
                                if ((equal x) y)
                                then x
                                else ((average (from ints take succ x)) (from ints take pred y))
                        in average

            succ = proc (x: from ints take t) (from ints take succ (from ints take succ x))
            pred = proc (x: from ints take t) (from ints take pred (from ints take pred x))

            is-zero = proc (x: from ints take t) (from ints take is-zero ((average zero) x))
        ]
```

`double-ints`的`zero`使用和`ints`相同的表示。

求和`plus`利用等式 `(plus x y) = (plus (- x 1) (+ y 1))`递归实现，递归出口是 `(plus 0 y) = y`。

求差`diff`利用等式 `(diff x y) = (diff (- x 1) (- y 1))`递归实现，递归出口是 `(diff x 0) = x`。

`equal` 利用两个数字差值为零时代表相等来实现`(equal x y) = (zero (diff x y))`。

`succ`、`pred`分别相当于之前的操作应用两次。

平均值`(average x y)` 通过将每次将`x`递增，`y`递减，直到相等来实现。在`2*k`的表示中，`x`、`y`的平均值肯定存在。

`is-zero`判断数字`x`是否是零，首先利用`(average 0 x)`求得 `x = 2*k`中对应的`k`，然后利用`ints`模块的`is-zero`判断`k`是否是零。

### 扩展模块调用语法

当前的模块调用语法中只支持使用标识符的形式`(id1 id2)`。

```scheme
(define the-grammar
    ; ...
    (module-body ("("identifier identifier")") app-module-body)
)
```

可以扩展语法支持任意`module-body`允许的形式（[Exer 8.26](../ch8/8.3/exer-8.26)）。

```scheme
(define the-grammar
    ; ...
    (module-body ("("module-body module-body")") app-module-body)
)
```

更新运行时对于模块调用的求值逻辑，之前使用`lookup-module-name-in-env`查找标识符代表的模块名，修改为递归调用`value-of-module-body`进行求值。

```scheme
(define (value-of-module-body m-body env)
  (cases module-body m-body
    (app-module-body (rator rand)
                     (let ([rator-val (value-of-module-body rator env)]
                           [rand-val (value-of-module-body rand env)])
                       (cases typed-module rator-val
                         (proc-module (m-name m-body env)
                                      (value-of-module-body m-body (extend-env-with-module m-name rand-val env))
                                      )
                         (else (report-bad-module-app rator-val))
                         )
                       )
                     )
    )
  )
```

类型检查部分的逻辑同样需要更新[Exer 8.24](../ch8/8.3/exer-8.24)。之前使用`lookup-module-name-in-tenv`查找标识符代表的模块类型，修改为使用`interface-of`递归推导类型。

```scheme
(define (interface-of m-body tenv)
  (cases module-body m-body
    (app-module-body (rator rand)
                     (let ([rator-iface (interface-of rator tenv)]
                           [rand-iface (interface-of rand tenv)])
                       (cases interface rator-iface
                         (simple-interface (decls)
                                           (report-attempt-to-apply-simple-module rator)
                                           )
                         (proc-interface (param-name param-iface result-iface)
                                         (cases interface rand-iface
                                           (simple-interface (decls)
                                                             (if (<:iface rand-iface param-iface tenv)
                                                                 (replace-iface result-iface param-name rand-iface)
                                                                 (report-bad-module-application-error param-iface rand-iface m-body)
                                                                 )
                                                             )
                                           (proc-interface (param-name2 param-iface2 result-iface2)
                                                           (eopl:error 'interface-of "application module body oprand must be simple interface, get ~s" rand-iface)
                                                           )
                                           )
                                         )
                         )
                       )
                     )
    )
  )
```

之前使用`(rename-in-iface result-iface param-name rand-id)`将返回接口`result-iface`中的限定类型名称从参数名称`param-name`替换为实际的名称`rand-id`，现在`rand-id`可能不是标识符了，无法直接替换。需要将返回类型`result-iface`中使用到的限定类型名称，替换为`rand-iface`中同名的类型。

下面例子中模块`ints1-to-int`导出的`to-int`类型中，用到的类型`from ints take t`，替换为参数中的类型定义`type t = int`。

```proc-modules
module ints1-to-int
    interface [
        to-int: (int -> int)
    ]
    body
        (module-proc (ints: [
            opaque t
            zero: t
            pred: (t -> t)
            succ: (t -> t)
            is-zero: (t -> bool)
        ])
        [
            to-int = let z? = from ints take is-zero
                        in let p = from ints take pred
                            in letrec int to-int (x: from ints take t) = if (z? x) then 0 else -((to-int (p x)), -1)
                                in to-int
        ]
        [
        type t = int
        zero = 0
        pred = proc(x : t) -(x,5)
        succ = proc(x : t) -(x,-5)
        is-zero = proc (x : t) zero?(x)
    ])
```

类型替换的逻辑参考[replace-iface](../ch8/8.3/exer-8.26/checker/renaming.rkt#L81)，同样对于接口、声明、类型等结构递归处理。区别在于最终`replace-in-type`对于`qualified-type`的处理，`t-name`和参数名称`rator-name`相同时，直接替换为`rand-iface`中的同名类型。

```scheme
(define (replace-in-type ty rator-name rand-iface)
  (cases type ty
    (proc-type (arg-type result-type)
               (proc-type (replace-in-type arg-type rator-name rand-iface) (replace-in-type result-type rator-name rand-iface))
               )
    (qualified-type (m-name t-name)
                    (if (eqv? m-name rator-name)
                        (find-iface-name rand-iface t-name)
                        ty
                        )
                    )
    (else ty)
    )
  )
```
