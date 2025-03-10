Red [
	Title:   "Test images convolution Red VID "
	Author:  "ldci"
	File: 	 %convolution2.red
	Needs:	 'View
]


fileName: ""
isFile: false

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red


identity: [0.0 0.0 0.0
		  0.0 1.0 0.0 
		  0.0 0.0 0.0]
		  
highPass: [-1.0 0.0 -1.0
		  0.0 8.0 0.0 
		  -1.0 0.0 -1.0]

lowPass: [1.0 1.0 1.0
		  1.0 1.0 1.0 
		  1.0 1.0 1.0]

; same as low pass * 1/9
{lowPass2: [0.111 0.111 0.111
		  0.111 0.111 0.111 
		  0.111 0.111 0.111]}
		  
rimg: rcvCreateImage 512x512
dst: rcvCreateImage 512x512

sumW: 0
factor: 1.0
delta: 0.0
op: 1


loadImage: does [
	sb1/data: ""
	isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: rejoin ["redCV Convolution: " fileName]
		rimg: rcvLoadImage tmp
		dst: rcvLoadImage tmp
		canvas/image: dst
		isFile: true
		op: 1
		dp/selected: 1
	]
]

img-convolve: func [num [integer!]] [
		sb1/text: copy ""
		switch num [
		1 	[rcvConvolve rimg dst identity factor delta]	
		2 	[t1: now/time/precise
			rcvConvolve rimg dst lowPass factor delta
			sb1/text: rejoin [round/to third now/time/precise - t1 0.001 " sec"]
			] 
		3 	[t1: now/time/precise
			rcvConvolve rimg dst highPass factor delta
			sb1/text: rejoin [round/to third now/time/precise - t1 0.001 " sec"]
			]
		]
]

view win: layout [
	title "redCV Convolution"
	origin 10x10 space 10x10
	button "Load" [loadImage]
	dp: drop-down 120x24 data [
		"Identity"  "Low Pass Filter" "High Pass Filter" 
	] select 1 
	
	on-change [op: face/selected if isFile [img-convolve op]]
	
	text "Rendered in: " sb1: field 100x24
	pad 35x0 
	button "Quit" [quit]
	return
	text 40 "Factor" 
	sl1: slider 100 [
		sumW: to-integer face/data * 256
		sumT/text: form sumW 
		either sumW > 0 [factor: 1.0 / sumW] [factor: 1.0]
		ft/data: form factor
		if isFile [img-convolve op] 
	]
	sumT: field 40 "0"
	ft: field  40 "1.0"
	text 40 "Delta" 
	sl2: slider 140  [delta: 0.0 + (face/data * 256.0) 
		dt/data: form delta
		if isFile [img-convolve op] 
	] 
	dt: field 40 "0.0"
	return
	canvas: base 512x512 dst 
	
]