Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %moments.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions

maxInt: 2147483647
minInt: -2147483647

{6.53608067e-04   6.07480284e-16   9.67218398e-18   1.40311655e-19
  -1.18450102e-37   8.60883493e-28  -1.12639633e-37}
  
isize: 256x256
bitSize: 32
img1: rcvCreateImage isize
img2: rcvCreateImage isize
mat1: rcvCreateMat 'integer! bitSize isize
isFile: false


; Clean App Quit
quitApp: does [
	rcvReleaseImage img1 
	rcvReleaseImage img2
	rcvReleaseMat mat1
	Quit
]


; loads any supported Red image 
loadImage: does [
	isFile: false
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size			
		mat1: rcvCreateMat 'integer! bitSize img1/size
		canvas1/image: img1
		rcvImage2Mat img1 mat1
		rcvMat2Image mat1 img2
		sb0/text: form img1/size
		sb01/text: form img1/size/x * img1/size/y
		append sb01/text " pixels"
		xyb: rcvGetMatCentroid mat1 img1/size/x img1/size/y 
		sb1/text: form xyb + 1
		plot: compose [line-width 1 fill-pen green circle (xyb) 5.0]
		img: draw img2 plot
		canvas2/image: img2
		;cm/text: form rcvGetMatCentralMoment mat1 img1/size/x img1/size/y 0.0 0.0
		cm/text: form rcvGetMatSpatialMoment mat1 img1/size/x img1/size/y 0.0 0.0
		
		
		hu: rcvGetMatHuMoments mat1 img1/size/x img1/size/y
		hu1/text: form hu/1
		hu2/text: form hu/2
		hu3/text: form hu/3
		hu4/text: form hu/4
		hu5/text: form hu/5
		hu6/text: form hu/6
		hu7/text: form hu/7
		isFile: true
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Hu Moments"
		button "Load" [loadImage]
		pad 380x0 
		button "Quit" [quitApp]
		return
		text 100 "Source" 
		pad 156x0 text 100 "Matrix image"
		return
		canvas1: base isize img1
		canvas2: base isize img2
		return
		text 150 "Image Size" 
		sb0: field 175
		sb01: field 175
		return
		text 150 "Centroid" 
		sb1: field 360 
		return
		text 150 "Central Moment 0" cm: field 360
		return
		text 150  "Hu1" hu1: field 360 
		return
		text 150 "Hu2"  hu2: field 360 
		return
		text 150 "Hu3"  hu3: field 360 
		return
		text 150 "Hu4"  hu4: field 360 
		return
		text 150 "Hu5"  hu5: field 360 
		return
		text 150 "Hu6"  hu6: field 360 
		return
		text 150 "Hu7"  hu7: field 360 
		return	
]