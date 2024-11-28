Red [
	Title:   "Red Computer Vision: Haar Casacade"
	Author:  "Francois Jouen"
	File: 	 %rcvHaarCascade.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]
; this stable version support only stump-base Haar Cascade!

{based on code developped by Francesco Comaschi: http://www.es.ele.tue.nl/video/}

#system-global [
	#include %structures/hStructs.reds	;--some Red/System structures
	cascade: 	declare rcvCascade!		;--classifier cascade
	equRect: 	declare rcvRect!		;--rectangle
	tr:			declare rcvRect!		;--rectangle
	ssum:		declare rcvIntImage!	;--sum table for integral image
	sqsum: 		declare rcvIntImage!	;--square sum table for integral image
	winSize0: 	declare rcvSize!		;--window size of the training set
	winSize:	declare rcvSize!		;--size of the image scaled up		
	sarray:		declare int-ptr! 		;--stagesArray
	rarray:		declare int-ptr!		;--rectanglesArray
	srarray: 	declare int-ptr!		;--scaledRectanglesArray
	oarray:		declare int-ptr!		;--tiltedArray
	warray:		declare float-ptr!		;--weightsArray
	a1array:	declare float-ptr!		;--alpha1Array
	a2array:	declare float-ptr!		;--alpha2Array
	tarray:		declare float-ptr!		;--treeThreshArray
	starray: 	declare float-ptr!		;--stagesThreshArray	
	unSigned: 	pow 2.0 32.0			;--for c-like uint conversion
]
		

#include %rcvHaarRectangles.red			;--for rectangles clustering

;--we need a lot of arrays with different size	
;--do not predefine size, since we use append later for filling arrays

stagesArray: 			make vector! [] 			; nStages
rectanglesArray: 		make vector! [] 			;--totalNodes * 12
scaledRectanglesArray: 	make vector! []				;--totalNodes * 12
tiltedArray: 			make vector! []				;--tilted feature
weightsArray:  			make vector! [float! 64 0]	;--totalNodes * 3
alpha1Array:  			make vector! [float! 64 0]	;--totalNodes 
alpha2Array: 			make vector! [float! 64 0]	;--totalNodes
treeThreshArray: 		make vector! [float! 64 0]	;--totalNodes
stagesThreshArray: 		make vector! [float! 64 0]	;--nStages
allCandidates: 			make vector! [] 			;--for identified candidates 

groupEPS: 0.4										;--for rectangles classification

;***********************************************************
;--create int pointers that give access to arrays  by routines
 
rcvCreateArrayPointers: routine [
][ 
	sarray:	 as int-ptr! vector/rs-head as red-vector! #get 'stagesArray		
	rarray:	 as int-ptr! vector/rs-head as red-vector! #get 'rectanglesArray	
	srarray: as int-ptr! vector/rs-head as red-vector! #get 'scaledRectanglesArray
	oarray:  as int-ptr! vector/rs-head as red-vector! #get 'tiltedArray
	warray:  as float-ptr! vector/rs-head as red-vector! #get 'weightsArray	
	a1array: as float-ptr! vector/rs-head as red-vector! #get 'alpha1Array	
	a2array: as float-ptr! vector/rs-head as red-vector! #get 'alpha2Array 
	tarray:  as float-ptr! vector/rs-head as red-vector! #get 'treeThreshArray	
	starray: as float-ptr! vector/rs-head as red-vector! #get 'stagesThreshArray
]

;***********************************************************
;-- rcvReadTextClassifier function
;-- all information is in classifierFile.txt
;-- HeaderSection
;-- how many stages are in the cascaded filter?
;-- the second line of classifierFile is the number of stages
;-- how many filters in each stage? 
;-- They are specified in classifierFile,starting from third line
;***********************************************************
;-- Filters  are defined in Nodes section
;--First line: window training size
;--Each stage of the cascaded filter has:
;--19 parameters per filter
;--+ 1 threshold per stage
;--The 19 parameters for each filter are:
;--1 to 4: coordinates of rectangle 1
;--5: weight of rectangle 1
;--6 to 9: coordinates of rectangle 2
;--10: weight of rectangle 2
;--11 to 14: coordinates of rectangle 3
;--15: weight of rectangle 3
;--16: tilted flag
;--17: threshold of the filter
;--18: alpha 1 of the filter ; node left value
;--19: alpha 2 of the filter ; node right value

