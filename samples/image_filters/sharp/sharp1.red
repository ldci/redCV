Red [
	Title:   "Laplacian Filter "
	Author:  "ldci"
	File: 	 %sharp1.red
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
degree: 0.6

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: fileName
		gray: rcvLoadImage/grayscale tmp
		img1: rcvLoadImage tmp
		
		either cb/data [cImg:  rcvCloneImage gray]
					   [cImg:  rcvCloneImage img1]
		dst:  rcvCloneImage cImg
		bb/image: img1
		canvas/image: dst
		isFile: true
		op: ops/1
		do op
		sl/data: 50%
		sl/data: 0.6
		f/text: "0.6"
		r1/data: true
		r2/data: false
		sl/visible?: f/visible?: false
		degree: 0.6
	]
]

ops: [
	[rcvSharpen cImg dst ]
	[rcvBinomialFilter cImg dst degree]
]




; ***************** Test Program ****************************
view win: layout [
		title "Sharpen"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[either face/data [cImg: rcvCloneImage gray] 
									[cImg:  rcvCloneImage img1]
									dst:  rcvCloneImage cImg
									do op
									canvas/image: dst]		
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst Quit]
		return
		bb: base 128x128 img1
		r1: radio "Uniform sharpen"  [sl/visible?: f/visible?: false do op: ops/1]
		r2: radio "Binomial sharpen" [sl/visible?: f/visible?: true do op: ops/2]	
		return 
		text 60 "Degree"
		sl: slider 360 [degree: face/data * 1.2
						f/text: form round/to degree 0.01
						do op]
		f: field 60 "0.6"
		return
		canvas: base defSize dst	
		do [r1/data: true sl/data: degree sl/visible?: f/visible?: false]
]
