Red [
	Title:   "Laplacian Filters "
	Author:  "Francois Jouen"
	File: 	 %laplacianR.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red


margins: 10x10
defSize: 512x512
iSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
currentImage:  rcvCreateImage defSize
isFile: false

loadImage: does [
    isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		win/text: copy "Laplacian of Robinson "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		currentImage rcvCreateImage img1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		iSize: currentImage/size
		dst:  rcvCloneImage currentImage
		bb/image: img1
		rcvLaplacianOfRobinson currentImage dst
		canvas/image: dst
		isFile: true
		;defSize/y: img1/size/y
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Laplacian of Robinson"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[
					either cb/data  [currentImage: rcvCloneImage gray]
					[currentImage: rcvCloneImage img1]
					dst:  rcvCloneImage currentImage
					rcvLaplacianOfRobinson currentImage dst
					canvas/image: dst
		]
			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage currentImage
								Quit]
		return
		bb: base 128x128 img1
		return
		canvas: base 512x512 dst	
]
