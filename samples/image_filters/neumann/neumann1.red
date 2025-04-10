Red [
	Title:   "Neumann Filter "
	Author:  "ldci"
	File: 	 %neumann1.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst1:  rcvCreateImage defSize
dst2:  rcvCreateImage defSize
currentImage:  rcvCreateImage defSize
gray: rcvCreateImage defSize

isFile: false

loadImage: does [
    isFile: false
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Neumann "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		dst1:  rcvCreateImage img1/size
		dst2:  rcvCreateImage img1/size
		currentImage: rcvCreateImage img1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		dst1:  rcvCloneImage currentImage
		dst2:  rcvCloneImage currentImage
		bb/image: img1
		canvas1/image: dst1
		canvas2/image: dst2
		isFile: true
		r1/data: true
		r2/data: false
		r3/data: false
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Neumann gradient and divergence"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[either cb/data [rcvCopyImage gray currentImage]
					   			[rcvCopyImage img1 currentImage]
					   			rcvCopyImage currentImage dst1 rcvCopyImage currentImage dst2
					   			r1/data: true
								r2/data: false
								r3/data: false
					   			]	
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage gray
								rcvReleaseImage currentImage
								rcvReleaseImage dst1
								rcvReleaseImage dst2
								Quit]
		return
		bb: base 128x128 img1 
		r1: radio "No filter"  [rcvCopyImage currentImage dst1 rcvCopyImage currentImage dst2
								canvas1/image: dst1 canvas2/image: dst2
								]
		r2: radio "Gradient"   [b: rcvGradNeumann currentImage dst1 dst2 
								canvas1/image: b/1 canvas2/image: b/2
								]
		r3: radio "Divergence" [b: rcvDivNeumann currentImage dst1 dst2
								canvas1/image: b/1 canvas2/image: b/2
								] 
		return
		text 250 "derivative along the x axis"
		text 250 "derivative along the y axis"
		return
		canvas1: base 256x256 dst1
		canvas2: base 256x256 dst2	
		do [r1/data: true]
]
