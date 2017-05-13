Red [
	Title:   "Test images convolution Red VID "
	Author:  "Francois Jouen - Didier Cadieu"
	File: 	 %convolution.red
	Needs:	 'View
]

;
fileName: ""
isFile: false

; all we need for computer vision with red
#include %../../libs/redcv.red ; for red functions

noFilter: [0.0 0.0 0.0
		  0.0 1.0 0.0 
		  0.0 0.0 0.0]
		  
quickMask: [-1.0 0.0 -1.0
		  0.0 4.0 0.0 
		  -1.0 0.0 -1.0]


emboss1: [0.0 0.0 0.0
		  0.0 1.0 0.0 
		  0.0 0.0 -1.0]
		  
emboss2: [2.0 0.0 0.0
		  0.0 -1.0 0.0 
		  0.0 0.0 -1.0]
		  
emboss3: [-1.0 -1.0 0.0
		  -1.0 0.0 1.0 
		   0.0 1.0 1.0]
		   
laplacian: [-1.0 0.0 -1.0
		    0.0 4.0 0.0 
		    -1.0 0.0 -1.0]
		    
embossH: [0.0 0.0 0.0
		  -1.0 2.0 -1.0 
		   0.0 0.0 0.0]
		   
embossV: [0.0 -1.0 0.0
		  0.0 0.0 0.0 
		  0.0 1.0 0.0]
		  
sobelH: [1.0 2.0 1.0
		 0.0 0.0 0.0 
		-1.0 -2.0 -1.0]
		
sobelV: [1.0 2.0 -1.0
		 2.0 0.0 -2.0 
		 1.0 -2.0 -1.0]

edges1: [-1.0 -1.0 -1.0
		 -1.0 8.0 -1.0 
		 -1.0 -1.0 -1.0]
edges2: [-5.0 -5.0 -5.0
		-5.0 40.0 -5.0 
		-5.0 -5.0 -5.0]
		
removal: [-1.0 -1.0 -1.0
		  -1.0 9.0 -1.0 
		 -1.0 -1.0 -1.0]		 
gaussian: [0.0 0.2 0.0
		   0.2 0.2 0.2 
		   0.0 0.2 0.0]		   
cross: [0.0 1.0 -1.0 0.0]
		   
motion: [1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
		0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0
		0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0
		0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0
		0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0
		0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0
		0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0
		0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0
		0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0]


;rimg: make image!  reduce [512x512 black]
rimg: rcvCreateImage 512x512
dst: rcvCreateImage 512x512

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
			win/size/y: rimg/size/y + 70
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
		
		1 	[rcvConvolve rimg dst noFilter 1.0 0.0]	
		2 	[t1: now/time/precise
			rcvConvolve rimg dst emboss1 1.0 128.0
			sb1/data: third now/time/precise - t1
			] 
		3 	[t1: now/time/precise
			rcvConvolve rimg dst emboss2 1.0 128.0
			sb1/data: third now/time/precise - t1
			]
		4 	[t1: now/time/precise
			rcvConvolve rimg dst emboss3 1.0 128.0
			sb1/data: third now/time/precise - t1
			]	
		5 	[t1: now/time/precise
			rcvConvolve rimg dst laplacian 1.0 128.0
			sb1/data: third now/time/precise - t1
			]
		
		6 	[t1: now/time/precise
			rcvConvolve rimg dst embossH 1.0 127.0
			sb1/data: third now/time/precise - t1
			]
		
		7 	[t1: now/time/precise
			rcvConvolve rimg dst embossV 1.0 127.0
			sb1/data: third now/time/precise - t1
			]
		
		8 	[t1: now/time/precise
			rcvConvolve rimg dst sobelH 1.0 127.0
			t2: now/time/precise
			sb1/data: third now/time/precise - t1
			]
		
		9 	[t1: now/time/precise
			rcvConvolve rimg dst sobelV 1.0 127.0
			sb1/data: third now/time/precise - t1
			]
			
		10 	[t1: now/time/precise
			rcvConvolve rimg dst edges1 1.0 0.0
			sb1/data: third now/time/precise - t1
			]	
			
		11 	[t1: now/time/precise
			rcvConvolve rimg dst edges2 1.0 127.0
			sb1/data: third now/time/precise - t1
			]; Edges 2	
		
			
		12 	[t1: now/time/precise
			rcvConvolve rimg dst removal 1.0 0.0
			sb1/data: third now/time/precise - t1
			]; mean removal	
		
		13 	[t1: now/time/precise
			rcvConvolve rimg dst gaussian 1.0 0.0
			sb1/data: third now/time/precise - t1
			]; Gaussian Blur
		
		14 	[t1: now/time/precise
			rcvConvolve rimg dst motion 1.0 / 9.0 0.0
			sb1/data: third now/time/precise - t1
		]; Motion Blur
		
		15 	[t1: now/time/precise
			rcvConvolve rimg dst quickMask 1.0 0.0
			sb1/data: third now/time/precise - t1
		]; Quick Mask
		16 	[t1: now/time/precise
			rcvConvolve rimg dst cross 1.0 0.0
			sb1/data: third now/time/precise - t1
		]
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
		"Edges detection" "Edges detection 2" "Mean removal" "Gaussian blur" 
		"Motion blur (9x9 Kernel)" "Quick Mask" "Cross"
	] select 1 on-change [if isFile [img-convolve face/selected]]
	
	text "Rendered in: " sb1: field 100x24 
	btn "Quit" [quit]
	return
	canvas: base dst
]