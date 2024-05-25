#!/usr/local/bin/red
Red [
]

#include %matrix.red
print "512x512 matrix create"
random/seed now/time/precise
bi: copy []
n: 512 * 512
repeat i n [append bi random 255] 
m1: matrix/create 2 8 512x512 bi
probe matrix/header m1


bi: copy []
n: 127 * 127
repeat i n [append bi random 127] 
m1: matrix/create 2 8 127x127 bi
probe matrix/header m1
probe matrix/data


m1: matrix/create 2 16 512x512 bi
probe matrix/header m1

m1: matrix/create 2 32 512x512 bi
probe matrix/header m1

print ""
print "512x512 matrix init"
mx: matrix/init/value/rand 2  8 512x512 255
probe matrix/header mx

mx: matrix/init/value/rand 2 16 512x512 255
probe matrix/header mx

mx: matrix/init/value/rand 2 32 512x512 255
probe matrix/header mx
