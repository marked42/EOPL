# Hindley-Milner Type System

1. / Type Variable / Type / Quantified Type / Type Scheme

type Constructor / Type Application

poly-type(type schemes) can be reduced to types by applying all free type variable with actual types
monotype types can be extended to type schemes by adding new free type variables

Meanings of notations

type environment / typing context $\Gamma$

extend type environment with variable `x` of type $\tau_1$ $\Gamma,x:\tau_1$

judgement / type relation

$
\Gamma \vdash e: \sigma
$

```test
// non well-typed
proc (f) (f true) (f 0)

// well-typed let-polymorphism
let f = proc (x) x in (f true, f 0)
```

special type inference rule for let binding

generalization
quantification: algorihtm W O(N^2) / level-based generalization O(N)

In this case, a signal advantage of the Hindley-Milner system is that each well-typed term has a unique "best" type, which is called the principal type

HM 是 System F 的一个子集，通过限制多态类型特化时只能使用简单类型作为参数让类型推导可行化，推导算法就是大名鼎鼎的 Algorithm W

简而言之就是在 SystemF 里面需要进行显示的标注，而 hindley/milner 用一个 type scheme 的策略来实现多态。比如在 Let ploymorphism(let x= t)中先对 t 进行 unification，生成 type scheme，以后用到 t 时就 new instance。每次生成的 instance 不一样，就不会产生冲突的 constraint。从而实现多态

Quantifiers can only appear top level

Equality of polytypes is up to reordering the quantification and renaming the quantified variables (alpha -conversion). Further, quantified variables not occurring in the monotype can be dropped.

different type variables in a type

1. bound variables (quantified type) type variables defined by quantified type
1. unbound free variables (look in typing context), type variables defined in typing context
1. other variables, implicitly treated as all-quantified (type variables) 类型标注中类型变量隐式的作为 quantified type variable

## References

1. CS 452 Foundations of Software Martin Odersky, EPFL [Note](https://kjaer.io/fos/) [Course Website](http://lampwww.epfl.ch/teaching/archive/type_systems/2010/docs/week01-2x2.pdf) [Repo](https://github.com/jxiw/Foundation-of-software/tree/master)
1. [Hindley Milner Type System Wiki](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
1. [Simply Typed Lambda Calculus](https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus)
1. [System F](https://en.wikipedia.org/wiki/System_F)
1. [Church’s Type Theory](https://plato.stanford.edu/entries/type-theory-church/)
1. [A Fresh View At Type Inference](https://drive.google.com/file/d/1VPN0WDEVnA3aPDwQh9HtroBcGnhJTL5g/view)
1. [value restriction](https://en.wikipedia.org/wiki/Value_restriction)
1. [Closed Under Composition](https://stackoverflow.com/questions/23104490/meaning-of-closed-under-composition)
1. [What Part of Hindley-Milner do you not understand?](https://stackoverflow.com/questions/12532552/what-part-of-hindley-milner-do-you-not-understand)

John C. Reynolds, Towards a Theory of Type Structure, 1974Hindley, R., The Principal Type-scheme of an Object in Combinatory Logic, Transactions of the American Mathematical Society 146, 29-60,1969

1. https://course.ccs.neu.edu/cs4410sp19/
