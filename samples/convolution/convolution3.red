Red [
	Title:   "Test images convolution Red VID "
	Author:  "Francois Jouen"
	File: 	 %convolution2.red
	Needs:	 'View
]


fileName: ""
isFile: false

; all we need for computer vision with red
#include %../../libs/redcv.red ; for red functions


knl: [0.0 0.0 0.0
	  0.0 1.0 0.0 
	  0.0 0.0 0.0]
		  
		  
rimg: rcvCreateImage 512x512
dst: rcvCreateImage 512x512

factor: 1.0
delta: 0.0

convolveImage: does [
	t1: now/time/precise
	if error? try [knl/1: to float! k1/data] [knl/1: 0]
	if error? try [knl/2: to float! k2/data] [knl/2: 0]
	if error? try [knl/3: to float! k3/data] [knl/3: 0]
	if error? try [knl/4: to float! k4/data] [knl/4: 0]
	if error? try [knl/5: to float! k5/data] [knl/5: 0]
	if error? try [knl/6: to float! k6/data] [knl/6: 0]
	if error? try [knl/7: to float! k7/data] [knl/7: 0]
	if error? try [knl/8: to float! k8/data] [knl/8: 0]
	if error? try [knl/9: to float! k9/data] [knl/9: 0]
	rcvConvolve rimg dst knl factor delta
	sb1/data: third now/time/precise - t1
]


loadImage: does [
	isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		rimg: load tmp
		dst: load tmp
		; update faces
		if rimg/size/x >= 512 [
			win/size/x: rimg/size/x + 20
			win/size/y: rimg/size/y + 190
		] 
		canvas/size/x: rimg/size/x
		canvas/size/y: rimg/size/y
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - rimg/size/x) / 2
		canvas/image: dst
		isFile: true
	]
]






view win: layout [
	title "Play with Kernel Values"
	origin 10x10 space 10x10
	style btn: button -1x22
	btn 50 "Load" [loadImage]
	btn 50 "Quit" [quit]
	return
	
	k1: field 50 k2: field 50 k3: field 50 
	text 50 "Factor" sl1: slider 150 [factor: 1.0 + (face/data * 256.0) 
		ft/data: form to integer! factor
		if isFile [convolveImage]
	]
	ft: field  50 "1.0"
	return
	k4: field 50 k5: field 50 k6: field 50
	
	text 50 "Delta" sl2: slider 150  [delta: 0.0 + (face/data * 256.0) dt/data: form delta
		if isFile [convolveImage] 
	]
	dt: field 50 "0.0"
	return
	k7: field 50 k8: field 50 k9: field 50
	return
	btn 170 "Process" [if isFile [convolveImage]]
	text "Rendered in: " sb1: field 100x24
	
	return
	canvas: base 512x512 dst 
	do [k1/data: knl/1 k2/data: knl/2 k3/data: knl/3 
	k4/data: knl/4 k5/data: knl/5 k6/data: knl/6 
	k7/data: knl/7 k8/data: knl/8 k9/data: knl/9 ]
]