#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Rotations ******************"

mx: matrix/create 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
matrix/show mx
print ["Squared matrix?" matrix/square? mx] 
print ["Matrix determinant: |" matrix/determinant mx "|"]

mxr: matrix/rotate mx 1
print "Rotated 1:" 
matrix/show mx

mxr: matrix/rotate mx 2
print "Rotated 2:" 
matrix/show mx

mxr: matrix/rotate mx 3
print "Rotated 3:" 
matrix/show mx

mx: matrix/create 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
matrix/show mx


{matrix/rotateRow mx 2 -1
print "Row 2 rotated by -1"
matrix/show mx

matrix/rotateCol mx [2 3] [-1 1]
print "Cols 2 and 3 rotated by -1 and 1 respectively"
matrix/show mx}


print "*************** Tests OK ******************"