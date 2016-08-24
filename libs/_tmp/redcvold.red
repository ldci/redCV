

; this file contains  red functions for image processing
; these functions are easier to memorize than routines


; toutes ces routines sont à déplacer


; ********* image conversion **********
 
rcv2Gray: function [ source [image!] /average /luminosity /lightness return: [image!]
"Converts RGB image to Grayscale" 
][
	case [
		average 	[rcvConvert source 1]
		luminosity 	[rcvConvert source 111]
		lightness 	[rcvConvert source 112]
	]
]


rcv2BGRA: function [source [image!] return: [image!] 
"Converts RGBA => BGRA"
][
	rcvConvert source 2 
]

rcv2RGBA: function [source [image!] return: [image!]
"Converts BGRA => RGBA"
][
	rcvConvert source 3 
]

rcv2BW: function [source [image!] return: [image!]
"Converts RGB image => Black and White"
][
	tmp: rcvConvert source 1 ; first a grayscale conversion
	rcvConvert tmp 4  ; then binarization of the gray image with 128.128.128.0 as threshold
]


rcvSplit: function[source [image!] /red /green /blue return: [image!]
"Split source image in separate channels"
][
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

; all logical operators can use /rgb as in the next sample
; but these functions are slower 

rcvAND_: function [source1 [image!] source2 [image!] return: [image!]][
"Image 1 AND image 2"
	img: copy source1
	img/rgb: source1/rgb and source2/rgb
	img
]


; fast logical operators

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
rcvANDS: function [src1 [image!] value [tuple!] return: [image!]]
[
	tmp: make image! reduce[src1/size value]
	rcvAND src1 tmp
]

rcvORS: function [src1 [image!] value [tuple!] return: [image!]]
[
	tmp: make image! reduce[src1/size value]
	rcvOR src1 tmp
]

rcvXORS: function [src1 [image!] value [tuple!] return: [image!]]
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


rcvAddS: function [source [image!] val [integer!] return: [image!]
"Adds value to image"
][
	rcvMathS source val 1
]

rcvSubS: function [source [image!] val [integer!]return: [image!]
"Substracts value to image"
][
	rcvMathS source val 2
]

rcvAddT: function [source [image!] val [tuple!] return: [image!]
"Adds value to image"
][
	rcvMathT source val 1
]

rcvSubT: function [source [image!] val [tuple!] return: [image!]
"Substracts value to image"
][
	rcvMathT source val 2
]


rcvMulS: function [source [image!] val [integer!] return: [image!]
"Multiplies image by value"
][
	rcvMathS source val 3
]

rcvDivS: function [source [image!] val [integer!]return: [image!] 
"Divides image by value"
][
	rcvMathS source val 4
]

rcvModS: function [source [image!] val [integer!]return: [image!]
"Modulo image value"
][
	rcvMathS source val 5
]

rcvRemS: function [source [image!] val [integer!]return: [image!]
"Remainder image value"
][
	rcvMathS source val 6
]

rcvPow: function [source [image!] val [integer!] return: [image!]
"Power image value"
][
	rcvMathS source val 7
]

rcvLSH: function [source [image!] val [integer!] return: [image!]
"Left shift"
][
	rcvMathS source val 8
]

rcvRSH: function [source [image!] val [integer!] return: [image!]
"Right Shift"
][
	rcvMathS source val 9
]




; *************** Image transform Functions *****************

rcvFlip: function [source [image!] /horizontal /vertical /both return: [image!]
"Left Right, Up down or both flip"
][
	case [
		horizontal 	[rcvFlipHV source 1]
		vertical 	[rcvFlipHV source 2]
		both		[rcvFlipHV source 3]
	]	
]


; *************** statistical Functions *****************

rcvCountNonZero: function [source [image!] return: [integer!]
"Returns number of non zero values in image"
][
	rcvCount source
]

rcvMedianImage: function [source [image!] return: [tuple!]
"Returns median value of image as tuple"
][
	img: copy source
	img/rgb: copy sort source/rgb 
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	pos: to integer! ((n + 1) / 2)
	either odd? n [pxl: img/(pos)] [m1: img/(pos) m2: img/(pos + 1) pxl: (m1 + m2) / 2]
	pxl
]


rcvMeanImage: function [source [image!] return: [tuple!] 
"Returns mean value of image as a tuple"
][
	v: rcvMeanInt source
	a: v >>> 24
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
	make tuple! reduce [r g b a]
]

rcvVarImage:  function [source [image!] /var /std  return: [tuple!] 
"returns variance or standard deviation value of image as a tuple"
][
	v:  rcvVarInt source
	a: v >>> 24
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
	case [
		var [vr: r * r vg: g * g vb: b * b va: a * a]
		std [vr: r vg: g vb: b va: a]
	]	 
	 make tuple! reduce [vr vg vb va]
]

rcvMinImage: function [source [image!] return: [tuple!]
"Minimal value in Image as a tuple"
][
	img: copy source
	img/rgb: copy sort source/rgb 
	pxl: img/1
]

rcvMaxImage: function [source [image!] return: [tuple!] 
"Maximal value in Image as a tuple"
][
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	pxl: img/(n)
]

rcvRangeImage: function [source [image!] return: [tuple!]
"Range value in Image as a tuple"
][
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	pxl1: img/1
	pxl2: img/(n)
	pxl2 - pxl1
]


rcvSortImage: function [source [image!] return: [image!]][
	img: copy source
	img/rgb: copy sort source/rgb 
	img
]


; *************** convolution Functions *****************
; convolution is defined in imgproc.red
; TBD Filters



; *************** Red Functions *****************

; these functions do not use Red System Routines

; Little-Big endian conversion and up down flip
rcvReverse: function [source [image!] return: [image!]
"Reverses RGB order"
][

	img: copy source
	img/rgb: reverse source/rgb
	img 
]

; similar to NOT image
rcvInvert: function [source [image!] return: [image!]
"Invert image = rcvNot"
][
	img: copy source
	img/rgb:  complement source/rgb 
	img
]



; to be improved
rcvInRange: function [source [image!] minThresh [tuple!] maxThresh [tuple!] return: [image!]
"Select range color values according to mini and maximal RGB values"
][
	img: copy source
	forall img [
			pxl: img/1
	    	if img/1 <= minThresh [pxl: 0.0.0.0] 
	    	if img/1 > maxThresh [pxl: 0.0.0.0] 
	     	img/1: pxl
	 	]
	 img
]



; OK nice but /alea very slow TBI
rcvRandom: function [size [pair!] value [tuple!] /uniform /alea return: [image!]][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
	] 
	img
]
