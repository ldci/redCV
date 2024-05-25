Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blendMatrices.red
	Needs:	 'View
]

;this version uses rcvSetIntensity and not rcvBlend

#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red


margins: 10x10								;--cosmetics
isize: 512x512								;--fix size
bitSize: 32									;--32-bit 
dst: rcvCreateImage isize					;--create an image
mat1: matrix/init/value 2 bitSize isize 0	;--32-bit matrix with 0 values
mat2: matrix/init/value 2 bitSize isize 255	;--32-bit matrix with 255 values
mat3: matrix/init 2 bitSize isize			;--result matrix 
alpha: 0.5									;--alpha [0.0 .. 1.0]

blending: does [
	rcvBlendMat mat1 mat2 mat3 alpha
	rcvMat2Image mat3  dst
	canvas/image: dst
	do-events/no-wait
]


; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		text 60 "Matrix 1" 
		f1: field 50 "0.5"
		sl: slider 170 [alpha: face/data * 1.0
					f1/text: form round/to alpha 0.001
					f2/text: form round/to (1 - alpha) 0.001
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
