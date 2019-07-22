Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvDistance.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


 

#include %rcvDistanceRoutines.red

;general distances functions 

_rcvGetEuclidianDistance: function [
"Gets Euclidian distance between 2 points"
	p 	[pair!] 
	cg 	[pair!]
][
	x2: (p/x - cg/x) * (p/x - cg/x)
	y2: (p/y - cg/y) * (p/y - cg/y)
	sqrt (x2 + y2) 
]

;new version
rcvGetEuclidianDistance: function [
"Gets Euclidian distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 1 0.0
]

rcvGetEuclidian2Distance: function [
"Gets Squared Euclidian distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 6 0.0
]

rcvGetManhattanDistance: function [
"Gets Manhattan distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 2 0.0
]

rcvGetChessboardDistance: function [
"Gets Chessboard distance between 2 points"
	a [pair!] 
	b [pair!] 
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 3 0.0
]

rcvGetMinkowskiDistance: function [
"Gets Minkowski distance between 2 points"
	a [pair!] 
	b [pair!] 
	p [float!]
][
	dxy: absolute b - a
	if p = 0.0 [p: 2.0]	; euclidian by default
	_rcvDotsDistance to-float dxy/x to-float dxy/y 4 p
]

rcvGetChebyshevDistance: function [
"Gets Chebyshev distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dxy: absolute b - a
	_rcvDotsDistance to-float dxy/x to-float dxy/y 5 0.0
]

; fractional distances
rcvGetCamberraDistance: function [
"Gets Camberra distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 1
]

; Sorensen or Bray Curtis Distance
rcvGetSorensenDistance: function [
"Gets Sorensen or Bray Curtis distance between 2 points"
	a [pair!] 
	b [pair!]
][
	dx1: to-float a/x - to-float b/x
	dx2: to-float a/x + to-float b/x
	dy1: to-float a/y - to-float b/y
	dy2: to-float a/y + to-float b/y
	_rcvDotsFDistance dx1 dx2 dy1 dy2 2
]

rcvDistance2Color: function [
"Returns tuple value modified by distance"
	dist [float!] 
	t [tuple!]
][
	_rcvDistance2Color dist t
]



rcvGetAngle: function [
"Gets angle in degrees from points coordinates"
	p 	[pair!] 
	cg 	[pair!]
][		
	rho: rcvGetEuclidianDistance p cg		; rho
	uY: to-float p/y - cg/y					; uY ->
	uX: to-float p/x - cg/x					; uX ->	
	costheta: uX / rho
	sinTheta: uY / rho
	tanTheta: costheta / sinTheta 
	theta: arccosine costheta
	if p/y > cg/y [theta: 360 - theta]
	theta
]

;needs a coordinate translation p - shape centroid
; angle * 180 / pi -> degrees
rcvGetAngleRadian: function [
"Gets angle in radian "
	p [pair!]
][
	atan2 p/y p/x
]


rcvRhoNormalization: function [
"Returns normalized block [0.0..1.0] of rho values" 
	b [block!] 
][
 	tmpb: copy b
 	sort tmpb
 	maxRho: last tmpb
 	normf: 1.0 / maxRho
	tmpv: make vector! reduce b
	tmpv * normf
	to block! tmpv
]

;*************** Voronoï and Distance Diagrams *********

rcvVoronoiDiagram: function [
"Creates Voronoï diagram"
	peaks 	[block!] 
	peaksC 	[block!] 
	img 	[image!] 
	param1 	[logic!]
	param2 	[integer!] 
	param3 	[float!]
][
	_rcvVoronoiDiagram peaks peaksC img param1 param2 param3
]

;Based on Boleslav Březovský's sample
rcvDistanceDiagram: function [
"Creates Distance diagram"
	peaks 	[block!] 
	peaksC 	[block!] 
	img [	image!] 
	param1 	[logic!]
	param2 	[integer!] 
	param3 	[float!]
][
	_rcvDistanceDiagram peaks peaksC img param1 param2 param3
]