rcvReadTextClassifier: function [
"Process classifier file and return number of stages, total number of filter and original win size"
	f		[file!]
	return: [block!]
][
	;-clear arrays for each reading!
	clear stagesArray
	clear rectanglesArray
	clear scaledRectanglesArray
	clear weightsArray
	clear treeThreshArray
	clear alpha1Array
	clear alpha2Array
	clear stagesThreshArray
	clear tiltedArray
	
	; header section
	blk: read/lines f
	line: 2
	nStages: to-integer blk/:line; (trim blk/:line)
	line: 3
	totalNodes: 0
	until [
		v: to-integer blk/:line; (trim blk/:line)
		append stagesArray v
		totalNodes: totalNodes + v
		line: line + 1
		blk/:line = "[Nodes]"
	]
	; Nodes section
	line: line + 1
	ws0: to-pair (trim blk/:line)
	line: line + 1
	i: 1
	while [i <= nStages] [
		n2: stagesArray/:i		
		j: 1
		;loop over n of tree of filters
		while [j <= n2][
			k: 1 
			;loop filter parameters
			nFilters: 19
			while [k <= nFilters][
				vf: to-float blk/:line
				v: to-integer vf
				;--rectangle 1 2 3
				if any [
					k = 1 k = 2 k = 3 k = 4 
					k = 6 k = 7 k = 8 k = 9 
					k = 11 k = 12 k = 13 k = 14
				] [append rectanglesArray v append scaledRectanglesArray 0] 
				;--weight 1 2 3			
				if any [k = 5 k = 10 k = 15] [append weightsArray vf]
				if k = 16 [append tiltedArray v]		;--not used for faces
				if k = 17 [append treeThreshArray vf]	;--threshold of the filter
				if k = 18 [append alpha1Array vf]		;--left leaf of the filter 
				if k = 19 [append alpha2Array vf]		;--right leaf of the filter
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
	reduce [nStages totalNodes ws0]		; return values
]

;***********************************************************
;--create Haar cascade structure
;--return value: structure address as an integer

rcvCreateHaarCascade: routine [
	nStages		[integer!]
	nNodes		[integer!]
	scale		[float!]
	wSizeX		[integer!]
	wSizeY		[integer!]
	return: 	[integer!]
][
	;--default cascade properties
	cascade/nStages: 			nStages
	cascade/totalNodes: 		nNodes
	cascade/scale: 				scale
	cascade/origWindowSize/x: 	wSizeX
	cascade/origWindowSize/y: 	wSizeX
	cascade/invWindowArea: 		0
	cascade/sumImg: 			null;ssum
	cascade/sqSumImg: 			null;sqsum
	cascade/*pq0: 				null
	cascade/*pq1: 				null
	cascade/*pq2: 				null
	cascade/*pq3: 				null
	cascade/*p0:  				null
	cascade/*p1:  				null
	cascade/*p2:  				null
	cascade/*p3:  				null
	as integer! cascade 		;--address of the cascade
]



;***********************************************************
; * This routine downsample an image using nearest neighbor
; * It is used to build the image pyramid
rcvNearestNeighbor: routine [
	src		[image!]
	dst		[image!]
	/local
	idxS 	[int-ptr!]
	idxD	[int-ptr!]
	pixS	[int-ptr!]
	pixD	[int-ptr!]
	handleS	[integer!]
	handleD	[integer!]
	w1		[integer!] 
	h1		[integer!]
	w2		[integer!]
	h2		[integer!]
	xRatio	[integer!]
	yRatio	[integer!]
	x2 		[integer!]
	y2 		[integer!]
	i 		[integer!]
	j		[integer!]
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

;***********************************************************
; Similar to rcvIntegralImg in redCV lib rcvIntegral.red
; source image is automatically converted to grayscale image

rcvHaarIntegralImage: routine [
"Direct  integral on image "
    src  			[image!]
    dst1  			[vector!]
    dst2 			[vector!]
    /local
        pix1 		[int-ptr!]
        pixD1 		[byte-ptr!]
        pixD2 		[byte-ptr!]
        idxD1		[byte-ptr!]
        idxD2		[byte-ptr!]
        p4			[int-ptr!]
        s			[series!]
        handle1 	[integer!]
        unit		[integer!]
        h 			[integer!]
        w 			[integer!]
        x 			[integer!]
        y 			[integer!]
        pIndexD		[integer!] 
        pindex2 	[integer!]
        val			[integer!]
        ssum 		[integer!]
        sqsum   	[integer!]  
        t			[integer!]
        tq			[integer!]
        r 			[integer!]
        g 			[integer!]
        b			[integer!] 
        rgb			[integer!]
        rgbf		[float!]
][
    handle1: 0
    pix1:  image/acquire-buffer src :handle1 
    pixD1: vector/rs-head dst1
    pixD2: vector/rs-head dst2
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
    	;loop over the number of columns
       	while [x < w][
       		pIndexD: ((y * w) + x) * unit 
       		; grayscale luminance
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh      
			rgbf: (0.2989 * as float! r) + (0.587 * as float! g) + (0.114 * as float! b) 
        	rgb: (as integer! rgbf) >> 0
       		;sum of the current row
       		ssum: ssum + rgb
       		sqsum: sqsum + (rgb * rgb)
       		t: ssum
       		tq: sqsum
       		if y <> 0 [
       			pIndexD: (((y - 1) * w) + x) * unit
       			;sum
				pixD1: idxD1 + pIndexD 
				t: t + vector/get-value-int as int-ptr! pixD1 unit
       			; square sum
       			pixD2: idxD2 + pIndexD 
       			tq: tq + vector/get-value-int as int-ptr! pixD2 unit
			]
			
        	pIndexD: ((y * w) + x) * unit
        	pixD1: idxD1 + pIndexD 
        	p4: as int-ptr! pixD1
     		p4/value: switch unit [
				1 [t and FFh or (p4/value and FFFFFF00h)]
				2 [t and FFFFh or (p4/value and FFFF0000h)]
				4 [t]
			]
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


;***********************************************************
;set images for haar classifier cascade
;this function loads the four corners,
;but does not do compuation based on 4 corners.
;The computation is done next in ScaleImageInvoker routine

rcvSetImageForCascadeClassifier: routine [
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
][
	equRect/x: 0
	equRect/y: 0
	equRect/width:  		cascade/origWindowSize/x		
 	equRect/height: 		cascade/origWindowSize/y		
 	cascade/invWindowArea: 	equRect/width * equRect/height	
 	cascade/sumImg: 		ssum							
	cascade/sqSumImg: 		sqsum						
	
	cascade/*p0: ssum/data 
	cascade/*p1: ssum/data + (equRect/width - 1)
  	cascade/*p2: ssum/data + (ssum/width * (equRect/height - 1))
  	cascade/*p3: ssum/data + (ssum/width * (equRect/height - 1) + equRect/width - 1)
  	
  	cascade/*pq0: sqsum/data 
	cascade/*pq1: sqsum/data + equRect/width - 1
  	cascade/*pq2: sqsum/data + (sqsum/width * (equRect/height - 1))
  	cascade/*pq3: sqsum/data + (sqsum/width * (equRect/height - 1) + equRect/width - 1)
  	
  	;--Load the index of the 4 corners of the filter rectangle
	rIndex: 1
	wIndex: 1
	;--loop over the number of stages
	i: 1
	while [i <= cascade/nStages][
		j: 1
		;--loop over the number of haar features
		while [j <= sarray/i][
			nr: 3
			;--loop over the number of rectangles
 			k: 0 
 			while [k < nr] [
 				idx: rIndex + (k * 4)	tr/x: rarray/idx
 				idx: idx + 1  			tr/y: rarray/idx
 				idx: idx + 1  			tr/width: rarray/idx
 				idx: idx + 1   			tr/height: rarray/idx
 				;--Attention! srarray:  pointer address as integer!
 				;--ptr: as int-ptr! (srarray/idx)
 				;--print [ ptr/value lf]
 				if k < 2 [
 					idx: rIndex + (k * 4)
 					idx2: ssum/width  * tr/y + tr/x
 					srarray/idx: as integer! ssum/data + idx2 
 				
 					idx: idx + 1
 					idx2: ssum/width  * tr/y  + tr/x + tr/width
 					srarray/idx: as integer! ssum/data + idx2 
 				
 					idx: idx + 1
 					idx2: ssum/width * (tr/y + tr/height) + tr/x
 					srarray/idx: as integer! ssum/data + idx2
 					
 					idx: idx + 1
 					idx2: ssum/width * (tr/y + tr/height) + tr/x + tr/width 
 					srarray/idx: as integer! ssum/data + idx2
 				] 
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
 						srarray/idx: as integer! ssum/data + idx2
 						
 						idx: idx + 1
 						idx2: ssum/width  * tr/y  + tr/x + tr/width
 						srarray/idx: as integer! ssum/data + idx2 
 						
 						idx: idx + 1
 						idx2: ssum/width * (tr/y + tr/height) + tr/x
 						srarray/idx: as integer! ssum/data + idx2
 					
 						idx: idx + 1
 						idx2: ssum/width * (tr/y + tr/height) + tr/x + tr/width 
 						srarray/idx: as integer! ssum/data + idx2
 					]
 				]; end k < 2
 				k: k + 1
 			]; end k loop
 			rIndex: rIndex + 12
 			wIndex: wIndex + 3
			j: j + 1
		]
		i: i + 1
	]
]


;***********************************************************
;-- evalWeakClassifier: the actual computation of a haar filter.
rcvEvalWeakClassifier: routine [
	variance			[float!]
	pOffset				[integer!]
	treeIndex			[integer!]
	wIndex				[integer!]
	rIndex				[integer!]
	return:				[float!]
	/local
	ptr					[int-ptr!]
	sigma				[float!]
	t					[float!]
	idx					[integer!]
	weight				[float!]
	a					[integer!]
	b					[integer!]
	c					[integer!]
	d					[integer!]
	overflow			[int-ptr!]			
][
	;--the node threshold is multiplied by the standard deviation of the image
	t: tarray/treeIndex * variance  
	overflow: ssum/data + (ssum/width * ssum/height); for pointer error in large images
	
	; srarray: array of pointer addresses!!
	idx: rIndex + 0 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [a: ptr/value] [a: overflow/value]
	idx: rIndex + 1 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [b: ptr/value] [b: overflow/value]
	idx: rIndex + 2 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [c: ptr/value] [c: overflow/value]
	idx: rIndex + 3 ptr: as int-ptr! srarray/idx 
	ptr: ptr + pOffset either ptr < overflow [d: ptr/value] [d: overflow/value]
	weight: warray/wIndex
	sigma: weight * as float! (a - b - c + d)
	
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
	sigma: sigma + (weight * as float! (a - b - c + d))
	
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
		sigma: sigma + (weight * as float! (a - b - c + d))
	]
	either  sigma >= t [a2array/treeIndex] [a1array/treeIndex]
]

rcvRunCascadeClassifier: routine [
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
  		] ;--end of filters loop
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


;***********************************************************
{Each stage of the classifier labels the region defined by the current location of 
the sliding window as either positive or negative. 
Positive indicates that an object was found and negative indicates no objects were found. 
If the label is negative, the classification of this region is complete, 
and the detector slides the window to the next location. 
If the label is positive, the classifier passes the region to the next stage. 
The detector reports an object found at the current window location 
when the final stage classifies the region as positive.}

rcvScaleImageInvoker: routine [
	factor		[float!]	;--initial scaling [1.0]
	step		[integer!]	;--window sliding  [1] can be increased for a faster detection
	sumRow		[integer!]	;--integral image height
	sumCol		[integer!]	;--integral image width
	p			[pair!]		;--current pixel
	rect		[vector!]	;--for candidates identified objects
	threshold	[float!]	;--used by rcvRunCascadeClassifier [1.1]
	/local	
	result		[integer!]
	x			[integer!]			
	y			[integer!]
	x2			[integer!]
	y1			[integer!]
	y2			[integer!]
][
	winSize0: 	cascade/origWindowSize
	winSize/x:  as integer! __round (factor * as float! winSize0/x) 
 	winSize/y:  as integer! __round (factor * as float! winSize0/y)
 	;--when filter window shifts to image boarder, some margin need to be kept
    y2: sumRow - winSize0/y
  	x2: sumCol - winSize0/x 
  	;--Step size of filter window shifting
  	;step: 1 ;--shift the filter window by 1 pixel
  	result: 0
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
  			;--and go to the next sliding window
  			if result > 0 [
  				vector/rs-append-int rect as integer! (factor * as float! x)
  				vector/rs-append-int rect as integer! (factor * as float! y)
  				vector/rs-append-int rect winSize/x
  				vector/rs-append-int rect winSize/y
  			]
  			y: y + step
  		]
  		x: x + step
  	]
]


;******************************************************************
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
	n
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



;***********************************************************
;--Function: rcvDetectObjects
;--calls all the major steps

rcvDetectObjects: function [
	img				[image!]	;--red image
	minSize			[pair!]		;--20x20
	startPos		[pair!]		;--0x0
	scaleFactor		[float!]	;--1.2
	minNeighbors	[integer!]	;--1
	step			[integer!]	;--1
	stageThreshold	[float!]	;--0.5
	grouping		[logic!]	;--true
	return:			[vector!]	;--found objects
][
	recycle/off						;--necessary to avoid pointer release by GC	
	clear allCandidates
	
	;--startPos can be used for limiting search for ROI
	;--by default we use the whole image (startPos: 0x0)
	;--window size of the training set (24x24 default)
	_winSize0: to pair! _getWindow0X _getWindow0Y 
	;--initial scaling factor
	factor: 1.0					
	;iterate over the image pyramid
	forever [
		;--size of the detection window scaled up (smaller to bigger)
		_winSize: as-pair __round (factor * _winSize0/x) __round (factor * _winSize0/y)
		;--size of the image scaled down (from bigger to smaller)
		;sz: as-pair (img/size/x / factor)  (img/size/y / factor)
		sz: img/size / factor
		;--difference between sizes of the scaled image and the original detection window
		;sz1: as-pair (sz/x - _winSize0/x) (sz/y - _winSize0/y)
		sz1: sz - _winSize0
		;--if the actual scaled image is smaller 
       	;--than the original detection window, exit from the loop
       	if any [sz1/x < 0 sz1/y < 0]  [break]
       	
       	;--if a minSize different from the original detection window is specified
       	;--continue to the next scaling
       	if any [_winSize/x < minSize/x _winSize/y < minSize/y]  [continue]
		
		;--Image and matrices resize 
		img1: 	make image! sz				;--for image processing
		sum1: 	make vector! sz/x * sz/y	;--sum integral image
		sqsum1:	make vector! sz/x * sz/y	;--squaresum integral image
		
		;--build image pyramid by downsampling with nearest neighbor routine
       	rcvNearestNeighbor img img1
		
		;--update integral images in classifier structure
       	_setSumImage sz/x sz/y sum1
       	_setSqSumImage sz/x sz/y sqsum1
       
       	;--at each scale of the image pyramid, compute integral images
       	rcvHaarIntegralImage img1 sum1 sqsum1
       	
       	;--set integral images for Haar classifier cascade
       	rcvSetImageForCascadeClassifier
       	
       	;--process the current scale with the cascaded filter
        rcvScaleImageInvoker factor step sz/y sz/x startPos allCandidates stageThreshold
       	factor: factor * scaleFactor
       	
	];--end of the factor loop, finish all scales in pyramid
	
	;--post detection processing
	;--identified: array of rectangles as vector!
	
	identified: make vector! [] 
	n: (length? allCandidates) / 4
	if n < 16384 [
		msize: as-pair 4 n
		identified: _mat2Array allCandidates msize
	
		; rectangles clustering
		if all [grouping minNeighbors <> 0][
			labels: copy []
			rcvGroupRectangles identified labels minNeighbors groupEPS
		]
	]
	recycle/on
	identified
]



