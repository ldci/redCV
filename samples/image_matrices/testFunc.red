Red [
]

#include %../../libs/matrix/rcvMatrix.red

m1: matrix/init/value/rand/bias 2 32 3x4 10 -2
m2: matrix/init/value/rand/bias 2 32 3x4 10 -2

print "Binary test"
m: rcvMakeBinaryMat m1
probe form m1/data
probe form m/data

m: rcvMakeFastBinaryMat m1
probe form m/data

print "Scale test"
m: rcvConvertMatIntScale m1 FFh FFFFh 
probe form m/data

print "Conversion test"
m: rcvMatInt2Float m1 64 1.0
probe form m/data
m2: rcvMatFloat2Int m 8 1.0
probe form m2/data

print "Log test"
rcvLogMatFloat m
probe form m/data

m1: matrix/init/value/rand/bias 2 32 3x4 10 -2
m2: matrix/init/value/rand 2 32 3x4 10
m3: matrix/init/value 2 32 3x4 0

print "Mean test"
rcvMeanMats m1 m2 m3
probe form m1/data
probe form m2/data
probe form m3/data

print "Logical test"
probe form m1/data
probe form m2/data

print "AND"
rcvANDMat m1 m2 m3
probe form m3/data

print "OR"
rcvORMat m1 m2 m3
probe form m3/data

print "XOR"
rcvXORMat m1 m2 m3
probe form m3/data


