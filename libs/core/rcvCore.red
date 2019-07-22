Red [
	Title:   "Red Computer Vision: Core functions"
	Author:  "Francois Jouen"
	File: 	 %rcvCore.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


{To know: loaded images by red are in ARGB format (a tuple )
Images are 8-bit [0..255] by channel and internally use bytes as a binary string
Actually Red can't create 1 2 or 3 channels images : only 4 channels
Actually Red can't create 16-bit (0..65536) 32-bit or 64-bit (0.0..1.0) images

pixel >>> 24				: Alpha
pixel and FF0000h >> 16 	: Red
pixel and FF00h >> 8		: Green
pixel and FFh				: Blue
}

#include %rcvCoreRoutines.red		; All Red/System routines

; ********* image basics **********


rcvCreateImage: function [
"Create empty (black) image"
	size 	[pair!]  "Image size"
][
	make image! reduce [size black]
]


rcvReleaseImage: function [
"Delete image from memory"
	src [image!]
][
	_rcvReleaseImage src 
]

rcvReleaseAllImages: function [
"Delete all images"
	list [block!] "List of images to delete"
][
	foreach img list [_rcvReleaseImage img]
]



rcvLoadImage: function [
"Loads image from file"
	fileName [file!]  
	/grayscale		
][
	src: load fileName
	if grayscale [
		gray: rcvCreateImage src/size
		rcv2Gray/average src gray 
		_rcvCopy gray src
	]
	src
]


rcvLoadImageAsBinary: function [
"Load image from file and return image as binary"
	fileName [file!] 
	/alpha			 

][
	tmp: load fileName
	either alpha [str: tmp/argb] [str: tmp/rgb]
	_rcvReleaseImage tmp
	str
]

rcvGetImageFileSize: function [
"Gets Image File Size as a pair!"
	fileName 	[file!] 
][
	tmp: load fileName
	isize: tmp/size
	_rcvReleaseImage tmp
	isize
]

rcvGetImageSize: function [
"Returns Image Size as a pair!"
	src 	[image!]  
][
	src/size
]

rcvSaveImage: function [
"Save image to file (only png actually)"
	src 		[image!] 
	fileName 	[file!] 
][
	save fileName src
]

rcvCloneImage: function [
"Returns a copy of source image"
	src 	[image!] 
][
	dst: make image! reduce [src/size black]
	_rcvCopy src dst
	dst
]
rcvCopyImage: function [
"Copy source image to destination image"
	src [image!] 
	dst [image!]
][
	_rcvCopy src dst
]

rcvRandomImage: function [
"Create a random uniform or pixel random image"
	size 	[pair!] 	
	value 	[tuple!] 	
	return: [image!]
	/uniform /alea /fast 

][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
		fast 	[img: make image! reduce [size black] _rcvRandImage img]
	] 
	img
]

rcvZeroImage: function [src [image!]
"All pixels to 0"
][
	src/argb: black
]

rcvColorImage: function [src [image!] acolor [tuple!]
"All pixels to color"
][
	src/argb: acolor 
]

rcvSetAlpha: function [src [image!] dst [image!] alpha [integer!]
"Sets image transparency"
][
	_rcvSetAlpha src dst alpha
]


{
rcvDecodeImage
rcvDecodeImageM
cvEncodeImage
}


;************** Pixel Access **********

rcvGetPixel: function [
"Returns pixel value at xy coordinates as tuple"
	src 		[image!] 
	coordinate  [pair!]	
	/argb

][
	v: _rcvGetPixel src coordinate
	a: 255 - (v >>> 24)
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
    either argb [tp: make tuple! reduce [a r g b]] [tp: make tuple! reduce [r g b]]
    tp
]

rcvPickPixel: function [
"Returns pixel value at xy coordinates as tuple"
	src 		[image!] 
	coordinate 	[pair!]  
][
	pick src coordinate
]


rcvGetPixelAsInteger: function [
"Returns pixel value at xy coordinates as integer"
	src 		[image!] 
	coordinate  [pair!]  
][
	_rcvGetPixel src coordinate
]

rcvSetPixel: function [
"Set pixel value at xy coordinates"
	src 		[image!] 	
	coordinate 	[pair!] 	
	val 		[tuple!] 
][
	n: length? val
	either (n = 3) [a: 255 r: val/1 g: val/2 b: val/3] 
				[a: val/1 r: val/2 g: val/3 b: val/4]
	
	intVal: (a << 24) OR (r << 16 ) OR (g << 8) OR b
	_rcvSetPixel src coordinate intVal
]

