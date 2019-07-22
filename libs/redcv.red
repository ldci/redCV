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
;the printed result is rounded to the closest integer value by default if it is less than 
;an internal epsilon value. There is an option to disable that "pretty printing" for ;
;floats, so you'll get a more accurate output:


system/options/float/pretty?: no

; All files you need for image processing with Red. Enjoy
; All Red/System routines can be directly called in Red Code 
; All Red/System routines are "exported" as easy-to-use red functions 

; Thanks to Nenad Rakocevic and Qingtian Xie for constant help :)


#include %core/rcvCore.red 			; Basic image creating and processing functions
#include %highgui/rcvHighGui.red	; Fast Highgui functions
#include %matrix/rcvMatrix.red		; Matrices functions
#include %imgproc/rcvImgProc.red	; Color space conversions Convolution and other
#include %math/rcvRandom.red		; Random laws for generating random images
#include %math/rcvStats.red			; Statistical functions for images
#include %math/rcvDistance.red		; Distance algorithm for detection in images
#include %ZLib/rcvZLib.red			; ZLib compression
#include %tiff/rcvTiff.red			; Tiff image reading and writing
#include %timeseries/rcvTS.red		; Time Series algorithms
#include %tools/rcvTools.red		; Some tools

;#include %video/rcvCapture.red		; experimental video access no more supported now XCode doesn't support 32-bit

