#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red

print "*********** Scalar ******************"
mx1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
print "Matrix"
matrix/show mx1
print "Addition 5"
mx2: matrix/scalarAddition mx1 5
matrix/show mx2
print "Subtraction 5"
mx1: matrix/scalarSubtraction mx2 5
matrix/show mx1
print "Product 5"
mx2: matrix/scalarProduct mx1 5
matrix/show mx2
print "Division 5"
mx1: matrix/scalarDivision mx2 5
matrix/show mx1
print "Remainder 2"
mx2: matrix/scalarRemainder mx1 2
matrix/show mx2

print "*************** Tests OK ******************"