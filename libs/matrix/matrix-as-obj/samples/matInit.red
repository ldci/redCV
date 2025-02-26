#!/usr/local/bin/red
Red [
]

print "*********** Matrix initialization ******************"
#include %../matrix-obj.red
;--matrices initialization test

m1: matrix/init 2 16 3x3
matrix/show m1

m2: matrix/init/value 2 16 3x3 9
matrix/show m2

m3: matrix/init/value/rand 2 16 3x3 255
matrix/show m3

m4: matrix/init/value/rand/bias 2 16 3x3 255 -2
matrix/show m4

m5: matrix/scalar 2 16 3x3 5
matrix/show m5

m6: matrix/identity 2 16 3x3
matrix/show m6

m7: matrix/zero 2 16 3x3
matrix/show m7

print "*************** Tests OK ******************"
