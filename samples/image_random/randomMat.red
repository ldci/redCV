Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %randomMat.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
isize: 512x512
bitSize: 32
value: 255
img1: rcvCreateImage isize
mat:  rcvCreateMat 'integer! bitSize img1/size
mat1: rcvCreateMat 'integer! bitSize img1/size


; ***************** Test Program ****************************
view win: layout [
		title "Matrice Random Tests"
		button 80 "Random" 	[if error? try [value: to-integer f/text] [value: 255]
							 rcvRandomMat mat value rcvMat2Image mat img1
							]
		f: field 50  "255" 	
		button 80 "Sort" 	[mat1: rcvSortMat mat rcvMat2Image mat1 img1]
		button 50 "Quit" 	[rcvReleaseImage img1 rcvReleaseMat mat rcvReleaseMat mat1 quit]
		return
		canvas: base 512x512 img1	
]