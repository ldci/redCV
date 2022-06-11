#!/usr/local/bin/red
Red [
	Title:   "Gabor function test "
	Author:  "Francois Jouen"
	File: 	 %gabor2.red
	Needs:	 'View
]

;--defaults values
f:  0.1
;theta: to-radians 90.0 ;--unsupported by Red
theta: 0.0 * pi / 180.0
sigma_x: 8.0
sigma_y: 8.0
radius: 10
img: none 
dst: none
isFile: false
auto?: false

;--required lib
#include %../../libs/imgproc/rcvGabor.red


showFilter: does [
	blk: rcvGaborKernel theta f sigma_x sigma_y radius	;--get Gabor function
	mat2: rcvGaborNormalizeFilter blk					;--get normalized values for visualization
	im: make image! as-pair blk/1 blk/1					;--create and update kernel image
	repeat i length? mat2 [
		im/:i: make tuple! reduce [mat2/:i mat2/:i mat2/:i]
	]
	
	img1/image: im	
	if im/size <= 25x25 [									;--show filter image
		bb/size: as-pair blk/1 blk/1
	]
	bb/image: im
]

loadImage: does [
	tmp: request-file
	unless none? tmp [
		img: load tmp
		dst: load tmp
		img0/image: img
		img2/image: black
		isFile: true
		clear ff/text
	]
]
filterImage: does [
	if isFile [
		clear ff/text
		do-events/no-wait
		blk: rcvGaborKernel theta f sigma_x sigma_y radius	;--get Gabor function
		dx: dy: blk/1
		t1: now/time/precise
		rcvImageGaborFilter img dst blk/4 dx dy
		t2: now/time/precise
		ff/text: form round/to third (t2 - t1) 0.000001
		img2/image: dst
	]
]


win: layout [
	title "Gabor Filters"
	button "Load Image" [loadImage]
	button 160 "Show Generated Filter"  [showFilter]
	button 160 "Apply Generated Filter" [filterImage]
	bb: base 25x25 black
	ff: field 80 
	check  100 "Automatic" false [auto?: face/data]
	pad 50x0
	button "Quit" [Quit]
	return
	
	text 55 "Frequency" 
	sl1: slider 140 [f: round/to to-float face/data 0.01 ffreq/text: form f
					showFilter if auto?[filterImage]]
	ffreq: field 40
	
	text 55 "Angle" 
	sl2: slider 140 [angle: to-integer face/data * 180 
					fTheta/text: form angle theta: angle * pi / 180.0
					showFilter if auto?[filterImage]]
					
	fTheta: field 40 [if error? try [angle: to-integer face/text][angle: 0]
						theta: angle * pi / 180.0 showFilter if auto?[filterImage]]
	
	return
	text 55 "X Sigma" 
	sl3: slider 140 [sigma_x: 0.5 + to-float face/data * 18.5
					fx_sigma/text: form round/to sigma_x 0.1 
					showFilter if auto?[filterImage]]
	fx_sigma: field 40 
	
	
	text 55 "Y Sigma" 
	sl4: slider 140 [sigma_y: 0.5 + to-float face/data * 18.5
					fy_sigma/text: form round/to sigma_y 0.1
					showFilter if auto?[filterImage]]
	fy_sigma: field 40 
	
	
	text 55 "Radius" 
	sl5: slider 140 [radius: 1 + to-integer face/data * 49 fradius/text: form radius
					showFilter if auto?[filterImage]]
	fradius: field 40 
	
	
	return
	img0: base 256x256 black
	img1: base 256x256 black
	img2: base 256x256 black
	return
	
	do [sl1/data: 10% sl2/data: 0% sl3/data: 40% sl4/data: 40% sl5/data: 20% 
		ffreq/text: form f fTheta/text: "0" fx_sigma/text: form sigma_x
		fy_sigma/text: form sigma_y fradius/text: form radius
		showFilter]
]
view win