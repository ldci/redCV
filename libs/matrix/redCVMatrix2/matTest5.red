#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Squared Matrices ******************"
mx: rcvCreateMat 2 16 3x3 [7 6 4 4 2 -2 3 0 9]
rcvMatShow mx
print ["Squared matrix?" rcvMatSquare? mx]
print ["Right diagonal:" rcvGetDiagonal mx 1 'r]
print ["Left diagonal :" rcvGetDiagonal mx 3 'l lf]

;--Determinant of a matrix |mx|
mx: rcvCreateMat 2 16 2x2 [4 6 3 8]
rcvMatShow mx
print ["Matrix determinant: |" rcvGetDeterminant mx "|" lf]

mx: rcvCreateMat 2 16 3x3 [6 1 1 4 -2 5 2 8 7]
rcvMatShow mx
print ["Matrix determinant: |" rcvGetDeterminant mx "|" lf]

;--symmetric matrix 
mx: rcvCreateMat 2 16 4x4 [3 2 11 5 2 9 -1 6 11 -1 0 7 5 6 7 9]
rcvMatShow mx
print ["Squared matrix?" rcvMatSquare? mx] 
print ["Matrix determinant: |" rcvGetDeterminant mx "|" lf]
; waiting for |mx|: -1339.9999999999998

mx: rcvCreateMat 2 16 2x2 [4 3 -2 -3]
rcvMatShow mx
print ["Trace:" rcvGetTrace mx]
print ["Determinant: |" rcvGetDeterminant mx "|"]
print ["Singular?" rcvMatSingular? mx]
print ["Degenerate?" rcvMatDegenerate? mx]
print ["Null?" rcvMatZero? mx]
print ["Eigenvalues:" rcvGetEigens2 mx lf]

mx: rcvCreateMat 2 32 3x3 [2 0 0 0 8 0 0 0 1]
rcvMatShow mx
print ["Diagonal? " rcvMatDiagonal? mx lf]

mx: rcvCreateMat 2 32 3x3 [2 0 0 0 8 0 0 1 0]
rcvMatShow mx
print ["Diagonal? " rcvMatDiagonal? mx lf]

mx: rcvCreateMat 2 32 4x4 [3 2 11 5 2 9 1 6 11 1 0 7 5 6 7 9]	
rcvMatShow mx

print ["Symmetric?: " rcvMatSymmetric? mx lf]

mx: rcvCreateMat 2 16 4x4 [1 2 3 5 2 1 2 3 3 2 1 2 4 3 2 1]
rcvMatShow mx
print ["Symmetric?:" rcvMatSymmetric? mx]


print "*************** Tests OK ******************"