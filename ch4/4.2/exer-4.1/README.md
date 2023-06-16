因为`count`定义在`g`内部，`a` 和 `b`对应的两次`(g 11)`生成了两个独立的变量`counter`，值相同，所以`-(a,b)`为`0`。

```
let g = proc (dummy)
               let counter = newref(0)
               in begin
                    setref(counter, -(deref(counter), -1));
                    deref(counter)
                  end
      in let a = (g 11)
         in let b = (g 11)
            in -(a,b)
```
