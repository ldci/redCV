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


