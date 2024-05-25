#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Rotations ******************"

mx: rcvCreateMat 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
print ["Squared matrix?" rcvMatSquare? mx] 
print ["Matrix determinant: |" rcvGetDeterminant mx "|"]

mxr: rcvMatRotate mx 1
print "Rotated 1:" 
rcvMatShow mx

mxr: rcvMatRotate mx 2
print "Rotated 2:" 
rcvMatShow mx

mxr: rcvMatRotate mx 3
print "Rotated 3:" 
rcvMatShow mx

mx: rcvCreateMat 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
rcvMatShow mx


rcvMatRotateRow mx 2 -1
print "Row 2 rotated by -1"
rcvMatShow mx

rcvMatRotateCol mx [2 3] [-1 1]
print "Cols 2 and 3 rotated by -1 and 1 respectively"
rcvMatShow mx


print "*************** Tests OK ******************"