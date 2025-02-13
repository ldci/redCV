Red [
	Title:   "Flip tests "
	Author:  "ldci"
	File: 	 %imageclip.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvConvolutionImg.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/imgproc/rcvImgEffect.red

margins: 10x10
winBorder: 10x50
iSize: 	512x512
img1: 	rcvCreateImage iSize
dst: 	rcvCreateImage iSize
rLimit: 0x0
lLimit: 512x512

canvas: none

loadImage: does [
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		dst: rcvResizeImage img1 iSize ; force image in 512x512
		canvas/image: dst
		;--for ROI
		start: 0x0
		end: start + 200
		poffset: negate start
		drawBlk: rcvClipImage poffset start end dst
		drawRect: compose [line-width 2 pen green box 0x0 200x200]
		p1/draw: [] ROI/draw: []
	]
]



; ***************** Test Program ****************************
view/tight [
		title "Clip Test"
		style rect: base 255.255.255.240 202x202 loose draw []
		origin margins space margins
		button 90 "Load Image"		[loadImage]
		button 80 "Show Roi" 		[p1/draw: drawRect ROI/draw: drawBlk]
		button 80 "Hide Roi" 		[p1/draw: [] ROI/draw: []]
		button 80 "Quit" 	 		[rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst react [	
			if (p1/offset/x > lLimit/x) AND (p1/offset/y > lLimit/y)[
				if (p1/offset/x  < rLimit/x) AND (p1/offset/y  < rLimit/y)[
					start: p1/offset - winBorder
					end: start + 200
					poffset: negate start
					sb/text: rejoin [" Roi Offset " form start	]	
					drawBlk/2: poffset 
					drawBlk/4: start
					drawBlk/5: end
				]
			]
			
		]
		ROI: base 200x200 white draw []
		return
		sb: field 512
		at winBorder p1: rect
		do [rcvCopyImage img1 dst lLimit: canvas/offset rLimit: canvas/size + canvas/offset - p1/size ]
]
