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


identity: [0.0 0.0 0.0
		  0.0 1.0 0.0 
		  0.0 0.0 0.0]
		  
highPass: [-1.0 0.0 -1.0
		  0.0 8.0 0.0 
		  -1.0 0.0 -1.0]

lowPass: [0.111 0.111 0.111
		  0.111 0.111 0.111 
		  0.111 0.111 0.111]
		  
rimg: rcvCreateImage 512x512
dst: rcvCreateImage 512x512

factor: 1.0
delta: 0.0

loadImage: does [
	sb1/data: ""
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
			win/size/y: rimg/size/y + 110
		] 
		canvas/size/x: rimg/size/x
		canvas/size/y: rimg/size/y
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - rimg/size/x) / 2
		;canvas/offset/y: 40 + (win/size/y - rimg/size/y) / 2
		
		canvas/image: dst
		isFile: true
		op/selected: 1
	]
]

img-convolve: func [num [integer!]] [
		switch num [
		
		1 	[rcvConvolve rimg dst identity factor delta]	
		2 	[t1: now/time/precise
			rcvConvolve rimg dst lowPass factor delta
			sb1/data: third now/time/precise - t1
			] 
		3 	[t1: now/time/precise
			rcvConvolve rimg dst highPass factor delta
			sb1/data: third now/time/precise - t1
			]
		]
]



view win: layout [
	title "Red view"
	origin 10x10 space 10x10

	style btn: button 50;-1x22
	style drop-d: drop-down 120x24 on-create [face/selected: 1]

	btn "Load" [loadImage]
	op: drop-d data [
		"No Filter"  "Low Pass Filter" "High Pass Filter" 
	] select 1 on-change [if isFile [img-convolve face/selected]]
	
	text "Rendered in: " sb1: field 100x24 
	btn "Quit" [quit]
	return
	text 40 "Factor" sl1: slider 140 [factor: 1.0 + (face/data * 256.0) 
		ft/data: form to integer! factor
		if isFile [img-convolve op/selected] ]
	ft: field  40 "1.0"
	text 40 "Delta" sl2: slider 140  [delta: 0.0 + (face/data * 256.0) dt/data: form delta
		if isFile [img-convolve op/selected] ] 
	dt: field 40 "0.0"
	return
	canvas: base 512x512 dst 
	
]