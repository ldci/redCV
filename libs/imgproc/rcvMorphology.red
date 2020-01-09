Red [
	Title:   "Red Computer Vision: Morphological Operators"
	Author:  "Francois Jouen"
	File: 	 %rcvMorphology.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;********************* morphological operators routines ******************************

rcvErode: routine [
"Erodes image by using structuring element"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idxD	[int-ptr!]
        kBase 	[red-value!]
		kValue 	[red-value!] 
		k		[red-integer!]
        cols	[integer!]
    	rows	[integer!]
        handle1 [integer!]
        handleD [integer!]
        h 		[integer!]
        w 		[integer!]
        x 		[integer!]
        y 		[integer!]
        i 		[integer!]
        j		[integer!]
        mini	[integer!]
        imx		[integer!] 
        imy 	[integer!]
       	radiusX	[integer!] 
       	radiusY	[integer!]
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    cols: kSize/x
    rows: kSize/y
    idx:  pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		kValue: kBase
        	j: 0 
        	mini: (255 << 24) OR (255 << 16) or (255 << 8) OR 255
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx: (x + i - radiusX + w) % w
        			imy: (y + j - radiusY + h) % h
        			idx: pix1 + (imy * w) + imx
        			k: as red-integer! kValue
        			if k/value = 1 [
        				if idx/value < mini [mini: idx/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
        	pixD/value: mini
       		pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1    
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

rcvDilate: routine [
"Dilates image by using structuring element"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idxD	[int-ptr!]
        kBase	[red-value!] 
		kValue	[red-value!]
		k		[red-integer!]
    	cols	[integer!]
    	rows	[integer!] 
        handle1 [integer!]
        handleD [integer!]
        h 		[integer!]
        w 		[integer!]
        x 		[integer!]
        y 		[integer!]
        i 		[integer!]
        j		[integer!]
        maxi	[integer!]
      	imx 	[integer!]
      	imy 	[integer!]
       	radiusX	[integer!] 
       	radiusY	[integer!]	
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    cols: kSize/x
    rows: kSize/y
	kBase: block/rs-head kernel ; get pointer address of the kernel first value
	radiusX: cols / 2
	radiusY: rows / 2
    y: 0
    while [y < h][
    	x: 0
       	while [x < w][
       		kValue: kBase
        	j: 0 
        	maxi: (255 << 24) OR (0 << 16) or (0 << 8) OR 0
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx: (x + i - radiusX + w) % w
        			imy: (y + j - radiusY + h) % h
        			idx: pix1 + (imy * w) + imx
        			k: as red-integer! kValue
        			if k/value = 1 [
        				if idx/value >= maxi [maxi: idx/value]
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
        	pixD/value: maxi
       		pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]



rcvMMean: routine [
"Means image by using structuring element"
    src  	[image!]
    dst  	[image!]
    kSize	[pair!]
    kernel 	[block!] 
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        idx	 	[int-ptr!]
        idxD	[int-ptr!]
        kBase	[red-value!] 
		kValue	[red-value!]
		k		[red-integer!]		 
        cols	[integer!]
    	rows	[integer!]
        handle1	[integer!] 
        handleD	[integer!] 
        h 		[integer!]
        w 		[integer!]
        x 		[integer!]
        y 		[integer!]
        i		[integer!] 
        j		[integer!]
        r 		[integer!]
        g 		[integer!]
        b		[integer!]
        sumr 	[integer!]
        sumg 	[integer!]
        sumb	[integer!]
        count	[integer!]
        imx 	[integer!]
        imy 	[integer!]
       	radiusX	[integer!] 
       	radiusY	[integer!]
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    idx:  pix1
    idxD: pixD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    kBase: block/rs-head kernel ; get pointer address of the kernel first value
    cols: kSize/x
    rows: kSize/y
	radiusX: cols / 2
	radiusY: rows / 2
    y: 0
    while [y < h][
    	x: 0
       	while [x < w][
       		kValue: kBase
        	count: 0
           	sumr: 0
           	sumg: 0
           	sumb: 0
           	j: 0 
        	; process kernel
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			; OK pixel (-1, -1) will correctly become pixel (w-1, h-1)
        			imx: (x + i - radiusX + w) % w
        			imy: (y + j - radiusY + h) % h
        			idx: pix1 + (imy * w) + imx ; corrected pixel index
        			r: idx/value and FF0000h >> 16 
        			g: idx/value and FF00h >> 8 
       				b: idx/value and FFh 
       				k: as red-integer! kValue 
       				if k/value <> 0 [
       					count: count + 1
        				sumr: sumr + r
        				sumg: sumg + g
        				sumb: sumb + b
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		r: sumr / count
       		g: sumg / count
       		b: sumb / count
       		pixD/value: (255 << 24) OR ( r << 16 ) OR (g << 8) OR b
           	pixD: pixD + 1
           	x: x + 1
       ]
       y: y + 1 
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

rcvCreateStructuringElement: function [
"The function  allocates and fills a block, which can be used as a structuring element in the morphological operations"
	kSize [pair!] 
	/rectangle /cross /vline /hline
][
	element: copy []
	cols: kSize/x
	rows: kSize/y
  	i: 1
  	j: 1
  	case [
  		rectangle [
  			j: 1
  			while [j <= rows] [
  				i: 1
  				while [i <= cols] [
  					append element 1 
  					i: i + 1
  				]
  				j: j + 1
  			]
  		]
  		cross [
  			i: j: 1
  			while [i <= (rows * cols)] [append element 0 i: i + 1]
  			cx: cols / 2 
  			cy: rows / 2 
  			j: 0
  			while [j < rows][
  				i: 0
  				while [i < cols] [
  					idx: (j * cols) + i + 1
  					if (i = cx) [element/(idx): 1]
  					if (j = cy) [element/(idx): 1]
  					i: i + 1
  				]
  				j: j + 1
  			]
  		]
  		vline [
  			i: j: 1
  			while [i <= (rows * cols)] [append element 0 i: i + 1]
  			cx: cols / 2 
  			cy: rows / 2 
  			j: 0
  			while [j < rows][
  				i: 0
  				while [i < cols] [
  					idx: (j * cols) + i + 1
  					if (i = cx) [element/(idx): 1]
  					i: i + 1
  				]
  				j: j + 1
  			]
  		]
  		hline [
  			i: j: 1
  			while [i <= (rows * cols)] [append element 0 i: i + 1]
  			cx: cols / 2 
  			cy: rows / 2 
  			j: 0
  			while [j < rows][
  				i: 0
  				while [i < cols] [
  					idx: (j * cols) + i + 1
  					if (j = cy) [element/(idx): 1]
  					i: i + 1
  				]
  				j: j + 1
  			]
  		]
  	]
  	element
]

; ******************* morphological operators functions **************************
rcvOpen: function [
"Erodes and Dilates image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
] [
	rcvErode src dst kSize kernel 
	rcvCopyImage dst src
	rcvDilate src dst kSize kernel
]


rcvClose: function [
"Dilates and Erodes image by using structuring element"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
] [
	rcvDilate src dst kSize kernel 
	rcvCopyImage dst src
	rcvErode src dst kSize kernel 
]

rcvMGradient: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!] 
	/reverse
][
	img1: rcvCloneImage src
	img2: rcvCloneImage src
	rcvDilate src img1 kSize kernel 
	rcvErode  src img2 kSize kernel 
	either reverse [rcvSub img2 img1 dst] [rcvSub img1 img2 dst]
]

rcvTopHat: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	img1: rcvCloneImage src
	rcvOpen src img1 kSize kernel 
	rcvSub img1 src dst
]

rcvBlackHat: function [
"Performs advanced morphological transformations using erosion and dilatation as basic operations"
	src 	[image!] 
	dst 	[image!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	img1: rcvCloneImage src
	rcvClose src img1 kSize kernel 
	rcvSub src img1 dst
]


; ******************* morphological Operations matrices *************************

; for integer matrices
; we don't need matrix lib here
rcvMorphology: routine [
   	src  	[vector!]
    dst  	[vector!]
    mSize	[pair!]
    cols	[integer!]
    rows	[integer!]
    kernel 	[block!] 
    op		[integer!]
    /local
        svalue 	[byte-ptr!]
        dvalue 	[byte-ptr!]
        idx	 	[byte-ptr!]
        idx2	[byte-ptr!]
        idxD	[byte-ptr!]
        kBase 	[red-value!]	
		kValue  [red-value!]
        s		[series!]
        h 		[integer!]
        w 		[integer!]
        x 		[integer!]
        y 		[integer!]
        i		[integer!] 
        j		[integer!]
        maxi	[integer!]
        k  		[integer!]
        imx 	[integer!]
        imy 	[integer!]
        imx2 	[integer!]
        imy2	[integer!]
       	radiusX	[integer!] 
       	radiusY	[integer!]
		unit	[integer!]
		v		[integer!]
][
    w: mSize/x
    h: mSize/y
    svalue: vector/rs-head src  ; get byte pointer address of the source matrix first value
	dvalue: vector/rs-head dst	; a byte ptr for destination matrix
	kBase:  block/rs-head kernel; get pointer address of the kernel first value
	s: GET_BUFFER(src)			
	unit: GET_UNIT(s)			; get mat bit size
	vector/rs-clear dst 		; clears destination matrix
    idx:  svalue				; address alias
    idx2: svalue				; address alias
    idxD: dvalue				; destination address		
	radiusX: cols / 2
	radiusY: rows / 2
    x: radiusX
    y: radiusY
    while [y < (h - radiusY)][
    	x: 0
    	while [x < (w - radiusX)][
       		idx: svalue + (y * w) + x  
       		kValue: kBase
        	j: 0 
        	switch op [
        		1	[maxi:  0] 	; dilatation
        		2	[maxi: 255]	; erosion
        	 ]
        	; process neightbour
        	while [j < rows][
        		i: 0
        		while [i < cols][
        			imx2: x + i - radiusX
        			imy2: y + j - radiusY
        			idx2: svalue + (imy2 * w) + imx2
        			k: vector/get-value-int as int-ptr! kValue unit
        			;kernel value <> 0
        			if k = 1 [
        				v: vector/get-value-int as int-ptr! idx2 unit
        				switch op [
        					1	[if v > maxi [maxi: v]] ; dilatation
        					2	[if v < maxi [maxi: v]]	; erosion
        	 			]	
        			]
        			kValue: kBase + (j * cols + i + 1)
        			i: i + 1
        		]
        		j: j + 1
        	]
       		dValue: idxD + (y * w) + x
       		vector/rs-append-int dst maxi
           	x: x + 1
       ]
       y: y + 1 
    ]
]

; ******************* morphological Operations**************************
rcvErodeMat: function [
"Erodes matrice by using structuring element"
	src 	[vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	rcvMorphology src dst mSize kSize/x kSize/y kernel 2
]

rcvDilateMat: function [
"Dilates matrice by using structuring element"
	src 	[vector!] 
	dst 	[vector!] 
	mSize 	[pair!] 
	kSize 	[pair!] 
	kernel 	[block!]
][
	rcvMorphology src dst mSize kSize/x kSize/y kernel 1 
]

