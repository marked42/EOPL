1. proc (x) -(x, 3)
x: int
(int -> int)

2. proc (f) proc (x) -((f x), 1)
x: t
f: (t -> int)
((t -> int) -> (t -> int))

3. proc (x) x
x: t
(t -> t)

4. proc (x) proc (y) (x y)
y: t1
x: (t1 -> t2)
((t1 -> t2) -> (t1 -> t2))

5. proc (x) (x 3)
x: (int -> t1)
((int -> t1) -> t1)

6. proc (x) (x x)
t1: (t1 -> t2)
x: t1
(t1 -> t2)

7. proc (x) if x then 88 else 99
x: bool
(bool -> int)

8. proc (x) proc (y) if x then y else 99
x: bool
y: int
(bool -> (int -> int))

9. (proc (p) if p then 88 else 99
    33)
error, p should be bool, got number

10. (proc (p) if p then 88 else 88
     proc (z) z)
error, p should be bool, got proc (z) z

11. proc (f) proc (g) proc (p) proc (x)
        if (p (f x)) then (g 1) else -((f x), 1)

f: (x -> int)
p: (int -> bool)
g: (int -> int)

12. proc (x) proc (p) proc (f)
      if (p x) then -(x, 1) else (f p)
x: int
p: (int -> bool)
f: ((int -> bool) -> int)
(int -> ((int -> bool) -> (((int -> bool) -> int) -> int)))

13. proc (f)
      let d = proc (x)
                proc (z) ((f (x x)) z)
      in proc (n) ((f (d d)) n)
