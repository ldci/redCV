
Red[
	needs: view
]

; a mettre dans la lib

_sortPixels: func [bl][sort bl]
_sortReversePixels: func [bl ][sort/reverse bl]

_rcvXSortImage: routine [
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    y: 0
    while [y < h] [
    	x: 0 
    	vector/rs-clear b
    	while [x < w] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		x: x + 1
    	]
    	either flag [#call [_sortReversePixels b]] 
    				[#call [_sortPixels b]]
    	ptr: as int-ptr! vBase
    	x: 0
		while [x < w] [
			idx: pixD + (y * w) + x
			n: x + 1			; ptr/0 returns vector size
			idx/value: ptr/n
			x: x + 1
		]
    	y: y + 1
    ]
]


_rcvYSortImage: routine [
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    x: 0
    while [x < w] [
    	y: 0 
    	vector/rs-clear b
    	while [y < h] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		y: y + 1
    	]
    	either flag [#call [_sortReversePixels b]] 
    				[#call [_sortPixels b]]
    	ptr: as int-ptr! vBase
    	y: 0
		while [y < h] [
			idx: pixD + (y * w) + x
			n: y + 1		; ptr/0 returns vector size
			idx/value: ptr/n 
			y: y + 1
		]
    	x: x + 1
    ]
]

rcvXSortImage: function [src [image!] dst[image!] flag [logic!]
"image sorting by line"
][
	b: make vector! src/size/x
	_rcvXSortImage src dst b flag
]

rcvYSortImage: function [src [image!] dst[image!] flag [logic!]
"image sorting by line"
][
	b: make vector! src/size/y
	_rcvYSortImage src dst b flag
]

isFile: false
size: 400x400
reverse: false
flag: 1

loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		img1: load tmp
		img2: make image! reduce [img1/size black]
		canvas1/image: img1
		canvas2/image: img2
		isFile: true
		process
	]
]

process: does [
	if isFile [
		if flag = 1 [rcvXSortImage img1 img2 reverse]
		if flag = 2 [rcvYSortImage img1 img2 reverse]
		canvas2/image: img2
	]
]


view win: layout [
	title "Sorting Images"
	button "Load" [loadImage]
	r1: radio "Lines" true [flag: 1 process]
	r2: radio "Columns" [flag: 2 process]
	cb: check "Reverse" [reverse: face/data process]
	pad 400x0
	button "Quit" [quit]
	return
	canvas1: base size black
	canvas2: base size black
	return
	
]