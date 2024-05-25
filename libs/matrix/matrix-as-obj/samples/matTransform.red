#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Matrices Transformations ******************"
;--some blocks for testing
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0];-float
m3: matrix/create 3 64 3x4 bf
matrix/show m3

matrix/removeRow m3 2 
print "matrix/removeRow m3 2"
matrix/show m3

matrix/insertRow/at m3 [4.0 5.0 6.0] 2
print "matrix/insertRow/at m3 [4.0 5.0 6.0] 2"
matrix/show m3

matrix/appendRow m3 [13.0 14.0 15.0]
print "matrix/appendRow m3 [13.0 14.0 15.0]"
matrix/show m3

matrix/appendRow m3 [16.0]
print "matrix/appendRow m3 [16.0]"
matrix/show m3

matrix/removeCol m3 2 
print "matrix/removeCol m3 2"
matrix/show m3

matrix/transpose m3
print "matrix/transpose m3"
matrix/show m3

print "Insert col [7 8] to matrix"
m1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
matrix/show m1
matrix/insertCol/at m1 [7 8] 3
matrix/show m1

print "Append col [9 10]:"
matrix/appendCol m1 [9 10]
matrix/show m1

print "Swap rows 1 and 3 of following matrix"
mx: matrix/create 2 16 4x4 [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]
matrix/show mx
matrix/switchRows mx 1 3
matrix/show mx

print "Augment m1 with m2:"
m1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
m2: matrix/create 2 16 2x2 [7 8 9 10]
matrix/show m1
matrix/show m2
m3: matrix/augment m1 m2
matrix/show m3

print "*************** Tests OK ******************"


