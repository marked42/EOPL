# EOPL

书籍《Essentials of Programming Language》使用 Scheme 实现了类似 Lisp 的语言用来解释语言设计中的一些核心概念。

本仓库使用 Racket 重新实现相关代码，Racket 有现成的库提供了 [EOPL](https://docs.racket-lang.org/eopl/index.html) 中使用的语法形式和函数。

使用 raco 命令安装 [EOPL 库](https://github.com/racket/eopl)，并在.rkt 文件第一行使用 `#lang eopl`开启这个模式。

```rkt
#lang eopl
```

EOPL 中使用 Scheme 的函数`identifier?`判断一个值是不是标识符，Racket 没有提供这个函数，但是有类似`symbol?`来判断一个值是不是符号，区别参考这个[问题](https://stackoverflow.com/questions/48393025/difference-between-an-identifier-and-symbol-in-scheme)。

## Chapter 3

source language/defined language 指要设计和实现的语言。
implementation language/defining language 指编写源码使用的语言。
expressed values 指原语言中可能的表达式值类型
denoted values 指实现语言中用来表示 expressed values 的值

在对源语言进行解释执行的过程中，要识别 expressed values 的类型，然后映射到 denoted values，在实现语言中对 denoted values 进行
相应的运算，然后将运算结果包装为对应的 expressed values，映射回源语言。

$n$ 是 denoted value，$\lceil n \rceil$ 代表 expressed value 中对应的值。

$n$ 是 expressed value，$\lfloor n \rfloor$ 代表 denoted value 中对应的值。

### TODO & FIXME

1. let-lang/parser.rkt sllgen:make-string-parser 隐式依赖 a-program 问题
1. `(provide (all-defined-out))` 还会有没使用但是导出了的符号提示
1. re-export imported symbols
1. display 换行
