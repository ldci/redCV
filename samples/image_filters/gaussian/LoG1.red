Red [
	Title:   "Robinson Filter "
	Author:  "ldci"
	File: 	 %LoG1.red
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
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize
isFile: false
kSize: 5x5
factor: 28.0
op: 1

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		win/text: copy "Edges detection: DoG "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		cImg rcvCreateImage img1/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		
		dst:  rcvCloneImage cImg
		bb/image: img1
		canvas/image: dst
		isFile: true
		process
	]
]

process: does [if isFile [rcvLaplacianOfGaussian cImg dst op]]


; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: LoG"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		pad 60x0
		cb: check 128 "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					process
					canvas/image: dst
		]
		text 100 "Kernel Size"
		r1: radio "3x3" true [if face/data [op: 1] process]
		r2: radio "5x5" false [if face/data [op: 2] process]
		pad 20x0
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		
		return
		bb: base 128x128 img1
		canvas: base 512x512 dst	
]