;*************** kMeans Algorithm ********************
; All functions require redCV array data type
rcvKMInitData: function [
"Creates data or centroid array"
	count [integer!]
][
	blk: copy []
	i: 0
	while [i < count] [
		append blk make vector! [float! 64 [0.0 0.0 0.0]]
		i: i + 1
	]
	blk
]

rcvKMGenCentroid: function [
"Generates centroids initial values"
	array [block!]
][
	_genCentroid array
]
rcvKMInit: function [
"k Means first initialization"
	points 		[block!] 
	centroid 	[block!] 
	tmpblk 		[block!]
][
	_kpp points centroid tmpblk
]

rcvKMCompute: function [
"Lloyd K-means clustering with convergence"
	points 		[block!] 
	centroid 	[block!]
][
	_lloyd points centroid
]

	
; ************** Chamfer distance **********

{ Thanks to Pierre Schwartz & Xavier Philippeau
 Kernels by Verwer, Borgefors and Thiel 
 http://www.developpez.com for the java implementation
 ; in french Distance de chanfrein}


; predefined array of distances 
cheessboard: copy [1 0 1 1 1 1]
chamfer3:	 copy [1 0 3 1 1 4]
chamfer5:	 copy [1 0 5 1 1 7 2 1 11]
chamfer7:	 copy [1 0 14 1 1 20 2 1 31 3 1 44]
chamfer13:	 copy [1 0 68 1 1 96 2 1 152 3 1 215 3 2 245 4 1 280 4 3 340 5 1 346 6 1 413]
normalizer:  0
chamfer:	 copy []


;src and dst are integer matrices
rcvMakeGradient: function [
"Makes a gradient matrix for contour detection (similar to Sobel) and returns max value"
	src 	[vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
][
	w: mSize/x
	h: mSize/y
	_makeGradient src dst w h
]

rcvMakeBinaryGradient: function [
"Makes a binary [0 1] matrix for contour detection"
	src 		[vector!] 
	mat 		[vector!] 
	maxG 		[integer!] 
	threshold 	[integer!]
][
	_makeBinaryGradient src mat maxG threshold 
]

; input float mat output integer mat
rcvFlowMat: function [
"Calculates the distance map to binarized gradient"
	input [vector!] 
	output[vector!] 
	scale [float!]
][
	_rcvFlowMat input output scale
]

rcvnormalizeFlow: function [
"Normalizes distance into 0..255 range"
	input 	[vector!]  
	factor 	[float!]
][
	_rcvnormalizeFlow input factor
]


rcvGradient&Flow: function [
"Creates an image including flow and gradient calculation"
	input1 	[vector!] 
	input2	[vector!] 
	dst 	[image!]
][
	_rcvGradient&Flow input1 input2 dst
]


rcvChamferDistance: function [
"Selects a pre-defined chamfer kernel"
	chamferMask [block!] 
][
	chamfer: copy chamferMask
	normalizer: chamfer/3  ;[0][2]
	reduce [chamfer normalizer]
]

; output must be a vector of float!

rcvChamferCreateOutput: function [
"Creates a distance map (float!)" 
	mSize [pair!] 
][
	n: mSize/x * mSize/y
	make vector! reduce ['float! 64 n]
]


rcvChamferInitMap: function [
"Initializes distance map inside the object distance=0  outside the object distance to be computed"
	input 	[vector!] 
	output 	[vector!]
][
	_initDistance input output
]


rcvChamferCompute: function [
"Calculates the distance map to binarized gradient"
	output 	[vector!] 
	chamfer [block!] 
	mSize 	[pair!]
][
	w: mSize/x
	h: mSize/y
	_rcvChamferCompute output chamfer w h
]

rcvChamferNormalize: function [
"Normalization"
	output [vector!] 
	value [integer!]
][
	_Normalize output value
]


