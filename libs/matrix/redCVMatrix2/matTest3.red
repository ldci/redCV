#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

print "*********** Matrices Transformations ******************"
;--some blocks for testing
bf: [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0 12.0];-float
m3: rcvCreateMat 3 64 3x4 bf
rcvMatShow m3

rcvRemoveRow m3 2 
print "rcvRemoveRow m3 2"
rcvMatShow m3

rcvInsertRow/at m3 [4.0 5.0 6.0] 2
print "rcvInsertRow/at m3 [4.0 5.0 6.0] 2"
rcvMatShow m3

rcvAppendRow m3 [13.0 14.0 15.0]
print "rcvAppendRow m3 [13.0 14.0 15.0]"
rcvMatShow m3

rcvAppendRow m3 [16.0]
print "rcvAppendRow m3 [16.0]"
rcvMatShow m3

rcvRemoveCol m3 2 
print "rcvRemoveCol m3 2"
rcvMatShow m3

rcvMatTranspose m3
print "rcvMatTranspose m3"
rcvMatShow m3

print "*************** Tests OK ******************"
