#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Squared Matrices ******************"
mx: matrix/create 2 16 3x3 [7 6 4 4 2 -2 3 0 9]
matrix/show mx
print ["Squared matrix?" matrix/square? mx]
print ["Right diagonal:" matrix/diagonal mx 1 'r]
print ["Left diagonal :" matrix/diagonal mx 3 'l lf]

;--Determinant of a matrix |mx|
mx: matrix/create 2 16 2x2 [4 6 3 8]
matrix/show mx
print ["Matrix determinant: |" matrix/determinant mx "|" lf]

mx: matrix/create 2 16 3x3 [6 1 1 4 -2 5 2 8 7]
matrix/show mx
print ["Matrix determinant: |" matrix/determinant mx "|" lf]

;--symmetric matrix 
mx: matrix/create 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
matrix/show mx
print ["Squared matrix?" matrix/square? mx] 
print ["Matrix determinant: |" matrix/determinant mx "|" lf]
; waiting for |mx|: -1339.9999999999998

mx: matrix/create 2 16 2x2 [4 3 -2 -3]
matrix/show mx
print ["Trace:" matrix/trace mx]
print ["Determinant: |" matrix/determinant mx "|"]
print ["Singular?" matrix/singular? mx]
print ["Degenerate?" matrix/degenerate? mx]
print ["Null?" matrix/null? mx]
print ["Eigenvalues:" matrix/eigens mx lf]

mx: matrix/create 2 32 3x3 [2 0 0 0 8 0 0 0 1]
matrix/show mx
print ["Diagonal? " matrix/diagonal? mx lf]

mx: matrix/create 2 32 3x3 [2 0 0 0 8 0 0 1 0]
matrix/show mx
print ["Diagonal? " matrix/diagonal? mx lf]

mx: matrix/create 2 32 4x4 [3 2 11 5 2 9 1 6 11 1 0 7 5 6 7 9]	
matrix/show mx

print ["Symmetric?: " matrix/symmetric? mx lf]

mx: matrix/create 2 16 4x4 [1 2 3 5 2 1 2 3 3 2 1 2 4 3 2 1]
matrix/show mx
print ["Symmetric?:" matrix/symmetric? mx]


print "*************** Tests OK ******************"