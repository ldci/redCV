#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Gabor Filter"
	Author:  "Francois Jouen"
	File: 	 %rcvGabor.red
	Tabs:	 4
	Rights:  "Copyright (C) 2022 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
;--in rcvTools.red
_rcvExp: routine [
"returns exponential value"
	value	[float!]
	return: [float!]
][
	;--use Euler's number e
	pow 2.718281828459045235360287471 value
]

;--requires grayscale images

rcvGaborFilter: routine [
"Generates 2-D Gabor filter"
	src 		[image!]
	dst 		[image!]
	angle		[float!]
	frequency	[float!]
	sigma		[float!]
	/local
		pixS pixD			[int-ptr!]
		handleS handleD 	[integer!]
		h w x y 			[integer!]
		dx dy distance		[float!]
		fx fy z f gv		[float!]
		cosPart gaussPart	[float!]
][
	handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	x: 0
    	while [x < w][
    		dx: as float! x
    		dy: as float! y
    		distance: sqrt ((dx * dx) + (dy * dy))
    		fx: cos angle * frequency
    		fy: sin angle * frequency
    		cosPart: cos ((dx * fx) + (dy * fy))
    		gv: 0.0 - (distance * distance)
    		gv: gv / (2.0 * sigma * sigma)
    		gaussPart: _rcvExp gv
    		z: cosPart * gaussPart
    		print [y " " x " " gv " " gaussPart lf]
    		f: as float! pixS/value
    		f: f + z
    		pixd/value: as integer! f
    		pixS: pixS + 1
        	pixD: pixD + 1
    		x: x + 1
    	]
    	y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


;-- test

src: load %lenags512.jpg
dst: make image! reduce [src/size black]

win: layout [
	title "Gabor Test"
	button "Filter" [rcvGaborFilter src dst 0.45 1.0 1.0 img2/image: dst]
	button "Quit" [Quit]
	return
	img1: base 512x512 src
	img2: base 512x512 black
]
view win

;

