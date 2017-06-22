Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blendMatrices.red
	Needs:	 'View
]

;this version uses rcvSetIntensity and not rcvBlend

#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
isize: 512x512
bitSize: 32

dst: rcvCreateImage isize

mat1: rcvCreateMat 'integer! bitSize isize
mat2: rcvCreateMat 'integer! bitSize  isize
matD: rcvCreateMat 'integer! bitSize  isize

alpha: 0.5

blending: does [
	rcvBlendMat mat1 mat2 matD alpha
	rcvMat2Image matD dst
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
							rcvReleaseMat matD
							Quit]
		return
		canvas: base isize dst
		do [sl/data: alpha rcvColorMat mat1 0 rcvColorMat mat2 255 blending]
]