rcvPokePixel: function [
"Set pixel value at xy coordinates"
	src 		[image!]  
	coordinate  [pair!]   
	val 		[tuple!]  

] [
	poke src coordinate val
]

rcvIsAPixel: function [
"Returns true if  pixel value is greater than threshold"
	src 		[image!]    
	coordinate 	[pair!]     
	threshold 	[integer!]  

][
	_rcvIsAPixel src coordinate threshold
]

; ********* image conversion **********
 
rcv2NzRGB: function [ 
"Normalizes the RGB values of an image" 
	src [image!]    
	dst [image!]    
	/sum/sumsquare  
][
	case [
		sum  		[_rcvConvert src dst 113]
		sumsquare 	[_rcvConvert src dst 114]
	] 
]
 
rcv2Gray: function [ 
"Convert RGB image to Grayscale acording to refinement" 
	src [image!]  
	dst [image!] 
	/average /luminosity /lightness 
][
	case [
		average 	[_rcvConvert src dst 1]
		luminosity 	[_rcvConvert src dst 111]
		lightness 	[_rcvConvert src dst 112]
	]
]

rcv2BGRA: function [
"Convert RGBA => BGRA"
	src [image!] 
	dst [image!] 
][
	_rcvConvert src dst 2 
]

rcv2RGBA: function [
"Convert BGRA => RGBA"
	src [image!] 
	dst [image!]
][
	_rcvConvert src dst 3 
]

rcv2BW: function [
"Convert RGB image => Black and White" 
	src [image!] 
	dst [image!]
][
	_rcvConvert src dst 4
]

rcv2WB: function [
	"Convert RGB image => White and Black" 
	src [image!] 
	dst [image!]
][
	_rcvConvert src dst 5
]

rcv2BWFilter: function [
"Convert RGB image => Black and White according to threshold"
	src [image!] 
	dst [image!] 
	thresh [integer!]
][
	_rcvFilterBW src dst thresh 0 0
]

rcvThreshold: function [
"Applies fixed-level threshold to image"
	src [image!] 
	dst [image!] 
	thresh [integer!] 
	mValue [integer!]
	/binary /binaryInv /trunc /toZero /toZeroInv
][
	case [
		binary 		[_rcvFilterBW src dst thresh mValue 1]
		binaryInv 	[_rcvFilterBW src dst thresh mValue 2]
		trunc		[_rcvFilterBW src dst thresh mValue 3]
		toZero 		[_rcvFilterBW src dst thresh mValue 4]
		toZeroInv 	[_rcvFilterBW src dst thresh mValue 5]
	]
]
 
rcvInvert: function [
"Similar to NOT image"
	src [image!] 
	dst [image!]
][
	dst/rgb:  complement src/rgb 
]


; ********** Math Operators on image **********


rcvAdd: function [
"dst: src1 +  src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 1
]

rcvSub: function [
"dst: src1 - src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 2
]

rcvMul: function [
"dst: src1 * src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 3
]

rcvDiv: function [
"dst: src1 / src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 4
] 

rcvMod: function [
"dst: src1 // src2 (modulo)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 5
] 

rcvRem: function [
"dst: src1 % src2 (remainder)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 6
] 

rcvAbsDiff: function [
"dst: absolute difference src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvMath src1 src2 dst 7
] 

rcvMIN: function [
"dst: minimum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rvcLogical src1 src2 dst 7
]

rcvMAX: function [
"dst: maximum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rvcLogical src1 src2 dst 8
]

;
rcvAddLIP: function [
"dest(x,y)= src1(x,y)+ src(x,y) – (src1(x,y)* src2(x,y)) / M"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvLIP src1 src2 dst 1
]

;
rcvSubLIP: function [
"im_out(x,y) = M.(im_in1(x,y) - im_in2(x,y)) / ( M - im_in2(x,y))"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	_rcvLIP src1 src2 dst 2
]


; ********** Math operators with scalar (tuple or integer) *********


rcvAddS: function [
"dst: src + integer! value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 1
]

rcvSubS: function [
"dst: src - integer! value"
	src [image!] 
	dst [image!] 
	val [integer!]
][
	_rcvMathS src dst val 2
]

rcvMulS: function [
"dst: src * integer! value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 3
]

