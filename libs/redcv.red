Red [
	Title:   "Red Computer Vision"
	Author:  "Francois Jouen"
	File: 	 %redcv.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
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
; Some routines (_rcvName) are internal routines  

; Thanks to Nenad Rakocevic and Qingtian Xie for constant help :)
;#include %../../libs/redcv.red ; for redCV functions

; mandatory libs
#include %core/rcvCore.red 			; Basic image creating and processing functions
#include %matrix/rcvMatrix.red		; Matrices functions
#include %tools/rcvTools.red		; Some Red tools mainly used by rcvImgProc.red
#include %imgproc/rcvImgProc.red	; Image and matrix processing algorithms

; optional libs
#include %imgproc/rcvFreeman.red	; Contour detection
#include %imgproc/rcvIntegral.red	; Integral Images
#include %imgproc/rcvMorphology.red	; Morphological operators
#include %imgproc/rcvHough.red		; Hough transforms
#include %math/rcvRandom.red		; Random laws for generating random images
#include %math/rcvStats.red			; Statistical functions for images and matrices
#include %math/rcvMoments.red		; Spatial and central moments
#include %math/rcvHistogram.red		; Histograms 
#include %math/rcvDistance.red		; Distance algorithms for detection in images
#include %math/rcvQuickHull.red		; Convex area 
#include %math/rcvChamfer.red		; Chamfer distance computation
#include %math/rcvComplex.red		; Some operators for complex numbers
#include %math/rcvCluster.red		; Data clustering (kMeans)
#include %zLib/rcvZLib.red			; ZLib compression
#include %tiff/rcvTiff.red			; Tiff image reading and writing
#include %timeseries/rcvTS.red		; Time Series algorithms
#include %timeseries/rcvSGF.red		; Savitzky-Golay filter
#include %timeseries/rcvDTW.red		; Dynamic Time Warping algorithms
#include %timeseries/rcvFFT.red		; FFT algorithms
#include %highgui/rcvHighGui.red	; Fast Highgui functions



