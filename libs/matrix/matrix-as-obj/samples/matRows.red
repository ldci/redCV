#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red

print "*********** Matrices Rows ******************"
mx0: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]
mx1: matrix/create 2 32 3x1 [1 2 3]
matrix/show mx0

mx2: matrix/rowAdd mx0 1 mx1/data 
matrix/show mx2
mx2: matrix/rowSub mx0 1 mx1/data 
matrix/show mx2

mx2: matrix/rowProduct mx0 1 mx1/data 
matrix/show mx2

mx2: matrix/rowDivision mx0 1 mx1/data 
matrix/show mx2

mx2: matrix/rowRemainder mx0 1 mx1/data 
matrix/show mx2

mx0: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]
mx2: matrix/rowXor mx0 1 mx1/data 
matrix/show mx2

print "*************** Tests OK ******************"