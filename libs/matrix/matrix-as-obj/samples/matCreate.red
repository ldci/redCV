#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Matrices Creation ******************"
;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]										;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float

m1: matrix/create 1 8  3x3 bc
m2: matrix/create 2 16 3x3 bi
m3: matrix/create 3 64 3x4 bf

print "Char matrix" 
print ["Mat Order :" matrix/order m1 "as Red pair!"]
print ["Mat header:" matrix/header m1]
print "Mat values:" 
matrix/show m1

print "Integer matrix"
print ["Mat Order :" matrix/order m2 "as Red pair!"]
print ["Mat header:" matrix/header m2]
print "Mat values:" 
matrix/show m2

print "Float matrix"
print ["Mat Order :" matrix/order m3 "as Red pair!"]
print ["Mat header:" matrix/header m3]
print "Mat values:"
matrix/show m3

iden: copy []
loop 9 [append iden 1.0]

m4: matrix/create 3 32 3x3 iden
print "Identical matrix (m4)"
print ["Mat Order :" matrix/order m4 "as Red pair!"]
print ["Mat header:" matrix/header m4]
print "Mat values:" 
matrix/show m4

;--tests for compatibility /libs/matrix/redCVmatrix.red 
makeRange: func [
	a 		[number!] 
	b 		[number!] 
	step 	[number!]][
    collect [i: a - step until [keep i: i + step i = (b - step)]]
]

m5: matrix/create 3 64 5x8 makeRange -5.0 5.0 0.25 
print "Ordered matrix (m5)"
print ["Mat Order :" matrix/order m5 "as Red pair!"]
print ["Mat header:" matrix/header m5]
print ["Mat values:" m5/data lf]
matrix/show m5

print ["Square? m4:" matrix/square? m4]
print ["Square? m5:" matrix/square? m5]

I: matrix/identity 3 32 3x3
matrix/show I

mx: matrix/scalar 3 32 5x5 5
matrix/show mx

nullMat: matrix/zero 3 32 3x3
matrix/show nullMat

print matrix/null? nullMat

print "*************** Tests OK ******************"



 
