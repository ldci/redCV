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

rcvRandomMat: function [mat [vector!] value [integer!]
"Randomize matrix"
][
	forall mat [mat/1: random value]
]

rcvColorMat: function [mat [vector!] value [integer!]
	"Set matrix color"
][
	forall mat [mat/1: value]
]

rcvImage2Mat: function [src	[image!] mat [vector!] unit	[integer!]
"Image to 2-D Matrice"
] [
	_rcvImage2Mat src mat unit
]
rcvMat2Image: function [mat [vector!] dst [image!] unit [integer!]
"2-D Matrice to Image"
] [
	_rcvMat2Image mat dst unit
]

rcvConvolveMat: function [src [vector!] dst [vector!] mSize[pair!] unit	[integer!] kernel [block!] factor [float!] delta [float!]
"Fast matrix convolution"
] [
	_rcvConvolveMat src dst mSize unit kernel factor delta 
]


