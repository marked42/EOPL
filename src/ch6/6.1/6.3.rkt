#lang eopl

; 1. (lambda (x y) (p (+ 8 x) (q y)))
(lamda (x y cont)
    (q y (lambda (val))
        (p (+ 8 x) val)
    )
)

; 2. (lambda (x y u v) (+ 1 (f (g x y) (+ u v))))
(lamda x y u v cont
    (g x y (lambda (val1)
        (f val1 (+ u v) (lambda (val2)
            (cont (+ 1 val2))
        ))
    ))
)

; 3. (+ 1 (f (g x y) (+ u (h v))))
(g x y (cont) (lambda (val1)
    (h v (lambda (val2)
        (f val1 (+ u val2) (lambda (val3)
            (+ 1 val3)
        ))
    ))
))

; 4. (zero? (if a (p x) (p y)))
(if a
    (p x (lambda (val) (zero? val)))
    (p y (lambda (val) (zero? val)))
)

; 5. (zero? (if (f a) (p x) (p y)))
(f a (lambda (val1)
    (if val1
        (p x (lambda (val2) (zero? val2)))
        (p y (lambda (val2) (zero? val2)))
    )
))

; 6. (let ((x (let ((y 8)) (p y)))) x)
(let ((y 8))
    (p y (lambda (val1)
        (let ((x val1))
            x
        )
    ))
)

; 7. (let ((x (if a (p x) (p y)))) x)
(p (if a x y) (lambda (val1)
    (let ((x val1))
        x
    )
))
