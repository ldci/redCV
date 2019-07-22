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

rcvCreateMat: function [ 
"Creates 2D matrix"
	type [word!] 
	bitSize [integer!] 
	mSize [pair!]
][
	xSize: mSize/x
	ySize: mSize/y
	make vector! reduce  [type bitSize xSize * ySize]
]

; should be modified as a routine with vector/delete mat
rcvReleaseMat: function [
"Releases Matrix"
	mat [vector!]
][
	mat: none
]

rcvCloneMat: function [
"Returns a copy of source matrix"
	src [vector!]
][
	t: _rcvGetMatType src
	if t = 1 [dst: make vector! reduce  [integer! length? src] _rcvCopyMat src dst]
	if t = 2 [dst: make vector! reduce  [float! length? src] _rcvCopyMatF src dst] 
	dst
]

rcvCopyMat: function [
"Copy source matrix to destination matrix"
	src [vector!] 
	dst [vector!]
][
	t: _rcvGetMatType src
	if t = 1 [_rcvCopyMat src dst]
	if t = 2 [_rcvCopyMatF src dst] 
]


; modified
rcvMakeBinaryMat: function [
"Makes [0 1] matrix"
	src [vector!] 
	dst [vector!]
][
	_rcvMakeBinaryMat src dst
]

makeRange: func [
	a 		[number!] 
	b 		[number!] 
	step 	[number!]][
    collect [i: a - step until [keep i: i + step i = b]]
]


rcvMakeRangeMat: function [
"Creates an ordered matrix"
	a 		[number!] 
	b 		[number!] 
	step 	[number!] 
][
	tmp: makeRange a b step
	make vector! tmp
]

rcvMakeIndenticalMat: func [
"Creates a matrix with identical values"
	type 	[word!] 
	bitSize [integer!] 
	vSize 	[integer!] 
	value 	[number!]
][
	tmp: make vector! reduce  [type bitSize vSize]
	tmp + value
]

; A verifier
rcvCreateRangeMat: function [
	a [number!] 
	b [number!] 
][
	tmp: makeRange a b
	make vector! tmp
]


rcvSortMat: func [
"Ascending sort of matrix"
	v [vector!] 
][
	vv: copy v ; to avoid source modification
	sort vv
]

rcvFlipMat: function [
"Reverses matrix"
	v [vector!] 
][
	vv: copy v ; to avoid source modification
	reverse vv
]

rcvLengthMat: function [
"Matrix length as integer value"
	mat [vector!] 
] [
	length? mat
]

rcvSumMat: function [
"Matrix sum as float value"
	mat [vector!]
][
	sum: 0.0
	foreach value mat [sum: sum + value]
	sum
]

rcvMeanMat: function [
"Matrix mean as float value"
	mat [vector!] 
][
	(rcvSumMat mat) / (rcvLengthMat mat)
]

rcvProdMat: function [
"Matrix product as float value"
	mat [vector!] 
][
	prod: to-float mat/1
	n: length? mat
	i: 2
	while [i <= n] [
		prod: (prod * mat/:i)
		i: i + 1
	]
	prod
]

rcvMaxMat: function [
"Max value of the matrix as number"
	mat [vector!] 
][
	n: length? mat
	vMax: mat/1
	i: 2
	while [i <= n] [
		either (mat/:i > vMax) [vMax: mat/:i] [vMax: vMax]
		i: i + 1
	]
	vMax
]

rcvMinMat: function [
"Min value of the matrix as number"
	mat [vector!] 
][
	n: length? mat
	vMin: mat/1
	i: 2
	while [i <= n] [
		either (mat/:i < vMin) [vMin: v/:i] [vMin: vMin]
		i: i + 1
	]
	vMin
]


_rcvRandomMat: function [v [vector!] value [number!]
][
	n: length? v
	collect [i: 0 until [ i: i + 1 keep  v/:i: random value i = n]]
]



rcvRandomMat: function [
"Randomize matrix"
	mat 	[vector!] 
	value 	[integer!]
][
	forall mat [mat/1: random value]
]



rcvColorMat: function [
	"Set matrix color"
	mat 	[vector!] 
	value 	[integer!]
][
	; for interpreted
	;n: length? mat
	;i: 1
	;while [i <= n] [mat/(i): value i: i + 1]
	forall mat [mat/1: value]
]


; direct pixel access for 1 channel image
; modified

rcvGetInt2D: function [ 
"Get integer matrix value"
	src 		[vector!] 
	mSize 		[pair!] 
	coordinate 	[pair!] 
][
	;return: [integer!]
	_rcvGetInt2D src mSize coordinate/x coordinate/y
]

