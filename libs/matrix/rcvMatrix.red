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



rcvMakeBinaryMat: function [src [vector!] return: [vector!]
"Makes a 0 1 matrix"
][
	tmpm: copy src
	tmpm / 255
]

makeRange: func [a [number!] b [number!] step [number!]][
    collect [i: a - step until [keep i: i + step i = b]]
]


rcvMakeRangeMat: function [a [number!] b [number!] step [number!] return: [vector!]
"Creates an ordered matrix"
][
	tmp: makeRange a b step
	make vector! tmp
]

rcvMakeIndenticalMat: func [type [word!] bitSize [integer!] vSize [integer!] value [number!]return: [vector!]
"Creates a matrix with identical values"
][
	tmp: make vector! reduce  [type bitSize vSize]
	tmp + value
]


rcvCreateRangeMat: function [a [number!] b [number!] return: [vector!]] 
[
	tmp: makeRange a b
	make vector! tmp
]



_rcvRandomMat: function [v [vector!] value [number!]
][
	n: length? v
	collect [i: 0 until [ i: i + 1 keep  v/:i: random value i = n]]
]


rcvSortMat: func [v [vector!] return: [vector!]
"Ascending sort of matrix"
] [
	vv: copy v ; to avoid source modification
	sort vv
]

rcvFlipMat: function [v [vector!] return: [vector!]
"Reverses matrix"
][
	vv: copy v ; to avoid source modification
	reverse vv
]

rcvLengthMat: function [mat [vector!] return: [integer!]] [
	length? mat
]

rcvSumMat: function [mat [vector!] return: [float!]] [
	sum: 0.0
	foreach value mat [sum: sum + value]
	sum
]

rcvMeanMat: function [mat [vector!] return: [float!]] [
	(rcvSumMat mat) / (rcvLengthMat mat)
]

rcvProdMat: function [mat [vector!] return: [float!]] [
	prod: to-float mat/1
	n: length? mat
	i: 2
	while [i <= n] [
		prod: (prod * mat/:i)
		i: i + 1
	]
	prod
]

rcvMaxMat: function [mat [vector!] return: [number!]] [
	n: length? mat
	vMax: mat/1
	i: 2
	while [i <= n] [
		either (mat/:i > vMax) [vMax: mat/:i] [vMax: vMax]
		i: i + 1
	]
	vMax
]

rcvMinMat: function [mat [vector!] return: [number!]] [
	n: length? mat
	vMin: mat/1
	i: 2
	while [i <= n] [
		either (mat/:i < vMin) [vMin: v/:i] [vMin: vMin]
		i: i + 1
	]
	vMin
]




