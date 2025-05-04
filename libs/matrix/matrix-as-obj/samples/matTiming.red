#!/usr/local/bin/red
Red [
]
#include %../matrix-obj.red
print "*********** Timing ******************"
print "512x512 integer matrix"
random/seed now/time/precise
bi: copy []
n: 512 * 512
repeat i n [append bi random 255]
t1: now/time/precise
mx: matrix/create 2 16 512x512 bi
t2: now/time/precise
print matrix/header mx
print rejoin ["Matrix creation: " round/to (third t2 - t1) * 1000 0.01 " ms"]
t3: now/time/precise
print "...."
matrix/rotate mx 1
t4: now/time/precise
print rejoin ["Matrix rotation: " round/to (third t4 - t3) * 1000 0.01 " ms"]
print "*************** Tests OK ******************"