rcvGetReal2D: function [ 
"Get float matrix value"
	src 		[vector!] 
	mSize 		[pair!] 
	coordinate 	[pair!] 
	/f32
][
	;return: [float! float32!]
	either f32 [_rcvGetReal322D src mSize coordinate/x coordinate/y]
	[_rcvGetReal2D src mSize coordinate/x coordinate/y]
]

rcvSetInt2D: function [ 
"Set integer matrix value"
	dst 		[vector!] 
	mSize 		[pair!] 
	coordinate 	[pair!] 
	val 		[integer!]
] [
	_rcvSetInt2D dst mSize coordinate/x coordinate/y val
]

rcvSetReal2D: function [
"Set float matrix value"
	 dst 		[vector!] 
	 mSize [	pair!] 
	 coordinate [pair!] 
	 val 		[float!]
][
	_rcvSetReal2D dst mSize coordinate/x coordinate/y val
]

rcvGetPairs: function [
"Gets coordinates from a binary matrix as pair values"
	binMatrix 	[vector!] 
	mSize 		[pair!] 
	points 		[block!]
][
	width: mSize/x height: mSize/y
	_rcvGetPairs binMatrix width height points
]

rcvGetPoints: function [
"Gets coordinates from a binary matrix as x y values"
	binMatrix 	[vector!] 
	width 		[integer!] 
	height 		[integer!] 
	points 		[vector!]
][
	_rcvGetPoints binMatrix width height points
]

; for contour detection

rcvMatleftPixel: function [
"Gets coordinates of first left pixel"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
][
	b: copy []
	_rcvleftPixel  mat matSize value b
	;return: [pair!]
	to-pair b/1
]

rcvMatRightPixel: function [
"Gets coordinates of first right pixel"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
][
	b: copy []
	_rcvRightPixel  mat matSize value b
	;return: [pair!]
	to-pair b/1
]

rcvMatUpPixel: function [
"Gets coordinates of first top pixel"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
][
	b: copy []
	_rcvUpPixel  mat matSize value b
	;return: [pair!]
	to-pair b/1 
]

rcvMatDownPixel: function [
"Gets coordinates of first bottom pixel"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
][
	b: copy []
	_rcvDownPixel  mat matSize value b
	;return: [pair!]
	to-pair b/1
]

rcvMatGetBorder: function [
"Gets pixels that belong to shape border"
	mat 	[vector!] 
	matSize [pair!] 
	value 	[integer!] 
	border 	[block!]
][
	_rcvGetBorder mat matSize value border
]


rcvMatGetChainCode: function [
"Gets Freeman Chain code"
	mat 	[vector!] 
	matSize [pair!] 
	coord 	[pair!] 
	value 	[integer!] 
][
	;return: [integer!]
	_borderNeighbors mat matSize coord/x coord/y value
]

; new
rcvGetContours: function [
"Gets next contour pixel to process"
	p [pair!] 
	d [integer!] 
][
	r: p
	switch d [
		0	[r/x: p/x + 1	r/y: p/y]		; east
		1	[r/x: p/x + 1 	r/y: p/y + 1]	; southeast
		2	[r/x: p/x 		r/y: p/y + 1]	; south
		3	[r/x: p/x - 1 	r/y: p/y + 1]	; southwest
		4	[r/x: r/x - 1 	r/y: p/y]		; west
		5	[r/x: p/x - 1 	r/y: p/y - 1]	; northwest
		6	[r/x: p/x 		r/y: p/y - 1]	; north
		7	[r/x: p/x + 1 	r/y: p/y - 1]	; northeast
	]
	;return: [pair!]
	r
]


;Image and Contour moments

; Hu Invariant Moments of 2D Matrix
;uses binary transform for large images

rcvGetMatCentroid: function [
"Returns the centroid of the image"
	mat 	[vector!] 
	matSize [pair!]
][
	minLoc: 0x0
	;return:	[pair!]
	_rcvGetMatCentroid mat matSize/x matSize/y minLoc
]


;p - the order of the moment
;q - the repetition of the moment
; p: q: 0.0 -> moment order 0 -> form area


rcvGetMatSpatialMoment: function [
"Returns the spatial moment of the mat"
	mat		[vector!] 
	matSize [pair!]
	p 		[float!] 
	q 		[float!] 
][
	;return: [float!]
	_rcvGetMatSpatialMoment mat matSize/x matSize/y p q
]

