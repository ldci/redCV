Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blendMatrices.red
	Needs:	 'View
]

;this version uses rcvSetIntensity and not rcvBlend

#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red


margins: 10x10
isize: 512x512
bitSize: 32

dst: rcvCreateImage isize

mat1: matrix/init/value 2 bitSize isize 0
mat2: matrix/init/value 2 bitSize isize 255
mat3: matrix/init 2 bitSize isize
alpha: 0.5

blending: does [
	rcvBlendMat mat1 mat2 mat3 alpha
	rcvMat2Image mat3  dst
	canvas/image: dst
]


; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		text 60 "Matrix 1" 
		f1: field 50 "0.5"
		sl: slider 170 [alpha: face/data * 1.0
					f1/text: form alpha
					f2/text: form (1 - alpha)
					blending
					]
		text 60 "Matrix 2" 
		f2: field 50  "0.5"
		button 60 "Quit" [	rcvReleaseImage dst 
							rcvReleaseMat mat1
							rcvReleaseMat mat2
							rcvReleaseMat mat3
							Quit]
		return
		canvas: base isize dst
		do [sl/data: alpha blending]
]
