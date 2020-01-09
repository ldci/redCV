
Red [
	Title:   "Red Computer Vision: Snake Active Contour"
	Author:  "Francois Jouen"
	File: 	 %rcvSnake1.red
	Tabs:	 4
	Rights:  "Copyright (C) 2017 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 'View
]


;required libs
#include %../../../libs/core/rcvCore.red
#include %../../../libs/matrix/rcvMatrix.red
#include %../../../libs/tools/rcvTools.red	
#include %../../../libs/math/rcvChamfer.red


margins: 10x10
isize: 512x512
bitSize: 32; => unit: 4

img0: rcvCreateImage isize
img1: rcvCreateImage isize
img2: rcvCreateImage isize
imgcopy: rcvCreateImage isize
binaryMat: rcvCreateMat 'integer! bitSize isize
flowMat: rcvCreateMat 'integer! bitSize isize
lumMat: rcvCreateMat 'integer! bitSize isize
gradientMat: rcvCreateMat 'integer! bitSize isize
distMat: rcvCreateMat 'float! 64 isize
threshold: 1
distance: 5.0
gMax: 0
isFile: false
;anti-aliasing: on



;************************* snake ***********************
; snake variables
snakeData: make block! []
newSnake: make block! []
sWidth: 0
sHeight: 0 	;image size
snakeLength: 0		;euclidian distance
snakeSize: 0		; size of array
;3x3 neighborhood used to compute energies
eUniformity: make vector! [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
eCurvature: make vector! [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
eFlow: make vector! [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
eInertia: make vector! [0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
;coefficients for the 4 energy functions
sAlpha: 1.1	;sAlpha = coefficient for uniformity
sBeta: 1.2	;coefficient for curvature
sGamma: 1.5	;coefficient for sFlow 
sDelta: 3.0	; coefficient for inertia
maxLen: 16
minLen: 8
autoAdapt: true
autoAdaptLoop: 10
maxIteration: 512
nLoop: 0
showAnimation: false

; snake actions (methods)	
; note: function -> Defines a function, making all set-words found in body, local.
	
; snake routines for a faster access	
getDistance2D: routine [
	A 		[pair!] 
	B 		[pair!] 
	return: [float!]
	/local
	ux uy
] [
	ux: as float! (A/x - B/x)
	uy:	as float! (A/y - B/y)
	sqrt (ux * ux) + (uy * uy)
]
	
getSnakeLength: routine [
	snakeData	[block!]
	return: 	[float!]
	/local
	l i kBase snakeSize _cur _next
][
	l: 0.0
	snakeSize: getSnakeSize snakeData
	kBase: block/rs-head snakeData
	i: 0
	while [i < snakeSize] [
		_cur: as red-pair! kBase
		_next: as red-pair! kBase + 1
		l: l + getDistance2D _cur _next
		kBase: kBase + 1
		i: i + 1
	]
	l
]


getSnakeSize: routine [ 
	snakeData	[block!]
	return: 	[integer!]
][
	 block/rs-length? snakeData
]

getSnakeValue1: routine [
	snakeData	[block!]
	pos			[integer!]
	return:		[pair!]
	/local
	s
][
	s: GET_BUFFER(snakeData)
	assert s/offset + pos < s/tail 
	as red-pair! copy-cell as cell! s/offset + pos as cell! snakeData
]

getBlockValue: routine [
	bdata 	[block!] 
	pos 	[integer!]
][
     stack/set-last block/rs-abs-at bdata pos
]



;************************** ENERGY FUNCTIONS **************************
;Calcul de l'écartement entre les points
uniformity: routine [
	snakeData	[block!]
	_previous 	[pair!] 
	p 			[pair!] 
	return: 	[float!]
	/local
	un avg dun l s
][
	;length of previous segment
	un:  getDistance2D _previous p
	;measure of uniformity
	l: getSnakeLength snakeData
	s: as float! getSnakeSize snakeData
	avg: l / s
	dun: un - avg
	if dun < 0.0 [dun: 0.0 - dun]; abs value
	;elasticity energy
	dun * dun
]	

;snake rigidity
curvature: routine [
	_previous 	[pair!] 
	_next 		[pair!] 
	p 			[pair!] 
	return: 	[float!]
	/local
	ux uy un vx vy vn cx cy
][
	ux: as float! (p/x - _previous/x)
	uy: as float! (p/y - _previous/y)
	un: sqrt ((ux * ux) + (uy * uy))
	vx: as float!  p/x - _next/x
	vy: as float!  p/y - _next/y
	vn: sqrt ((vx * vx) + (vy * vy))
	if any [un = 0.0 vn = 0.0] [return 0.0]
	cx: (vx + ux)/(un * vn)
	cy: (vy + uy)/(un * vn)
	;curvature energy
	(cx * cx) + (cy * cy)
]



;Push snake to external borders

gflow: routine [
	cur 		[pair!] 
	p 			[pair!]
	flowMat		[vector!]
	sWidth		[integer!]
	return: 	[float!]
	/local
	idx dcur dp
	mvalue unit
][
	mvalue: vector/rs-head flowMat
    unit: 4; rcvGetMatBitSize flowMat
    idx: mvalue + (((cur/y * sWidth) + cur/x) * unit) 
    dcur: vector/get-value-int as int-ptr! idx unit
    idx: mvalue + (((p/y * sWidth) + p/x) * unit)
    dp: vector/get-value-int as int-ptr! idx unit
   	as float! dp - dcur 
]


;Pull snake to high density gradient 
inertia: routine [
	cur 		[pair!] 
	p 			[pair!]
	gradMat		[vector!]
	sWidth		[integer!]
	return: 	[float!]
	/local
	idx d g
	mvalue unit	
][
	unit: 4; rcvGetMatBitSize gradMat
	mvalue: vector/rs-head gradMat
	idx: mvalue + (((cur/y * sWidth) + cur/x) * unit)
	d: getDistance2D cur p
	g: as float! vector/get-value-int as int-ptr! idx unit
	g * d
]


; functions

normalizeMat: func [array [vector!]
"Normalizes energy matrix"
][
	sum: 0.0
	foreach p array [sum: absolute(sum + p)]
	if sum = 0.0 [exit]
	array: array / sum
]
	

snakeLoop: func [] [
	nLoop: 0
	while [snakeStep AND (nLoop < maxIteration)]  [
		if (autoAdapt AND (nLoop % autoAdaptLoop = 0)) [
			removeOverlappingPoints minLen
			addMissingPoints maxLen snakeData	
		] 
		if showAnimation [drawSnake] 
		nLoop: nLoop + 1
		niter/text: form nLoop
	]
	;rebuild using spline interpolation
	if autoAdapt [snakeData: copy rebuild maxLen]
]

;update the position of each point of the snake
;return true if the snake has changed, otherwise false.	
snakeStep: func [ return: [logic!]] [
	isChanged: false
	; computes number of points in snake
	snakeSize: getSnakeSize snakeData 
	;computes  length of original snake (used by uniformity)
	snakelength: getSnakeLength snakeData 
	;computes the new snake
	newSnake: copy []
	;for each point of the previous snake
	i: 0
	while [i < snakeSize] [
		_prev: getBlockValue snakeData (i + snakeSize - 1) % (snakeSize)		
		_cur: getBlockValue snakeData (i)
		_next: getBlockValue snakeData (i + 1) % snakeSize	
		;computes all energies
		dy: -1
		while [dy <= 1] [
			dx: -1
			while [dx <= 1] [
				; for 1 to 9  values in vector 
				idx: dx + 1 + (dy + 1 * 3) + 1 
				p: as-pair _cur/x + dx _cur/y + dy
				eUniformity/(idx): uniformity snakeData _prev p
				eCurvature/(idx): curvature _prev p _next
				eFlow/(idx): gflow _cur p flowMat sWidth
				eInertia/(idx): inertia _cur p gradientMat sWidth
				dx: dx + 1
			]
			dy: dy + 1
		]
		
		;normalize energies
		normalizeMat eUniformity
		normalizeMat eCurvature
		normalizeMat eFlow
		normalizeMat eInertia
			
		;find the point with the minimum sum of energies
		emin: 1000000.0
		e: 0.0
		x: y: 0
		dy: -1
		while [dy <= 1] [
			dx: -1
			while [dx <= 1] [
				idx: dx + 1 + (dy + 1 * 3) + 1 ; for 1 to 9
				e: 0.0
				e: e + (sAlpha * eUniformity/(idx))		;internal energy
				e: e + (sBeta * eCurvature/(idx))		;internal energy
				e: e + (sGamma * eFlow/(idx))			;external energy
				e: e + (sDelta * eInertia/(idx))		;external energy
				if e < emin [emin: e x: _cur/x + dx y: _cur/y + dy]
				dx: dx + 1
			]
			dy: dy + 1
		]
		;boundary check to avoid pointer error!
		if (x < 1) [x: 1]
		if (x >= (swidth - 1 )) [x: sWidth - 2]
		if (y < 1) [y: 1]
		if (y >= (sHeight - 1)) [y: sHeight - 2]
		if ANY [x <> _cur/x y <> _cur/y] [isChanged: true]
		;create the point in the new snake
		append newSnake as-pair x y 
		i: i + 1
	]	
	snakeData: copy newSnake
	isChanged
]



;************************** AUTOADAPT **************************

removeOverlappingPoints: func [minlen [integer!]
][
	snakeSize: getSnakeSize snakeData
	;for each point of the snake
	i: 0
	while [i < (snakeSize)] [
		cur: getBlockValue snakeData i 
		;check the other points (right half)
		di: 1 + snakeSize / 2
		while [di > 0] [
			_end: getBlockValue snakeData (i + di) % snakeSize
			dist: getDistance2D cur _end
			;if the two points are to close...
			if ( dist <= minlen ) [
				;cut the "loop" part of the snake
				k: 0
				while [k < di] [
					remove at snakeData (i + 1 % snakeSize) + 1
					k: k + 1
				]
				break
			]
			di: di - 1
		]
		;update snake size 
		snakeSize: getSnakeSize snakeData
		i: i + 1
	]
]

addMissingPoints: func [maxlen [integer!]
][
	;precomputed Uniform cubic B-spline for t=0.5
	c0: 0.125 / 6.0 c1: 2.875 / 6.0
	c2: 2.875 / 6.0 c3: 0.125 / 6.0
	;for each point of the snake
	snakeSize: getSnakeSize snakeData
	i: 0
	while [ i < snakeSize] [
		prev: getBlockValue snakeData (i + snakeSize - 1) % snakeSize
		cur: getBlockValue snakeData i 
		_next: getBlockValue snakeData (i + 1) % snakeSize
		_next2: getBlockValue snakeData (i + 2) % snakeSize
		;if the next point is to far then add a new point
		if ((getDistance2D cur _next) > maxlen)[
			x: 0.5 + (prev/x * c3) + (cur/x * c2) + (_next/x * c1) + (_next2/x * c0)
			y: 0.5 + (prev/y * c3) + (cur/y * c2) + (_next/y * c1) + (_next2/y * c0)
			insert at snakeData i + 1 as-pair x y ;to pair! reduce [x y]
			i: i - 1
		]
		i: i + 1
	]
]
	
;rebuild the snake using cubic spline interpolation for t=0.5

rebuild: func [space [integer!] return: [block!]
][
	;precompute length(i) = length of the snake from start to point #i
	snakeSize: getSnakeSize snakeData
	clength: make vector! reduce  ['float! 64 snakeSize + 1]
	i: 0
	while [i < snakeSize] [
		cur: getBlockValue snakeData i 
		_next: getBlockValue snakeData (i + 1) % snakeSize
		clength/(i + 2): clength/(i + 1) + getDistance2D cur _next
		i: i + 1
	]
	
	;compute number of points in the new snake
	total: clength/(snakeSize) + 0.5
	nmb: to-integer total / space 
	
	;build a new snake
	newSnake: copy []
	j: 0
	while [j < nmb] [
		i: 0
		dist: (j * total) / nmb
		;find corresponding interval of points in the original snake
		tt1: tt2: false
		while [ not ( tt1 and tt2)] [
			tt1: clength/(i + 1) <= dist
			tt2: dist < clength/(i + 2)
			i: i + 1
		]
		;get points (P-1,P,P+1,P+2) in the original snake
		prev: getBlockValue snakeData ((i + snakeSize - 1) % snakeSize) 
		cur: getBlockValue snakeData i
		_next: getBlockValue snakeData ((i + 1) % snakeSize)
		_next2: getBlockValue snakeData ((i + 2) % snakeSize) 
		;do cubic spline interpolation
		t:  (dist - clength/(i)) / (clength/(i + 1) - clength/(i))
		t2: t * t 
		t3: t2 * t
		;c0: 1 * t3
		c1: (-3 * t3) + (3 * t2) + (3 * t) + 1
		c2: (3 * t3) - (6 * t2) + 4
		c3: (-1 * t3) + (3 * t2) - (3 * t) + 1
		x: 0.5 + (prev/x * c3) + (cur/x * c2) + (_next/x * c1) + (_next2/x * t3)
		y: 0.5 +(prev/y * c3) + (cur/y * c2) + (_next/y * c1) + (_next2/y * t3)
		;add computed point to the new snake
		append newSnake as-pair (x / 6) (y / 6)
		j: j + 1
	]
	newSnake
]


;************************* test program ***************************

quitApp: does [
	rcvReleaseImage img0
	rcvReleaseImage img1
	rcvReleaseImage img2
	rcvReleaseImage imgcopy
	rcvReleaseMat binaryMat
	rcvReleaseMat flowMat
	rcvReleaseMat lumMat
	rcvReleaseMat gradientMat
	rcvReleaseMat distMat
	Quit
]


computeFlow: does [		
	; binary thresholding		
	rcvMakeBinaryGradient gradientMat binaryMat gMax threshold img0/size
	; Chamfer distance map
	rcvChamferInitMap binaryMat distMat	
	rcvChamferCompute distMat chamfer img0/size 
	rcvChamferNormalize distMat normalizer
	;distance map to binarized gradient
	maxf: rcvFlowMat distMat flowMat distance
	rcvMat2Image flowMat img1
	; flow and gradient
	rcvGradient&Flow flowMat binaryMat img2	
]


startSnake: func [img [image!]][
	w: img/size/x
	h: img/size/y
	;snake initial points
	radius: ((w / 2.0) + (h / 2.0)) / 2.0 
	perimeter: 2 * pi * radius
	nmb: to-integer (perimeter / maxLen)
	snakeData: copy []
	i: 0
	while [i < nmb] [
		angleR: (2 * pi * i) / nmb
		radius: (w / 2.0) - 2 
		x: (w / 2.0) + (radius * cos angleR)
		radius: (h / 2.0) - 2 
		y: (h / 2.0) + (radius * sin angleR)
		append snakeData as-pair x y
		i: i + 1
	]
	sWidth: w
	sHeight: h
	if error? try [sAlpha: to-float falpha/text][sAlpha: 1.1]
	if error? try [sBeta: to-float fbeta/text][sBeta: 1.2]
	if error? try [sGamma: to-float fgamma/text][sGamma: 1.5]
	if error? try [sDelta: to-float fdelta/text][sDelta: 1.0]
	if error? try [maxIteration: to-integer maxIter/text] [maxIteration: 512]
	if error? try [minLen: to-integer fMinL/text] [minLen: 8]
	if error? try [maxLen: to-integer fMinL/text] [maxLen: 16]
	; coefficient for inertia
	snakeSize: getSnakeSize snakeData 
	snakeLength: getSnakeLength snakeData 
	snSize/text: form snakeSize
	drawSnake
]




runSnake: does [
	if isFile [
		clear niter/text
		nLoop: 0
		startSnake img0
		t1: now/time/precise
		snakeLoop
		fTime/text: form now/time/precise - t1
		drawSnake
		
	]
]


drawSnake: does [
	; we need 3 points or more for a polygon 
	if (getSnakeSize snakeData) >= 3 [
		snSize/text: form getSnakeSize snakeData
		rcvCopyImage img0 imgcopy
		plot: copy [line-width 1 pen red polygon]
		foreach p snakeData [append plot p]
		append plot 'fill-pen 
		append plot 'yellow
		foreach p snakeData [append plot 'circle append plot p append plot 2]
		canvas2/image: draw imgcopy plot
	]
]


loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/image: none
	tmp: request-file
	if not none? tmp [
		img0: rcvLoadImage tmp
		img1: rcvCreateImage img0/size
		img2: rcvCreateImage img0/size
		imgcopy: rcvCreateImage img0/size 
		lumMat: rcvCreateMat 'integer! bitSize img0/size ; grasycale matrix
		gradientMat: rcvCreateMat 'integer! bitSize img0/size ;
		binaryMat: rcvCreateMat 'integer! bitSize img0/size ; for binary gradient [0/1]
		flowMat: rcvCreateMat 'integer! bitSize img0/size; for flow in image
		distMat: rcvChamferCreateOutput img0/size;
		; for chamfer distance
		chamfer: first rcvChamferDistance chamfer5
		normalizer: second rcvChamferDistance chamfer5
		rcvCopyImage img0 imgcopy
		canvas2/image: imgcopy
		; we need a grayscale image
		rcv2Gray/luminosity img0 img1
		; GrayLevelScale (Luminance) mat
		rcvImage2Mat img1 lumMat
		; Gradient (sobel) 	mat				
	    gMax: rcvMakeGradient lumMat gradientMat img0/size
		computeFlow 
		canvas1/image: img2
		clear niter/text
		startSnake img0
		fsize/data: form img0/size
		isFile: true
	]
]



view win: layout [
	title "Snake"
	origin margins space margins
	button "Load image" [loadImage]
	fsize: field 100
	
	text "Number of Iterations" 
	maxIter: field 50 [if error? try [maxIteration: to-integer face/text] [maxIteration: 512]]
	
	cb1: check "Spline" [autoAdapt: face/data]
	;cb2: check "Show Animation" [showAnimation: face/data]
	button "Reset" [startSnake img0]
	
	button " Run Snake" [runSnake]
	text "Rendered in " 
	ftime: field 120
	pad 20x0
	button "Quit" [quitApp]
	return
	text 100 "Flow + Gradient"
	pad 412x0
	text 100 "Snake iterations" 
	niter: field 50
	text "Snake Size"
	snSize: field 50 
	
	return
	canvas1: base isize img1
	canvas2: base isize img2
	return
	text "Gradient Threshold"
	sl: slider 320 [
		if isFile [
			threshold: 1 + (to-integer face/data * 98)
			fgt/text: form threshold
			computeFlow
		] 
	]
	fgt: field 40 "0" 
	pad 10x0
	text 70 "Uniformity" falpha: field 40 "1.1"
	text 70 "Curvature" fbeta: field 40 "1.2"
	text 50 "Flow" fgamma: field 40 "1.5"
	text 50 "Inertia" fdelta: field 40 "1.0"
	return
	pad 520x0
	text "Minimal Length"  fMinL: field 40 "8"
	text "Maximal Length"  fMaxL: field 40 "16"
	do [cb1/data: true maxIter/text: form maxIteration ]
]