rcvGetMatCentralMoment: function [
"Returns the central moment of the mat"
	mat		[vector!] 
	matSize [pair!]
	p 		[float!] 
	q 		[float!] 
	
][
	minLoc: 0x0
	centroid: _rcvGetMatCentroid mat matSize/x matSize/y minLoc
	;return: [float!]
	_rcvGetMatCentralMoment mat matSize/x matSize/y centroid p q
]



;Return the scale invariant moment of the image
;p - the order of the moment
;q - the repetition of the moment



rcvGetNormalizedCentralMoment: function [
"Return the scale invariant moment of the image"
	mat  			[vector!]
	matSize 		[pair!]
    p				[float!]
    q				[float!]
] [
	moment1: rcvGetMatCentralMoment mat matSize p q 
	moment2: rcvGetMatCentralMoment mat matSize 0.0 0.0
	exponent: p + q / 2.0 + 1.0  
	m00: power moment2 exponent
	;return:	[float!]
	moment1 / m00
]

rcvGetMatHuMoments: function [
"Returns Hu moments of the image"
	mat  			[vector!]
	matSize 		[pair!]
][
	;where ηi,j are normalized central moments of 2-nd and 3-rd orders.
	n20: rcvGetNormalizedCentralMoment mat matSize 2.0 0.0
	n02: rcvGetNormalizedCentralMoment mat matSize 0.0 2.0
	n11: rcvGetNormalizedCentralMoment mat matSize 1.0 1.0
	n12: rcvGetNormalizedCentralMoment mat matSize 1.0 2.0
	n21: rcvGetNormalizedCentralMoment mat matSize 2.0 1.0
	n30: rcvGetNormalizedCentralMoment mat matSize 3.0 0.0
	n03: rcvGetNormalizedCentralMoment mat matSize 0.0 3.0

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
	; return: 		[block!]		
	reduce [hu1 hu2 hu3 hu4 hu5 hu6 hu7]
]





;********* Matrices functions **************************

rcvImage2Mat: function [
"Red Image to integer or char 2-D Matrix "
	src	[image!] 
	mat [vector!]
][
	_rcvImage2Mat src mat
]

rcvMat2Image: function [
"Matrix to Red Image"
	mat [vector!] 
	dst [image!]
][
	_rcvMat2Image mat dst
]

rcvMat2Binary: function [
"Matrix to binary value"
	mat [vector!] 
][
	to-binary to-block mat
]

rcvSplit2Mat: function [
"Split an image to 4 8-bit matrices"
	src 	[image!] 
	mat0 	[vector!] 
	mat1 	[vector!] 
	mat2 	[vector!] 
	mat3 	[vector!]  
][
	; mat0: a values
	; mat1: r mat2 g mat3 b values
	_rcvSplit2Mat src mat0 mat1 mat2 mat3
]

rcvMerge2Image: function [
"Merge 4 8-bit matrices to image"
	 mat0 	[vector!] 
	 mat1 	[vector!] 
	 mat2 	[vector!] 
	 mat3 	[vector!]  
	 dst 	[image!]
][
	_rcvMerge2Image mat0 mat1 mat2 mat3 dst
]

rcvConvolveMat: function [
"Classical matrix convolution"
	src 	[vector!] 
	dst 	[vector!] 
	mSize	[pair!] 
	kernel 	[block!] 
	factor 	[float!] 
	delta 	[float!]
] [
	_rcvConvolveMat src dst mSize kernel factor delta 
]


rcvConvolveNormalizedMat: function [
"Normalized fast matrix convolution"
	src 	[vector!] 
	dst 	[vector!] 
	mSize	[pair!] 
	kernel 	[block!] 
	factor 	[float!] 
	delta 	[float!]
][
	_rcvConvolveMat2 src dst mSize kernel factor delta 
]

