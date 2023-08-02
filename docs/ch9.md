# Chapter 9 Objects and Classes

## 面向对象的基础概念

### 不带继承的对象

若干个互相**关联**的变量组合在一起称为对象（object），对象变量之间存在约束关系，使用一组方法（method）来查询操作对象保证对象始终处于合法状态。变量被称为对象的字段（field）。

下面例子中类`c1`封装了两个数字类型的字段`i/j`，两个数字是**相反数**的关系，也就是和为零。对字段的修改必须始终保持这个关系，使用`countup`方法封装了满足关系的修改操作，禁止使用其他方式修改字段值。

```classes
class c1 extends object
  field i
  field j
  method initialize (x)
    begin
      set i = x;
      set j = -(0,x)
    end
  method countup (d)
    begin
      set i = +(i,d);
      set j = -(j,d)
    end
  method getstate ()
    list(i,j)
let t1 = 0
    t2 = 0
    o1 = new c1(3)
    o2 = new c1(3)
  in begin
    set t1 = send o1 getstate();
    send o1 countup(2);
    set t2 = send o1 getstate();
    list(t1,t2)
  end
```

基于类（class）的面向对象中，对象不能单独存在，必须从属于某一个类，对象是类的实例（instance）。创建对象并设置对象字段初始值的过程称之为初始化（initialization），初始化使用的对象方法称为构造函数（constructor），上述代码中固定使用`initialize`方法作为构造函数。表达式`new c1(3)`创建对象实例内部隐式的调用构造函数。

从一个类中可以新建多个对象，这些对象具有相同名称的字段和方法，但是实例之间的字段值是独立的，对象`o1`和`o2`的字段互相独立。

`send o1 getstate()`调用对象方法获取对象的状态，也可以将方法调用理解为向一个对象传递消息，消息包含方法名称和参数。对象接收到消息后进行相应的计算得到并返回结果，这个视角称为消息传递（message-passing）。这里的语法`send`使用了消息传递的视角，Java等语言中方法调用使用`o1.getstate()`的语法。

类中的字段和方法都是类的成员（member），字段是数据成员（member field），方法是方法成员（member field）。方法定义所在的类称为方法的宿主类（host-class）。

### 闭包与对象等价

