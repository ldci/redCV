#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red
;--large matrices copy test

print "*********** Matrices Copy ******************"
mx: matrix/create 2 32 3x3 []
matrix/show mx
mSize: 512x512
m: matrix/init/value/rand 2 16 mSize 255
t1: now/time/precise
mc: matrix/_copy m
t2: now/time/precise
;matrix/show mc
print rejoin ["Red Matrix copy: " round/to (third t2 - t1) * 1000 0.01 " ms"]

print "*************** Tests OK ******************"

