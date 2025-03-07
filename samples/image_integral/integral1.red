Red [
	Title:   "Integral1"
	Author:  "ldci"
	File: 	 %integral1.red
	Needs:	 'View
]

; required last Red Master

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvIntegral.red

thresh: 32
boxW: 5
boxH: 5

margins: 5x5
msize: 640x480
bitSize: 32



img1: 	rcvCreateImage msize				; src
gray: 	rcvCreateImage img1/size			; gray scale
sum: 	rcvCreateImage img1/size			; dst 1
sqsum:	rcvCreateImage img1/size			; dst 2
plot: 	copy []

loadImage: does [
	canvas1/image: black
	canvas2/image: black
	canvas2/draw: []
	clear sb/text
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		gray: rcvCreateImage img1/size ; just for visualization
		rcv2Gray/average img1 gray
		ssum: 	matrix/init/value 2 bitSize img1/size 0
		sqsum: 	matrix/init/value 2 bitSize img1/size 0
		mat1: 	matrix/init/value 2 bitSize img1/size 0
		rcvImage2Mat img1 mat1 		
		rcvIntegral mat1 ssum sqsum 
		canvas1/image: img1
		canvas2/image: gray
	]
]



ProcessImage: does [
	canvas2/image: black
	canvas2/draw: []
	do-events/no-wait
	plot: copy [line-width 1 pen green]
	if error? try [boxW: to integer! wt/text] [boxW: 5]
	if error? try [boxH: to integer! ht/text] [boxH: 5]
	w: img1/size/x 
	h: img1/size/y
	y: boxH + 1
	t1: now/time/precise
	while [y < h] [
	sb/text: copy "Processing line "
	append sb/text form y
	do-events/no-wait	;-- allow GUI msgs to be processed
	x: boxW + 1
		while [x < w] [
			scal0: rcvGetInt2D ssum x y
			scal1: rcvGetInt2D ssum (x - boxW) (y - boxH)  
			scal2: rcvGetInt2D ssum x (y - boxH) 
			scal3: rcvGetInt2D ssum (x - boxW) y
			val: (scal0 + scal1 - scal2 - scal3)
			val: val / (boxW * boxH)  
        	topLeft: as-pair (x - boxW) (y - boxH)
       	 	bottomRight: as-pair (x) (y)
			if val <= thresh [
				append plot compose [box (topLeft) (bottomRight)]
			]
		x: x + 1
		]
	y: y + 1
	]
	
	sb/text: copy "Done! Rendering..."
	do-events/no-wait
	canvas2/draw: plot
	t2: now/time/precise
	sb/text: copy "Rendered : " 
	append sb/text form round/to third (t2 - t1) * 1000 0.01
	append sb/text " ms"
]



; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Load Image" 	[loadImage]
		text "Threshold" 
		sl: slider 200 	[thresh: 1 + to integer! face/data * 254 
										slt/text: form thresh] 
		slt: field 50 "32"
		text "Box [w h]"
		wt: field 40 "5" [if error? try [boxW: to integer! wt/text] [boxW: 5] ProcessImage]
		ht: field 40 "5" [if error? try [boxH: to integer! ht/text] [boxH: 5] ProcessImage]
		button 100 "Process" 			[ProcessImage]
		sb: field 256
		
		button 100 "Quit" 				[rcvReleaseImage img1  Quit]
		return
		
		text 640 "Source"  text  640 "Integral" 
		return
		canvas1: base msize img1
		canvas2: base msize gray
		do [sl/data: 0.125]
		
]