rcvDivS: function [
"dst: src / integer! value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 4
]

rcvModS: function [
"dst: src // integer! value (modulo)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 5
]

rcvRemS: function [
"dst: src % integer! value (remainder)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 6
]


rcvLSH: function [
"Left shift image by value"
	src [image!] 
	dst [image!]
	val [integer!] 
][
	_rcvMathS src dst val 7
]

rcvRSH: function [
"Right Shift image by value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	_rcvMathS src dst val 8
]

rcvPow: function [
"dst: src ^integer! or float! value"
	src [image!]  
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = float!   [_rcvMathF src dst val 1] 
	if t = integer! [_rcvMathS src dst val 9] 
]


rcvSQR: function [
"Image square root"
	src [image!] 
	dst [image!] 
	val [number!]  
][
	t: type? val
	if t = integer! [_rcvMathS src dst val 10] 
	if t = float!   [_rcvMathF src dst val 2]
]


rcvAddT: function [
"dst: src + tuple! value"
	src [image!] 
	dst [image!] 
	val [tuple!] 
][
	_rcvMathT src dst val 1
]

rcvSubT: function [
"dst: src - tuple! value"
	src [image!] 
	dst [image!] 
	val [tuple!]
][
	_rcvMathT src dst val 2	
]

rcvMulT: function [
"dst: src * tuple! value"
	src [image!] 
	dst [image!] 
	val [tuple!] 
][
	_rcvMathT src dst val 3
]

rcvDivT: function [
"dst: src / tuple! value"
	src [image!] 
	dst [image!] 
	val [tuple!] 
][
	_rcvMathT src dst val 4
]

rcvModT: function [
"dst: src // tuple! value (modulo)"
	src [image!] 
	dst [image!] 
	val [tuple!] 
][
	_rcvMathT src dst val 5
]

rcvRemT: function [
"dst: src % tuple! value (remainder)"
	src [image!] 
	dst [image!] 
	val [tuple!] 
][
	_rcvMathT src dst val 6
]


; ************* Logical operator ***************************
rcvAND: function [
"dst: src1 AND src2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2 dst 1
]

rcvOR: function [
"dst: src1 OR src2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2 dst 2
]

rcvXOR: function [
"dst: src1 XOR src2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2  dst 3
]

rcvNAND: function [
"dst: src1 NAND src2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2 dst 4
]

rcvNOR: function [
"dst: src1 NOR src2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2 dst 5
]

rcvNXOR: function [
"dst: src1 NXOR rc2"
	src1 [image!] 
	src2 [image!] 
	dst [image!]
][
	_rvcLogical src1 src2 dst 6
]

rcvNot: function [
"dst: NOT src"
	src [image!] 
	dst [image!]
][
	_rcvNot src dst
]

; ************ logical operators and scalar (tuple!) on image **********

rcvANDS: function [
"dst: src AND tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	_rvcLogical src tmp dst 1
	tmp: none
]

rcvORS: function [
"dst: src OR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	_rvcLogical src tmp dst 2
	tmp: none
]

rcvXORS: function [
"dst: src XOR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	_rvcLogical src tmp dst 3
	tmp: none
]

; ;********** stats on 2 images ***********************
 
rcvMeanImages: function [
"Calculates pixels mean value for 2 images"
	src1 [image!] 
	src2 [image!] dst [image!]
][
	_rcvMath src1 src2 dst 8
]

;********** SUB-ARRAYS ************************
rcvSplit: function [
"Split source image in RGB and alpha separate channels"
	src [image!] 
	dst [image!]
	/red /green /blue /alpha
][
	case [
		red 	[_rcvChannel src dst 1]
		green 	[_rcvChannel src dst 2]
		blue 	[_rcvChannel src dst 3]
		alpha	[_rcvChannel src dst 4]
	]
]

rcvMerge: function [
"Merge 3 images to destination image"
	src1 [image!] 
	src2 [image!] 
	src3 [image!] 
	dst [image!]
][
	_rcvMerge src1 src2 src3 dst
]


rcvInRange: function [
"Extracts sub array from image according to lower and upper rgb values"
	src 	[image!] 
	dst 	[image!] 
	lower 	[tuple!] 
	upper 	[tuple!] 
	op 		[integer!]
][
	lr: lower/1 lg: lower/2 lb: lower/3
	ur: upper/1 ug: upper/2 ub: upper/3
	_rcvInRange src dst lr lg lb ur ug ub op

]