rcvConvertMatScale: function [
"Converts Matrix Scale"
	src 		[vector!] 
	dst 		[vector!] 
	srcScale 	[number!] 
	dstScale 	[number!] 
	/fast /std
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

rcvMatInt2Float: function [
"Converts Integer Matrix to Float [0..1] matrix"	
	src 		[vector!] 
	dst 		[vector!] 
	srcScale 	[number!]
][
	if type? srcScale = integer! [srcScale: to float! srcScale]
	n: length? src
	i: 1
	while [i <= n] [
					dst/(i): to float! (src/(i)) / srcScale 
	 				i: i + 1
	]
]

;modified scale
rcvMatFloat2Int: function [
"Converts float matrix to integer [0..255] matrix"	
	src 		[vector!] 
	dst 		[vector!] 
	dstScale 	[integer!]
][
	n: length? src
	i: 1
	while [i <= n] [
					dst/(i): to integer! (src/(i) * dstScale)
	 				i: i + 1
	]
]

rcvMatFastSobel: function [ 
"Fast Sobel on Matrix"
	src 	[vector!] 
	dst 	[vector!] 
	iSize 	[pair!]
][
	_rcvSobelMat src dst iSize
]

rcvMatrixMedianFilter: function [
"Median Filter for matrices"
	src [vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
	kSize 	[pair!]
][	
	kernel: make vector! []
	n: kSize/x * kSize/y
	repeat i n [append kernel 0]
	_rcvMatrixMedianFilter src dst mSize kSize/x kSize/y kernel
]

; median filter for matrices NEW!!!
rcvMatrixMedianFilter: function [src [vector!] dst [vector!] mSize [pair!] kSize [pair!]
"Median Filter for matrices"
][	kernel: make vector! []
	n: kSize/x * kSize/y
	repeat i n [append kernel 0]
	_rcvMatrixMedianFilter src dst mSize kSize/x kSize/y kernel
]

;***********************Matrices Operations *********************
__rcvAddMat: function [
"dst: src1 +  src2"
	src1 	[vector!] 
	src2 	[vector!] 
	dst 	[vector!]
][
	dst: src2 + src1
	dst
]

rcvAddMat: function [
"dst: src1 +  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	src1 + src2
]


rcvSubMat: function [
"dst: src1 -  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	src1 - src2
]

rcvMulMat: function [
"dst: src1 *  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	src1 * src2
]

rcvDivMat: function [
"dst: src1 /  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	src1 / src2
]

rcvRemMat: function [
"dst: src1 % src2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	src1 % src2
]

rcvMeanMats: function [
"dst: src1 + src2 / 2"
	src1 [vector!] 
	src2 [vector!] 
][
	;return: [vector!]
	(src1 + src2) / 2
]


; ****************************scalars*******************************
; Scalar operations directly modify vector
rcvAddSMat: function [
"src +  value"
	src 	[vector!] 
	value 	[integer!] 
][
	src + value
]

rcvSubSMat: function [
"src -  value"
	src 	[vector!] 
	value 	[integer!]
][
	src - value
]

rcvMulSMat: function [
"src *  value"
	src [vector!] 
	value [integer!] 
][
	src * value
]

rcvDivSMat: function [
"src /  value"
	src [vector!] 
	value [integer!]
][
	src / value
]

rcvRemSMat: function [ 
"dst: src %  value"
	src [vector!] 
	value [integer!]
][
	src % value
]

;**********************Logical ************************************

rcvANDMat: function [
"dst: src1 AND  src2"
	src1 [vector!] 
	src2 [vector!] 
][
	src1 AND src2
]

rcvORMat: function [
"dst: src1 OR src2"
	src1 [vector!] 
	src2 [vector!]
][
	src1 OR src2
]

rcvXORMat: function [
"dst: src1 XOR  src2"
	src1 [vector!] 
	src2 [vector!]
][
	src1 XOR src2
]

; Scalar operations directly modify vector

rcvANDSMat: function [
"src AND  value"
	src 	[vector!] 
	value 	[integer!]
][
	src AND value
]

rcvORSMat: function [
"src OR value"
	src 	[vector!] 
	value 	[integer!]
][
	src OR value
]

rcvXORSMat: function [
"src XOR value"
	src 	[vector!] 
	value 	[integer!]
][
	src XOR value
]


; ******************* morphological Operations**************************
rcvErodeMat: function [
"Erodes matrice by using structuring element"
	src 	[vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	_rcvMorpho src dst mSize kSize/x kSize/y kernel 2
]

rcvDilateMat: function [
"Dilates matrice by using structuring element"
	src 	[vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	_rcvMorpho src dst mSize kSize/x kSize/y kernel 1 
]

;************** matrices alpha blending ***********************

rcvBlendMat: function [
"Computes the alpha blending of two matrices"
	mat1 	[vector!] 
	mat2 	[vector!] 
	dst 	[vector!] 
	alpha 	[float!] 
][
	_rcvBlendMat mat1 mat2 dst alpha
]

rcvInRangeMat: function [
"Extracts sub array from matrix according to lower and upper values"
	src 	[vector!] 
	dst 	[vector!] 
	lower 	[integer!] 
	upper 	[integer!] 
	op 		[integer!]
] [
	_rcvInRangeMat src dst lower upper op
]
