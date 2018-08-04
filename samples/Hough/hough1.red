Red [
	Title:   "Hough Transform"
	Author:  "Francois Jouen"
	File: 	 %hough1.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for redCV functions

isFile: false
isize: 256x256
isizex: first isize
img: rcvCreateImage isize			; source image
srcCopy: rcvCreateImage isize		; source copy
dst: rcvCreateImage isize			; destination image
edges: rcvCreateImage isize			; edges detection image
bw: rcvCreateImage isize			; for B&W transform
hSpace: rcvCreateImage 360x256		; for Hough space 
thresh: 32							; threshold
imgW: imgH: 0						; img size
acc: []								; Hough accumulator
contrast: 1.0						; for visualization
canny: [-1.0 -1.0 -1.0 
		-1.0 8.0 -1.0 
		-1.0 -1.0 -1.0] 			; edges detection kernel

;**************** Hough program **********************

loadImage: does [	
	isFile: false
	canvas1/image: none
	canvas2/image: none
	canvas3/image: none
	tmp: request-file 
	if not none? tmp [		
		img: load tmp	
		imgW: img/size/x 
		imgH: img/size/y
		dst:  rcvCreateImage img/size
		srcCopy:  rcvCreateImage img/size
		edges: rcvCreateImage img/size
		bw: rcvCreateImage img/size
		mat: make vector! imgW * imgH		; a matrix for Hough transform
		rcvConvolve img edges canny 1.0 0.0 ; edges detection
		rcv2BW edges bw						; B&W image [0 255]
		rcvCopyImage img srcCopy			; src image copy
		rcvImage2Mat bw mat 				; image to mat for Hough transform
		canvas1/image: img
		canvas2/image: bw
		isFile: true
		process
	]
]



process: does [
	acc: rcvMakeHoughAccumulator imgW imgH			; makes Hough accumulator
	rcvHoughTransform mat acc imgW imgH 			; performs Hough transform
	hSpace: rcvCreateImage rcvGetAccumulatorSize acc; creates Hough space image
	rcvHough2Image acc hSpace contrast				; shows Hough space
	canvas3/image: hSpace
]

drawLines: does [
	if isFile [
		rcvCopyImage srcCopy img
		lines: copy []								; makes block for lines storage
		rcvGetHoughLines acc img thresh lines		; Gets lines 
		ff/text: form (length? lines) / 2			; Number of lines
		plot: copy [line-width 1]					; makes plot
		foreach [c1 c2] lines [ 
			append plot 'pen 
			append plot 'green 
			append plot 'line 
			append plot c1
			append plot c2
			append plot 'pen 
			append plot 'off
		]
		canvas1/image: draw img plot				; shows result
	]
]

view win: layout [
	title "redCV: Hough Transform"
	button "Load" 		[loadImage]
	button "Get Lines" 	[drawLines]
	sl1: slider 150 	[thresh: 1 + to integer! face/data * 512 f/text: form thresh drawLines]
	f: field 50 "32" 	[if error? try [thresh: to-integer face/text] [thresh: thresh] 
						sl1/data: to-percent to-float thresh / 512.0
						drawLines]
	ff: field 50
	pad 80x0
	text "Contrast"
	sl2: slider 150 	[contrast: 1.0 + to float! (face/data * 25.0) cf/text: 
						form to-integer contrast
						if isFile [rcvHough2Image acc hSpace contrast]
						canvas3/image: hSpace]
	cf: field 30 "1"
	button "Quit" 		[Quit]
	return 
	text isizex "Source Image and Result"
	text isizex "Canny Edge Detector"
	text 360 	"Hough Space"
	return
	canvas1: base isize img
	canvas2: base isize  dst
	canvas3: base 360x256 hspace
	do [sl1/data: 12.5%]
]