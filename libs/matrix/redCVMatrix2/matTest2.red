#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Matrices Indexing ******************"
;--some blocks for testing

bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float
m3: rcvCreateMat 3 64 3x4 bf
rcvMatShow m3

print "Matrix rows"
i: 1
while [i <= 4][
	print [i ": " rcvGetRow m3 i]
	i: i + 1
]
print "Matrix columns"
i: 1
while [i <= 3][
	print [i ": " rcvGetCol m3 i]
	i: i + 1
]
print lf
print ["Matrix offset" _HLEN] 
print ["Index 1 3    " _getIdx m3 1 3 ]
print ["RowIndex 6   " _getRowIdx m3 6]
print ["RowIndex 7   " _getRowIdx m3 7]
print ["ColIndex 6   " _getColIdx m3 6]
print ["ColIndex 7   " _getColIdx m3 7]
print ["GetAt 3 1    " _getAt m3 3 1]
print ["rcvGetAt 3 1 " rcvgetAt m3 3 1 lf]
rcvSetAt m3 1 2 10.0
print "rcvSetAt m3 1 2 10.0"
rcvMatShow m3
print "*************** Tests OK ******************"
