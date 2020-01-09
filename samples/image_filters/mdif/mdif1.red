Red [
	Title:   "Prewitt Filter "
	Author:  "Francois Jouen"
	File: 	 %mdif1.red
	Needs:	 'View
]

;Le filtre MDIF est une combinaison d'un filtre moyenneur avec un filtre de Prewitt.

; required libs
#include %../../../libs/tools/rcvTools.red
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/imgproc/rcvImgProc.red

margins: 10x10
defSize: 512x512
iSize: 0x0
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
cImg:  rcvCreateImage defSize
gray: rcvCreateImage defSize

isFile: false
param: 3

loadImage: does [
    isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: copy "Edges detection: MDIF " 
		append win/text fileName
		img1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		iSize: img1/size
		dst: rcvCreateImage iSize
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage img1]
		bb/image: img1
		isFile: true
		r1/data: true
		r2/data: false
		r3/data: false
		r4/data: false
		r5/data: false
		param: 1
		process
	]
]


process: does [
	if isFile [
		rcvMDIF cImg dst iSize param
		canvas/image: dst
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: MDIF"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		cb: check "Grayscale"	[either cb/data [cImg: rcvCloneImage gray]
					   			[cImg: rcvCloneImage img1]
					   			process
		]				
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								rcvReleaseImage dst Quit]
		return	
		text middle 128x20 "Filter Direction"
		r1: radio "Horizontal" 	[param: 1 process]
		r2: radio "Vertical" 	[param: 2 process]	
		r3:	radio 50 "Both" 	[param: 3 process]
		r4:	radio "Magnitude"	[param: 4 process]
		r5: radio 60 "Angle"	[param: 5 process]
		return
		bb: base 128x128 img1
		canvas: base defSize dst
		
]
