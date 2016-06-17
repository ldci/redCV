Red [
	Title:   "Test images convolution Red VID "
	Author:  "Francois Jouen - Didier Cadieu"
	File: 	 %opimage.red
	Needs:	 'View
]

;
fileName: ""
isFile: false

; all we need for computer vision with red
#include %libs/redcv.red ; for red functions


;interface
rimg: make image!  reduce [512x512 black]

loadImage: does [
	isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		rimg: load tmp
		
		; update faces
		if rimg/size/x >= 512 [
			win/size/x: rimg/size/x + 20
			win/size/y: rimg/size/y + 50
		] 
		canvas/size/x: rimg/size/x
		canvas/size/y: rimg/size/y
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - rimg/size/x) / 2
		;canvas/offset/y: 40 + (win/size/y - rimg/size/y) / 2
		
		canvas/image: rimg
		isFile: true
		op/selected: 1
	]
]

img-convolve: func [num [integer!]] [
		switch num [
		
		1 	[canvas/image: rimg]	
		2 [filter: [0.0 0.0 0.0
		            0.0 1.0 0.0 
		            0.0 0.0 -1.0]
		canvas/image: rcvConvole rimg filter 1.0 128.0] ;emboss 1
		3 [filter: [2.0 0.0 0.0
		            0.0 -1.0 0.0 
		            0.0 0.0 -1.0]
		canvas/image: rcvConvole rimg filter 1.0 128.0]; emboss2
		4 [filter: [-1.0 -1.0 0.0
		            -1.0 0.0 1.0 
		            0.0 1.0 1.0]
		canvas/image: rcvConvole rimg filter 1.0 128.0]; emboss3
		
		5 [filter: [-1.0 0.0 -1.0
		            0.0 4.0 0.0 
		            -1.0 0.0 -1.0]
		canvas/image: rcvConvole rimg filter 1.0 128.0]; emboss Laplacian
		
		6 [filter: [0.0 0.0 0.0
		            -1.0 2.0 -1.0 
		            0.0 0.0 0.0]
		canvas/image: rcvConvole rimg filter 1.0 127.0]; emboss Hz
		
		7 [filter: [0.0 -1.0 0.0
		            0.0 0.0 0.0 
		            0.0 1.0 0.0]
		canvas/image: rcvConvole rimg filter 1.0 127.0]; emboss Vz
		
		8 [filter: [1.0 2.0 1.0
		            0.0 0.0 0.0 
		            -1.0 -2.0 -1.0]
		canvas/image: rcvConvole rimg filter 1.0 127.0]; Sobel H
		
		9 [filter: [1.0 0.0 -1.0
		            2.0 0.0 -2.0 
		            1.0 -2.0 -1.0]
		canvas/image: rcvConvole rimg filter 1.0 127.0]; Sobel v
	]
]


view win: layout [
	title "Red view"
	origin 10x10 space 10x10

	style btn: button -1x22
	style drop-d: drop-down 120x24 on-create [face/selected: 1]

	btn "Load" [loadImage]
	op: drop-d data [
		"Convolution"  "Emboss1" "Emboss2" "Emboss3" "Emboss Laplacian"
		"Emboss Horizontal" "Emboss Vertical" "Sobel Horizontal" "Sobel Vertical"
	] select 1 on-change [if isFile [img-convolve face/selected]]
	
	btn "Quit" [quit]
	return
	canvas: base rimg
	
]