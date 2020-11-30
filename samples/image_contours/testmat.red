Red [
	Title:   "Matrices"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required libs
#include %../../libs/matrix/rcvMatrix.red
random/seed now/time/precise
mat: matrix/init/value/rand 2 8 3x4 10
probe mat
repeat j mat/rows [
	repeat i mat/cols[
		print ["Row" j "Col" i ":" matrix/_getAt mat j i
		matrix/getAt mat as-pair i j
		rcvGetInt2D mat i j 
		]
	]
]
			
			