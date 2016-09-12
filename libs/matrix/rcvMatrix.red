Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Francois Jouen"
	File: 	 %rcvMatrix.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


#include %rcvMatrixRoutines.red	; All Red/System Matricesroutines

; To be modified when Matrix! datatype will be available

rcvCreateMat: function [ type [word!] bitSize [integer!] mSize [pair!] return: [vector!]
"Creates 2D matrix "
][
	xSize: mSize/x
	ySize: mSize/y
	make vector! reduce  [type bitSize xSize * ySize]
]

; should be modified as a routine with vector/delete mat
rcvReleaseMat: function [mat [vector!]
"Releases Matrix"
] [
	mat: none
]

rcvCloneMat: function [src [vector!] return: [vector!]
"Returns a copy of source matrix"
][
	dst: make vector! reduce  [integer! length? src]
	dst: copy src
	dst
]

rcvCopyMat: function [src [vector!] dst [vector!]
"Copy source matrix to destination matrix"
][
	dst: src
]


rcvRandomMat: function [mat [vector!] value [integer!]
"Randomize matrix"
][
	; for interpreted
	;n: length? mat
	;i: 1
	;while [i <= n] [mat/(i): random value i: i + 1]
	forall mat [mat/1: random value]
]



rcvColorMat: function [mat [vector!] value [integer!]
	"Set matrix color"
][
	; for interpreted
	;n: length? mat
	;i: 1
	;while [i <= n] [mat/(i): value i: i + 1]
	forall mat [mat/1: value]
]

rcvImage2Mat: function [src	[image!] mat [vector!]
"Red Image to a 8-bit 2-D Matrice "
] [
	_rcvImage2Mat src mat
]
rcvMat82Image: function [mat [vector!] dst [image!] 
"8-bit Matrice to Red Image"
] [
	_rcvMat2Image mat dst 1
]

rcvMat162Image: function [mat [vector!] dst [image!] 
"16-bit Matrice to Red Image"
] [
	_rcvMat2Image mat dst 2
]

rcvMat322Image: function [mat [vector!] dst [image!] 
"32-bit Matrice to Red Image"
] [
	_rcvMat2Image mat dst 4
]

rcvConvolveMat: function [src [vector!] dst [vector!] mSize[pair!] kernel [block!] factor [float!] delta [float!]
"Fast matrix convolution"
] [
	_rcvConvolveMat src dst mSize kernel factor delta 
]

rcvConvertMatScale: function [src [vector!] dst [vector!] srcScale [number!] dstScale [number!] /fast /normal
"Converts Matrix Scale"
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	if type? dstScale = integer! [dstScale: to float! dstScale]
	case [
		normal  [n: length? src
					i: 1
					while [i <= n] [
						dst/(i): to integer! (to float! src/(i) / srcScale * dstScale)
	 					i: i + 1]
	 				]
		fast	[_convertMatScale src dst srcScale dstScale]
	]	
]



;***********************Matrices Operations *********************
rcvAddMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 +  src2"
][
	src1 + src2
]

rcvSubMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 -  src2"
][
	src1 - src2
]

rcvMulMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 *  src2"
][
	src1 * src2
]

rcvDivMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 /  src2"
][
	src1 / src2
]

rcvRemMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 % src2"
][
	src1 % src2
]

; ****************************scalars*******************************
; Scalar operations directly modify vector
rcvAddSMat: function [src [vector!] value [integer!] 
"src +  value"
][
	src + value
]

rcvSubSMat: function [src [vector!] value [integer!]
"src -  value"
][
	src - value
]

rcvMulSMat: function [src [vector!] value [integer!] 
"src *  value"
][
	src * value
]

rcvDivSMat: function [src [vector!] value [integer!]
"src /  value"
][
	src / value
]

rcvRemSMat: function [src [vector!] value [integer!] 
"dst: src %  value"
][
	src % value
]

;**********************Logical ************************************

rcvAndMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 AND  src2"
][
	src1 AND src2
]

rcvOrMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 OR src2"
][
	src1 OR src2
]

rcvXorMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 XOR  src2"
][
	src1 XOR src2
]

; Scalar operations directly modify vector

rcvAndSMat: function [src [vector!] value [integer!]
"src AND  value"
][
	src AND value
]

rcvOrSMat: function [src [vector!] value [integer!]
"src OR value"
][
	src OR value
]

rcvXorSMat: function [src [vector!] value [integer!]
"src XOR value"
][
	src XOR value
]
