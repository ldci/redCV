#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red

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
mx: matrix/division m1 m2					;--matrix division 
matrix/show mx
mx: matrix/division/right m1 m2					;--matrix division 
matrix/show mx

print "*************** Tests OK ******************"