闭包同样可以将若干变量与关联的方法封装在一起，实现与对象[等价](https://stackoverflow.com/questions/2497801/closures-are-poor-mans-objects-and-vice-versa-what-does-this-mean)的效果。

> Closure are poor man's object.

```proc
let c1 = proc (x)
            let i = x j = x
               in let countup (d) = begin set i = +(i, d); set j = -(j, d) end
                      getstate() = list(i, j)
                  in list(countup, getstate)
   in let t1 = 0
          t2 = 0
          o1 = c1(3)
         in let countup = car(o1)
                getstate = cdr(o1)
               in begin
                  set t1 = (getstate);
                  (countup 2);
                  set t2 = (getstate);
                  list(t1,t2)
               end
```

上面例子中定义函数`c1`，其中封装了两个局部变量`i/j`，使用参数`x`进行初始化，相当于构造函数，返回两个闭包函数`countup`和`getstate`。局部变量对外界不可见，通过闭包函数进行操作。

### 继承与多态

开闭原则（[Open-closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)）指导我们使用**拓展**而不是**修改**的方式对现有系统增加功能支持，类的继承特性符合这一原则。类通过**继承**其他类的方式**复用**基类（base class）的功能，如`class c1 extends object`，被继承的基类`object`也称为父类（parent class）、超类（superclass）；相应地`c1`被称为派生类（derived class），也被称为子类（child class/subclass）。继承可以是多层的，如`c2`继承了`c1`，`c1`继承了`object`，`object`被称为`c2`的 ancestor class，`c2`被称为`object`的 descendant class。ancestor class也包括父类，因此`c1`也是`c2`的ancestor class；类似的descendant class也包括子类。

```classes
class c1 extends object
  field x
  field y
  method initialize () 1
  method setx1 (v) set x = v
  method sety1 (v) set y = v
  method getx1 () x
  method gety1 () y

class c2 extends c1
  field y
  method sety2 (v) set y = v
  method getx2 () x
  method gety2 () y
```

子类中的字段和方法可能与父类**重名**，子类中的同名字段和方法**覆盖（shadowing）**父类。例如`c2`的方法`sety2`中字段`y`引用的是子类`c2`而不是父类`c1`的字段。

多态是指子类同名的方法覆盖父类，子类对象被当做父类型使用的时候，实际调用的是子类的方法，这样实现了不改变父类与使用代码的情况下扩展了代码逻辑。对象`o2`是类`c2`的实例，在函数`get-m1`中被当做`c1`类型使用，调用了方法`m1`，实际上执行的是`c2`的`m1`方法。对于`send o m1()`来说`m1`方法由运行时对象`o`的具体类型决定，而不是编译时静态决定，这叫做方法的动态分发（dynamic dispatch）。

```classes
class c1 extends object
  method initialize () 1
  method m1 () 11
  method m2 () send self m1()

class c2 extends c1
  method initialize () super initialize()
  method m1 () 22

let get-m1 = proc (o: c1) send o m1()
    o2 = new c2()
  in (get-m1 o2)
```

`super`代表当前类的父类，用来在被覆盖的情况下引用父类的同名方法，`c2`的`initialize`方法复用父类`c1`的构造函数进行初始化。`self`关键字代表当前方法关联的对象。

### 基于原型的面向对象

基于类、原型的面向对象
TODO:

## 简单实现

支持基于类的面向对象功能[classes](../ch9/9.4/classes/interpreter.rkt#L30)。

### 语法定义

增加新的语法结构支持面向对象，包括类的定义、对象创建`new-object-exp`、方法调用`method-call-exp`、父类方法调用`super-call-exp`和`self`等表达式。

```clases
(define the-grammar
  '((program ((arbno class-decl) expression) a-program)
    ...
    (class-decl ("class" identifier "extends" identifier (arbno "field" identifier) (arbno method-decl)) a-class-decl)
    (method-decl ("method" identifier "("(separated-list identifier ",")")" expression) a-method-decl)
    (expression ("new" identifier "("(separated-list expression ",")")") new-object-exp)
    (expression ("send" expression identifier "("(separated-list expression ",")")") method-call-exp)
    (expression ("super" identifier "("(separated-list expression ",")")") super-call-exp)
    (expression ("self") self-exp)
    )
)
```

### 类与对象模型

在程序表达式计算之前，首先要对类定义进行解析并保存[initialize-class-env](../ch9/9.4/classes/interpreter.rkt#L30)，方便后续使用。

```scheme
(define (value-of-program prog)
  ; new stuff
  (initialize-store!)
  (cases program prog
    (a-program (class-decls exp1)
               (initialize-class-env! class-decls)
               (value-of-exp exp1 (init-env))
               )
    )
  )
```

类的定义位于程序开头，可以有多个，是全局的，使用关联列表（association list）类型的全局变量[the-class-env](../ch9/9.4/classes/classes.rkt#L42)来表示，键是类名称，值是类定义。初始环境中包含类`object`的定义，它没有父类、字段、方法。

```scheme
(define the-class-env '())

(define (initialize-class-env! c-decls)
  (set! the-class-env (list (list 'object (a-class #f '() '()))))
  (for-each initialize-class-decl! c-decls)
  )
```

一个[类](../ch9/9.4/classes/classes.rkt#L16)包括父类（super-name）、字段名称（field-names）、方法定义（method-env）等三部分信息。

```scheme
(define-datatype class class?
  (a-class
   (super-name (maybe symbol?))
   (field-names (list-of symbol?))
   (method-env method-environment?)
   )
  )
```

一个类有若干个方法，同样使用关联列表表示，键是方法的名称，值是方法的定义。类的方法包括参数名称列表、方法体、父类名称、字段名称列表。

```scheme
(define-datatype method method?
  (a-method
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   )
  )
```

同一个类的多个实例对象使用的方法是相同的，因此对象中只需要保存类名称（查找类方法）和字段列表（每个对象独有）。

```scheme
(define-datatype object object?
    (an-object (class-name symbol?) (fields (list-of reference?)))
)
```

类继承带来的同名字段和方法**覆盖问题**需要在类环境的初始化中进行处理。对象的字段列表中父类对象的字段位于子类对象的**前边**，顺序排列的好处是子类对象的字段列表中属于父类的部分和父类对象的字段列表完全一致。因此可以被将子类对象直接当做父类对象使用，字段顺序不需要调整。

参考类`c1`定义了字段`x/y`；类`c2`继承`c1`，定义字段`y`；类`c3`继承`c2`，定义字段`x/z`。

| 类  | 字段 | 字段列表    | 处理后的字段名称列表 |
| --- | ---- | ----------- | -------------------- |
| c1  | x, y | (x y)       | (x y)                |
| c2  | y    | (x y y)     | (x y%1 y)            |
| c3  | x, z | (x y y x z) | (x%1 y%1 y x z)      |

类`c2`的字段列表`(x y y)`包含两个`y`，第一个属于`c1`，第二个属于`c2`。类`c3`的字段列表`(x y y x z)`包含两个`x`，第一个属于`c1`，第二个属于`c3`。在字段列表中**从左到右**对字段按名称查找时，重名的情况下会首先查找到父类的字段。因此需要对字段列表做处理，将同名的字段中除了最后一个都进行重命名，这样从左到右查找字段时能够找到当前类的字段，也就是字段列表中同名的最后一个。重命名的字段名称包含`%`，避免与用户定义字段名称重复。[initialize-class-decl](../ch9/9.4/classes/classes.rkt#L72)`中调用[append-field-names](../ch9/9.4/classes/classes.rkt#L116)将子类字段名称列表与父类字段名称列表做合并重命名。

```scheme
(define (initialize-class-decl! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name f-names m-decls)
                  (let* ([super-class-f-names (class->field-names (lookup-class s-name))]
                         [f-names (append-filed-names super-class-f-names f-names)])
                    (add-to-class-env!
                     c-name
                     (a-class s-name f-names
                              (merge-method-envs
                               (class->method-env (lookup-class s-name))
                               (method-decls->method-env m-decls s-name f-names)
                               )
                              )
                     )
                    )
                  )
    )
  )

(define (append-filed-names super-fields new-fields)
  (if (null? super-fields)
      new-fields
      (let ([first-super-field (car super-fields)] [rest-super-fields (cdr super-fields)])
        (cons
         (if (memq first-super-field new-fields)
             (fresh-identifier first-super-field)
             first-super-field
             )
         (append-filed-names rest-super-fields new-fields)
         )
        )
      )
  )
```

同名方法的处理不要求父类子类方法**顺序**排列，可以将子类方法排在父类方法之前，在[merge-method-envs](../ch9/9.4/classes/classes.rkt#L88)中直接将父类方法附加在子类之后即可。

```scheme
; static dispatch
(define (merge-method-envs super-m-env new-m-env)
  (append new-m-env super-m-env)
  )
```

### 类表达式求值

新增的类表达式[求值](../ch9/9.4/classes/interpreter.rkt#L151)包括新建对象（new-object-exp）、方法调用（method-call-exp）、父类方法调用（super-call-exp）和self表达式（self-exp）。其中前三个内部都是调用一个类方法，区别在于`new-object-exp`调用的是类的构造函数`initialize`；`method-call-exp`调用的方法动态分发，是对象`obj`所属类的方法`method-name`；`super-call-exp`调用的方法静态分发，是父类`super-name`的方法`method-name`。`self-exp`访问环境变量中的变量`%self`，代表方法对应的当前对象。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    (new-object-exp (class-name rands)
                    (let ([args (value-of-exps rands env)] [obj (new-object class-name)])
                      (apply-method
                       ; constructor method
                       (find-method class-name 'initialize)
                       obj
                       args
                       )
                       ; return newly created obj
                       obj
                      )
                    )
    (method-call-exp (obj-exp method-name rands)
                     (let ([args (value-of-exps rands env)] [obj (value-of-exp obj-exp env)])
                       (apply-method
                        (find-method (object->class-name obj) method-name)
                        obj
                        args
                        )
                       )
                     )
    (super-call-exp (method-name rands)
                    ; use surrounding self
                    (let ([args (value-of-exps rands env)] [obj (apply-env env '%self)])
                      (apply-method
                       ; find method in super class
                       (find-method (apply-env env '%super) method-name)
                       obj
                       args
                       )
                      )
                    )
    (self-exp () (apply-env env '%self))
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
```

对象方法中可以使用`super`、`self`两个特殊信息，需要在[apply-method](../ch9/9.4/classes/method.rkt#L23)调用方法时使用`extend-env-with-self-and-super`保存到环境变量中。

```scheme
(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names)
              (value-of-exp body
                        (extend-env* vars (map newref args)
                                     (extend-env-with-self-and-super self super-name
                                                                     (extend-env* field-names (object->fields self)
                                                                                  (empty-env)
                                                                                  )
                                                                     )
                                     )
                        )
              )
    )
  )
```

## 类型检查

为面向对象添加类型检查[typed-oo](../ch9/9.5/typed-oo/checker/main.rkt#L16)，包括三部分内容。

1. `instanceof`表达式可以检查对象是否是类的实例，`cast`表达式将对象转换为指定类型。
2. 增加接口功能，接口声明若干方法，实现了接口的类需要具有接口要求的所有方法。
3. 类字段和方法的类型检查，包括新增的几种类相关表达式类型。

### `instanceof`/`cast`

添加运行时支持，这两个表达式都需要判断对象是否是某个类的实例。区别在于`cast`在不成里的情况下抛出错误，类型转换失败；`instanceof`则返回布尔类型值。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    ...
    (cast-exp (obj-exp class-name)
              (let ([obj (value-of-exp obj-exp env)])
                (if (is-subclass? (object->class-name obj) class-name)
                    obj
                    (report-cast-error class-name obj)
                    )
                )
              )
    (instanceof-exp (obj-exp class-name)
                    (let ([obj (value-of-exp obj-exp env)])
                      (if (is-subclass? (object->class-name obj) class-name)
                          (bool-val #t)
                          (bool-val #f)
                          )
                      )
                    )
    )
  )
```

对象`obj`是类`class2`的实例，等价于对象的类`class1`与`class2`相同或者是其子类，在[is-subclass?](../ch9/9.5/typed-oo/class.rkt#L149)中顺着继承关系查找`class1`的继承链中是否包含`class2`即可。

```scheme
(define (is-subclass? class1 class2)
  (if (eqv? class1 class2)
      #t
      (let ([super-name (class->super-name (lookup-class class1))])
        (if super-name
            (is-subclass? class1 class2)
            #f
            )
        )
      )
  )
```

对这两个表达式进行类型检查，首先要求`obj-exp`是对象类型，不是对象的话表达式不合法。`cast`要求目标类是对象类的子类，如果目标类是对象类父类，没有必要使用`cast`类型转换；如果对象的类跟目标类没有继承关系，也不合法。`instanceof`要求对象的类和目标类兼容[statically-is-instanceofable?](../ch9/9.5/typed-oo/checker/static-class.rkt#L304)，可以是相同的类、类之间具有继承关系，或者类实现接口的关系。

```scheme
(define (type-of exp tenv)
  (cases expression exp
    ...
    (cast-exp (obj-exp class-name)
              (let* ([obj-type (type-of obj-exp tenv)] [obj-class-name (type->class-name obj-type)])
                ; can only cast to subclass, no need to cast to super class
                (if (statically-is-subclass? class-name obj-class-name)
                    (if (class-type? obj-type)
                        (class-type class-name)
                        (report-bad-type-to-cast obj-type exp)
                        )
                    (eopl:error 'cast "can't cast from ~s to ~s, not subtype" obj-class-name class-name)
                    )
                )
              )
    (instanceof-exp (obj-exp class-name)
                    (let* ([obj-type (type-of obj-exp tenv)] [obj-class-name (type->class-name obj-type)])
                      (if (and (class-type? obj-type)
                               ; disallow when object class and target class has no inheritance relationship
                               (statically-is-instanceofable? obj-class-name class-name)
                               )
                          (bool-type)
                          (report-bad-type-to-instanceof obj-type exp)
                          )
                      )
                    )

    (else (eopl:error 'type-of "Not checking OO now."))
    )
  )
```

### 接口与类定义检查

新增接口的定义，把接口当做`class-decl`的类型处理，区别在于接口只包括抽象方法的声明，抽象方法只包括方法签名，没有实现。在`type-of-program`中首先使用`initialize-static-class-env!`对接口、类型定义信息进行收集。对类定义进行检查，[要求](../ch9/9.5/typed-oo/checker/static-class.rkt#L117)类实现的接口名称不能重复、类的字段名称不能重复、类必须有构造函数。

```scheme
(define (add-class-decl-to-static-env! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name interface-names f-types f-names m-decls)
                  (let* ([static-class (lookup-static-class s-name)]
                         [i-names (append (static-class->interface-names static-class) interface-names)]
                         [f-names (append-field-names (static-class->field-names static-class) f-names)]
                         [f-types (append (static-class->field-types static-class) f-types)]
                         [method-tenv (let ([local-method-tenv (method-decls->method-tenv m-decls)])
                                        (check-no-dups! (map car local-method-tenv) c-name)
                                        (merge-method-tenvs (static-class->method-tenv static-class) local-method-tenv)
                                        )]
                         )
                    (check-no-dups! i-names c-name)
                    (check-no-dups! f-names c-name)
                    (check-for-initialize! method-tenv c-name)
                    (add-static-class-binding!
                     c-name
                     (a-static-class s-name i-names f-names f-types method-tenv)
                     )
                    )
                  )
    (an-interface-decl (name abstract-m-decls)
                       (let ([m-tenv (abs-method-decls->method-tenv abstract-m-decls)])
                         (check-no-dups! (map car m-tenv) name)
                         (add-static-class-binding! name (an-interface m-tenv))
                         )
                       )
    )
  )
```

收集完整接口与类型信息后可以对类的定义做更多的检查。[check-method-decl!](../ch9/9.5/typed-oo/checker/static-class.rkt#L219)检查类的方法定义，方法的返回类型和标注的返回类型是否兼容。如果方法覆盖了父类同名方法，子类方法的类型需要和父类方法类型兼容。

```scheme
(define (check-method-decl! m-decl class-name super-name field-names field-types)
  (cases method-decl m-decl
    (a-method-decl (res-type m-name vars var-types body)
                   (let* ([tenv1 (extend-tenv* field-names field-types (init-tenv))]
                          [tenv2 (extend-tenv-with-self-and-super (class-type class-name) super-name tenv1)]
                          [tenv3 (extend-tenv* vars var-types tenv2)]
                          [body-type (type-of body tenv3)])
                     (check-is-subtype! body-type res-type m-decl)
                     (if (eqv? m-name 'initialize)
                         ; pass check fot initialize
                         #t
                         (let ([maybe-super-type (maybe-find-method-type (static-class->method-tenv (lookup-static-class super-name)) m-name)])
                           ; check if method type is compatible with parent method type
                           (if maybe-super-type
                               (check-is-subtype!
                                (proc-type var-types res-type)
                                maybe-super-type
                                m-decl
                                )
                               ; pass check for non-overriden method
                               #t
                               )
                           )
                         )
                     )
                   )
    (an-abstract-method-decl (res-type method-name vars var-types)
                             (eopl:error 'check-method-decl "Expect a-method-decl, get ~s" m-decl)
                             )
    )
  )
```

[check-class-decl!](../ch9/9.5/typed-oo/checker/static-class.rkt#L212)检查每个类是否实现了其声明的接口。

```scheme
(define (type-of-program pgm)
  (cases program pgm
    (a-program (class-decls exp1)
               (initialize-static-class-env! class-decls)
               (for-each check-class-decl! class-decls)
               (type-of exp1 (init-tenv))
               )
    )
  )
```

[check-if-implements!](../ch9/9.5/typed-oo/checker/static-class.rkt#L251)检查类实现了声明的接口，要求接口的每一个方法在类中都有实现，并且类定义的方法类型是接口声明的方法类型的子类型。

```scheme
(define (check-if-implements! c-name i-name)
  (cases static-class (lookup-static-class i-name)
    (a-static-class (s-name i-names f-names f-types m-tenv)
                    (report-cant-implement-non-interface c-name i-name)
                    )
    (an-interface (method-tenv)
                  (let ([class-method-tenv (static-class->method-tenv (lookup-static-class c-name))])
                    (for-each
                     (lambda (method-binding)
                       (let* ([m-name (car method-binding)]
                              [m-type (cadr method-binding)]
                              [c-method-type (maybe-find-method-type class-method-tenv m-name)])
                         (if c-method-type
                             (check-is-subtype! c-method-type m-type c-name)
                             (report-missing-method c-name i-name m-name)
                             )
                         )
                       )
                     method-tenv
                     )
                    )
                  )
    )
  )
```

子类型的检查[is-subtype](../ch9/9.5/typed-oo/checker/type.rkt#L53)是在之前的基础上扩展了对于类类型（class type）的支持，函数类型的检查同样满足参数类型逆变，返回类型协变的关系。

```scheme
(define (is-subtype? ty1 ty2)
  (cases type ty1
    (class-type (name1)
                (cases type ty2
                  (class-type (name2)
                              (statically-is-subclass? name1 name2)
                              )
                  (else #f)
                  )
                )
    (proc-type (args1 res1)
               (cases type ty2
                 (proc-type (args2 res2)
                            (and
                             (every2? is-subtype? args2 args1)
                             (is-subtype? res1 res2)
                             )
                            )
                 (else #f)
                 )
               )
    ; list-type is covariant
    (list-type (element-type1)
               (cases type ty2
                (list-type (element-type2) (is-subtype? element-type1 element-type2))
                (else #f)
                )
               )
    (else (equal? ty1 ty2))
    )
  )
```

### 方法调用检查

使用[type-of-call](../ch9/9.5/typed-oo/checker/main.rkt#L219)对类的`new-object-exp`、`method-call-exp`、`super-call-exp`三种方法调用进行类型检查。要求实参和形参个数相同，每个实参的类型都必需是形参的子类型。

```scheme
(define (type-of-call rator-type rand-types rands exp)
  (cases type rator-type
    (proc-type (arg-types result-type)
               (if (not (= (length arg-types) (length rand-types)))
                   (report-wrong-number-of-arguments
                    (map type-to-external-form arg-types)
                    (map type-to-external-form rand-types)
                    exp
                    )
                   (for-each check-is-subtype! rand-types arg-types rands)
                   )
               result-type
               )
    (else (report-rator-not-of-proc-type (type-to-external-form rator-type) exp))
    )
  )
```

## 更多特性

### 父类方法

1. single-inheritance/dynamic dispatch/subclass polymorphism
   1. Exer 9.2
   1. final method 9.13
1. instanceof Exer 9.6
1. class/static field / method Exer 9.15
1. overloading name mangling Exer 9.16/Exer 9.22
1. local class Exer 9.17
1. shadowing/static dispatch
   1. Exer 9.8 fieldref/set
   1. Exer 9.9 superfieldref/set
   1. Exer 9.10 named send
1. encapsulation/visibility
   1. Exer 9.11 method
   1. Exer 9.12 field
1. compile time optimization
   1. Exer 9.18 constant time method searching
   1. Exer 9.19/20 lexical addressing
   1. Exer 9.22 overloading resolution at compile time
   1. Exer 9.23 super call
   1. Exer 9.24 named send method
1. binary method problem Exer 9.25
1. double dispatch
1. multiple inheritance Exer 9.26 diamond problem
1. prototype based oo Exer 9.27/9.28/9.29
