#!/usr/local/bin/red
Red [
]

#include %matrix.red

;*********************** tests *******************************

;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]                                     ;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]    ;-float

;--matrices creation
m1: matrix/create 1 8  3x3 bc
m2: matrix/create 2 16 3x3 bi
m3: matrix/create 3 64 3x4 bf

probe matrix/header m2

print ["Order : " matrix/order m1]
matrix/show m1
print ["Order : " matrix/order m2]
matrix/show m2
print ["Order : " matrix/order m3]
matrix/show m3
;--matrice init
print "Matrices initialization"
m4: matrix/init 2 16 9x9 ;--similar to matrix/zero
matrix/show m4
m4: matrix/init/value 2 16 9x9 1
matrix/show m4
m4: matrix/init/value/rand 2 16 9x9 10
matrix/show m4
m4: matrix/init/value/rand/bias 2 16 9x9 2 -1
matrix/show m4

;--scalar matrix
print "Scalar matrix"
m2: matrix/scalar 2 16 3x3 5
matrix/show m2

print "Zero matrix"
m2: matrix/zero 2 16 3x3 
matrix/show m2

print "Identity matrix"
m2: matrix/identity 2 16 3x3 
matrix/show m2


print ["Null matrix?" matrix/null? m2]
print ["Square matrix? " matrix/square? m2]
print ["Matrix diagonal" matrix/diagonal m2 1 'r]
print ["Matrix diagonal" matrix/diagonal m2 1 'l]
print ["Matrix trace" matrix/trace m2]


print matrix/getAt m3 1x3
print matrix/setAt m3 1x3 99.0
print matrix/getAt m3 1x3

m3: matrix/create 3 64 3x4 bf
matrix/show m3

m5: matrix/split m3 2
matrix/show m5

m3: matrix/create 3 64 3x4 bf
matrix/switchRows m3 1 3 
matrix/show m3

m2: matrix/create 2 32 3x2 [1 2 3 4 5 6]
matrix/show m2
print ["Product: " matrix/product m2]
print ["Sum: "matrix/sigma m2]
print ["Mean: " matrix/mean m2]

print "*********** Compute ******************"

m1: matrix/create 2 16 2x2 [3 8 4 6]
m2: matrix/create 2 16 2x2 [4 0 1 -9]
matrix/show m1
matrix/show m2
print "Addition"
mx: matrix/addition m1 m2
matrix/show mx

print "Subtraction"
mx: matrix/subtraction m1 m2
matrix/show mx

m1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
m2: matrix/create 2 16 2x3 [7 8 9 10 11 12]
print "Multiplication"
mx: matrix/standardProduct m1 m2
matrix/show mx

print "Hadamard product"
m1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
m2: matrix/create 2 16 3x2 [7 8 9 10 11 12]
mx: matrix/HadamardProduct m1 m2
matrix/show mx

print "Kronecker product"
mx: matrix/KroneckerProduct m1 m2
matrix/show mx

print "Division"
m1: matrix/create 2 16 2x2 [3 5 4 7]		;--matrix
m2: matrix/create 2 16 2x2 [7 -5 -4 3] 		;--inverse matrix
mx: matrix/standardProduct m1 m2			;--matrix * inverse matrix
matrix/show mx
mx: matrix/division m2 m2					;--matrix division 
matrix/show mx






