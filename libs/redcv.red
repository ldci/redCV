Red [
	Title:   "Red Computer Vision"
	Author:  "Francois Jouen"
	File: 	 %redcv.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


#include %core.red ; basic image processing routines

; this file contains functions for basic processing

; ********* image transformation **********
;see core.red for the basic routine

; these functions are easier to memorize 
;but you can directly call rcvConvert Image Op param in your Red Code 
rcv2Gray: function [source [image!] /average /luminosity /lightness return: [image!]] [
"Converts RGB image to Grayscale"
	case [
		average [rcvConvert source 1]
		luminosity [rcvConvert source 111]
		lightness [rcvConvert source 112]
	]
]


rcv2BGRA: function [source [image!] return: [image!]] [
"Converts RGBA to BGRA"
	rcvConvert source 2 
]


rcv2BW: function [source [image!] return: [image!] /local r g b a v][
"Converts RGB image to Black and White"
	tmp: rcvConvert source 1 ; first a grayscale conversion
	rcvConvert tmp 3  ; then binarization of the gray image
]

; to be continued



; ************ logical operators on images as Red/S routines**********


rcvAND: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 1
]

rcvOR: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 2
]

rcvXOR: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 3
]

rcvNAND: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 4
]

rcvNOR: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 5
]

rcvNXOR: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 6
]

rcvMIN: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 7
]

rcvMAX: function [src1 [image!] src2 [image!] return: [image!]] [
	rvcLogical src1 src2 8
]



; ************ logical operators and scalar (tuple!) on images **********
rcvANDS: function [src1 [image!] value [tuple!] return: [image!]/local tmp]
[
	tmp: make image! reduce[src1/size value]
	rcvAND src1 tmp
]

rcvORS: function [src1 [image!] value [tuple!] return: [image!]/local tmp]
[
	tmp: make image! reduce[src1/size value]
	rcvOR src1 tmp
]

rcvXORS: function [src1 [image!] value [tuple!] return: [image!]/local tmp]
[
	tmp: make image! reduce[src1/size value]
	rcvXOR src1 tmp
]




; ********** Math Operators on image **********


rcvAdd: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 1
]

rcvSub: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 2
]

rcvMul: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 3
]

rcvDiv: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 4
] 

rcvMod: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 5
] 

rcvRem: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 6
] 

rcvAbsDiff: function [src1 [image!] src2 [image!] return: [image!]][
	rcvMath src1 src2 7
] 

; ********** Math operators on image with Tuple *********


rcvAddT: function [source [image!] val [tuple!]return: [image!]] [
"Adds RGB value to image"
	rcvMathT source val 1
]

rcvSubT: function [source [image!] val [tuple!]return: [image!]] [
"Substract RGB value to image"
	rcvMathT source val 2
]

; ********** Math operators with scalar (integer only) *********


rcvAddS: function [source [image!] val [integer!]return: [image!]] [
"Adds value to image"
	rcvMathS source val 1
]

rcvSubS: function [source [image!] val [integer!]return: [image!]] [
"Substracts value to image"
	rcvMathS source val 2
]

rcvMulS: function [source [image!] val [integer!]return: [image!]] [
"Multiplies image by value"
	rcvMathS source val 3
]

rcvDivS: function [source [image!] val [integer!]return: [image!]] [
"Divides image by value"
	rcvMathS source val 4
]

rcvModS: function [source [image!] val [integer!]return: [image!]] [
"Modulo image value"
	rcvMathS source val 5
]

rcvRemS: function [source [image!] val [integer!]return: [image!]] [
"Remainder image value"
	rcvMathS source val 6
]

rcvPow: function [source [image!] val [integer!] return: [image!]] [
"Power image value"
	rcvMathS source val 7
]

rcvLSH: function [source [image!] val [integer!] return: [image!]] [
"Left shift"
	rcvMathS source val 8
]

rcvRSH: function [source [image!] val [integer!] return: [image!]] [
"Right Shift"
	rcvMathS source val 9
]




; *************** MISC Functions *****************

; Little-Big endian conversion
rcvReverse: function [source [image!] return: [image!]] [
"Reverses RGB order"
	img: copy source
	img/rgb: reverse source/rgb
	img 
]

rcvInvert: function [source [image!] return: [image!]][
"Invert image : rcvNot"
	img: copy source
	img/rgb:  complement source/rgb 
	img
]




rcvInRange: function [source [image!] minThresh [tuple!] maxThresh [tuple!] return: [image!]][
"Select range color values according to mini and maximal RGB values"
	img: copy source
	forall img [
			pxl: img/1
	    	if img/1 <= minThresh [pxl: 0.0.0.0] 
	    	if img/1 > maxThresh [pxl: 0.0.0.0] 
	     	img/1: pxl
	 	]
	 img
]


; OK nice
rcvRandom: function [source [image!] value [tuple!] return: [image!]][
	img: copy source
	forall img [
	    img/1: random value 
	 ]
	 img
]

rcvSort: function [source [image!] return: [image!]][
	img: copy source
	img/rgb: copy sort source/rgb 
	img
]

;???
rcvSwap: function [source1 [image!] source2 [image!]] [
	swap source1/rgb source2/rgb
]

rcvSplit: function[source [image!] channel [integer!] return: [image!]][
"Split source image"
	if channel = 1 [rgb: extract/index source/rgb 3 1]
	if channel = 2 [rgb: extract/index source/rgb 3 2]
	if channel = 3 [rgb: extract/index source/rgb 3 3]
	make image! reduce [source/size rgb]
]




