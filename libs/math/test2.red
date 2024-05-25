#!/usr/local/bin/red
Red [
]
#include %rcvComplex.red
;--Red tests

z1: complex/cCreate [0.0 1.0]
print ["i^2: " complex/cProduct z1 z1]


z1: complex/cCreate [1.4 0.4]
print complex/sAlgebraic z1
print ["module : " complex/cModulus z1]
print ["radians: " complex/cArgument z1]
print ["degrees: " complex/cArgument/degrees z1]


print ["Polar notation" complex/sPolar z1]
p:  complex/toPolar z1
print ["Polar values " p]
print ["Polar to Cartesian "complex/toCartesian p]
z2: complex/toComplex/rounding p
print ["Polar to Complex" complex/sAlgebraic z2]

print "Matrix test"
i: complex/cCreate [0.0 1.0] ;iota
print complex/sAlgebraic i
ii: complex/toMatrix i
probe ii

print "i2 test"
iota: complex/cProduct i i
print ["i^2:" iota/re]



