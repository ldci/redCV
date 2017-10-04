Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %intensity.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
alpha: 0.5


loadImage: does [
    isFile: false
	canvas/image/rgb: black
	sl/data: 0.5 
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		; update faces
		if img1/size/x >= defSize/x [
			win/size/x: img1/size/x + 20
			win/size/y: img1/size/y + 90
		] 
		canvas/size: img1/size
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - img1/size/x) / 2
		isFile: true
		alpha: 0.5
		rcvSetIntensity img1 dst alpha
		canvas/image: dst
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Image intensity"
		button "Load Image" [loadImage] 
		sl: slider 256 [alpha: face/data * 1.0
					f1/text: form alpha
					rcvSetIntensity img1 dst alpha
					]
		f1: field 50 "0.5"
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst
		do [sl/data: alpha]
]
