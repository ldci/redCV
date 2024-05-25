#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Matrices Indexing ******************"
;--some blocks for testing

bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float
m3: matrix/create 3 64 3x4 bf
matrix/show m3

print "Matrix rows"
i: 1
while [i <= 4][
	print [i ": " matrix/getRow m3 i]
	i: i + 1
]
print "Matrix columns"
i: 1
while [i <= 3][
	print [i ": " matrix/getCol m3 i]
	i: i + 1
]
print lf
print ["Index 1 3    " matrix/_getIdx m3 1 3 ]
print ["RowIndex 6   " matrix/_getRowIdx m3 6]
print ["RowIndex 7   " matrix/_getRowIdx m3 7]
print ["ColIndex 6   " matrix/_getColIdx m3 6]
print ["ColIndex 7   " matrix/_getColIdx m3 7]
print ["GetAt 3 1    " matrix/_getAt m3 3 1]
print ["rcvGetAt 1x3 " matrix/getAt m3 1x3 lf]
matrix/setAt m3 2x1 10.0
print "rcvSetAt m3 2x1 10.0"
matrix/show m3
print "*************** Tests OK ******************"
