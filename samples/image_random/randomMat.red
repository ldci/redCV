Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	File: 	 %randomMat.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
isize: 512x512
bitSize: 8
value: 255
img1: rcvCreateImage isize

;--obsolete definitions
;mat1: rcvCreateMat 'integer! bitSize isize
;mat2: rcvCreateMat 'integer! bitSize isize

;--use this
mat1: matrix/create 2 bitsize isize
mat2: matrix/create 2 bitsize isize


; ***************** Test Program ****************************
view win: layout [
		title "Matrice Random Tests"
		button 80 "Random" 	[if error? try [value: to-integer f/text] [value: 255]
							 ;rcvRandomMat mat1 value 
							 mat1: matrix/init/value/rand 2 bitsize isize 255

							 rcvMat2Image mat1 img1
							 canvas/image: img1
							]
		f: field 50  "255" 	
		button 80 "Sort" 	[mat2: rcvSortMat mat1 1 mat2 rcvMat2Image mat2 img1 canvas/image: img1]
		button 50 "Quit" 	[rcvReleaseImage img1 rcvReleaseMat mat1 rcvReleaseMat mat2 quit]
		return
		canvas: base 512x512 img1	
]