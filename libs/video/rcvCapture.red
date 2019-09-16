Red [
	Title:   "Red Computer Vision: Video Capture"
	Author:  "Francois Jouen"
	File: 	 %rcvCapture.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


#include %rcvCaptureRoutines.red

; camera access

rcvCreateCam: function [
"Opens Camera device number (0 default cam)"
	device [integer!] 
][
	;return: [integer!]
	createCam device
]

rcvSetCamSize: function [
"Sets cam size"
	device 	[integer!] 
	cSize 	[pair!]
][
	w: to float! cSize/x
	h: to float! cSize/y
	setCamSize w h
]

rcvsetCamWidth: function [value [float!]] [
	setCamWidth value
]

rcvsetCamHeight: function [value [float!]] [
	setCamHeight value
]



rcvgetCamSize: function [
"Gets cam size"
	device [integer!]
][
	cSize: 0x0
	cSize/x: to integer! getCamWidth
	cSize/y: to integer! getCamHeight
	cSize
]

rcvgetCameraFPS: function [] [
	to integer! getCameraFPS
]

rcvGetCamImage: function []
"Gets cam immage"
][
	;return: [integer!
	getCamImage 
]


; for movies access


rcvGetMovieFile: function [fileName [string!] return: [integer!]][
	getMovieFile fileName
]


; for opencv image access



; get memory as binary! string
; Thanks to Qtxie for the optimization!
getBinaryValue: routine [dataAddress [integer!] dataSize [integer!] return: [binary!]] [
	as red-binary! stack/set-last as red-value! binary/load as byte-ptr! dataAddress dataSize
]

; sizeof(IplImage) should be 112 bytes
getISize: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/1
]

; version (=0)
getIID: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/2
]

; Most of OpenCV functions support 1,2,3 or 4 channels
getIChannels: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/3
]
; alpha: Ignored by OpenCV
getIAlpha: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/4
]

;image depth in bits
getIDepth: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/5
]

; color model 
getIColorModel: routine [img [integer!] return: [string!] /local b str tmp] [
	tmp: as int-ptr! img
	b: as byte! tmp/6
	if (b = #"R") [str: "RGBA"]
	if (b = #"B") [str: "BGRA"]
	if (b = #"G") [str: "GRAY"]
	as red-string! stack/set-last as red-value! string/load str length? str UTF-8 
]

; color order
getIChannelSequence: routine [img [integer!] return: [string!] /local b str tmp] [
	tmp: as int-ptr! img
	b: as byte! tmp/7
	if (b = #"B") [str: "BGRA"]
	if (b = #"R") [str: "RGBA"] 
	if (b = #"G") [str: "GRAY"]
	as red-string! stack/set-last as red-value! string/load str length? str UTF-8
]

;0 - interleaved color channels, 1 - separate color channels.
getIdataOrder: routine [img [integer!] return: [string!] /local b str tmp] [
	tmp: as int-ptr! img
	b: tmp/8
	if (b = 0) [str: "interleaved color channels"]
	if (b = 1) [str: "separate color channels"]
	as red-string! stack/set-last as red-value! string/load str length? str UTF-8
]

;0 - top-left origin, 1 - bottom-left origin (Windows bitmaps style). 
getIOrigin: routine [img [integer!] return: [string!] /local b str tmp] [
	tmp: as int-ptr! img
	b: tmp/9
	if (b = 0) [str: "top-left"]
	if (b = 1) [str: "bottom-left"]
	as red-string! stack/set-last as red-value! string/load str length? str UTF-8
]

;Alignment of image rows (4 or 8).OpenCV ignores it and uses widthStep instead.
getIRowAlign: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/10
]
; image x size
getIWidth: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/11
]

; image y size
getIHeight: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/12
]

; IplROI!pointer Image ROI. If NULL, the whole image is selected 
getIRoi: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/13
]

;Must be NULL.
getIRoiMask: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/14
]

;Must be NULL.
getImageID: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/15
]
;Must be NULL.
getITileInfo: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/16
]

;Image data size in bytes
getImageSize: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/17
]

;Pointer to aligned image data.
getImageData: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/18
]

;Size of aligned image row in bytes.
getIWStep: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/19
]

;Ignored by OpenCV.
getIBorderModel: routine [img [integer!] idx [integer!] return: [integer!] /local v tmp] [
	tmp: as int-ptr! img
	if (idx = 1) [v: tmp/20]
	if (idx = 2) [v: tmp/21]
	if (idx = 3) [v: tmp/22]
	if (idx = 4) [v: tmp/23]
	v
]

;Ignored by OpenCV.
getIBorderColor: routine [img [integer!] idx [integer!] return: [integer!] /local v tmp] [
	tmp: as int-ptr! img
	if (idx = 1) [v: tmp/24]
	if (idx = 2) [v: tmp/25]
	if (idx = 3) [v: tmp/26]
	if (idx = 4) [v: tmp/27]
	v
]

;Pointer to very origin of image data
getIDataOrigin: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/28
]

; for image calculation when a line offset is required
getIStep: routine [img [integer!] return: [integer!] /local tmp] [
	tmp: as int-ptr! img
	tmp/3 * tmp/11
]



; useful to know memory aligment of OpenCV image
; if false -> getLine line/line
; if true -> getImageData

getImageOffset: routine [&src [integer!] return: [logic!]/local sz][
	sz: (getIChannels &src) * (getIWidth &src) * (getIHeight &src)
	either (sz = getImageSize &src) [false] [true]
]


; From OpenCV to Red Image

; get image memory content line by line
getLine: routine [ img [integer!] ln [integer!] return: [binary!] /local step idx laddr] [
	step: getIStep img				; line size
	idx: (getIWStep img) * ln			; line index
	laddr: (getImageData img) + idx				; line address
	getBinaryValue laddr step			; binary values	
]

; get all image memory content by pointer
getAllImageData: routine [img [integer!] return: [binary!] /local tmp] [
 	getBinaryValue getImageData img getImageSize img
]


; Red Functions calling routines to create or update Red Image from OpenCV Image

makeImage: function [ im [integer!] w [integer!] h [integer!] return: [image!]] [		 
	rgb: getAllImageData im
	make image! reduce [as-pair w h reverse rgb] ;reverse BGRA to RGBA for red
]

makeImagebyLine: function [im [integer!] w [integer!] h [integer!] return: [image!]] [
	y: 0
	rgb: copy #{}
	until [
		append rgb getLine im y
		y: y + 1
		y = h
	]
	make image! reduce [as-pair w h reverse rgb]	
]



makeRedImage: function [im [integer!] w [integer!] h [integer!] return: [image!]] [
	lineRequired: getImageOffset im
	either lineRequired [makeImagebyLine im w h] [makeImage im w h]
]

updateImage: function [ src [integer!] dst [image!]] [
	dst/rgb: reverse getAllImageData src
]

updateImagebyLine: function [ src [integer!] dst [image!]] [
	y: 0
	h: dst/size/y
	dst/rgb: copy #{}
	until [
		append dst/rgb getLine src y
		y: y + 1
		y = h
	]
	reverse dst/rgb
]

updateRedImage: function [ src [integer!] dst [image!]] [
	lineRequired: getImageOffset src
	either lineRequired [updateImagebyLine src dst] [updateImage src dst]
]