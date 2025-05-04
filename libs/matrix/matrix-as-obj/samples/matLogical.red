#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red

print "*********** Scalar ******************"
mx1: matrix/create 2 16 3x2 [1 2 3 4 5 6]
print "Matrix"
matrix/show mx1
print "AND 5"
mx2: matrix/scalarAnd mx1 5
matrix/show mx2
print "OR 5"
mx2: matrix/scalarOr mx1 5
matrix/show mx2
print "XOR5"
mx2: matrix/scalarXor mx1 5
matrix/show mx2
print "Right Shift 2"
mx2: matrix/scalarRightShift mx1 2
matrix/show mx2
print "Right Shift Unsigned 1"
mx2: matrix/scalarRightShiftUnsigned mx1 1
matrix/show mx2
print "Left Shift 2"
mx2: matrix/scalarLeftShift mx1 2
matrix/show mx2
print "*************** Tests OK ******************"