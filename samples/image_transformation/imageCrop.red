Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %ImageCrop.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

margins: 10x10
winBorder: 10x50
defSize: 512x512
clipSize: 100x100
clipSize2: clipSize + 2 

imgRoi: rcvCreateImage clipSize
imgSrc: rcvCreateImage defSize
imgDst: rcvCreateImage defSize
winBorder: 10x50
start: 0x0
end: start + clipSize/x
poffset: negate start
isFile: false
canvas: none

drawClip: compose [line-width 1 pen green box 0x0 (clipSize)]

loadImage: does [
	isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		roi/image: none
		imgSrc: rcvLoadImage tmp
		imgDst: rcvResizeImage imgSrc defSize
		canvas/image: imgDst
		rcvCropImage imgDst imgRoi start
		roi/image: imgRoi
		p1/draw: drawClip
		isFile: true
	]
]



; ***************** Test Program ****************************
view/tight [
		title "Crop Test"
		style rect: base 255.255.255.240 clipSize2 loose draw []
		origin margins space margins
		button 90 "Load Image"		[loadImage]
		check "Show RoI" true		[either face/data [p1/draw: drawClip] [p1/draw: []] ]
		pad 350x0
		button 80 "Quit" 	 		[rcvReleaseImage imgSrc imgDst Quit]
		return 
		canvas: base 512x512 imgDst cursor hand react [
			posc: p1/offset - winBorder	
			if all [posc/x >= 0 posc/y >= 0
					posc/x <= (defSize/x - clipSize/x)  
					posc/y <= (defSize/y - clipSize/y)] [
					start: posc
					end: start + clipSize
					sb/text: rejoin [form start	"-" form end]
					if isFile [
							rcvCropImage imgDst imgRoi start
							roi/image: imgRoi
						]
			]
		]
		ROI: base clipSize white draw []
		return
		sb: field 512
		at winBorder p1: rect
]
