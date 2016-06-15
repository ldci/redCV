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

; Thanks to Qingtian Xie for help :)

{To know: loaded images by red are in RGBA format (a tuple )
Images are 8-bit [0..255] and internally uses bytes as a binary string
Actually Red can't create 1 2 or 3 channels images : only 4 channels
Actually Red can't create 16-bit (0..65536) 32-bit or 64-bit (0.0..1.0) images

pixel and 00FF0000h >> 16 	: Red
pixel and FF00h >> 8		: Green
pixel and FFh				: Blue
pixel >>> 24				: Alpha
}


#include %core.red 			; basic image processing routines
#include %colorspace.red	; Color space conversions

; All included Red/System routines can be directly called in Red Code 
; See routines definition in included files

; this file contains  red functions for image processing
; these functions are easier to memorize than routines



; ********* image conversion **********
 
rcv2Gray: function [source [image!] /average /luminosity /lightness return: [image!]] [
"Converts RGB image to Grayscale"
	case [
		average [rcvConvert source 1]
		luminosity [rcvConvert source 111]
		lightness [rcvConvert source 112]
	]
]


rcv2BGRA: function [source [image!] return: [image!]] [
"Converts RGBA => BGRA"
	rcvConvert source 2 
]

rcv2RGBA: function [source [image!] return: [image!]] [
"Converts BGRA => RGBA"
	rcvConvert source 3 
]

rcv2BW: function [source [image!] return: [image!] /local tmp][
"Converts RGB image => Black and White"
	tmp: rcvConvert source 1 ; first a grayscale conversion
	rcvConvert tmp 4  ; then binarization of the gray image with 128.128.128.0 as threshold
]


rcvSplit: function[source [image!] /red /green /blue return: [image!]][
"Split source image in separate channels"
	case [
		red [rcvChannel source 1]
		green [rcvChannel source 2]
		blue [rcvChannel source 3]
	]
]



; ************ Color space conversions as Red/S routines**********
rcvRGB2XYZ: function [src [image!] return: [image!]] [
	rcvRGBXYZ src
] 

rcvXYZ2RGB: function [src [image!] return: [image!]] [
	rcvXYZRGB src
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


; ********** Math operators with scalar (tuple or integer) *********


rcvAddS: function [source [image!] val [integer! tuple!]return: [image!]] [
"Adds value to image"
	either type? val = integer! [rcvMathS source val 1] [rcvMathT source val 1]
]

rcvSubS: function [source [image!] val [integer! tuple!]return: [image!]] [
"Substracts value to image"
	either type? val = integer! [rcvMathS source val 2] [rcvMathT source val 2]
]

rcvMulS: function [source [image!] val [integer!] return: [image!]] [
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




; *************** Image transform Functions *****************

; Little-Big endian conversion and up down flip
rcvReverse: function [source [image!] return: [image!]] [
"Reverses RGB order"
	img: copy source
	img/rgb: reverse source/rgb
	img 
]

rcvFlip: function [source [image!]/vertical /horizontal return: [image!]] [
"Up down flip"
	case [
		vertical [rcv2BGRA rcvReverse source]
		horizontal [rcvFlipH source]
	]	
]


; *************** Red Functions *****************

; these functions do not use Red System Routines

; similar to NOT image
rcvInvert: function [source [image!] return: [image!]][
"Invert image = rcvNot"
	img: copy source
	img/rgb:  complement source/rgb 
	img
]



; to be improved
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
rcvRandom: function [size [pair!] value [tuple!] return: [image!]][
	img: make image! reduce [size black]
	forall img [
	    img/1: random value 
	]
	 img
]



; *************** statistical Functions *****************

rcvCountNonZero: function [source [image!] return: [integer!] /local n img][
"Returns number of non zero values in image"
	n: 0
	img: copy source
	forall img [
	    	if img/1 > 0.0.0.0 [n: n + 1] 
	 ]
	 n
]

rcvMedianImage: function [source [image!] return: [tuple!] /local img n pxl pos][
"Returns median value of image as tuple"
	img: copy source
	img/rgb: copy sort source/rgb 
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	pos: to integer! ((n + 1) / 2)
	either odd? n [pxl: img/(pos)] [m1: img/(pos) m2: img/(pos + 1) pxl: (m1 + m2) / 2]
	pxl
]

rcvMeanImage: function [source [image!] return: [tuple!] /local img n pxl sa sr sg sb][
"Returns mean value of image as a tuple"
	n: 0
	sa: 0
	sr: 0
	sg: 0 
	sb: 0
	img: copy source
	forall img [
			n: n + 1
	     	pxl: img/1 
	     	sr: sr + pxl/1
	     	sg: sg + pxl/2
	     	sb: sb + pxl/3
	     	sa: sa + pxl/4
	 ]
	 sr: sr / n sg: sg / n sb: sb / n sa: sa / n
	 make tuple! reduce [sr sg sb sa]
]

rcvStdDevImage:  function [source [image!] return: [tuple!] 
    /local 
	n pxl sa sr sg sb sa2 sr2 sg2 sb2 ma mr mg mb e va vr vg vb][
"returns standard deviation value of image as a tuple"
	n: 0
	sa: 0
	sr: 0
	sg: 0 
	sb: 0
	sa2: 0
	sr2: 0
	sg2: 0
	sb2: 0
	img: copy source
	forall img [
			n: n + 1
	     	pxl: img/1 
	     	sr: sr + pxl/1
	     	sg: sg + pxl/2
	     	sb: sb + pxl/3
	     	sa: sa + pxl/4 	
	 ]
	 ma: sa / n
	 mr: sr / n
	 mg: sg / n
	 mb: sb / n
	 
	 forall img [
	     	pxl: img/1 
	     	e: pxl/1 - mr sr2: sr2 + (e * e)
	     	e: pxl/2 - mg sg2: sg2 + (e * e)
	     	e: pxl/3 - mb sb2: sb2 + (e * e)
	     	e: pxl/4 - ma sa2: sa2 + (e * e)
	 ]
	 
	 vr: to integer! (square-root (sr2 / (n - 1)))
	 vg: to integer! (square-root (sg2 / (n - 1)))
	 vb: to integer! (square-root (sb2 / (n - 1)))
	 va: to integer! (square-root (sa2 / (n - 1)))
	 make tuple! reduce [vr vg vb va]
]

rcvMinImage: function [source [image!] return: [tuple!] /local img pxl][
"Minimal value in Image as a tuple"
	img: copy source
	img/rgb: copy sort source/rgb 
	pxl: img/1
]

rcvMaxImage: function [source [image!] return: [tuple!] /local img n pxl][
"Maximal value in Image as a tuple"
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	pxl: img/(n)
]

rcvRangeImage: function [source [image!] return: [tuple!]/local n img pxl1 pxl2][
"Range value in Image as a tuple"
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	pxl1: img/1
	pxl2: img/(n)
	pxl2 - pxl1
]


rcvSortImage: function [source [image!] return: [image!]/local img][
	img: copy source
	img/rgb: copy sort source/rgb 
	img
]