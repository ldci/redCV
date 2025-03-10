Red [
	Title:   "Integral2"
	Author:  "ldci"
	File: 	 %integral2.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvIntegral.red

thresh: 32
boxW: 5
boxH: 5

margins: 5x5
msize: 320x240
bitSize: 32
isFile: false


img1: 	rcvCreateImage msize				; src
gray: 	rcvCreateImage img1/size			; gray scale
bimage: rcvCreateImage img1/size			; to visualize result
plot: 	copy []

loadImage: does [
	isFile: false
	canvas1/image: black
	canvas2/image: black
	canvas3/image: black
	canvas3/draw: []
	clear sb/text
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		gray: rcvCreateImage img1/size ; just for visualization
		bimage: rcvCreateImage img1/size
		rcv2Gray/average img1 gray
		ssum:  matrix/init 2 bitSize img1/size		; dst 1
		sqsum: matrix/init 2 bitSize img1/size		; dst 2
		rcvIntegralImg img1 ssum sqsum
		canvas1/image: img1
		canvas2/image: gray
		isFile: true
	]
	ProcessImage
]

ProcessImage: does [
	if isFile [
		canvas3/image: black
		rcvZeroImage bimage
		plot: copy [line-width 1 pen green]
		if error? try [boxW: to integer! wt/text] [boxW: 5]
		if error? try [boxH: to integer! ht/text] [boxH: 5]
		t1: now/time/precise
		either r1/data 
			[rcvProcessIntegralImage ssum boxW boxH thresh plot] 
			[rcvProcessIntegralImage sqsum boxW boxH thresh plot]
		canvas3/image: draw bimage plot
		t2: now/time/precise
		sb/text: copy "Rendered : " 
		append sb/text form round/to third (t2 - t1) * 1000 0.01
		append sb/text " ms"
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Load Image" 		[loadImage]
		r1: radio "Sum"					[ProcessImage]
		r2: radio "Squared Sum"			[ProcessImage]
		text "Threshold" sl: slider 180 [thresh: 1 + to integer! face/data * 254 
										slt/text: form thresh
										ProcessImage] 
		slt: field 50 "32"
		text "Box [width height]"
		wt: field 40 "5" [if error? try [boxW: to integer! wt/text] [boxW: 5] ProcessImage]
		ht: field 40 "5" [if error? try [boxH: to integer! ht/text] [boxH: 5] ProcessImage]
		sb: field 250
		pad 100x0
		button 80 "Quit" 				[rcvReleaseImage img1  Quit]
		return
		text 320 "Source" text 320 "Grayscale"  
		text 640 "Integral Image"
		return
		canvas1: base msize img1
		canvas2: base msize gray
		canvas3: base 640x480 black
		do [sl/data: 0.125 r1/data: true r2/data: false]
		
]