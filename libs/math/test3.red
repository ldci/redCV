#!/usr/local/bin/red
Red [
]
#include %rcvComplex.red
;--Red tests

print "Complex log test"

z1: complex/cCreate [0.0 1.0]
z2: complex/cLog z1
print complex/sAlgebraic z2

z1: complex/cCreate [1.0 1.0]
z2: complex/cLog z1
print complex/sAlgebraic z2

z1: complex/cCreate [2.0 1.0]
z2: complex/cLog z1
print complex/sAlgebraic z2

z1: complex/cCreate [3.0 1.0]
z2: complex/cLog z1
print complex/sAlgebraic z2

z1: complex/cCreate [1.0 2.0]
z2: complex/cLog z1
print complex/sAlgebraic z2

print "Complex exp test"
z1: complex/cCreate [0.0 1.0]
z2: complex/cExp z1
print complex/sAlgebraic z2


z1: complex/cCreate [2.0 1.0]
z2: complex/cExp z1
print complex/sAlgebraic z2