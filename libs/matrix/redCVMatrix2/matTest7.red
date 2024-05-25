#!/usr/local/bin/red
Red [
]
#include %rcvMatrix2.red

print "*********** Compute ******************"

m1: rcvCreateMat 2 16 2x2 [3 8 4 6]
m2: rcvCreateMat 2 16 2x2 [4 0 1 -9]
rcvMatShow m1
rcvMatShow m2
print "Addition"
mx: rcvMatAddition m1 m2
rcvMatShow mx

print "Subtraction"
mx: rcvMatSubtraction m1 m2
rcvMatShow mx

m1: rcvCreateMat 2 16 3x2 [1 2 3 4 5 6]
m2: rcvCreateMat 2 16 2x3 [7 8 9 10 11 12]
print "Multiplication"
mx: rcvMatStandardProduct m1 m2
rcvMatShow mx

print "Hadamard product"
m1: rcvCreateMat 2 16 3x2 [1 2 3 4 5 6]
m2: rcvCreateMat 2 16 3x2 [7 8 9 10 11 12]
mx: rcvMatHadamardProduct m1 m2
rcvMatShow mx

print "Kronecker product"
mx: rcvMatKroneckerProduct m1 m2
rcvMatShow mx


print "Division"
m1: rcvCreateMat 2 16 2x2 [3 5 4 7]		;--matrix
m2: rcvCreateMat 2 16 2x2 [7 -5 -4 3] 	;--inverse matrix
mx: rcvMatStandardProduct m1 m2			;--matrix * inverse matrix
rcvMatShow mx
mx: rcvMatDivide m2 m2					;--matrix division 
rcvMatShow mx


