Red [
	Title:   "Harris Detector"
	Author:  "Francois Jouen"
	File: 	 %harris.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red


margins: 10x10
defSize: 128x128
gray: rcvCreateImage defSize
imgX: rcvCreateImage defSize
imgY: rcvCreateImage defSize
dst:  rcvCreateImage defSize
thresh: 1
isFile: false
iSize: 0x0
method: 1
k: 0.04
loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		canvas3/image: none
		fileName: to string! to-file tmp
		win/text: fileName
		gray: rcvLoadImage/grayscale tmp
		iSize: gray/size
		imgX: rcvCreateImage iSize
		imgY: rcvCreateImage iSize
		dst: rcvCreateImage iSize
		canvas0/image: gray
		isFile: true
		compute
	]
]


compute: does [
	if isFile [
		canvas0/image: gray
		switch method [
			1 [rcvSobel gray imgX iSize 1 1 rcvSobel gray imgY iSize 2 1]
			2 [rcvDerivative2 gray imgX iSize 1.0 1 rcvDerivative2 gray imgY iSize 1.0 2]
			3 [rcvLineDetection gray imgX iSize 1 rcvLineDetection gray imgY iSize 2]
		]
		
		{rcvGaussianFilter imgX imgX 3x3 2.0
		rcvGaussianFilter imgY imgY 3x3 2.0}
		
		canvas1/image: imgX	
		canvas2/image: imgY
		rcvHarris imgX imgY dst k thresh
		canvas3/image: dst 
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Harris"
		origin margins space margins
		button 60 "Load" 		[loadImage]
		drop-down 120 data ["Sobel" "2nd Derivative" "Line"]
				on-change [method: face/selected compute]
				select 1
		text "K value" 
		fk: field 50 "0.04" [if error? try [k: to-float face/text] [k: 0.04]
						compute]
		pad 60x0
		text "Threshold" 
		sl: slider 255 [thresh: 1 + to-integer face/data * 127
						ft/text: form thresh
						rcvHarris imgX imgY dst k thresh
						canvas3/image: dst ]
		ft: field 50 "127" 
		button 60 "Quit" 		[rcvReleaseImage gray 
								rcvReleaseImage dst Quit]
		return
		text 128 "Source"
		text 128 "X direction"
		text 128 "Y direction"
		text 512 "Harris corner detection"
		return
		canvas0: base defSize gray
		canvas1: base defSize imgX
		canvas2: base defSize imgY
		canvas3: base 512x512 dst	
		do [sl/data: 0%]
]
