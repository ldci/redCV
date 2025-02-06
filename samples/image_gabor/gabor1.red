Red [
	Title:   "Gabor function test "
	Author:  "ldci"
	File: 	 %gabor1.red
	Needs:	 'View
]

; required libs
#include %../../libs/imgproc/rcvGabor.red


;--defaults values
f:  0.1
;theta: to-radians 90.0 ;--unsupported by Red
theta: 0.0 * pi / 180.0
sigma_x: 8.0
sigma_y: 8.0
radius: 20

;--general function with image generation
showFilter: does [
	blk: rcvGaborKernel theta f sigma_x sigma_y radius	;--get Gabor function
	mat2: rcvGaborNormalizeFilter blk					;--get normalized values for visualization
	im: make image! as-pair blk/1 blk/1					;--create and update kernel image
	repeat i length? mat2 [
		im/:i: make tuple! reduce [mat2/:i mat2/:i mat2/:i]
	]
	;img1/size: im/size
	img1/image: im										;--show filter image
]

win: layout [
	title "Gabor Function"
	text 70 "Frequency" 
	sl1: slider 125 [f: round/to to-float face/data 0.01 ffreq/text: form f
					showFilter]
	ffreq: field 40
	return
	
	text 70 "Angle" 
	sl2: slider 125 [angle: to-integer face/data * 180
					fTheta/text: form angle theta: angle * pi / 180.0 
					showFilter]
	fTheta: field 40
	
	return
	text 70 "X Sigma" 
	sl3: slider 125 [sigma_x: 1.0 + round to-float face/data * 99
					fx_sigma/text: form round sigma_x showFilter]
	fx_sigma: field 40 
	
	return
	text 70 "Y Sigma" 
	sl4: slider 125 [sigma_y: 1.0 + round to-float face/data * 99
					fy_sigma/text: form round sigma_y showFilter]
	fy_sigma: field 40 
	
	return
	text 70 "Radius" 
	sl5: slider 125 [radius: 1 + to-integer face/data * 99 fradius/text: form radius
					showFilter]
	fradius: field 40 
	return
	img1: base 256x256 black
	return
	button 256 "Show Generated Filter" [showFilter]
	return
	pad 100x0
	button "Quit" [Quit]
	do [sl1/data: 10% sl2/data: 0% sl3/data: 8% sl4/data: 8% sl5/data: 20% 
		ffreq/text: form f fTheta/text: form theta fx_sigma/text: form sigma_x
		fy_sigma/text: form sigma_y fradius/text: form radius
		showFilter]
]
view win