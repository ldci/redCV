#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red
;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]										;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]					;-float

m1: rcvCreateMat2 1 8  3x3 bc
m2: rcvCreateMat2 2 16 3x3 bi
m3: rcvCreateMat2 3 64 3x4 bf


print ["Mat Order :" rcvGetMatOrder m1]
print ["Mat header:" rcvGetMatHeader m1]
print "Mat values:" rcvMatShow m1

print ["Mat Order :" rcvGetMatOrder m2]
print ["Mat header:" rcvGetMatHeader m2]
print "Mat values:" rcvMatShow m2

print ["Mat Order :" rcvGetMatOrder m3]
print ["Mat header:" rcvGetMatHeader m3]
print "Mat values:" rcvMatShow m3

print "Rows"
i: 1
while [i <= 4][
	print [i ": " rcvGetRow m3 i]
	i: i + 1
]
print "Columns"
i: 1
while [i <= 3][
	print [i ": " rcvGetCol m3 i]
	i: i + 1
]

print ["Index 1 3 " _getIdx m3 1 3]
print ["RowIndex 6 " _getRowIdx m3 6]
print ["RowIndex 7 " _getRowIdx m3 7]
print ["ColIndex 6 " _getColIdx m3 6]
print ["ColIndex 7 " _getColIdx m3 7]
print ["GetAt 3 1" _getAt m3 3 1]
print ["rcvGetAt 3 1" rcvgetAt m3 3 1]


rcvSetAt m3 1 2 10.0
print "rcvSetAt m3 1 2 10.0"
rcvMatShow m3

rcvRemoveRow m3 2 
print "rcvRemoveRow m3 2"
rcvMatShow m3

rcvInsertRow/at m3 [4.0 5.0 6.0] 2
print "rcvInsertRow/at m3 [4.0 5.0 6.0] 2"
rcvMatShow m3

rcvAppendRow m3 [13.0 14.0 15.0]
print "rcvAppendRow m3 [13.0 14.0 15.0]"
rcvMatShow m3

rcvAppendRow m3 [16.0]
print "rcvAppendRow m3 [16.0]"
rcvMatShow m3

rcvRemoveCol m3 2 
print "rcvRemoveCol m3 2"
rcvMatShow m3

rcvMatTranspose m3
print "rcvMatTranspose m3"
rcvMatShow m3

print ["Square? m3:" rcvMatSquare? m3]
print ["Square? m2:" rcvMatSquare? m2]
