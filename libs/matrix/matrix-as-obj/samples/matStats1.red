#!/usr/local/bin/red
Red [
]

#include %../matrix-obj.red

print "*********** Matrices Statistics ******************"
;--some blocks for testing
bc: [#"^@" #"^@" #"^@" #"^A" #"^@" #"^@" #"^@" #"^@" #"^@"] ;--char
bi: [1 2 3 4 5 6 7 8 9]										;--integer
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float

m1: matrix/create 1 8  3x3 bc
m2: matrix/create 2 16 3x3 bi
m3: matrix/create 3 64 3x4 bf

matrix/show m1
print ["Sigma  :" matrix/sigma m1]
print ["Mean   :" matrix/mean m1]
print ["Product:" matrix/product m1]
print ["Minimal:" to-integer matrix/mini m1]
print ["Maximal:" to-integer matrix/maxi m1 lf]
matrix/show m2
print ["Sigma  :" matrix/sigma m2]
print ["Mean   :" matrix/mean m2]
print ["Product:" matrix/product m2]
print ["Minimal:" matrix/mini m2]
print ["Maximal:" matrix/maxi m2 lf]
matrix/show m3
print ["Sigma  :" matrix/sigma m3]
print ["Mean   :" matrix/mean m3]
print ["Product:" matrix/product m3]
print ["Minimal:" matrix/mini m3]
print ["Maximal:" matrix/maxi m3 lf]

print ["Add m3 to m3:"]
matrix/show matrix/addition m3 m3

print "*************** Tests OK ******************"