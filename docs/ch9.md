# Chapter 9 Objects and Classes

## 面向对象的基础概念

### 不带继承的对象

若干个互相**关联**的变量组合在一起称为对象（object），变量被称为对象的字段（field），字段之间存在约束，使用一组方法（method）来操作对象保证对象始终处于合法状态。

下面例子中类`c1`封装了两个数字类型的字段`i`和`j`，两个数字是**相反数**的关系，和为零。`countup`方法修改字段始终满足这个约束，禁止使用其他方式修改字段值。

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

一个类可以新建多个对象，这些对象具有相同名称的字段和方法，但是实例之间的字段值是独立的，对象`o1`和`o2`的字段互相独立。

`send o1 getstate()`调用对象方法获取对象的状态，也可以将方法调用理解为向一个对象传递消息，消息包含方法名称和参数。对象接收到消息后进行相应的计算得到并返回结果，这个视角称为消息传递（message-passing）。这里的语法`send`使用了消息传递的视角，Java等语言中方法调用使用`o1.getstate()`的语法。

类中的字段和方法都是类的成员（member），字段是数据成员（member field），方法是方法成员（member field）。方法定义所在的类称为方法的宿主类（host-class）。

### 闭包与对象等价

> Closure are poor man's object.

闭包同样可以将若干变量与关联的方法封装在一起，实现与对象[等价](https://stackoverflow.com/questions/2497801/closures-are-poor-mans-objects-and-vice-versa-what-does-this-mean)的效果。

例子中定义函数`c1`，其中封装了两个局部变量`i`和`j`，使用参数`x`进行初始化，相当于构造函数，返回两个闭包函数`countup`和`getstate`。局部变量对外界不可见，通过闭包函数进行操作。

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

### 继承与多态

开闭原则（[Open-closed principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)）指导我们使用**拓展**而不是**修改**的方式对现有系统增加功能支持，类的继承特性符合这一原则。类通过**继承**其他类的方式**复用**基类（base class）的功能，如`class c1 extends object`，被继承的基类`object`也称为父类（parent class）、超类（superclass）；相应地`c1`被称为派生类（derived class），也被称为子类（child class/subclass）。继承可以是多层的，如`c2`继承了`c1`，`c1`继承了`object`，`object`被称为`c2`的 祖先类（ancestor class），`c2`被称为`object`的 祖先类（descendant class）。祖先类也包括父类，因此`c1`也是`c2`的祖先类；类似的后代类也包括子类。

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

子类中的字段和方法可能与父类**重名**，子类的字段和方法**覆盖（override）**父类同名字段和方法。例如`c2`的方法`sety2`中字段`y`引用的是子类`c2`而不是父类`c1`的字段。

多态是指子类同名的方法覆盖父类方法，子类对象被当做父类类型型使用的时候，实际调用的是子类的方法，这样实现了不改变父类与使用代码的情况下扩展了代码逻辑。对象`o2`是类`c2`的实例，在函数`get-m1`中被当做`c1`类型使用，调用了方法`m1`，实际上执行的是`c2`的`m1`方法。对于`send o m1()`来说`m1`方法由运行时对象`o`的具体类型决定，而不是编译时静态决定，这叫做方法的动态分发（dynamic dispatch）。

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

## 简单实现

实现基于类的面向对象[classes](../ch9/9.4/classes/interpreter.rkt#L30)。

### 语法定义

增加新的语法支持面向对象，包括类的定义、对象创建`new-object-exp`、方法调用`method-call-exp`、父类方法调用`super-call-exp`和`self`等表达式。

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

在程序表达式计算之前，首先要对类定义进行解析并保存[initialize-class-env!](../ch9/9.4/classes/interpreter.rkt#L30)，方便后续使用。

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

类的定义位于程序开头，可以有多个，是**全局的**，使用关联列表（association list）类型的变量[the-class-env](../ch9/9.4/classes/classes.rkt#L42)表示，键是类名称，值是类定义。初始环境中包含`object`类的定义，它作为所有类的基类，自身没有父类。

```scheme
(define the-class-env '())

(define (initialize-class-env! c-decls)
  (set! the-class-env (list (list 'object (a-class #f '() '()))))
  (for-each initialize-class-decl! c-decls)
  )
```

[类](../ch9/9.4/classes/classes.rkt#L16)包括父类（super-name）、字段名称（field-names）、方法定义（method-env）等三部分信息。

```scheme
(define-datatype class class?
  (a-class
   (super-name (maybe symbol?))
   (field-names (list-of symbol?))
   (method-env method-environment?)
   )
  )
```

一个类有若干个方法，使用关联列表表示，键是方法的名称，值是方法的定义。类的方法包括参数名称列表、方法体、父类名称、字段名称列表。

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

类继承带来的同名字段和方法**覆盖问题**需要在类环境的初始化过程处理。对象的字段列表中父类对象的字段位于子类对象的**前边**，顺序排列的好处是子类对象的字段列表中属于父类的部分和父类对象的字段列表完全一致。因此可以被将子类对象直接当做父类对象使用，字段顺序不需要调整。

参考类`c1`定义了字段`x`和`y`；类`c2`继承`c1`，定义字段`y`；类`c3`继承`c2`，定义字段`x`和`z`。

| 类  | 字段 | 字段列表    | 处理后的字段名称列表 |
| --- | ---- | ----------- | -------------------- |
| c1  | x, y | (x y)       | (x y)                |
| c2  | y    | (x y y)     | (x y%1 y)            |
| c3  | x, z | (x y y x z) | (x%1 y%1 y x z)      |

类`c2`的字段列表`(x y y)`包含两个`y`，第一个属于`c1`，第二个属于`c2`。类`c3`的字段列表`(x y y x z)`包含两个`x`，第一个属于`c1`，第二个属于`c3`。在字段列表中**从左到右**对字段按名称查找时，重名的情况下会首先查找到父类的字段。因此需要对字段列表做处理，将同名的字段中除了最后一个都进行重命名，这样从左到右查找字段时能够找到当前类的字段，也就是字段列表中同名的最后一个。重命名的字段名称包含`%`，避免与用户定义字段名称重复。[initialize-class-decl!](../ch9/9.4/classes/classes.rkt#L72)`中调用[append-field-names](../ch9/9.4/classes/classes.rkt#L116)将子类字段名称列表与父类字段名称列表做合并重命名。

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

新增的类[表达式](../ch9/9.4/classes/interpreter.rkt#L151)包括新建对象（new-object-exp）、方法调用（method-call-exp）、父类方法调用（super-call-exp）和self表达式（self-exp）。其中前三个内部都是调用一个类方法，区别在于`new-object-exp`调用的是类的构造函数`initialize`；`method-call-exp`调用的方法动态方法，是对象`obj`所属类的方法`method-name`；`super-call-exp`调用的方法静态方法，是父类`super-name`的方法`method-name`。`self-exp`访问环境变量中的变量`%self`，代表方法对应的当前对象。

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

对象方法中可以使用`super`、`self`两个特殊变量，需要在[apply-method](../ch9/9.4/classes/method.rkt#L23)调用方法时使用`extend-env-with-self-and-super`保存到环境变量中。方法的调用包含了方法参数、`self/super`、对象字段列表等三层环境变量。

```scheme
(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names)
              (value-of-exp body
               (extend-env* vars (map newref args)
                (extend-env-with-self-and-super self super-name
                 (extend-env* field-names (object->fields self) (empty-env))
                 )
                )
               )
              )
    )
  )
```

## 类型检查

为面向对象添加类型检查[typed-oo](../ch9/9.5/typed-oo/checker/main.rkt#L16)，包括三部分内容。

1. `instanceof`表达式检查对象是否为目标类的实例，`cast`表达式将对象转换为指定类型。
2. 增加接口功能，接口声明若干方法，实现了接口的类需要具有接口要求的所有方法。
3. 类字段和方法的类型检查，包括新增的几种类相关表达式类型。

### `instanceof`/`cast`

`instanceof o1 c1`检查对象`o1`是否是类`c1`的实例。

```typed-oo
class c1 extends object
  method initialize() 1

let o1 = new c1()
  in instanceof o1 c1
```

`test-cast`函数接收`parent`类型的参数，`c`是`child`类型的，在`test-cast`中使用`cast p child`将对象`p`从`parent`类型转换为`child`类型。

```typed-oo
class parent extends object
  method int initialize() 1

class child extends parent
  method int initialize() 2
  method int value() 2

let c = new child()
in let test-cast = proc (p: parent) send cast p child value()
in list((test-cast c))
```

添加运行时支持，这两个表达式都需要判断对象是否是某个类的实例。区别在于`cast`在不成立的情况下抛出错误，类型转换失败；`instanceof`则返回布尔类型值。

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

由于函数定义中会使用到`self`，类型就是当前类，为了检查函数定义的类型必须要有`self`的完整类型信息。所以类方法定义的检查要分成[两趟](../ch9/9.5/exer-9.38/README.md)，第一趟搜集类的完整定义，第二趟才能对方法定义进行检查。[check-method-decl!](../ch9/9.5/typed-oo/checker/static-class.rkt#L219)检查类的方法定义，方法的返回类型和标注的返回类型是否兼容。如果方法覆盖了父类同名方法，子类方法的类型需要和父类方法类型兼容。

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

使用[type-of-call](../ch9/9.5/typed-oo/checker/main.rkt#L219)对类的`new-object-exp`、`method-call-exp`、`super-call-exp`三种方法调用进行类型检查。要求实参和形参**个数相同**，每个实参的类型都必需是形参的**子类型**。

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

## 字段读写

`fieldref obj field-name`读取对象字段，`fieldset obj field-name = exp`写入对象字段。

```classes
class c1 extends object
  field x
  method initialize()
    set x = 1

class c2 extends object
  field x
  field y
  method initialize()
    begin
      set x = 2;
      set y = 3
    end

let o1 = new c1()
  in fieldref o1 x
```

[object->field](../ch9/9.4/exer-9.8/object.rkt#L38)在对象**类的字段列表**中查找指定名称的字段的下标，**对象字段列表**对应下标得到字段值的引用。

```scheme
(define (object->field obj field-name)
  (let* ([obj-class (lookup-class (object->class-name obj))]
         [field-names (class->field-names obj-class)]
         [index (index-of field-names field-name)])
    (if index
        (list-ref (object->fields obj) index)
        (eopl:error 'object->field "Field ~s not found on object ~s" field-name obj)
        )
    )
  )
```

对字段引用进行[读写](../ch9/9.4/exer-9.8/interpreter.rkt#L184)即可。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    (fieldref-exp (obj-exp field-name)
                  (let* ([obj (value-of-exp obj-exp env)] [field (object->field obj field-name)])
                    (deref field)
                    )
                  )
    (fieldset-exp (obj-exp field-name exp1)
                  (let* ([obj (value-of-exp obj-exp env)] [field (object->field obj field-name)])
                    (setref! field (value-of-exp exp1 env))
                    )
                  )
  )
)
```

为`fieldref/fieldset`添加[类型检查](../ch9/9.5/exer-9.41/checker/main.rkt#L189)，要求`obj-exp`必须是对象类型，字段`field-name`必须存在，值的类型`exp1-type`必须是字段类型`field-type`的子类型。

```scheme
(define (type-of exp tenv)
  (cases expression exp
    ; ...
    (fieldref-exp (obj-exp field-name)
                  (let ([obj-exp-type (type-of obj-exp tenv)])
                    (if (class-type? obj-exp-type)
                        (let ([obj-class-name (type->class-name obj-exp-type)])
                          (let ([field-type (find-class-field-type obj-class-name field-name)])
                            (if field-type
                                field-type
                                (eopl:error 'type-of "fieldref expression ~s of refs unknown field name ~s in class ~s" exp obj-class-name field-name)
                                )
                            )
                          )
                        (eopl:error 'type-of "fieldref target expression must be class type, get ~s" obj-exp)
                        )
                    )
                  )
    (fieldset-exp (obj-exp field-name exp1)
                  (let ([obj-exp-type (type-of obj-exp tenv)] [exp1-type (type-of exp1 tenv)])
                    (if (class-type? obj-exp-type)
                        (let ([obj-class-name (type->class-name obj-exp-type)])
                          (let ([field-type (find-class-field-type obj-class-name field-name)])
                            (if field-type
                                (begin
                                  (check-is-subtype! exp1-type field-type exp)
                                  (void-type)
                                  )
                                (eopl:error 'type-of "fieldset expression ~s of refs unknown field name ~s in class ~s" exp obj-class-name field-name)
                                )
                            )
                          )
                        (eopl:error 'type-of "fieldset target expression must be class type, get ~s" obj-exp)
                        )
                    )
                  )
    )
  )
```

对于父类的同名字段使用`superfieldref/superfieldset`语法支持读写，唯一的区别[object->super-field](../ch9/9.4/exer-9.9/object.rkt#L49)是在对象类的**父类字段列表**查找字段下标。

```scheme
(define (object->super-field obj super-field-name)
  (let* ([host-class (lookup-class (object->class-name obj))]
         [super-name (class->super-name host-class)]
         [super-class (lookup-class super-name)]
         [super-field-names (class->field-names super-class)]
         [index (index-of super-field-names super-field-name)])
    (if index
        (list-ref (object->fields obj) index)
        (eopl:error 'object->super-field "Super field ~s not found on object ~s" super-field-name obj)
        )
    )
  )
```

## 指定函数调用

使用`super`可以调用父类的同名函数，但是更上层的类同名函数仍然不可见，设计命名语法`named-send c1 o m1()`调用指定类`c1`的方法`m1`。
在指定的类`class-name`而不是对象`obj`的类上查找函数`method-name`，被调用的函数在编译时确定，属于静态分发（static dispatch）。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    ; ...
    (named-method-call-exp (class-name obj-exp method-name rands)
                           (let ([args (value-of-exps rands env)] [obj (value-of-exp obj-exp env)])
                             (apply-method
                              (find-method class-name method-name)
                              obj
                              args
                              )
                             )
                           )
  )
)
```

## 可见性

对象的**字段**和**方法**需要控制可见性，保证内部的数据对外界不可见，防止抽象泄露（leaky abstraction）。

对象字段和方法支持设置三种可见性。

1. `public` 公开的，在任意地方可用。
1. `private` 私有的，只能在类本身的方法中可用。
1. `protected` 保护的，在类和子类的方法中可见。

对可见性进行检查需要两个信息，一个是字段和方法的可见性，更新语法使用[method-modifier](../ch9/9.4/exer-9.11/parser.rkt#L25)表示，设计了可选的语法形式支持向前兼容；另一个是字段和方法使用的环境信息（类外全局环境、类内部、子类内部），新增[extend-env-method*](../ch9/9.4/exer-9.11/method.rkt#L29)将**方法调用**和**普通函数调用**区分开。

可见性的需要的信息都是**静态的**，因此可以在**运行前**进行，这里为了实现方便在运行时进行。

```scheme
(define (apply-method class-name method-name m self args)
  (cases method m
    (a-method (modifier vars body super-name field-names)
              (value-of-exp body
                            (extend-env-method* class-name method-name vars (map newref args)
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

然后在方法调用[method-call-exp](../ch9/9.4/exer-9.11/modifier.rkt#L18)之前进行检查。`public`不做检查；`private`检查方法调用所在的类是否为方法的宿主类（host class）；`protected`检查方法调用所在类是不是宿主类或者宿主类的子类。

```scheme
(define (check-method-call-visibility class-name method-name env)
  (let* ([method (find-method class-name method-name)]
         [caller-class-method (find-caller-class-method env)]
         [modifier (method->modifier method)])
    (cases method-modifier modifier
      (public-modifier () #t)
      (protected-modifier ()
                          (if (not caller-class-method)
                              (eopl:error 'check-method-call-visibility "Protected method ~s.~s called in global environment, can only be called in ~s" class-name method-name class-name)
                              (let ([caller-class-name (car caller-class-method)] [caller-method-name (cdr caller-class-method)])
                                (if (is-sub-class caller-class-name class-name)
                                    #t
                                    (eopl:error 'check-method-call-visibility "Proteced method ~s.~s called in ~s.~s, can only be called in class ~s or its descendants." class-name method-name caller-class-name caller-method-name class-name)
                                    )
                                )
                              )
                          )
      (private-modifier ()
                        (if (not caller-class-method)
                            (eopl:error 'check-method-call-visibility "Private method ~s.~s called in global environment, can only be called in ~s" class-name method-name class-name)
                            (let ([caller-class-name (car caller-class-method)] [caller-method-name (cdr caller-class-method)])
                              (if (eqv? class-name caller-class-name)
                                  #t
                                  (eopl:error 'check-method-call-visibility "Private method ~s.~s called in ~s.~s, can only be called inside class ~s." class-name method-name caller-class-name caller-method-name class-name)
                                  )
                              )
                            )
                        )
      )
    )
  )

```

字段读写的可见性检查[check-field-visibility](../ch9/9.4/exer-9.12/modifier.rkt#L57)实心类似。

```scheme
(define (check-field-visibility obj field-name env)
  (let* ([p (find-field-class-modifier-pair (object->class-name obj) field-name)]
         [class-name (car p)]
         [f-modifier (cdr p)]
         [caller-class-method (find-caller-class-method env)]
         [caller-class-name (car caller-class-method)]
         [caller-method-name (cdr caller-class-method)])
    (cases field-modifier f-modifier
      (public-field () #t)
      (protected-field ()
                       (if (is-sub-class caller-class-name class-name)
                           #t
                           (eopl:error 'check-field-visibility "Proteced field ~s.~s accessed in ~s.~s, can only be accessed in class ~s or its descendants." class-name field-name caller-class-name caller-method-name class-name)
                       )
      )
      (private-field ()
        (if (eqv? class-name caller-class-name)
          #t
          (eopl:error 'check-field-visibility "Private field ~s.~s accessed in ~s.~s, can only accessed inside class ~s" class-name field-name caller-class-name caller-method-name class-name)
        )
      )
    )
  )
)
```

## 方法重载

支持一个类定义多个同名的方法，但是要求方法的参数个数和类型（method signature）不能完全相同，否则无法进行区分。方法重载可以通过保存多个具有不同签名的同名函数实现，根据实参和函数签名进行重载决议（overloading resolution），也可以通过名称修饰（[name mangling](https://en.wikipedia.org/wiki/Name_mangling)）实现。名称修饰是根据方法签名生成唯一的方法名，避免重名。

[Exer 9.16](../ch9/9.4/exer-9.16/overloading.rkt#L6)在运行时进行名称修饰（m%n）。[Exer 9.22](../ch9/9.4/exer-9.22/interpreter.rkt#L114)在运行前将方法的定义和使用处都转换为修饰后的唯一名称（m@n）。这里只考虑了参数的个数，没有考虑参数类型。

```scheme
(define (mangle-method-name name arity)
    (string->symbol
        (string-append
            (symbol->string name)
            "@:"
            (number->string arity)
        )
    )
)

(define (translation-of-exp exp)
  (cases expression exp
    (method-call-exp (obj-exp method-name rands)
                     (method-call-exp
                        (translation-of-exp obj-exp)
                        (mangle-method-name method-name (length rands))
                        (translation-of-exps rands)
                        )
                     )
    (super-call-exp (method-name rands)
                    (super-call-exp
                        (mangle-method-name method-name (length rands))
                        (translation-of-exps rands)
                        )
                    )
    (else exp)
    )
)
```

## 静态成员

类静字段性通常用于保存跟类有关，但是所有实例共享的数据。在初始化类环境的时机[initialize-class-decl!](../ch9/9.4/exer-9.15/class.rkt#L80)中保存即可，为了方便对静态字段初始化只支持编译时可以确定值的表达式。

```scheme
(define (initialize-class-decl! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name static-field-names static-field-initializers f-names m-decls)
                  (let* ([super-class-f-names (class->field-names (lookup-class s-name))]
                         [class-static-fields (evaluate-class-static-fields static-field-names static-field-initializers)]
                         [f-names (append-filed-names super-class-f-names f-names)])
                    (add-to-class-env!
                     c-name
                     (a-class s-name
                              f-names
                              (merge-method-envs
                               (class->method-env (lookup-class s-name))
                               (method-decls->method-env m-decls s-name f-names class-static-fields)
                               )
                              )
                     )
                    )
                  )
    )
  )
```

在方法中可以访问类静态字段，所以方法调用时需要将静态字段放到[方法环境](../ch9/9.4/exer-9.15/method.rkt#L38)中。

```scheme
(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names class-static-fields)
              (value-of-exp
               body
               (extend-env*
                vars (map newref args)
                (extend-env-with-self-and-super
                 self
                 super-name
                 (extend-env*
                  field-names
                  (object->fields self)
                  (extend-env*
                   (map car class-static-fields)
                   (map cdr class-static-fields)
                   (empty-env)
                   )
                  )
                 )
                )
               )
              )
    )
  )

```

静态方法的支持比较简单，方法信息保存到类中，设计静态方法调用语法支持即可。需要注意的是类型检查中静态方法和普通方法要做区分，类普通方法采用动态分发，静态方法是静态分发，所以一个方法在父类、子类中应该[保持一致](../ch9/9.5/exer-9.37/checker/static-class.rkt#L287)。

```scheme
(define (check-method-decl! m-decl class-name super-name field-names field-types)
  (cases method-decl m-decl
    ; ...
    (a-static-method-decl (res-type m-name vars var-types body)
                          (let* ([tenv1 (extend-tenv* field-names field-types (init-tenv))]
                                 [tenv2 (extend-tenv-with-self-and-super (class-type class-name) super-name tenv1)]
                                 [tenv3 (extend-tenv* vars var-types tenv2)]
                                 [body-type (type-of body tenv3)])
                            (check-is-subtype! body-type res-type m-decl)
                            (if (eqv? m-name 'initialize)
                                ; pass check fot initialize
                                #t
                                (let* ([m-tenv (static-class->method-tenv (lookup-static-class super-name))]
                                       [maybe-super-type (maybe-find-method-type m-tenv m-name)])
                                  ; check if method type is compatible with parent method type
                                  (if maybe-super-type
                                      (begin
                                        (when (not (find-method-is-static super-name m-name))
                                          (eopl:error 'check-method-decl "static method ~s.~s override dynamic super method ~s.~s" class-name m-name super-name m-name)
                                          )
                                        (check-is-subtype!
                                         (proc-type var-types res-type)
                                         maybe-super-type
                                         m-decl
                                         )
                                        )
                                      ; pass check for non-overriden method
                                      #t
                                      )
                                  )
                                )
                            )
                          )
    )
  )
```

## 局部类

当前类的定义是全局的（global），Java中支持嵌套类（[nested class](https://docs.oracle.com/javase/tutorial/java/javaOO/nested.html)）和内部类（[inner class](https://www.geeksforgeeks.org/inner-class-java/)）。

设计新的语法`letclass c = ... in e`支持局部类，类`c`只在表达式`e`中可见。新增[extend-env-with-class](../ch9/9.4/exer-9.17/environment.rkt#L31)类型的环境记录，支持记录类的定义。

全局的类环境修改为嵌套的环境，对`letclass-exp`表达式求值的时候，[extend-env-with-class-component](../ch9/9.4/exer-9.17/interpreter.rkt#L190)将类的定义保存到环境中。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    ; ...
    (letclass-exp (class-name super-name field-names method-decls body)
                  (let ([new-env (extend-env-with-class-components class-name super-name field-names method-decls env)])
                    (value-of-exp body new-env)
                    )
                  )
  )
)
```

相应地在使用类的时候，根据类名查询类定义的过程[lookup-class](../ch9/9.4/exer-9.17/interpreter.rkt#L190)变成了在嵌套的环境中查找。

```scheme
(define (lookup-class c-name env)
  (cases environment env
    (extend-env* (vars vals saved-env) (lookup-class c-name saved-env))
    (extend-env-rec* (p-names b-vars p-bodies saved-env) (lookup-class c-name saved-env))
    (extend-env-with-self-and-super (self super-name saved-env) (lookup-class c-name saved-env))
    (extend-env-with-class (class-name c saved-env)
                           (if (eqv? class-name c-name)
                               c
                               (lookup-class c-name saved-env)
                               )
                           )
    (else (report-unknown-class-name c-name))
    )
  )
```

## 编译优化

当前使用关联列表的形式保存类的字段和方法，在运行时对字段和方法按照名称取查找，时间复杂度是O(N)。对象的字段在字段列表中的位置是静态确定的，`super-call-exp`调用的[父类方法](../ch9/9.4/exer-9.23/translator/main.rkt#L115)和[指定名称方法调用](../ch9/9.4/exer-9.24/translator/main.rkt#L137)也可以静态确定，还有方法调用中的变量也是静态的，可以进行 [Lexical Addressing](../ch3/3.7/lexical-addressing/translator.rkt#L22) 优化。

对类定义可以在编译时转换，[translation-of-method-decl](../ch9/9.4/exer-9.19/translator/class.rkt#L74)将类方法中的变量表达式转换为使用下标的形式`nameless-var-exp`。

```scheme
(define (translation-of-method-decl m-decl c-name senv)
  (cases method-decl m-decl
    (a-method-decl (method-name vars body)
                   (let* ([field-names (class->field-names (lookup-class c-name))]
                          [field-env (extend-senv-normal field-names senv)]
                          [self-super-env (extend-senv-normal (list '%self '%super) field-env)]
                          [vars-env (extend-senv-normal vars self-super-env)])
                     (a-method-decl
                      method-name
                      vars
                      (translation-of-exp body vars-env)
                      )
                     )
                   )
    )
  )
```

运行时执行使用下标版本的表达式实现O(1)的时间复杂度。

```scheme
(define (value-of-exp exp env)
  (cases expression exp
    ; ...
    ; translation
    (nameless-var-exp (index)
                      (let ([ref (apply-nameless-env env index)])
                       (deref ref)
                        )
                      )
  )
)
```

## Binary Method Problem

定义父类`point`有两个字段`x`和`y`，方法`similarpoints`判断两个`point`相等要求字段分别相等。子类`colorpoint`继承`point`，新增一个字段`color`，覆盖`similarpoints`方法要求要求`x/y/color`字段都相等。

在相等性判断的四种组合情况中，类型相同的话`similarpoints`返回正确。类型不同时，`(point colorpoint)`调用`point`类的`similarpoints`方法，将`colorpoint`当成`point`处理也正确。但是`(colorpoints point)`的情况下，调用`colorpoints`的方法，将`point`当成了`colorpoints`处理，这种情况错误。

```classes
class point extends object
  field x
  field y
  method initialize (initx, inity)
    begin
      set x = initx;
      set y = inity
    end
  method getx() x
  method gety() y
  method similarpoints(pt)
    if equal?(send pt getx(), x)
    then equal?(send pt gety(), y)
    else zero?(1)

class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints (pt)
    if super similarpoints(pt)
    then equal?(send pt getcolor(),color)
    else zero?(1)
```

要修复避免这个问题，需要在`colorpoint`类的`similarpoints`方法中对参数类型进行检查，确保是`colorpoint`类型。

```classes
class colorpoint extends point
  field color
  method initialize(x, y, c)
    begin
      super initialize(x, y);
      set color = c
    end
  method getcolor ()
    color
  method similarpoints(pt)
    if super similarpoints(pt)
    then
      % check if pt is colorpoint
      if instanceof pt colorpoint
      then equal?(send pt getcolor(), color)
      else zero?(0)
    else zero?(1)
```

判断两个点是否相等时两个参数的地位是等价的，但是面向对象的方法调用时一个作为`self`对象，一个作为参数，动态分发的方法只由`self`的类型决定，这是造成这个问题的根本原因。在支持双重分发机制的语言中，能避免这种不对称造成的问题。也可以使用[函数](../base/test.rkt#L3556)而不是方法定义避免这个问题。

```classes
let similarpoint = proc (pt1, pt2)
                      if equal?(send pt1 getx(), send pt2 getx())
                      then equal?(send pt1 gety(), send pt2 gety())
                      else zero?(1)
  in let similarcolorpoint = proc (cpt1, cpt2)
                              if (similarpoint cpt1 cpt2)
                              then if instanceof cpt1 colorpoint
                                   then if instanceof cpt2 colorpoint
                                        then equal?(send cpt1 getcolor(), send cpt2 getcolor())
                                        else zero?(0)
                                   else zero?(0)
                              else zero?(1)
    in let c1 = new colorpoint(1, 2, 255)
           c2 = new point(1, 2)
          in (similarcolorpoint c1 c2)
```

## 双重分发实现相等判断

两个节点类`interior-node`和`leaf-node`都实现了接口`tree`，使用[双重分发（double dispatch）](../base/test.rkt#L3796)的方式实现`equal`判断两个`tree`是不是等价的节点。等价的节点必须都是`interior-node`或者`leaf-node`，而且内部数据相同。

不使用`instanceof`判断`tree`的具体类型情况下，在`interior-node`的`equal`函数中调用参数`t: tree`的方法`send t equal_with_interior_node`，动态分发机制会根据对象的具体类型调用该类型的函数，`self`对象的类型信息被函数名称`equal_with_interior_node`表示了。两个节点类对比有四种组合情况，对应了两个类中`equal_with_interior_node/equal_with_leaf_node`的四个方法定义。

```classes
interface tree
  method int sum()
  method bool equal(t: tree)
  method bool equal_with_interior_node(t: interior-node)
  method bool equal_with_leaf_node(t: leaf-node)

class interior-node extends object implements tree
  field tree left
  field tree right
  method void initialize(l: tree, r: tree)
    begin
      set left = l;
      set right = r
    end

  method tree getleft() left
  method tree getright() right
  method int sum()
    +(send left sum(), send right sum())

  method bool equal(t: tree)
    send t equal_with_interior_node (self)

  method bool equal_with_interior_node (t: interior-node)
    if send left equal (send t getleft())
    then send right equal (send t getright())
    else zero?(1)

  method bool equal_with_leaf_node (t: leaf-node)
    zero?(1)

class leaf-node extends object implements tree
  field int value
  method void initialize(v: int)
    set value = v
  method int sum() value
  method int getvalue() value

  method bool equal(t: tree)
    send t equal_with_leaf_node (self)

  method bool equal_with_interior_node(t: interior-node)
    zero?(1)

  method bool equal_with_leaf_node(t: leaf-node)
    zero?(-(value, send t getvalue()))

let l1 = new leaf-node(1)
in let l2 = new leaf-node(2)
in let i1 = new interior-node(l1, l2)
in let i2 = new interior-node(l1, i1)
in list(
  send l1 equal (l1),
  send l1 equal (l2),
  send l1 equal (i1),
  send i1 equal (i1),
  send i1 equal (i2),
  send i1 equal (l1)
)
```

## 多继承

多继承（Exer 9.26）带来的问题要远大于其好处，Java选择只支持单继承。

## 基于原型的面向对象

基于原型也可以支持面向对象的特性，不需要类定义，而是直接在对象中保存字段和方法。对象可以直接继承另外一个对象，复用被继承对象的字段和方法，可参考练习[Exer 9.27](../ch9/9.4/exer-9.27/prototype.rkt)、[Exer 9.28](../ch9/9.4/exer-9.29/prototype.rkt)。
