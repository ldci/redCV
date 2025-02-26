#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red
#include %../routines-obj.red

bc: [#"^A" #"^B" #"^C" #"^D" #"^E" #"^F" #"^G" #"^H" #"^@"] ;--char
m1: matrix/create 1 8  3x3 bc
print ["Matrix Type:        " getMatType m1 getMatTypeAsString m1]
print ["Matrix Bit Size:    " getMatBits m1]
print ["Matrix Order:       " getMatOrder m1]
print ["Matrix Data Length: " getMatDataLength m1]
print ["Matrix data:        " getMatData m1]
print ["Matrix unit:        " getMatUnit m1 lf]


m2: matrix/create 2 32 3x3 [1 2 3 4 5 6 7 8 9]				;--integer
print ["Matrix Type:        " getMatType m2 getMatTypeAsString m2]
print ["Matrix Bit Size:    " getMatBits m2]
print ["Matrix Order:       " getMatOrder m2]
print ["Matrix Data Length: " getMatDataLength m2]
print ["Matrix data:        " getMatData m2]
print ["Matrix unit:        " getMatUnit m2 lf]

bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0]	;-float
m3: matrix/create 3 64 3x4 bf
print ["Matrix Type:        " getMatType m3 getMatTypeAsString m3]
print ["Matrix Bit Size:    " getMatBits m3]
print ["Matrix Order:       " getMatOrder m3]
print ["Matrix Data Length: " getMatDataLength m3]
print ["Matrix data:        " getMatData m3]
print ["Matrix unit:        " getMatUnit m3 lf]