rcvRandomMat: function [mat [vector!] value [integer!]
"Randomize matrix"
][
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
; modified

rcvGetInt2D: function [ src [vector!] mSize [pair!] coordinate [pair!] return: [integer!]
"Get integer matrix value"
] [
	;idx: coordinate/x + (coordinate/y * mSize/x) + 1
	;src/(idx)
	_rcvGetInt2D src mSize coordinate/x coordinate/y
]

rcvGetReal2D: function [ src [vector!] mSize [pair!] coordinate [pair!] return: [float!] /f32
"Get float matrix value"
] [
	;idx: coordinate/x + (coordinate/y * mSize/x) + 1
	;src/(idx)
	either f32 [_rcvGetReal322D src mSize coordinate/x coordinate/y]
	[_rcvGetReal2D src mSize coordinate/x coordinate/y]
]

rcvSetInt2D: function [ dst [vector!] mSize [pair!] coordinate [pair!] val [integer!]
"Set integer matrix value"
] [
	;idx: coordinate/x + (coordinate/y * mSize/x) + 1
	;dst/(idx): val
	_rcvSetInt2D dst mSize coordinate/x coordinate/y val
]

rcvSetReal2D: function [ dst [vector!] mSize [pair!] coordinate [pair!] val [float!]
"Set float matrix value"
] [
	;idx: coordinate/x + (coordinate/y * mSize/x) + 1
	;dst/(idx): val
	_rcvSetReal2D dst mSize coordinate/x coordinate/y val
]

rcvGetPairs: function [binMatrix [vector!] width [integer!] height [integer!] points [block!]
"Gets coordinates from a binary matrix as pair values"
][
	_rcvGetPairs binMatrix width height points
]

rcvGetPoints: function [binMatrix [vector!] width [integer!] height [integer!] points [vector!]
"Gets coordinates from a binary matrix as x y values"
][
	_rcvGetPoints binMatrix width height points
]

; news for contour detection

rcvMatleftPixel: function [mat [vector!] matSize [pair!] value [integer!] return: [pair!]
"Gets coordinates of first left pixel"
][
	b: copy []
	_rcvleftPixel  mat matSize value b
	to-pair b/1
]

rcvMatRightPixel: function [mat [vector!] matSize [pair!] value [integer!] return: [pair!]
"Gets coordinates of first right pixel"
][
	b: copy []
	_rcvRightPixel  mat matSize value b
	to-pair b/1
]

rcvMatUpPixel: function [mat [vector!] matSize [pair!] value [integer!] return: [pair!]
"Gets coordinates of first top pixel"
][
	b: copy []
	_rcvUpPixel  mat matSize value b
	to-pair b/1 
]

rcvMatDownPixel: function [mat [vector!] matSize [pair!] value [integer!] return: [pair!]
"Gets coordinates of first bottom pixel"
][
	b: copy []
	_rcvDownPixel  mat matSize value b
	to-pair b/1
]

; end news

rcvMatGetBorder: function [mat [vector!] matSize [pair!] value [integer!] border [block!]
"Gets pixels that belong to shape border"
][
	_rcvGetBorder mat matSize value border
]


rcvMatGetChainCode: function [mat [vector!] matSize [pair!] 
coord [pair!] value [integer!] return: [integer!]
"Gets Freeman Chain code"
][
	_borderNeighbors mat matSize coord/x coord/y value
]


;Image and Contour moments

; Hu Invariant Moments of 2D Matrix
;uses binary transform for large images

rcvGetMatCentroid: function [
"Returns the centroid of the image"
	mat 	[vector!] 
	width 	[integer!]
	height 	[integer!] 
	return:	[pair!]
][
	minLoc: 0x0
	_rcvGetMatCentroid mat width height minLoc
]


;p - the order of the moment
;q - the repetition of the moment
; p: q: 0.0 -> moment order 0 -> form area


rcvGetMatSpatialMoment: function [
"Returns the spatial moment of the mat"
	mat		[vector!] 
	width 	[integer!] 
	height	[integer!] 
	p 		[float!] 
	q 		[float!] 
	return: [float!]
][
	_rcvGetMatSpatialMoment mat width height p q
]

rcvGetMatCentralMoment: function [
"Returns the central moment of the mat"
	mat		[vector!] 
	width 	[integer!] 
	height	[integer!] 
	p 		[float!] 
	q 		[float!] 
	return: [float!]
][
	minLoc: 0x0
	centroid: _rcvGetMatCentroid mat width height minLoc
	_rcvGetMatCentralMoment mat width height centroid p q
]



;Return the scale invariant moment of the image
;p - the order of the moment
;q - the repetition of the moment



rcvGetNormalizedCentralMoment: function [
"Return the scale invariant moment of the image"
	mat  			[vector!]
	width           [integer!]
    height          [integer!]
    p				[float!]
    q				[float!]
    return:			[float!]
] [
	moment1: rcvGetMatCentralMoment mat width height p q 
	moment2: rcvGetMatCentralMoment mat width height 0.0 0.0
	exponent: p + q / 2.0 + 1.0  
	m00: power moment2 exponent
	moment1 / m00
]

rcvGetMatHuMoments: function [
"Returns Hu moments of the image"
	mat  			[vector!]
	width           [integer!]
    height          [integer!]
    return: 		[block!]
][
	;where ηi,j are normalized central moments of 2-nd and 3-rd orders.
	n20: rcvGetNormalizedCentralMoment mat width height 2.0 0.0
	n02: rcvGetNormalizedCentralMoment mat width height 0.0 2.0
	n11: rcvGetNormalizedCentralMoment mat width height 1.0 1.0
	n12: rcvGetNormalizedCentralMoment mat width height 1.0 2.0
	n21: rcvGetNormalizedCentralMoment mat width height 2.0 1.0
	n30: rcvGetNormalizedCentralMoment mat width height 3.0 0.0
	n03: rcvGetNormalizedCentralMoment mat width height 0.0 3.0

	{from OpenCV
	h1=η20+η02
	h2=(η20-η02)²+4η11²
	h3=(η30-3η12)²+ (3η21-η03)²
	h4=(η30+η12)²+ (η21+η03)²
	h5=(η30-3η12)(η30+η12)[(η30+η12)²-3(η21+η03)²]+(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	h6=(η20-η02)[(η30+η12)²- (η21+η03)²]+4η11(η30+η12)(η21+η03)
	h7=(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]-(η30-3η12)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	}
	
	hu1: n20 + n02
	hu2: power (n20 - n02) 2 +  (4 * power n11 2)
	hu3: (power n30 - (3 * n12) 2) + (power 3 * n21 - n03 2)
	hu4: power (n30 + n12) 2 + power (n21 + n03) 2
	
	
	;h5=(η30-3η12)(η30+η12)[(η30+η12)²-3(η21+η03)²]+(3η21-η03)(η21+η03)[3(η30+η12)²-(η21+η03)²]
	
	
	a: n30 - (3 * n12)
	b: n30 + n12
	c: power n30 + n12 2
	d: 3 * power n21 + n03 2 
	e: 3 * n21 - n03
	f: n21 + n03
	g: 3 * power n30 + n12 2
	h: power n21 + n03 2
	
	hu5: (a * b) * (c - d) + (e * f * (g - h))
	
	
	
	;hu5: n30 - (3 * n12) * (n30 + n12) - (3 * (n21 + n03) ** 2)))) 
	;	+ (((3 * n21) - n03) * (n21 + n03)) * (3 * ((n30 + n12) ** 2) - ((n21 + n03) ** 2))
	a: n20 - n02
	b: (n30 + n12) ** 2
	c: (n21 + n03) ** 2
	d: 4 * n11
	e: n30 + n12
	f: n21 + n03
	;print (a * (b - c)) + (d * e * f)
	
	hu6: (n20 - n02) * (((n30 + n12) ** 2) - (n21 + n03) ** 2) + (4 * n11) * ((n30 + n12) * (n21 + n03))
	hu7: (3 * n21 - n03) * (n30 + n12) * ((n30 + n12) ** 2 - 3 * (n21 + n03) ** 2) -
			(n30 - 3 * n12) * (n21 + n03) * (3 * (n30 + n12) ** 2 - (n21 + n03) ** 2)
			
	reduce [hu1 hu2 hu3 hu4 hu5 hu6 hu7]
]




;*********

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

rcvMat2Binary: function [mat [vector!] return: [binary!]
"Matrix to binary value"
] [
	to-binary to-block mat
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
