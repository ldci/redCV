#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Matrices Slicing ******************"

bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0 13.0 14.0 15.0  16.0]	;-float

m3: matrix/create 3 64 4x4 bf
print "Float matrix"
print ["Mat Order :" matrix/order m3 "as Red pair!"]
print ["Mat header:" matrix/header m3]
print "Mat values:"
matrix/show m3

l1: matrix/getRow m3 1
ln: matrix/getRow m3 4
c1: matrix/getCol m3 1
cn: matrix/getCol m3 4
probe l1
probe ln
probe c1
probe cn


print "Split column 2"
mx: matrix/split m3 2
matrix/show mx



print " Slice 2 3 2 3"
mx: matrix/slice m3 2 3 2 3
matrix/show mx

print " Slice 3 4 3 4"
mx: matrix/slice m3 3 4 3 4
matrix/show mx

print "*************** Tests OK ******************"



