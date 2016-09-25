Red [
	Title:   "Simple Sobel Filter "
	Author:  "Francois Jouen"
	File: 	 %Sobel.red
	Needs:	 'View
]


; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions

sobelH: [1.0 2.0 1.0
		 0.0 0.0 0.0 
		-1.0 -2.0 -1.0]
		
sobelV: [1.0 2.0 -1.0
		 2.0 0.0 -2.0 
		 1.0 -2.0 -1.0]


margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
img2: rcvCreateImage defSize
img3: rcvCreateImage defSize
dst:  rcvCreateImage defSize


isFile: false
gScale: false
factor: 1
delta: 0


loadImage: does [
    isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		either gScale [img1: rcvLoadImage/grayscale tmp] [img1: rcvLoadImage tmp]
		img2: rcvCloneImage img1
		img3: rcvCloneImage img1
		dst:  rcvCloneImage img1
		; update faces
		if img1/size/x >= defSize/x [
			win/size/x: img1/size/x + 20
			win/size/y: img1/size/y + 90
		] 
		canvas/size: img1/size
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		canvas/image: dst
		isFile: true
		sobel
	]
]

sobel: func [] [
	rcvConvolve img1 img2 sobelH to float! factor to float! delta
	rcvConvolve img1 img3 sobelV to float! factor to float! delta
	rcvAdd img2 img3 dst
]


; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Sobel"
		origin margins space margins
		button 45 "Load" 		[loadImage]	
		 
		check 25 				[gScale: face/data]	
		text 55 "Grayscale?"
		pad 305x0					
		button 50 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage img2
								rcvReleaseImage img3
								rcvReleaseImage dst 
								Quit]
		return
		text 30 "Factor" 
		p1: slider 150 			[factor: 1 + to integer! face/data * 254 pt1/text: form factor sobel]
		pt1: field 50
		text 30 "Delta"  
		p2: slider 150 			[delta: to integer! face/data * 255  pt2/text: form delta sobel]
		pt2: field 50
		return 
		canvas: base 512x512 dst
		do [pt1/text: form factor pt2/text: form delta]	
]
