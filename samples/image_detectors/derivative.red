Red [
	Title:   "Derivative Filter "
	Author:  "ldci"
	File: 	 %derivative.red
	Needs:	 'View
]


; last Red Master required!
;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize

isFile: false
delta: 0.0 
direction: 3

loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: 2nd Derivative "
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		dst: rcvCreateImage img1/size
		bb/image: img1
		delta: 0.0
		sl/data: 0%
		sl/data: delta 
		r1/data: false 
		r2/data: false
		r3/data: true
		direction: 3
		isFile: true
		process
	]
]

process: does [
	rcvDerivative2 cImg dst delta direction
	canvas/image: dst
]




; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: 2nd Derivative"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					process
		]			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		return
		bb: base 128x128 img1
		return
		text 60 "Direction"
		r1: radio 50 "X"  [direction: 1 process]
		r2: radio 50 "Y"  [direction: 2 process]
		r3: radio 50 "XY" [direction: 3 process]
		text 40 "Delta" 
		sl: slider 150 [delta: to float! face/data * 127.0
						f/text: form round/to delta 0.01
						process
		               ]
		f: field 50 "0.0"
		return
		canvas: base defSize dst	
		do [sl/data: 0.0 r3/data: true]
]
