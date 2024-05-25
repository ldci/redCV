Red [
	Title:   "Matrices"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]
;--to be executed in shell terminal
; required libs
#include %../../libs/matrix/rcvMatrix.red
random/seed now/time/precise
mat: matrix/init/value/rand 2 8 3x4 100
probe mat
repeat j mat/rows [
	repeat i mat/cols[
		print ["Row" j "Col" i ":" matrix/_getAt mat j i]
	]
]

print "Done"
			
			