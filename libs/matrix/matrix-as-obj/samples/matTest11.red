#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red
;--large matrices copy test

{mx1: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]
matrix/show mx1
mx2: matrix/create 2 32 2x3 [1 0 0 1 1 0]
matrix/show mx2
mxa: matrix/augment mx1 mx2
matrix/show mxa
matrix/split mxa 4
matrix/show mxa

matrix/switchRows mxa 1 3
matrix/show mxa}


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