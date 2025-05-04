#!/usr/local/bin/red
Red [
]
#include %rcvComplex.red
;--Red tests

print "Complex trigometric test"

z1: complex/cCreate [2.0 -3.0]
print ["z: " complex/sAlgebraic z1]
z2: complex/cSin z1
print ["Sine: " complex/sAlgebraic z2]
z2: complex/cCos z1
print ["Cosine: " complex/sAlgebraic z2]
z2: complex/cTan z1
print ["Tangent: " complex/sAlgebraic z2]

z2: complex/cSinh z1
print ["Hyperbolic sine: " complex/sAlgebraic z2]
z2: complex/cCosh z1
print ["Hyperbolic cosine: " complex/sAlgebraic z2]
z2: complex/cTanh z1
print ["Hyperbolic tangent: " complex/sAlgebraic z2]
