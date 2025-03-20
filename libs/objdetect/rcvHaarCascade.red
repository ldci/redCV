Red [
	Title:   "Red Computer Vision: Haar Casacade"
	Author:  "ldci"
	File: 	 %rcvHaarCascade.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
;--version 2
;--stump-based and tree-based cascades are supported
;--tilted Haar features are now supported
;--part of code based on C code developed by Francesco Comaschi: 
;--http://www.es.ele.tue.nl/video/

#system-global [
	#include %structures/hStructs.reds	;--Red/System structures
	cascade: 	declare rcvCascade!		;--classifier cascade
	equRect: 	declare rcvRect!		;--rectangle
	tr:			declare rcvRect!		;--rectangle
	ssum:		declare rcvIntImage!	;--summed-area table
	sqsum: 		declare rcvIntImage!	;--square summed-area table
	stsum: 		declare rcvIntImage!	;--tilted summed-area table
	winSize0: 	declare rcvSize!		;--window size of the training set
	winSize:	declare rcvSize!		;--size of the image scaled up or down	
	sarray:		declare int-ptr! 		;--stagesArray
	rarray:		declare int-ptr!		;--rectanglesArray
	srarray: 	declare int-ptr!		;--scaledRectanglesArray
	oarray:		declare int-ptr!		;--tiltedArray
	warray:		declare float-ptr!		;--weightsArray
	a1array:	declare float-ptr!		;--alpha1Array left values
	a2array:	declare float-ptr!		;--alpha2Array right values
	n1array:	declare float-ptr!		;--nodes left value
	n2array:	declare float-ptr!		;--nodes right values
	l1array:	declare int-ptr!		;--nodes has left nodes?
	l2array:	declare int-ptr!		;--nodes has right nodes ?
	tarray:		declare float-ptr!		;--treeThreshArray
	starray: 	declare float-ptr!		;--stagesThreshArray	
	unSigned: 	pow 2.0 32.0			;--for c-like uint conversion
]
		

#include %rcvHaarRectangles.red			;--for rectangles clustering

;--we need a lot of arrays with different size	
;--do not predefine size, since we use append later for filling arrays
													;--Size of array
stagesArray: 			make vector! [] 			;--nStages
rectanglesArray: 		make vector! [] 			;--totalNodes * 12
scaledRectanglesArray: 	make vector! []				;--totalNodes * 12
tiltedArray: 			make vector! []				;--totalNodes
logic1Array:  			make vector! []				;--totalNodes 
logic2Array: 			make vector! []				;--totalNodes
weightsArray:  			make vector! [float! 64 0]	;--totalNodes * 3 
alpha1Array:  			make vector! [float! 64 0]	;--totalNodes 
alpha2Array: 			make vector! [float! 64 0]	;--totalNodes
node1Array:  			make vector! [float! 64 0]	;--totalNodes 
node2Array: 			make vector! [float! 64 0]	;--totalNodes
leftArray:				make vector! [float! 64 0]	;--totalNodes
rightArray: 			make vector! [float! 64 0]	;--totalNodes
treeThreshArray: 		make vector! [float! 64 0]	;--totalNodes
stagesThreshArray: 		make vector! [float! 64 0]	;--nStages


allCandidates: 			make vector! [] 			;--for identified candidates 
groupEPS: 				0.4							;--for rectangles classification
isTilted: 				0							;--tilted Haar feature?
									

;*************************************************************************************
;--create int pointers that give access to Red arrays by routines
 
rcvCreateArrayPointers: routine [
"Create integer or float pointers that give access to Red arrays by routines"
][ 
	sarray:	 as int-ptr! vector/rs-head as red-vector!   #get 'stagesArray		
	rarray:	 as int-ptr! vector/rs-head as red-vector!   #get 'rectanglesArray	
	srarray: as int-ptr! vector/rs-head as red-vector!   #get 'scaledRectanglesArray
	oarray:  as int-ptr! vector/rs-head as red-vector!   #get 'tiltedArray
	l1array: as int-ptr! vector/rs-head as red-vector!   #get 'logic1Array 
	l2array: as int-ptr! vector/rs-head as red-vector!   #get 'logic2Array 
	warray:  as float-ptr! vector/rs-head as red-vector! #get 'weightsArray	
	a1array: as float-ptr! vector/rs-head as red-vector! #get 'alpha1Array	
	a2array: as float-ptr! vector/rs-head as red-vector! #get 'alpha2Array 
	n1array: as float-ptr! vector/rs-head as red-vector! #get 'node1Array 
	n2array: as float-ptr! vector/rs-head as red-vector! #get 'node2Array 
	tarray:  as float-ptr! vector/rs-head as red-vector! #get 'treeThreshArray	
	starray: as float-ptr! vector/rs-head as red-vector! #get 'stagesThreshArray
]

;*************************************************************************************
;-- rcvReadTextClassifier function
;-- all information is in classifierFile.txt
;-- [Header] Section
;-- how many stages are in the cascaded filter?
;-- the second line of classifierFile is the number of stages
;-- how many filters in each stage? 
;-- They are specified in classifierFile,starting from third line
;--Filters  are defined in [Nodes] section
;--First line: window training size
;--then each stage of the cascaded filter has:
;-- 23 parameters per filter
;--+ 1 threshold parameter per stage
;--The 23 parameters for each filter are:
;--1 to 4: coordinates of rectangle 1
;--5: weight of rectangle 1
;--6 to 9: coordinates of rectangle 2
;--10: weight of rectangle 2
;--11 to 14: coordinates of rectangle 3 (default 0)
;--15: weight of rectangle 3 (default 0.0)
;--16: tilted flag
;--17: threshold of the filter
;--18: alpha 1 of the filter ; node left value
;--19: alpha 2 of the filter ; node right value
;--20: has left node?	
;--21: left node value; 0, 1 or 2
;--22: has right node?
;--23: right node value; 0, 1 or 2

