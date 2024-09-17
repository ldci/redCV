Red [
	Title:   "Kirsch Filter "
	Author:  "Francois Jouen"
	File: 	 %kirsch1.red
	Needs:	 'View
]


; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512

op: 1
dirc: 3
img1: rcvCreateImage defSize
gray: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg: rcvCreateImage defSize
isFile: false

loadImage: does [
    isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		win/text: copy "Edges detection: Kirsch "
		append win/text to string! tmp
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		iSize: img1/size
		cImg: rcvCreateImage iSize
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		
		dst:  rcvCloneImage cImg
		bb/image: img1
		dirc: 3
		rcvKirsch cImg dst dirc op
		canvas/image: dst
		r1/data: false
		r2/data: false
		r3/data: true
		r4/data: false
		r5/data: false
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: Kirsch"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		
			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		return
		bb: base 128x128 img1
		return
		cb: check "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					dst:  rcvCloneImage cImg
					if isFile [rcvKirsch cImg dst dirc op]
					canvas/image: dst
					r1/data: false
					r2/data: false
					r3/data: true
					r4/data: false
					r5/data: false
		]
		cb1: check "Inverse Kernel"	[either face/data [op: 2] [op: 1]
											if isFile [rcvKirsch cImg dst dirc op]]
		return
		
		text middle 100x20 "Kirsch Detection"
		r1: radio "Horizontal" 	[dirc: 1 if isFile [rcvKirsch cImg dst  dirc op]]
		r2: radio "Vertical" 	[dirc: 2 if isFile [rcvKirsch cImg dst  dirc op]]	
		r3:	radio 50 "Both" 	[dirc: 3 if isFile [rcvKirsch cImg dst  dirc op]]
		r4:	radio "Magnitude" 	[dirc: 4 if isFile [rcvKirsch cImg dst  dirc op]]
		r5:	radio 60 "Angle" 	[dirc: 5 if isFile [rcvKirsch cImg dst  dirc op]]
		return
		canvas: base defSize dst	
		do [r3/data: true]
]
