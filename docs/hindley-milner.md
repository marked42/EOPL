# Hindley-Milner Type System

Type Variable / Type / Quantified Type / Type Scheme

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

#### Let-polymorphism

因为 let 引入的变量绑定，所以一个函数可以有多处调用，因此产生了多态的需求

### Algorithm W

### Better Error Messages

1. [Generalizing Hindley-Milner Type Inference Algorithms](http://www.cs.uu.nl/research/techreps/repo/CS-2002/2002-031.pdf)
1. [Better type errors for the Hindley-Milner type system](https://www.cs.kent.ac.uk/people/staff/oc/typeerrors.html)
1. OCaml type-directed error recovery
1. Haskell type holes
1. [Diagnosing Type Errors with Class](https://ecommons.cornell.edu/handle/1813/39907)
1. [Top Quality Type Error Messages](https://dspace.library.uu.nl/bitstream/handle/1874/7297/?sequence=7)

### Value Restriction

```ocaml
let id = fun x -> x;
let r = ref id;
r := succ;
!r true;;
```

**mutable polymorphic type** can never hold more than one type

OCaml weak type variable: stand for a single unknown type.

```java
class Animal {}
class Elephant extends Animal {}
class Rabbit extends Animal {}
Animal[] animals = new Rabbit[2];

// ok
animals[0] = new Rabbit();

// Exception java.lang.ArrayStoreException
animals[1] = new Elephant();
```

1. https://caml.inria.fr/pub/papers/garrigue-value_restriction-fiwflp04.pdf
1. [How OCaml type checker works -- or what polymorphism and garbage collection have in common](https://okmij.org/ftp/ML/generalization.html)
1. Modern Compiler Implementation in ML Chapter 16 Polymorphic Types

### References

1. [Unification](<https://en.wikipedia.org/wiki/Unification_(computer_science)#Substitution>) John Alan Robinson
1. A machine-oriented logic based on the resolution principle J.A. Robinson's 1965
1. An Efficient Unification algorithm by Martelli and Montanari
1. Unification: A Multidisciplinary survey by Kevin Knight
1. [Correcting a widespread error in unification algorithms](https://www.semanticscholar.org/paper/Correcting-a-widespread-error-in-unification-Norvig/95af3dc93c2e69b2c739a9098c3428a49e54e1b6) Peter Norvig 1991
1. [Unification](https://eli.thegreenplace.net/2018/unification/)

1. [Type Inference](https://eli.thegreenplace.net/2018/type-inference/)

1. CS 452 Foundations of Software Martin Odersky, EPFL [Note](https://kjaer.io/fos/) [Course Website](http://lampwww.epfl.ch/teaching/archive/type_systems/2010/docs/week01-2x2.pdf) [Repo](https://github.com/jxiw/Foundation-of-software/tree/master)
1. [Hindley Milner Type System Wiki](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
1. [Simply Typed Lambda Calculus](https://en.wikipedia.org/wiki/Simply_typed_lambda_calculus)
1. [9.6 Type Inference](https://cs3110.github.io/textbook/chapters/interp/inference.html#)
1. [Type Inference Wiki](https://en.wikipedia.org/wiki/Type_inference)
1. [A Fresh View At Type Inference](https://drive.google.com/file/d/1VPN0WDEVnA3aPDwQh9HtroBcGnhJTL5g/view)
1. [System F](https://en.wikipedia.org/wiki/System_F)
1. [Church’s Type Theory](https://plato.stanford.edu/entries/type-theory-church/)
1. [value restriction](https://en.wikipedia.org/wiki/Value_restriction)
1. [Closed Under Composition](https://stackoverflow.com/questions/23104490/meaning-of-closed-under-composition)
1. [What Part of Hindley-Milner do you not understand?](https://stackoverflow.com/questions/12532552/what-part-of-hindley-milner-do-you-not-understand)
1. John C. Reynolds, Towards a Theory of Type Structure, 1974
1. Hindley, R., The Principal Type-scheme of an Object in Combinatory Logic
1. https://course.ccs.neu.edu/cs4410sp19/
1. [CS 4410/6410: Compiler Design Lecture 11: Type Inference](https://course.ccs.neu.edu/cs4410sp19/lec_type-inference_notes.html)
