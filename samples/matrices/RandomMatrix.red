Red [
	Title:   "Matrix tests"
	Author:  "Francois Jouen"
	File: 	 %RandomMatrix.red
	Needs:	 'View
]
#include %../../libs/redcv.red ; for redCV functions
img: rcvCreateImage 512x512			; a 512x512 image
mat: rcvCreateMat 'char! 8 512x512	; a 512X512 matrix of chars 
title: "1-Channel Matrix -> Red Image"
rcvRandomMat mat 255				; 8-bits and 1-channel random matrix
rcvMat82Image mat img				; converts matrix to Red Image
dest: rcvNamedWindow title 			; creates a window
rcvResizeWindow dest 512x512		; resizes the window
rcvShowImage dest img				; shows image
do-events

