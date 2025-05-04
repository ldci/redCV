#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red
mx1: matrix/create 2 16 3x3 [1 2 3 4 5 6 7 8 9]
print "Square Matrix"
matrix/show mx1
print "Identity"
mx2: matrix/getIdentity mx1
matrix/show mx2

mx1: matrix/create 2 16 3x4 [1 2 3 4 5 6 7 8 9 10 11 12]
print "Not Square Matrix"
matrix/show mx1
print "Identity Left"
mx2: matrix/getIdentity/side mx1 'l
matrix/show mx2

print "Identity Right"
mx2: matrix/getIdentity/side mx1 'r
matrix/show mx2

mx1: matrix/create 3 64 3x3 [2.0 -1.0 0.0 -1.0 2.0 -1.0 0.0 -1.0 2.0]
print "Matrix"
matrix/show mx1
print "LU"
mx2: matrix/LU mx1
print "L"
matrix/show mx2/1
print "U"
matrix/show mx2/2

