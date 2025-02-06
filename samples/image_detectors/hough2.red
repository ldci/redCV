Red [
	Title:   "Test Hough"
	Author:  "ldci"
	File: 	 %hough2.red
	Needs:	 View
]
;--see https://www.keymolen.com/2013/05/hough-transformation-c-implementation.html
;--required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvHough.red

img: rcvCreateImage 256x256				;--default value
dst: rcvCreateImage 256x256				;--default value
imgCopy:  rcvCreateImage 256x256		;--default value
edges: rcvCreateImage 256x256			;--default value
bw: rcvCreateImage 256x256				;--default value
hSpace: rcvCreateImage 360x256			;--default value
mat: matrix/init 2 32 256x256			;--32-bit integer matrix
thresh: 32								;--default value
isFile: false							;--default value
imgW: imgH: 0							;--default value
factor: 1.0								;--default value
delta: 0.0								;--default value
contrast: 1.0							;--default value
acc: none								;--for Hough accumulator
plot: none								;--for drawing results


;--Canny Kernel
canny: [-1.0 -1.0 -1.0
		-1.0 8.0 -1.0 
		-1.0 -1.0 -1.0]
;--identity kernel		
knl: [0.0 0.0 0.0
	  0.0 1.0 0.0 
	  0.0 0.0 0.0]

;**************** program demo **********************
loadImage: does [	
	isFile: false
	canvas1/image: none
	canvas2/image: none
	canvas3/image: none
	tmp: request-file 
	unless none? tmp [		
		img: load tmp	
		dst: rcvCreateImage img/size			;--create destination image
		imgCopy:  rcvCreateImage img/size		;--source image copy
		edges: rcvCreateImage img/size			;--create an image for edges detection
		mat: matrix/init 2 32 img/size			;--a 32-bit integer matrix
		bw: rcvCreateImage img/size				;--Back and white image for edges detection
		rcvConvolve img edges knl factor delta	;--no filter by default
		imgW: bw/size/x 
		imgH: bw/size/y
		imgSizeF/text: copy "Source Image: "
		append imgSizeF/text form img/size
		rcvCopyImage img imgCopy				;--copy src image 
		isFile: true
		r0/data: true r1/data: r2/data: r3/data: false
		filter
	]
]


filter: does [
	if isFile [
		rcv2BW edges bw									;--B&W image [0 255]
		rcvImage2Mat bw mat 							;--B&W image to mat
		acc: rcvMakeHoughAccumulator imgW imgH			;--make Hough accumulator
		rcvHoughTransform mat/data acc imgW imgH 127	;--perform Hough transform
		hSpace: rcvCreateImage rcvGetAccumulatorSize acc;--create Hough space image
		rcvHough2Image acc hSpace contrast				;--show Hough space
		canvas1/image: img
		canvas2/image: bw
		canvas3/image: hSpace
		accSizeF/text: copy "Hough Space: " 
		append accSizeF/text form rcvGetAccumulatorSize acc
	]
]

drawLines: does [
	if isFile [
		rcvCopyImage imgCopy img
		lines: copy []								;--makes block for lines storage
		rcvGetHoughLines acc img thresh lines		;--Gets lines 
		fLines/text: form (length? lines) / 2		;--lines number
		plot: copy [line-width 2]					;--draw lines
		foreach [c1 c2] lines [ 
			append plot 'pen 
			append plot 'green 
			append plot 'line 
			append plot (c1)
			append plot (c2)
			append plot 'pen 
			append plot 'off
		]
		canvas1/image: draw img plot
	]
]

rcvLineDetection img edges 2 						;--from rcvImgProc lib

view win: layout [
	title "redCV Hough Transform"
	button 60 "Load" 		[loadImage]
	r0: radio 70 "No filter"[rcvCopyImage imgCopy img rcvConvolve img edges knl factor delta filter]
	r1: radio 60 "Canny"   	[rcvCopyImage imgCopy img rcvConvolve img edges canny factor delta filter]
	r2: radio 65 "Roberts" 	[rcvCopyImage imgCopy img rcvRoberts img edges 3 filter]
	r3: radio 60 "Sobel" 	[rcvCopyImage imgCopy img rcvSobel img edges 3 4 filter]
	button 80 "Get Lines"  	[drawLines]
	text "Threshold"	
	sl1: slider 140 		[thresh: 1 + to integer! face/data * 1023 fThresh/text: form thresh drawLines]
	fThresh: field 45 "32"	[
		if error? try [thresh: to-integer face/text] [thresh: thresh] 
		sl1/data: to-percent to-float thresh / 1024.0
		drawLines
	]
	fLines: field 60
	pad 5x0
	button "Quit" [Quit]
	return 
	text 256 "Source Image and Result"
	text 256 "Edges Detection"
	text "Hough Space"
	text 60 "Contrast"
	sl2: slider 140 	[
			contrast: 1.0 + to float! (face/data * 25.0) fContrast/text: form round contrast
			if isFile [rcvHough2Image acc hSpace contrast canvas3/image: hSpace]
	]
	fContrast: field 40 "1.0"
	return
	canvas1: base 256x256 img
	canvas2: base 256x256 bw
	canvas3: base 360x256 hSpace
	return
	imgSizeF: field 256
	pad 266x0 accSizeF: field 360
	do [sl1/data: 12.5% sl2/data: 0% r0/data: true r1/data: r2/data: r3/data: false] 
]