;**************************************************************************************
rcvReadTextClassifier: func [
{Process classifier file and return number of stages, total number of nodes 
and original win size}
	f			[file!]
	nParameters	[integer!] ;--default 23
	return: 	[block!]
][
	;--clear arrays for each reading!
	clear stagesArray
	clear rectanglesArray
	clear scaledRectanglesArray
	clear weightsArray
	clear treeThreshArray
	clear alpha1Array
	clear alpha2Array
	clear node1Array
	clear node2Array
	clear logic1Array
	clear logic2Array
	clear stagesThreshArray
	clear tiltedArray
	isTilted: 0
	
	blk: read/lines f
	; header section ligne 1
	;probe blk/1
	line: 2
	nStages: to-integer blk/2 ;blk/:line
	line: 3
	totalNodes: 0
	until [
		v: to-integer blk/:line
		append stagesArray v
		totalNodes: totalNodes + v
		line: line + 1
		blk/:line = "[Nodes]"
	]
	; Nodes section
	;print blk/:line
	line: line + 1					;--window training size
	ws0: to-pair (trim blk/:line)
	;--first part is OK	
	line: line + 1
	i: 1
	while [i <= nStages] [
		nFilters: stagesArray/:i
		j: 1
		;loop over n of tree of filters
		while [j <= nFilters][
			k: 1 
			;loop filter parameters
			while [k <= nParameters][
				;--for unset value
				if error? try [vf: to float! blk/:line] [vf: 0.0]
				v: to-integer vf
				;--rectangles 1 2 3
				if any [
					k = 1 k = 2 k = 3 k = 4 
					k = 6 k = 7 k = 8 k = 9 
					k = 11 k = 12 k = 13 k = 14
				] [append rectanglesArray v append scaledRectanglesArray 0] 
				;--weight rectangles 1 2 3			
				if any [k = 5 k = 10 k = 15] [append weightsArray vf]
				;--tilted not used for frontal faces
				case [
					k = 16 [append tiltedArray v isTilted: isTilted + v]	
					k = 17 [append treeThreshArray vf]	;--threshold of the filter
					k = 18 [append alpha1Array vf]		;--left value of the filter 
					k = 19 [append alpha2Array vf]		;--right value of the filter
					k = 20 [append logic1Array v]		;--left has node?
					k = 21 [append node1Array vf]		;--left node value
					k = 22 [append logic2Array v]		;--right has node?
					k = 23 [append node2Array vf]		;--right node value
				]
				line: line + 1
				k: k + 1
			]
			j: j + 1
		]
		vf: to-float blk/:line
		append stagesThreshArray vf 	;--stage threshold
		line: line + 1
		i: i + 1
	]
	rcvCreateArrayPointers				;--for #system access	
	reduce [nStages totalNodes ws0]		; return values as a block
]

;***************************************************************************************
;--create Haar cascade structure
;--return: structure address as an integer

