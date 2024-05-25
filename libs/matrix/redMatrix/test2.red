#!/usr/local/bin/red
Red [
]

#include %matrix.red
print "512x512 matrix init"
t1: now/time/precise
mx: matrix/init/value/rand 2 8 255x255 255
t2: now/time/precise
probe matrix/header mx
;matrix/show mx

print rejoin ["Matrix creation: " round/to third t2 - t1 * 1000 0.01 " ms"]

print "512x512 matrix rotation"
t3: now/time/precise
mxr: matrix/rotate mx 3
t4: now/time/precise
;matrix/show mxr 
print rejoin ["Matrix rotation: " round/to third t4 - t3 * 1000 0.01 " ms"]
