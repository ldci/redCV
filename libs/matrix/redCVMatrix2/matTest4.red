#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Matrices Computation ******************"
;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^A" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]										;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float

m1: rcvCreateMat 1 8  3x3 bc
m2: rcvCreateMat 2 16 3x3 bi
m3: rcvCreateMat 3 64 3x4 bf

print ["Sigma  :" rcvMatSum m1]
print ["Mean   :" rcvMatMean m1]
print ["Product:" rcvMatProduct m1]
print ["Minimal:" to-integer rcvMatMin m1]
print ["Maximal:" to-integer rcvMatMax m1 lf]

print ["Sigma  :" rcvMatSum m2]
print ["Mean   :" rcvMatMean m2]
print ["Product:" rcvMatProduct m2]
print ["Minimal:" rcvMatMin m2]
print ["Maximal:" rcvMatMax m2 lf]

print ["Sigma  :" rcvMatSum m3]
print ["Mean   :" rcvMatMean m3]
print ["Product:" rcvMatProduct m3]
print ["Minimal:" rcvMatMin m3]
print ["Maximal:" rcvMatMax m3 lf]

print "*************** Tests OK ******************"