rcvCreateHaarCascade: routine [
"Create Haar cascade structure"
	nStages		[integer!]
	nNodes		[integer!]
	scale		[float!]
	wSize		[pair!]
	return: 	[integer!]
][
	;--default cascade properties
	cascade/nStages: 			nStages
	cascade/totalNodes: 		nNodes
	cascade/scale: 				scale
	cascade/origWindowSize/x: 	wSize/x
	cascade/origWindowSize/y: 	wSize/y
	cascade/invWindowArea: 		0
	cascade/sumImg: 			null;--summed-area table
	cascade/sqSumImg: 			null;--square summed-area table
	cascade/stSumImg:			null;--tilted summed-area table
	cascade/*pq0: 				null
	cascade/*pq1: 				null
	cascade/*pq2: 				null
	cascade/*pq3: 				null
	cascade/*p0:  				null
	cascade/*p1:  				null
	cascade/*p2:  				null
	cascade/*p3:  				null
	cascade/*pt0:  				null
	cascade/*pt1:  				null
	cascade/*pt2:  				null
	cascade/*pt3:  				null
	as integer! cascade 			;--address of the cascade
]


;**************************************************************************************
;--This routine downsample an image using nearest neighbor
;--It is used to build the image pyramid
rcvNearestNeighbor: routine [
"Downsample an image using nearest neighbor"
	src		[image!]
	dst		[image!]
	/local
	idxS idxD pixS pixD		[int-ptr!]
	handleS	handleD			[integer!]
	w1 h1 w2 h2	 x2 y2 i j	[integer!] 
	xRatio yRatio			[integer!]
][
	handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
	w1: IMAGE_WIDTH(src/size)
	h1: IMAGE_HEIGHT(src/size)
	w2: IMAGE_WIDTH(dst/size)
	h2: IMAGE_HEIGHT(dst/size)
	xRatio: ((w1 << 16) / w2) + 1
	yRatio: ((h1 << 16) / h2) + 1
	i: 0
	while [i < h2] [
		j: 0
		while [j < w2] [
			x2: ((j * xRatio) >> 16) 
            y2: ((i * yRatio) >> 16)
            ;print-line x2
            ;print-line y2
            idxS: pixS + (y2 * w1) + x2
            idxD: pixD + (i * w2) + j 
            idxD/value: idxS/value
			j: j + 1
		]
		i: i + 1
	]
	image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]

;**************************************************************************************
;--Similar to rcvIntegralImg in redCV lib rcvIntegral.red
;--source image is automatically converted to grayscale image
;--we use fixed-point gray-scale transform, close to openCV transform

rcvHaarIntegralImage1: routine [
"Compute summed-area table and square summed-area table"
    src  			[image!]
    dst1  			[vector!]
    dst2 			[vector!]
    /local
        pix1 p4						[int-ptr!]
        pixD1 pixD2 idxD1 idxD2		[byte-ptr!]
        s							[series!]
        handle1 unit h w x y r g b	[integer!]
        pIndexD	ssum sqsum t tq rgb	[integer!] 
][
    handle1: 0
    pix1:  image/acquire-buffer src :handle1 	;--image
    pixD1: vector/rs-head dst1					;--summed-area table			
    pixD2: vector/rs-head dst2					;--square summed-area table
    idxD1: pixD1
    idxD2: pixD2
    pIndexD: 0
    s: GET_BUFFER(dst1)
	unit: GET_UNIT(s)
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    y: 0
    while [y < h] [
    	ssum: 0
    	sqsum: 0
    	x: 0
    	;--loop over the number of columns
    	;--process first row
       	while [x < w][
       		pIndexD: ((y * w) + x) * unit 
       		; grayscale luminance
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh      
        	rgb: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
       		;--sum of the current row
       		ssum: ssum + rgb
       		sqsum: sqsum + (rgb * rgb)
       		t: ssum
       		tq: sqsum
       		;--process other rows
       		if y > 0 [
       			pIndexD: (((y - 1) * w) + x) * unit
       			;--summed-area table
				pixD1: idxD1 + pIndexD 
				t: t + vector/get-value-int as int-ptr! pixD1 unit
       			;--square summed-area table
       			pixD2: idxD2 + pIndexD 
       			tq: tq + vector/get-value-int as int-ptr! pixD2 unit
			]
			;--update values
        	pIndexD: ((y * w) + x) * unit
        	;--summed-area table
        	pixD1: idxD1 + pIndexD 
        	p4: as int-ptr! pixD1
     		p4/value: switch unit [
				1 [t and FFh or (p4/value and FFFFFF00h)]
				2 [t and FFFFh or (p4/value and FFFF0000h)]
				4 [t]
			]
			;--square summed-area table
			pixD2: idxD2 + pIndexD 
        	p4: as int-ptr! pixD2
     		p4/value: switch unit [
				1 [tq and FFh or (p4/value and FFFFFF00h)]
				2 [tq and FFFFh or (p4/value and FFFF0000h)]
				4 [tq]
			]
        	pix1: pix1 + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src handle1 no
]

;--Similar to rcvIntegralImg in redCV lib rcvIntegral.red
;--source image is automatically converted to grayscale image
;--we use fixed-point gray-scale transform, close to openCV transform
;--but we calculate 3 integral images from Lienhart et al. 
;--extension using tilted features 

rcvHaarIntegralImage2: routine [
"Compute summed-area table, square summed-area table and rotated summed-area table"
    src  			[image!]
    dst0			[vector!]
    dst1  			[vector!]
    dst2 			[vector!]
    dst3			[vector!]
    /local
        pix1 pixD0 pixD1 pixD2 pixD3		[int-ptr!]
        handle1 h w y ssum sqsum r g b rgb 	[integer!]
        idx1 idx2 idx3 idx4 val1 val2 j k l	[integer!]
][
    handle1: 0
    pix1:   image/acquire-buffer src :handle1 	;--source image
    pixD0:  as int-ptr!  vector/rs-head dst0	;--grayscale image matrix	
    pixD1:  as int-ptr!  vector/rs-head dst1	;--summed-area table			
    pixD2:  as int-ptr!  vector/rs-head dst2	;--square summed-area table
    pixD3:  as int-ptr!  vector/rs-head dst3	;--tilted summed-area table
    w: IMAGE_WIDTH(src/size)					;--image width
    h: IMAGE_HEIGHT(src/size)					;--image height
    l: w * h									;--image length
    ;--process first row
    ssum: 0
    sqsum: 0
    j: 0 
    while [j < w][
    	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh      
        rgb: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
    	ssum: ssum + rgb
       	sqsum: sqsum + (rgb * rgb)
       	pixD0/j: rgb		;--grayscale matrix
       	pixD1/j: ssum		;--summed-area table
       	pixD2/j: sqsum		;--square summed-area table
       	pixD3/j: rgb		;--tilted summed-area table
    	pix1: pix1 + 1		;--next pixel
    	j: j + 1
    ]
    ;-- process other rows
    ssum: 0
    sqsum: 0
    k: 0 
    y: 1
    while [j < l][
    	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh      
        rgb: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
        ssum: ssum + rgb
       	sqsum: sqsum + (rgb * rgb)
       	;--we need a double pass for tilted integral
       	idx1: j - w
       	idx2: j - w - w 
       	idx3: j + 1 - w
       	idx4: j - 1 - w
       	either y > 1 [val1: pixD3/idx2] [val1: 0] ; y always > 1
       	either k > 0 [val2: pixD3/idx4] [val2: 0]
       	pixD0/j: rgb
       	pixD1/j: pixD1/idx1 + ssum
       	pixD2/j: pixD2/idx1 + sqsum
       	pixD3/j: pixD3/idx3 + rgb + pixD0/idx1 + val1 + val2 
       	k: k + 1
       	j: j + 1
       	if k >= w [k: 0 y: y + 1 ssum: 0 sqsum: 0]
       	pix1: pix1 + 1
    ]
    image/release-buffer src handle1 no
]

rcvCannyFilter: routine [
"Canny filtering for faster object detection"
	src		[image!]
	dst		[image!]
	gray	[vector!]
	lowPass	[vector!]
	canny	[vector!]
	/local
	pixS pixD ptrG ptrLP ptrC		[int-ptr!]
	w h i j k sum sum2 gradX gradY	[integer!]
	ind0 ind1 ind2 ind_1 ind_2		[integer!]
	handleS handleD 				[integer!]
	count a r g b rgb 				[integer!]
][
	handleS: 0
	handleD: 0
    pixS:   image/acquire-buffer src :handleS 	;--source image
    pixD:   image/acquire-buffer dst :handleD 	;--destination image
    
    w: IMAGE_WIDTH(src/size)					;--image width
    h: IMAGE_HEIGHT(src/size)					;--image height
	count: w * h								;--image size
	ptrG: 	as int-ptr! vector/rs-head gray		;--grayscale matrix
	ptrLP:  as int-ptr! vector/rs-head lowPass	;--Gaussian low pass matrix
	ptrC: 	as int-ptr! vector/rs-head canny	;--Canny matrix
	
	;--grayscale matrix OK
	i: 0 
	while [i < count][
		a: pixS/value >>> 24
		r: pixS/value and FF0000h >> 16 
        g: pixS/value and FF00h >> 8 
        b: pixS/value and FFh 
        rgb: ((4899 * r) + (9617 * g) + (1868 * b) + 8192) >>> 14 and FFh
        ;--this is what matlab uses but fails with Red
        ;rgb:  ((0.2989 * r) + (0.587 * g)  + (0.114 * b)) >> 0	
        ;rgb: (r + g + b) / 3	;simple way 
        ptrG/i: rgb
        i: i + 1
        pixS: pixS + 1
	]
	
	;--gaussian lowpass filtering OK
	i: 2
	while [i < (w - 2)][
		sum: 0
		j: 2 
		k: w << 1
		while [j < (h - 2)][
			ind0:  i + k
            ind1:  ind0 + w
            ind2:  ind1 + w 
            ind_1: ind0 - w
            ind_2: ind_1 - w
            ;--use as simple fixed-point arithmetic as possible (only addition/subtraction and binary shifts)
            sum: (0 
            + (ptrG/ind_2 - 2 << 1) + (ptrG/ind_1 - 2 << 2) + (ptrG/ind0 - 2 << 2) + (ptrG/ind0 - 2) 
            + (ptrG/ind1 - 2 << 2) + (ptrG/ind2 - 2 << 1) + (ptrG/ind_2 - 1 << 2) + (ptrG/ind_1 - 1 << 3)
 			+ (ptrG/ind_1 - 1) + (ptrG/ind0 - 1 << 4) - (ptrG/ind0 - 1 << 2) + (ptrG/ind1 - 1 << 3)
 			+ (ptrG/ind1 - 1) + (ptrG/ind2 - 1 << 2) + (ptrG/ind_2 << 2) + (ptrG/ind_2) + (ptrG/ind_1 << 4)
			- (ptrG/ind_1 << 2) + (ptrG/ind0 << 4) - (ptrG/ind0)  +  (ptrG/ind1 << 4) - (ptrG/ind1 << 2)
 			+ (ptrG/ind2 << 2)  +  (ptrG/ind2) + (ptrG/ind_2 + 1 << 2) + (ptrG/ind_1 + 1 << 3) + (ptrG/ind_1 + 1)
 			+ (ptrG/ind0 + 1 << 4) - (ptrG/ind0 + 1 << 2) + (ptrG/ind1 + 1 << 3) + (ptrG/ind1 + 1) + (ptrG/ind2 + 1 << 2)
 			+ (ptrG/ind_2 + 2 << 1) + (ptrG/ind_1 + 2 << 2) + (ptrG/ind0 + 2 << 2) + (ptrG/ind0 + 2)
 			+ (ptrG/ind1 + 2 << 2) + (ptrG/ind2 + 2 << 1)
 			)
            ptrLP/ind0: ((((103 * sum + 8192) and FFFFFFFFh) >>> 14) and FFh) >>> 0
			k: k + w
			j: j + 1
		]
		i: i + 1
	]
	;--sobel gradient edge detection OK
	i: 1
	while [i < (w - 1)][
		j: 1
		k: w
		while [j < (h - 1)][
			;--compute coords using simple add/subtract arithmetic (faster)
            ind0:  k + i
            ind1:  ind0 + w
            ind_1: ind0 - w 
            gradX: (0 
            - (ptrLP/ind_1 - 1) 
			+ (ptrLP/ind_1 + 1) 
			- (ptrLP/ind0 - 1) - (ptrLP/ind0 - 1)
			+ (ptrLP/ind0 + 1) + (ptrLP/ind0 + 1)
			- (ptrLP/ind1 - 1)
			+ (ptrLP/ind1 + 1)
			)
			gradY: (0
			+ ptrLP/ind_1 - 1 
			+ ptrLP/ind_1 + ptrLP/ind_1
			+ ptrLP/ind_1 + 1 
			- ptrLP/ind1 - 1 
			- ptrLP/ind1 - ptrLP/ind1
			- ptrLP/ind1 + 1
			)
			;--absolute values
			if gradX < 0 [gradX: 0 - gradX]
			if gradY < 0 [gradY: 0 - gradY]
			ptrC/ind0: gradX + gradY
			k: k + w
			j: j + 1
		]
		i: i + 1
	]
	;--make Canny image OK
	i: 0
	while [i < count][
		pixD/value: (255 << 24) OR (ptrC/i << 16 ) OR (ptrC/i << 8) OR ptrC/i
		pixD: pixD + 1
		i: i + 1
	]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


;**************************************************************************************
;--this function loads the four corners,
;--but does not do computation based on 4 corners
;--rectangles values are used to make scaled rectangles 
;--from integral image values
;--computation is done next in ScaleImageInvoker routine

rcvSetImageForCascadeClassifier: routine [
"Set images for haar classifier cascade"
	/local
	rIndex	[integer!]
	wIndex	[integer!]
	i		[integer!]		
	j		[integer!]
	k		[integer!]
	nr		[integer!]
	idx		[integer!]
	idx2	[integer!]
	ptr		[int-ptr!]
	count	[integer!]
][
	equRect/x: 				0
	equRect/y: 				0
	equRect/width:  		cascade/origWindowSize/x		
 	equRect/height: 		cascade/origWindowSize/y		
 	cascade/invWindowArea: 	equRect/width * equRect/height	
 	cascade/sumImg: 		ssum							
	cascade/sqSumImg: 		sqsum	
	cascade/stSumImg:		stsum					
	;--update cascade pointer addresses for corners
	cascade/*p0: ssum/data 
	cascade/*p1: ssum/data + (equRect/width - 1)
  	cascade/*p2: ssum/data + (ssum/width * (equRect/height - 1))
  	cascade/*p3: ssum/data + (ssum/width * (equRect/height - 1) + equRect/width - 1)
  	
  	cascade/*pq0: sqsum/data 
	cascade/*pq1: sqsum/data + equRect/width - 1
  	cascade/*pq2: sqsum/data + (sqsum/width * (equRect/height - 1))
  	cascade/*pq3: sqsum/data + (sqsum/width * (equRect/height - 1) + equRect/width - 1)
  	
  	cascade/*pt0: stsum/data 
	cascade/*pt1: stsum/data + equRect/width - 1
  	cascade/*pt2: stsum/data + (stsum/width * (equRect/height - 1))
  	cascade/*pt3: stsum/data + (stsum/width * (equRect/height - 1) + equRect/width - 1)
  	
  	;--Load the index of the 4 corners of the feature
	rIndex: 1 ;--rectangles index
	wIndex: 1 ;--weight index
	;--loop over the number of stages
	count: 1
	i: 1
	while [i <= cascade/nStages][
		j: 1
		;--loop over the number of filters
		while [j <= sarray/i][
			nr: 3 ;--(3 rectangles max by feature)
			;--loop over the number of rectangles features
 			k: 0 
 			while [k < nr] [
 				idx: rIndex + (k * 4)	tr/x: rarray/idx
 				idx: idx + 1  			tr/y: rarray/idx
 				idx: idx + 1  			tr/width: rarray/idx
 				idx: idx + 1   			tr/height: rarray/idx
 				
 				;--Attention! srarray:  pointer address as integer!
 				;--ptr: as int-ptr! (srarray/idx)
 				;--print [ ptr/value lf]
 				
 				;--now update scaled rectangles array
 				;--4 corners: x y width height values
 				;--use tilted or not tilted rectangles
 				if k < 2 [
 					idx: rIndex + (k * 4)
 					idx2: ssum/width  * tr/y + tr/x
 					either oarray/count = 0 [srarray/idx: as integer! ssum/data + idx2]
 						[srarray/idx: as integer! stsum/data + idx2]
 				
 					idx: idx + 1
 					idx2: ssum/width  * tr/y  + tr/x + tr/width
 					either oarray/count = 0 [srarray/idx: as integer! ssum/data + idx2]
 						[srarray/idx: as integer! stsum/data + idx2]
 				
 					idx: idx + 1
 					idx2: ssum/width * (tr/y + tr/height) + tr/x
 					either oarray/count = 0 [srarray/idx: as integer! ssum/data + idx2]
 						[srarray/idx: as integer! stsum/data + idx2]
 					idx: idx + 1
 					idx2: ssum/width * (tr/y + tr/height) + tr/x + tr/width 
 					either  oarray/count = 0 [srarray/idx: as integer! ssum/data + idx2]
 						[srarray/idx: as integer! stsum/data + idx2]
 				] 
 				;--in most cases third rectangle is unset
 				if k >= 2 [
 				 	either all [tr/x = 0 tr/y = 0 tr/width = 0 tr/height = 0][
 						idx: rIndex + (k * 4) 
 						srarray/idx: 0				;--null pointer
 						idx: idx + 1
 						srarray/idx: 0				;--null pointer
 						idx: idx + 1
 						srarray/idx: 0				;--null pointer
 						idx: idx + 1
 						srarray/idx: 0				;--null pointer
 					][ 
 						idx: rIndex + (k * 4)
 						idx2: ssum/width  * tr/y + tr/x
 						either oarray/count = 0 [
 							srarray/idx: as integer! ssum/data + idx2]
 							[srarray/idx: as integer! stsum/data + idx2]
 						
 						idx: idx + 1
 						idx2: ssum/width  * tr/y  + tr/x + tr/width
 						either oarray/count = 0 [
 							srarray/idx: as integer! ssum/data + idx2] 
 							[srarray/idx: as integer! stsum/data + idx2] 
 						
 						idx: idx + 1
 						idx2: ssum/width * (tr/y + tr/height) + tr/x
 						either oarray/count = 0 [
 							srarray/idx: as integer! ssum/data + idx2]
 							[srarray/idx: as integer! stsum/data + idx2]
 						
 						idx: idx + 1
 						idx2: ssum/width * (tr/y + tr/height) + tr/x + tr/width 
 						either oarray/count = 0 [
 							srarray/idx: as integer! ssum/data + idx2]
 							[srarray/idx: as integer! stsum/data + idx2]
 					]
 				]; end k < 2
 				k: k + 1
 			]; end k loop
 			rIndex: rIndex + 12 ; next rectangles in rectangle array
 			wIndex: wIndex + 3	; next weight in weight array
 			count: count + 1
			j: j + 1
		]
		i: i + 1
	]
]

;**************************************************************************************
;--evalWeakClassifier: the actual computation of any haar filter.

rcvEvalWeakClassifier: routine [
"Compute each weak classifier value"
	variance			[float!]
	pOffset				[integer!]
	treeIndex			[integer!]
	wIndex				[integer!]
	rIndex				[integer!]
	return:				[float!]
	/local
	ptr	overflow				[int-ptr!]
	sigma weight t				[float!]
	idx a b c d	area			[integer!]
	hasLeft? hasRight?			[integer!]
	leftNode rightNode v1 v2	[float!]
][
	;--the node threshold is multiplied by the standard deviation of the image
	t: tarray/treeIndex * variance  
	
	;--for pointer error in large images
	overflow: ssum/data + (ssum/width * ssum/height)
	; srarray: array of addresses!!
	
	; compute rectangles sigma from integral image values
	;first rectangle
	idx: rIndex + 0 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
	idx: rIndex + 1 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
	idx: rIndex + 2 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
	idx: rIndex + 3 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
	weight: warray/wIndex
	area: a - b - c + d
	sigma: weight * as float! (area)
	
	; second rectangle
	idx: rIndex + 4 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
	idx: rIndex + 5 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
	idx: rIndex + 6 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
	idx: rIndex + 7 ptr: as int-ptr! srarray/idx
	ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
	wIndex: wIndex + 1
	weight: warray/wIndex
	area: a - b - c + d
	sigma: sigma + (weight * as float! (area))
	
	;third rectangle 
	idx: rIndex + 8
	ptr: as int-ptr! (srarray/idx)
	if (as integer! ptr) > 0 [
		idx: rIndex + 8  ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
		idx: rIndex + 9  ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
		idx: rIndex + 10 ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
		idx: rIndex + 11 ptr: as int-ptr! srarray/idx 
		ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
		wIndex: wIndex + 1
		weight: warray/wIndex
		area: a - b - c + d
		sigma: sigma + (weight * as float! (area))
	]
	
	;--go to left or  right according node threshold value
	;--and return weak classifier value according to the decision about sigma
	
	either sigma < t [
		v1: 		a1array/treeIndex 
		hasLeft?: 	l1array/treeIndex
		leftNode: 	n1array/treeIndex
		if hasLeft? > 0 [
			;--node has leaves (2 max) -> go to the next left node
			until [			
				idx: treeIndex + (as integer! leftNode)	
				v1: a1array/idx 
				leftNode: n1array/idx
				hasLeft?: l1array/idx
				hasleft? = 0 
			]
		]
		;--no leaves return left value
		return v1 	
	][  
		v2: 		a2array/treeIndex
		hasRight?:	l2array/treeIndex 
		rightNode: 	n2array/treeIndex
		if hasRight? > 0 [
			;--node has leaves (2 max) -> go to the next right node
			until [
				idx: treeIndex + (as integer! rightNode)
				v2: a2array/idx
				rightNode: 	n2array/idx
				hasRight?:	l2array/idx
				hasRight? = 0 
			]
		]
		;--no leaves return right value	
		return v2	
	]
	;--we need a default value, but in all cases v1 or v2 are returned 
	0.0
]

rcvRunCascadeClassifier: routine [
"Execute classifier cascade"
	pt				[pair!]
	startStage		[integer!]
	threshold		[float!]
	return:			[integer!]	
	/local
	idx				[int-ptr!]	
	haarCounter		[integer!]
	wIndex			[integer!]
	rIndex			[integer!]
 	pOffset			[integer!]
 	pqOffset		[integer!]
  	stageSum		[float!]
  	r1				[integer!]
  	r2				[integer!]
  	r3				[integer!]
  	r4				[integer!]
  	i				[integer!]
  	j				[integer!]	
  	variance		[float!]
  	mean			[integer!]
	testv			[float!]	
	weak			[float!]
	v				[integer!]
][
	haarCounter: 	1
  	wIndex: 		1
 	rIndex: 		1
	pOffset: 		(pt/y * cascade/sumImg/width) + pt/x	
  	pqOffset: 		(pt/y * cascade/sqSumImg/width) + pt/x 	
	
  	idx: cascade/*pq0 + pqOffset r1: idx/value
  	idx: cascade/*pq1 + pqOffset r2: idx/value
 	idx: cascade/*pq2 + pqOffset r3: idx/value
 	idx: cascade/*pq3 + pqOffset r4: idx/value
 	v: r1 - r2 - r3 + r4 

 	idx: cascade/*p0 + pqOffset r1: idx/value
  	idx: cascade/*p1 + pqOffset r2: idx/value
 	idx: cascade/*p2 + pqOffset r3: idx/value
 	idx: cascade/*p3 + pqOffset r4: idx/value
 	mean:  (r1 - r2 - r3 + r4) 
 	
 	v: v * cascade/invWindowArea
  	v: v - (mean * mean)

  	;unsigned int automatic casting in c/c++ 
	; we have to cast as an unsigned integer!
  	either v > 0 [variance: sqrt as float! v][
  		variance: (as float! v) + unSigned
  		variance: sqrt variance
  	]
  	if v < 0 [variance: 1.0]; not really necessary since we use unSigned integers
  	
  	;--process each stage 
  	i: startStage ;
  	
  	while [i <= cascade/nStages]  [
  		;--sarray/i: number of filters by stage
  		;--process each filter of the current stage
  		j: 0
  		stageSum: 0.0 
  		while [j < sarray/i][
  			weak: rcvEvalWeakClassifier variance pOffset haarCounter wIndex rIndex
  			stageSum: stageSum + weak
  			haarCounter: haarCounter + 1
  			wIndex: wIndex + 3
  			rIndex: rIndex + 12
  			j: j + 1
  		] ;--end of filter loop
  		
  		;--per-stage thresholding 
  		testv: threshold * starray/i
  		;--no object detected break and return to rcvScaleImageInvoker routine
  		;--otherwise, an object is detected continue with the next stage
  		;--until the last filter confirms the object detection -> 1
  		if (stageSum  < testv) [return 0 - i]
  		;--end of the per-stage thresholding
  		i: i + 1
  	] ;end of i loop
	1	
]


;***************************************************************************************
{Each stage of the classifier labels the region defined by the current location of 
the sliding window as either positive or negative. 
Positive indicates that an object was found and negative indicates no objects were found. 
If the label is negative, the classification of this region is complete, 
and the detector slides the window to the next location. 
If the label is positive, the classifier passes the region to the next stage. 
The detector reports an object found at the current window location 
when the final stage classifies the region as positive.}

rcvScaleImageInvoker: routine [
"Search for objects in image" 
	factor			[float!]	;--initial scaling [1.0]
	step			[integer!]	;--window sliding  [1] can be increased for a faster detection
	sSize			[pair!]		;--integral image size
	p				[pair!]		;--current pixel
	rect			[vector!]	;--for candidates identified objects
	maxCandidates	[integer!]	;--max candidates number
	threshold		[float!]	;--used by rcvRunCascadeClassifier [1.1]
	/local	
	result			[integer!]
	x				[integer!]			
	y				[integer!]
	x2				[integer!]
	y1				[integer!]
	y2				[integer!]
	nCandidates		[integer!]
][
	winSize0: 	cascade/origWindowSize
	winSize/x:  as integer! __round (factor * as float! winSize0/x) 
 	winSize/y:  as integer! __round (factor * as float! winSize0/y)
 	;--when filter window shifts to image boarder, some margin need to be kept
 	
  	y2: sSize/y - winSize0/y
  	x2: sSize/x - winSize0/x 
  	
  	;--Step size of filter window shifting
  	;step: 1 ;--shift the filter window by 1 pixel
  	result: 0
  	nCandidates: 0
  	;--Shift the sliding window over the image according to start position
  	x:  p/x
  	y1: p/y
  	while [x <= x2] [
  		y: y1
  		while [y <= y2] [
  			p/x: x
  			p/y: y
  			;--same cascade filter is used 	
  			result: rcvRunCascadeClassifier p 1 threshold
  			;--if a face is detected  store coordinates 
  			;--and go to the next sub-region
  			if result > 0 [
  				vector/rs-append-int rect as integer! (factor * as float! x)
  				vector/rs-append-int rect as integer! (factor * as float! y)
  				vector/rs-append-int rect winSize/x
  				vector/rs-append-int rect winSize/y
  				nCandidates: (vector/rs-length? rect) / 4
  			]
  			;--no more candidates
  			if nCandidates > maxCandidates [exit]
  			y: y + step
  		]
  		x: x + step
  	]
]

;**************************************************************************************
; internal routines for rcvDetectObjects function (not documented)

_getWindow0X: routine [
	return: [integer!]
][cascade/origWindowSize/x]

_getWindow0Y: routine [
	return: [integer!]
][cascade/origWindowSize/y]

;--Integral images update
_setSumImage: routine [
	width	[integer!]
	height	[integer!]
	ss		[vector!]
][
	ssum/width: 	width
	ssum/height:	height
	ssum/data: 		as int-ptr! vector/rs-head ss 
]

_setSqSumImage: routine [
	width	[integer!]
	height	[integer!]
	ss		[vector!]
][
	sqsum/width: 	width
	sqsum/height:	height
	sqsum/data: 	as int-ptr! vector/rs-head ss 
]

_setTiltedSumImage: routine [
	width	[integer!]
	height	[integer!]
	ss		[vector!]
][
	stsum/width: 	width
	stsum/height:	height
	stsum/data: 	as int-ptr! vector/rs-head ss 
]

__round: routine [
	f 		[float!]
	return: [float!]
][
    either (f - floor f) > 0.5 [ceil f] [floor f] 
]

; similar to rcvMat2Array (avoids to load matrices lib)
_mat2Array: routine [
"Vector to block of vectors (Array)"
	mat 	[vector!] 
	matSize [pair!]
	return: [block!]
	/local
	blk		[red-block!]
	*Mat	[byte-ptr!]
	idx 	[byte-ptr!]
	vect 	[red-vector!]
	s	   	[series!]
	w 		[integer!]
	h		[integer!]
	i 		[integer!]
	j 		[integer!]	 
	p		[byte-ptr!]
	p4		[int-ptr!]
	p8		[float-ptr!]
	unit	[integer!]	
	n		[integer!]
][
	w: matSize/x
	h: matSize/y
	*Mat: vector/rs-head mat
	s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	blk: as red-block! stack/arguments
	n: h
	if zero? n [n: 1]
	block/make-at blk n
	j: 0
	while [j < h] [
		i: 0
		either unit <= 4 [vect: vector/make-at stack/push* w TYPE_INTEGER unit] 
						 [vect: vector/make-at stack/push* w TYPE_FLOAT unit] 
		while [i < w] [
			idx: *Mat + (j * w + i * unit)
			s: GET_BUFFER(vect)
			p: alloc-tail-unit s unit
			p4: as int-ptr! p
			p8: as float-ptr! p	
			either unit <= 4 [p4/value: vector/get-value-int as int-ptr! idx unit] 
				[p8/value: vector/get-value-float idx unit]
			i: i + 1
		]
		block/rs-append blk as red-value! vect
		j: j + 1
	]
	as red-block! stack/set-last as cell! blk 
]

;***************************************************************************************
;--Function: rcvDetectObjects
;--calls all the major steps
;--OK

rcvDetectObjects: func [
"Process image and find objects"
	img				[image!]	;--red image
	startPos		[pair!]		;--0x0 whole image
	scaleFactor		[float!]	;--1.2 initial ratio between the window size and the Haar classifier size
	step			[integer!]	;--1 shift of the window at each sub-step
	stageThreshold	[float!]	;--0.5
	maxCandidates	[integer!]	;--max candidates number
	minNeighbors	[integer!]	;--1 The minimum numbers of similar rectangles needed for the region to be considered as a feature (avoid noise)
	grouping		[logic!]	;--true
	method			[integer!]	;--0 no Canny 1 Canny pruning
	return:			[vector!]	;--found objects
][
	recycle/off					;--necessary to avoid pointer release by GC	
	clear allCandidates
	;--use Canny filtering?
	if method = 1 [
		imgC: copy img;make image! img/size
		mat1: make vector! img/size/x * img/size/y
		mat2: make vector! img/size/x * img/size/y
		mat3: make vector! img/size/x * img/size/y
		rcvCannyFilter img imgC mat1 mat2 mat3
	]
	;--startPos can be used for limiting search for ROI
	;--by default we use the whole image (startPos: 0x0)
	;--window size of the training set
	_winSize0: to pair! _getWindow0X _getWindow0Y 
	;--initial scaling factor
	factor: 1.0					
	;--iterate over the image pyramid
	forever [
		;--size of the detection window scaled up (smaller to bigger)
		_winSize: as-pair __round (factor * _winSize0/x) __round (factor * _winSize0/y)
		;--size of the image scaled down (from bigger to smaller)
		sz: as-pair (img/size/x / factor) (img/size/y / factor)
		;--difference between sizes of the scaled image and the original detection window
		sz1: sz - _winSize0
		;--if the actual scaled image is smaller 
       	;--than the original detection window, exit from the loop
       	if any [sz1/x < 0 sz1/y < 0]  [break]
		;--Image and matrices resizing 
		img1: 	make image! sz				;--source image 
		sum0: 	make vector! sz/x * sz/y	;--image to matrix
		sum1: 	make vector! sz/x * sz/y	;--summed-area table
		sqsum1:	make vector! sz/x * sz/y	;--square summed-area table
		stsum1: make vector! sz/x * sz/y	;--tilted summed-area table
		;--build image pyramid by downsampling with nearest neighbor routine
		case [
			method = 0 [rcvNearestNeighbor img img1]	;--default 
			method = 1 [rcvNearestNeighbor imgC img1]	;--Canny pruning
		]
		;--update integral images in cascade structure
       	_setSumImage sz/x sz/y sum1
       	_setSqSumImage sz/x sz/y sqsum1
       	_setTiltedSumImage sz/x sz/y stsum1
       	;--at each scale of the image pyramid, compute integral images
       	 case [
       	 	isTilted = 0 [rcvHaarIntegralImage1 img1 sum1 sqsum1]
       	 	isTilted > 0 [rcvHaarIntegralImage2 img1 sum0 sum1 sqsum1 stsum1]
       	 ]
       	
       	;--set integral images for Haar classifier cascade
       	rcvSetImageForCascadeClassifier
       	;--process the current scale with the cascaded filter
       	
        rcvScaleImageInvoker factor step sz startPos allCandidates maxCandidates stageThreshold
       	factor: factor * scaleFactor
	];--end of the factor loop, finish all scales in pyramid
	;--post detection processing
	;--identified: array of rectangles as vector!
	identified: make vector! [] 
	n: (length? allCandidates) / 4
	msize: as-pair 4 n 
	identified: _mat2Array allCandidates msize
	; rectangles clustering
	if all [grouping minNeighbors > 0][
		labels: copy []
		;--this function creates pb
		rcvGroupRectangles identified labels minNeighbors groupEPS
	]
	recycle/on ;-- restore GC
	identified
]



