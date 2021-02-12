Red [
	Title:   "Laplacian Filter "
	Author:  "Francois Jouen"
	File: 	 %laplacian1.red
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
dst:  rcvCreateImage defSize
currentImage:  rcvCreateImage defSize
gray: rcvCreateImage defSize
isFile: false
param: 4


loadImage: does [
    isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: Laplacian "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		currentImage rcvCreateImage img1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage img1]
		dst:  rcvCloneImage currentImage
		bb/image: img1
		canvas/image: dst
		isFile: true
		rcvLaplacian currentImage dst param
		r1/data: true
		r2/data: false
		r3/data: false
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Laplacian"
		origin margins space margins
		
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[either cb/data 
									[currentImage: rcvCloneImage gray]
					   				[currentImage: rcvCloneImage img1]
									rcvLaplacian currentImage dst param
								]
					
		button 60 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage gray 
								rcvReleaseImage dst rcvReleaseImage currentImage 
								Quit]
		return
		bb: base 128x128 img1
		return
		r1: radio "Connexity 4"  [param: 4 rcvLaplacian currentImage dst param ]
		r2: radio "Connexity 8"  [param: 8 rcvLaplacian currentImage dst param]	
		r3: radio "Connexity 16" [param: 16 rcvLaplacian currentImage dst param]
		return
		canvas: base 512x512 dst	
		do [r1/data: true]
]
