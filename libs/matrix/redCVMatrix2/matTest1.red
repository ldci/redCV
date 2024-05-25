#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Matrices Creation ******************"
;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]										;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float

m1: rcvCreateMat 1 8  3x3 bc
m2: rcvCreateMat 2 16 3x3 bi
m3: rcvCreateMat 3 64 3x4 bf

print "Char matrix" 
print ["Mat Order :" rcvGetMatOrder m1 "as Red pair!"]
print ["Mat header:" rcvGetMatHeader m1]
print ["Mat values:" rcvGetMatData m1 lf]


print "Integer matrix"
print ["Mat Order :" rcvGetMatOrder m2 "as Red pair!"]
print ["Mat header:" rcvGetMatHeader m2]
print ["Mat values:" rcvGetMatData m2 lf]


print "Float matrix"
print ["Mat Order :" rcvGetMatOrder m3 "as Red pair!"]
print ["Mat header:" rcvGetMatHeader m3]
print ["Mat values:" rcvGetMatData m3 lf]


iden: copy []
loop 9 [append iden 1.0]

m4: rcvCreateMat 3 32 3x3 iden
print "Identical matrix"
print ["Mat Order :" rcvGetMatOrder m4 "as Red pair!"]
print ["Mat header:" rcvGetMatHeader m4]
print ["Mat values:" rcvGetMatData m4 lf]

;--tests for compatibility /libs/matrix/redCVmatrix.red 
makeRange: func [
	a 		[number!] 
	b 		[number!] 
	step 	[number!]][
    collect [i: a - step until [keep i: i + step i = (b - step)]]
]

m5: rcvCreateMat 3 64 5x8 makeRange -5.0 5.0 0.25 
print "Ordered matrix"
print ["Mat Order :" rcvGetMatOrder m5 "as Red pair!"]
print ["Mat header:" rcvGetMatHeader m5]
print ["Mat values:" rcvGetMatData m5 lf]
rcvMatShow m5

print ["Square? m3:" rcvMatSquare? m4]
print ["Square? m2:" rcvMatSquare? m5]

I: rcvCreateMatIdentity 3 32 3x3
rcvMatShow I

mx: rcvCreateMatScalar 3 32 5x5 5
rcvMatShow mx

nullMat: rcvCreateMatZero 3 32 3x3
rcvMatShow nullMat

print rcvMatZero? nullMat

print "*************** Tests OK ******************"



 
