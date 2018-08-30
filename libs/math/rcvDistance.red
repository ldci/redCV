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

rcvGetEuclidianDistance: function [p [pair!] cg [pair!] return: [float!]
"Gets Euclidian distance between 2 points"
][
	x2: (p/x - cg/x) * (p/x - cg/x)
	y2: (p/y - cg/y) * (p/y - cg/y)
	sqrt (x2 + y2) 
]

rcvGetAngle: function [p [pair!] cg [pair!]return: [float!]
"Gets angle in degrees form points coordinates"
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
rcvMakeGradient: function [src [vector!] dst [vector!] mSize [pair!] return: [integer!]
"Makes a gradient matrix for contour detection (similar to Sobel) and returns max value"
][
	w: mSize/x
	h: mSize/y
	_makeGradient src dst w h
]

rcvMakeBinaryGradient: function [src [vector!] mat [vector!] maxG [integer!] threshold [integer!]
"Makes a binary [0 1] matrix for contour detection"
][
	_makeBinaryGradient src mat maxG threshold 
]

; input float mat output integer mat
rcvFlowMat: function [input [vector!] output[vector!] scale [float!] return: [float!]
"Calculates the distance map to binarized gradient"
][
	_rcvFlowMat input output scale
]

rcvnormalizeFlow: function [input [vector!]  factor [float!]
"Normalizes distance into 0..255 range"
] [
	_rcvnormalizeFlow input factor
]


rcvGradient&Flow: function [input1 [vector!] input2	[vector!] dst [image!]
"Creates an image including flow and gradient calculation"
] [
	_rcvGradient&Flow input1 input2 dst
]


rcvChamferDistance: function [chamferMask [block!] return: [block!]
"Selects a pre-defined chamfer kernel"
][
	chamfer: copy chamferMask
	normalizer: chamfer/3  ;[0][2]
	reduce [chamfer normalizer]
]

; output must be a vector of float!

rcvChamferCreateOutput: function [mSize [pair!] return: [vector!]
"Creates a distance map (float!)" 
][
	n: mSize/x * mSize/y
	make vector! reduce ['float! 64 n]
]


rcvChamferInitMap: function [input [vector!] output [vector!]
"Initializes distance map inside the object distance=0  outside the object distance to be computed"
][
	_initDistance input output
]


rcvChamferCompute: function [output [vector!] chamfer [block!] mSize [pair!]
"Calculates the distance map to binarized gradient"
][
	w: mSize/x
	h: mSize/y
	_rcvChamferCompute output chamfer w h
]

rcvChamferNormalize: function [output [vector!] value [integer!]
][
	_Normalize output value
]


;********************* DTW Dynamic Time Warping ****************************
; a very basic DTW algorithm
; thanks to Nipun Batra (https://nipunbatra.github.io/blog/2014/dtw.html)





rcvDTWGetPath1: function [x [block!] y [block!] cMat [block!] return: [block!]
"Find the path minimizing the distance "
][
	xPath: copy []
	i: length? y
	j: length? x
	while [(i >= 1) and (j >= 1)] [
		either any [i = 1 j = 1][
			case/all [
				i = 1 [j: j - 1 ] 
				j = 1 [i: i - 1 ]	
			]
		]
		[minD: rcvDTWMin cMat/(i - 1)/(j - 1) cMat/(i - 1)/(j) cMat/(i)/(j - 1)
		t0: false
			case/all [
				cMat/(i - 1)/(j) = minD [i: i - 1 t0: true]
				cMat/(i)/(j - 1) = minD [j: j - 1 t0: true]
			]
			unless t0 [i: i - 1 j: j - 1]
		]
		b: copy []
		append b j ; x
		append b i ; y
		append/only xPath b
	]
	append/only xPath [0 0]
	reverse xPath
]


rcvDTWMin: function [x [number!] y [number!] z [number!] return: [number!]
"Minimal value between 3 values"
][
	_rcvDTWMin x y z
]

rcvDTWDistances: function [x [block!] y [block!] return: [vector!]
"Making a 2d matrix to compute distances between all pairs of x and y series"
][
	xl: length? x
	yl: length? y
	matSize: xl * yl
	dMat: make vector! reduce ['float! 64 matSize]
	t: type? first x
	if t = integer! [_rcvDTWDistances x y dmat 0]
	if t = float! [_rcvDTWDistances x y dmat 1]
	dMat
]

rcvDTWRun: function [x [block!] y [block!] dMat [vector!] return: [vector!]
"Making a 2d matrix to compute minimal distance cost "
] [
	xl: length? x
	yl: length? y
	matSize: xl * yl
	cMat: make vector! reduce ['float! 64 matSize]
	_rcvDTWRun xl yl dMat cMat
	cMat
]

rcvDTWGetPath: function [x [block!] y [block!] cMat [vector!] return: [block!]
"xx"
] [
	xPath: copy []
	_rcvDTWGetPath x y cMat xPath
	reverse xPath
]


rcvDTWGetDTW: function [cMat [vector!] return: [number!]
"Returns DTW value"
][
	last cMat
]

rcvDTWCompute: function [x [block!] y [block!] return: [number!]
"Short-cut to get DTW value if you don't need distance and cost matrices"
][
	dMat: rcvDTWDistances x y
	cMat: rcvDTWRun x y dMat	
	last cMat
]

