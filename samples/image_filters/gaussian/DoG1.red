Red [
	Title:   "Robinson Filter "
	Author:  "ldci"
	File: 	 %DoG.red
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
		rcvDoGFilter cImg dst kSize 1.0 2.0 factor
		probe 3
		canvas/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Edges detection: DoG"
		origin margins space margins
		button 60 "Load" 		[loadImage]	
		
			
		button 60 "Quit" 		[rcvReleaseImage img1 
								rcvReleaseImage dst 
								rcvReleaseImage gray
								rcvReleaseImage cImg
								Quit]
		return
		cb: check 128 "Grayscale" 	[
					either cb/data  [cImg: rcvCloneImage gray]
					[cImg: rcvCloneImage img1]
					rcvDoGFilter cImg dst kSize 1.0 2.0 factor
					canvas/image: dst
		]
		
		text 50 "Factor"
		sl: slider 380 [
			factor: 1.0 + (face/data * 127.0)
			f/text: form factor
			if isFile [rcvDoGFilter cImg dst kSize 1.0 2.0 factor canvas/image: dst]
		]
		f: field 50 "16.0"
		return
		bb: base 128x128 img1
		canvas: base 512x512 dst	
		do [sl/data: 0.225]
]
