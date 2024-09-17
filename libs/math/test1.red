#!/usr/local/bin/red
Red [
]
#include %rcvComplex.red
;--Red tests

print "Operations on complex numbers" 
print "Creation"
z1: complex/cCreate [3 4]
z2: complex/cCreate [5 -2]
print ["z1 = " complex/sAlgebraic z1]
print ["z2 = " complex/sAlgebraic z2]
z3: complex/cNegate z2
print ["cNegate z2 = " complex/sAlgebraic z3]
z3: complex/cConjugate z2
print ["cConjugate z2 = " complex/sAlgebraic z3]
z4: complex/cAdd z1 z2
print ["z1 + z2 = " complex/sAlgebraic z4]
z4: complex/cSubtract z1 z2
print ["z1 - z2 = " complex/sAlgebraic z4]
z4: complex/cProduct z1 z2
print ["z1 * z2 = " complex/sAlgebraic z4]
z4: complex/cFoilProduct z1 z2
print ["z1 * z2 = " complex/sAlgebraic z4]
z4: complex/cDivide z1 z2
print ["z1 / z2 = " complex/sAlgebraic z4]
z4: complex/scalarProduct z1 2.0
print ["z1 * 2.0 = " complex/sAlgebraic z4]
z4: complex/scalarDivision z1 4.0
print ["z1 / 2.0 = " complex/sAlgebraic z4]
