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
	t: _rcvGetMatType src
	if t = 1 [dst: make vector! reduce  [integer! length? src] _rcvCopyMat src dst]
	if t = 2 [dst: make vector! reduce  [float! length? src] _rcvCopyMatF src dst] 
	dst
]

rcvCopyMat: function [src [vector!] dst [vector!]
"Copy source matrix to destination matrix"
][
	t: _rcvGetMatType src
	if t = 1 [_rcvCopyMat src dst]
	if t = 2 [_rcvCopyMatF src dst] 
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


; direct pixel access for 1 channel image
; since image coordinates is 0x0 based -> + 1 in matrices 

rcvGetInt2D: function [ src [vector!] mSize [pair!] coordinate [pair!] return: [integer!]
"Get integer matrix value"
] [
	idx: coordinate/x + (coordinate/y * mSize/x) + 1
	src/(idx)
]

rcvGetReal2D: function [ src [vector!] mSize [pair!] coordinate [pair!] return: [float!]
"Get float matrix value"
] [
	idx: coordinate/x + (coordinate/y * mSize/x) + 1
	src/(idx)
]

rcvSetInt2D: function [ dst [vector!] mSize [pair!] coordinate [pair!] val [integer!]
"Set integer matrix value"
] [
	idx: coordinate/x + (coordinate/y * mSize/x) + 1
	dst/(idx): val
]

rcvSetReal2D: function [ dst [vector!] mSize [pair!] coordinate [pair!] val [float!]
"Set float matrix value"
] [
	idx: coordinate/x + (coordinate/y * mSize/x) + 1
	dst/(idx): val
]



rcvImage2Mat: function [src	[image!] mat [vector!]
"Red Image to integer or char 2-D Matrix "
] [
	_rcvImage2Mat src mat
]



rcvMat2Image: function [mat [vector!] dst [image!]
"Matrix to Red Image"
] [
	_rcvMat2Image mat dst
]


rcvSplit2Mat: function [src [image!] mat0 [vector!] mat1 [vector!] mat2 [vector!] mat3 [vector!]  
"Split an image to 4 8-bit matrices"
] [
	_rcvSplit2Mat src mat0 mat1 mat2 mat3
]

rcvMerge2Image: function [ mat0 [vector!] mat1 [vector!] mat2 [vector!] mat3 [vector!]  dst [image!]
"Merge 4 8-bit matrices to image"
] [
	_rcvMerge2Image mat0 mat1 mat2 mat3 dst
]

rcvConvolveMat: function [src [vector!] dst [vector!] mSize[pair!] kernel [block!] factor [float!] delta [float!]
"Classical matrix convolution"
] [
	_rcvConvolveMat src dst mSize kernel factor delta 
]


rcvConvolveNormalizedMat: function [src [vector!] dst [vector!] mSize[pair!] kernel [block!] factor [float!] delta [float!]
"Normalized fast matrix convolution"
] [
	_rcvConvolveMat2 src dst mSize kernel factor delta 
]

rcvConvertMatScale: function [src [vector!] dst [vector!] srcScale [number!] dstScale [number!] /fast /std
"Converts Matrix Scale"
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	if type? dstScale = integer! [dstScale: to float! dstScale]
	case [
		std  [n: length? src
					i: 1
					while [i <= n] [
						dst/(i): to integer! ((src/(i) / srcScale) * dstScale)
	 					i: i + 1]
	 				]
		fast	[_convertMatScale src dst srcScale dstScale]
	]	
]

rcvMatInt2Float: function [src [vector!] dst [vector!] srcScale [number!]
"Converts Integer Matrix to Float [0..1] matrix"	
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	n: length? src
	i: 1
	while [i <= n] [
					dst/(i): to float! (src/(i)) / srcScale 
	 				i: i + 1
	]
]

rcvMatFloat2Int: function [src [vector!] dst [vector!]
"Converts float matrix to integer [0..255] matrix"	
][
	n: length? src
	i: 1
	while [i <= n] [
					dst/(i): to integer! (src/(i) * 255) 
	 				i: i + 1
	]
]

rcvMatFastSobel: function [src [vector!] dst [vector!] iSize [pair!] 
"Fast Sobel on Matrix"
][
	_rcvSobelMat src dst iSize
]


;***********************Matrices Operations *********************
__rcvAddMat: function [src1 [vector!] src2 [vector!] dst [vector!]
"dst: src1 +  src2"
][
	dst: src2 + src1
	dst
]

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

rcvMeanMats: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 + src2 / 2"
][
	(src1 + src2) / 2
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

rcvANDMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 AND  src2"
][
	src1 AND src2
]

rcvORMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 OR src2"
][
	src1 OR src2
]

rcvXORMat: function [src1 [vector!] src2 [vector!] return: [vector!]
"dst: src1 XOR  src2"
][
	src1 XOR src2
]

; Scalar operations directly modify vector

rcvANDSMat: function [src [vector!] value [integer!]
"src AND  value"
][
	src AND value
]

rcvORSMat: function [src [vector!] value [integer!]
"src OR value"
][
	src OR value
]

rcvXORSMat: function [src [vector!] value [integer!]
"src XOR value"
][
	src XOR value
]


; ******************* morphological Operations**************************
rcvErodeMat: function [ src [vector!] dst [vector!] mSize [pair!] kSize [pair!] kernel [block!]
"Erodes matrice by using structuring element"
] [
	_rcvMorpho src dst mSize kSize/x kSize/y kernel 2
]

rcvDilateMat: function [ src [vector!] dst [vector!] mSize [pair!] kSize [pair!] kernel [block!]
"Dilates matrice by using structuring element"
] [
	_rcvMorpho src dst mSize kSize/x kSize/y kernel 1 
]

;************** matrices alpha blending ***********************

rcvBlendMat: function [ mat1 [vector!] mat2 [vector!] dst [vector!] alpha [float!] 
"Computes the alpha blending of two matrices"
][
	_rcvBlendMat mat1 mat2 dst alpha
]

rcvInRangeMat: function [src [vector!] dst [vector!] lower [integer!] upper [integer!] op [integer!]
"Extracts sub array from matrix according to lower and upper values "
] [
	_rcvInRangeMat src dst lower upper op
]
