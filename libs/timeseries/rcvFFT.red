Red [
	Title:   "Red Computer Vision: FFT"
	Author:  "Francois Jouen"
	File: 	 %rcvFFT.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;--stand alone test
#include %../core/rcvCore.red
#include %../tools/rcvTools.red
#include %../matrix/rcvMatrix.red

;************** 1-D Fast Fourier Transform **********************
; Thanks to Mel Cepstrum and Toomas Voglaid :)
; routines and functions require float (64-bit) values


;This computes an in-place complex-to-complex FFT 
;re and im are the real (x) and imaginary (y) arrays of 2^m points.
;dir: 1 gives forward transform
;dir: -1 gives reverse or backward transform 
;this code is based on http://paulbourke.net/miscellaneous/

rcvFFT: routine [
"In-place complex-to-complex FFT"
	 re 			[vector!] 
	 im 			[vector!] 
	 dir			[integer!]
	 scaling		[integer!]
	/local
	*re	*im			[float-ptr!] 
	tre tim		 	[float!] 
	m n i i1 i2		[integer!]
	j k l l1 l2		[integer!] 
	u1 u2 c1 c2		[float!]  
	z f				[float!]
][
	*re: as float-ptr! vector/rs-head re
	*im: as float-ptr! vector/rs-head im
	;Calculate the number of points
	m: as integer! rcvLog-2 as float! (vector/rs-length? re)
	n: 1 << m
	; Do the bit reversal (Danielson-Lanzcos algorithm)
	i2: n >> 1 
	j: 1
	i: 1 
	while [i < n][
		if i < j [
			tre: *re/i			
			tim: *im/i
			*re/i: *re/j			
			*im/i: *im/j
			*re/j: tre			
			*im/j: tim
		]
		k: i2
		while [k < j][  
			j: j - k
			k: k >> 1
		]
		j: j + k
		i: i + 1
	]
	; Compute the FFT
	c1: -1.0 
	c2:  0.0
	l2: 1
	l: 0 
	while [l < m][			
		l1: l2
		l2: l2 << 1
		u1: 1.0 
		u2: 0.0
		j: 1 
		while [j <= l1][	
			i: j
			while [i <= n][	 
				i1: i + l1
				tre: (u1 * *re/i1) - (u2 * *im/i1)
				tim: (u1 * *im/i1) + (u2 * *re/i1)
				*re/i1:  *re/i - tre 
				*im/i1:  *im/i - tim
				*re/i: *re/i + tre
				*im/i: *im/i + tim
				i: i + l2
			]
			z:  (u1 * c1) - (u2 * c2)
			u2: (u1 * c2) + (u2 * c1)
			u1:  z
			j: j + 1
		]
		c2:  sqrt ((1.0 - c1) / 2.0)
		if dir = 1 [c2: 0.0 - c2] 
		c1: sqrt ((1.0 + c1) / 2.0)
		l: l + 1
	]  
	;  Scaling for forward transform
	switch scaling [
		0 [f: 1.0]	; no scaling
		1 [f: 1.0 / as float! n]
		2 [f: 1.0 / sqrt as float! n]
	]
	if dir = 1 [
		i: 1 
		while [i <= n ][	
			*re/i: *re/i * f
			*im/i: *im/i * f
			i: i + 1
		]
	]
]

rcvFFTAmplitude: routine [
"FFT amplitude. Only float matrices"
	re 		[vector!] 	; real part
	im 		[vector!] 	; imaginary part
	return:	[vector!]	; magnitude matrix
	/local
	ptrRe	[float-ptr!]
	ptrIm	[float-ptr!]
	x* 		[red-vector!]
	unit	[integer!]
	s		[series!]
	i		[integer!] 
	n		[integer!]
	px*		[float-ptr!]
][
	;s: GET_BUFFER(re)	
	;unit: GET_UNIT(s)
	ptrRe: as float-ptr! vector/rs-head re
	ptrIm: as float-ptr! vector/rs-head im
	n: vector/rs-length? re 
	x*: vector/make-at stack/push* n TYPE_FLOAT 8
	px*: as float-ptr! vector/rs-head x*
	i: 1
	while [i <= n] [
		px*/i: sqrt ((ptrRe/i * ptrRe/i) + (ptrIm/i * ptrIm/i))
		i: i + 1
	]
	s: GET_BUFFER(x*)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! x* 	
]


rcvFFTPhase: routine [
"FFT phase. Only float matrices"
	re 		[vector!] 	; real part
	im 		[vector!] 	; imaginary part
	degree	[logic!]
	return:	[vector!]	; magnitude matrix
	/local
	ptrRe	[float-ptr!]
	ptrIm	[float-ptr!]
	x* 		[red-vector!]
	s		[series!]
	unit	[integer!]
	i		[integer!] 
	n		[integer!]
	px*		[float-ptr!]
	f		[float!]
][
	;s: GET_BUFFER(re)			
	;unit: GET_UNIT(s)
	f: 1.0
	if degree [f: 180.0 / pi]
	ptrRe: as float-ptr! vector/rs-head re
	ptrIm: as float-ptr! vector/rs-head im
	n: vector/rs-length? re 
	x*: vector/make-at stack/push* n TYPE_FLOAT 8
	px*: as float-ptr! vector/rs-head x*
	i: 1
	while [i <= n] [
		px*/i: (atan2 ptrRe/i ptrIm/i) * f
		i: i + 1
	]
	s: GET_BUFFER(x*)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! x* 	
]

rcvFFTFrequency: routine [
{Returns the FFT sample frequencies
 and shifts the DC (zero-frequency component) to the center of the spectrum}
	n 		[integer!]	; window length
	delta	[float!]	; time step (inverse of sampling rate)
	return:	[vector!]
	/local
	x* 		[red-vector!]
	px*		[float-ptr!]
	s		[series!]
	n*		[integer!]
	i		[integer!]
	f
][
	x*: vector/make-at stack/push* n TYPE_FLOAT 8
	px*: as float-ptr! vector/rs-head x*
	either n % 2 = 0 [i: 0 - n / 2][i:  0 - (n + 1) / 2]
	while [i < -1] [
		f: (as float! i) / ((as float! n) * delta)
		px*/value: f
		px*: px* + 1
		i: i + 1
	]
	either n % 2 = 0 [n*: n / 2 + 1][n*: n / 2]
	i: 0 
	while [i <= n*] [
		f: (as float! i) / ((as float! n) * delta)
		px*/value: f
		px*: px* + 1
		i: i + 1
	]
	s: GET_BUFFER(x*)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! x* 
]

rcvFFTShift: routine [
"Shifts to the center of the spectrum"
	x		[vector!]
	return: [vector!]
	/local
	xx		[red-vector!]
	x* 		[byte-ptr!]
	head	[byte-ptr!]
	p8		[float-ptr!]
	p8*		[float-ptr!]
	p8**	[float-ptr!]
	s		[series!]
	n*		[integer!]
	n		[integer!]
	idx		[integer!]
	unit	[integer!]
	vf1		[float!]
	vf2		[float!]
	;vi1		[integer!]
	;vi2		[integer!]
][
	n: vector/rs-length? x		; length
	head: vector/rs-head x		; head
	;s: GET_BUFFER(x)			; series
	;unit: GET_UNIT(s)			; unit
	unit: 8
	xx: vector/make-at stack/push* n TYPE_FLOAT unit
	x*: vector/rs-head xx		; head
	either n % 2 = 0 [n*: n / 2 - 1][n*: (n - 1) / 2]
	idx: 0
	while [idx <= n*] [
		p8: as float-ptr! head + (idx * unit)
		vf1: p8/value
		p8: as float-ptr! head + (idx + n* + 1 * unit)
		vf2: p8/value
		p8*:  as float-ptr! x* + (idx * unit)
		p8**: as float-ptr! x* + (idx + n* + 1 * unit)
		p8*/value: 	vf2			; swap value
		p8**/value: vf1			; temp value
		idx: idx + 1
	]
	s: GET_BUFFER(xx)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! xx 	
]

rcvFFTFilter: routine [
"FFT Low or High Pass Filter"
	x			[vector!]
	radius		[float!]
	op			[integer!]
	return:		[vector!]
	/local
	xx			[red-vector!]
	head		[byte-ptr!]
	head*		[byte-ptr!]
	tail		[byte-ptr!]
	s			[series!]
	unit		[integer!]
	p			[float-ptr!]
	p*			[float-ptr!]
	f			[float!]
	n			[integer!]
][
	unit: 8
	n: vector/rs-length? x		; length
	head: vector/rs-head x		; head
	tail: vector/rs-tail x		; tail
	xx: vector/make-at stack/push* n TYPE_FLOAT unit	;--new vector
	head*: vector/rs-head xx	; head new vector
	while [head < tail] [
		p: as float-ptr! head
		p*: as float-ptr! head*
		f: vector/get-value-float as byte-ptr! p unit
		p*/value: f
		if f < 0.0 [f: 0.0 - f]					; absolute value
		switch op [
			1	[if f > radius [p*/value: 0.0]]	; high pass
			2 	[if f < radius [p*/value: 0.0]]	; low pass
		]
		head: head + unit
		head*: head* + unit
	]
	s: GET_BUFFER(xx)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! xx	
]

rcvFFTLSFilter: routine [
"Deblurring of image by using least-squares filtering in FFT space"
	re 			[vector!] 		; matrice
	im 			[vector!] 		; array of vectors	
	/local
	headX		[byte-ptr!]
	headY		[byte-ptr!]
	tailX		[byte-ptr!]
	px			[float-ptr!]
	py			[float-ptr!]
	norm		[float!]
	divd		[float!]
	unit		[integer!]
	fX			[float!]
	fY			[float!]			
	sigma		[float!]
	wkX			[float!]
	wkY			[float!]
	s			[series!]
	
][

	s: GET_BUFFER(re)			
	unit: GET_UNIT(s)
	sigma: 0.01
	unit: 8
	headX: vector/rs-head re
	tailX: vector/rs-tail re
	headY: vector/rs-head im
	while [headX < tailX] [
		pX: as float-ptr! headX
		pY: as float-ptr! headY
		fX: vector/get-value-float as byte-ptr! pX unit
		fY: vector/get-value-float as byte-ptr! pY unit
		norm: (pow fX 2.0) + (pow fY 2.0)
		divd: (norm + 2.0) * pow sigma 2.0
		wkX: fX
      	wkY: fY
      	px/value: ((fY * wkX) + (fY * wkY)) / divd
      	py/value: ((fY * wkY) - (fY * wkX)) / divd
		headX: headX + unit
		headY: headY + unit
	]
]


;************** 2-D Fast Fourier Transform **********************
;Perform a 2D FFT inplace given a complex 2D array
;The direction dir, 1 for forward, -1 for reverse
;Only 64 float vectors!!!

rcvFFT2D: routine [
"Perform a 2D FFT inplace given a complex 2D array"
	re 			[block!] 		; array of vectors
	im 			[block!] 		; array of vectors
	dir			[integer!]		; direction
	scaling		[integer!]		; scaling mode
	/local
	headX		[red-value!]
	headY		[red-value!]
	tailX		[red-value!]
	vectBlkX	[red-vector!]
	vectBlkY	[red-vector!]
	x* 			[red-vector!]
	y*			[red-vector!]
	vx 			[byte-ptr!]
	vy 			[byte-ptr!]
	ptrX*		[float-ptr!]
	ptrY*		[float-ptr!]
	px 			[float-ptr!]
	py			[float-ptr!]
	s			[series!]
	nx 			[integer!]
	ny			[integer!]
	idx			[integer!]
	x 			[integer!]
	y			[integer!]
	unit		[integer!]
][
	headX: block/rs-head re
	tailX: block/rs-tail re
	headY: block/rs-head im
	vectBlkY: as red-vector! headY
	vectBlkX: as red-vector! headX
    nx: vector/rs-length? vectBlkX
    ny: block/rs-length? re 
    s: GET_BUFFER(vectBlkX)		
	unit: GET_UNIT(s)
	
	;FFT Transform on rows
	while [headX < tailX] [
		vectBlkX: as red-vector! headX
		vectBlkY: as red-vector! headY
		rcvFFT vectBlkX vectBlkY dir scaling
		headX: headX + 1
		headY: headY + 1
	]
	; Store row FFT transform 
	headX: block/rs-head re
	headY: block/rs-head im
	x*: vector/make-at stack/push* (nx * ny) TYPE_FLOAT unit  
	y*: vector/make-at stack/push* (nx * ny) TYPE_FLOAT unit 
	ptrX*: as float-ptr! vector/rs-head x*
	ptrY*: as float-ptr! vector/rs-head Y*
	y: 0 
	while [y < ny][
		vectBlkX: as red-vector! headX
		vectBlkY: as red-vector! headY
		vx: vector/rs-head vectBlkX
		vy: vector/rs-head vectBlkY
 		x: 0
 		while [x < nx][
 			idx: y * nx + x + 1
			ptrX*/idx: vector/get-value-float vx unit
			ptrY*/idx: vector/get-value-float vy unit
			vx: vx + unit
			vy: vy + unit
 			x: x + 1
 		]
 		headX: headX + 1
		headY: headY + 1
		y: y + 1
	]	
	; FFT transform on cols
	headX: block/rs-head re
	headY: block/rs-head im
	x: 0 
	while [x < nx][
		vectBlkX: as red-vector! headX
		vectBlkY: as red-vector! headY
		vx: vector/rs-head vectBlkX
		vy: vector/rs-head vectBlkY
		y: 0
		while [y < ny] [
			idx: y * nx + x + 1
			px: as float-ptr! vx
			px/value: ptrX*/idx 
			py: as float-ptr! vy
			py/value: ptrY*/idx 
			vx: vx + unit
			vy: vy + unit
			y: y + 1
		]
		rcvFFT vectBlkX vectBlkY dir scaling
		headX: headX + 1
		headY: headY + 1
		x: x + 1
	]
]

rcvFFT2DShift: routine [
	array		[block!]		;--block of vectors
	return: 	[block!]		;--idem
	/local
	headX		[red-value!]
	tailX		[red-value!]
	vectBlkX	[red-vector!]
	x*			[red-vector!]
	s			[series!]
	blk 		[red-block!]
	blk2		[red-block!]
	unit		[integer!]
	nx			[integer!]
	ny			[integer!]
	n 			[integer!]
	idx			[integer!]
][
	headX: block/rs-head array
	tailX: block/rs-tail array
	ny: block/rs-length? array
	vectBlkX: as red-vector! headX
    nx: vector/rs-length? vectBlkX
	s: GET_BUFFER(vectBlkX)		
	unit: GET_UNIT(s)
	x*: vector/make-at stack/push* nx * ny TYPE_FLOAT unit
	
	; shift columns
	blk: as red-block! stack/push*;arguments
	block/make-at blk ny
	while [headX < tailX] [
		vectBlkX: as red-vector! headX
		x*: rcvFFTShift vectBlkX
		block/rs-append blk as red-value! x*
		headX: headX + 1
	]
	; shift lines
	either ny % 2 = 0 [n: ny / 2][n: ny / 2 + 1]
	blk2: as red-block! stack/push*;arguments
	block/make-at blk2 ny
	headX: block/rs-head blk
	idx: 0
	while [idx < n] [
		vectBlkX: as red-vector! headX + (idx + n)
		block/rs-append blk2 as red-value! vectBlkX
		idx: idx + 1
	]
	idx: 0
	while [idx < n] [
		vectBlkX: as red-vector! headX + (idx)
		block/rs-append blk2 as red-value! vectBlkX
		idx: idx + 1
	]
	as red-block! stack/set-last as cell! blk2
]

rcvTransposeArray: routine [
"Makes a matrix tranposition"
	bArray 	[block!] 		; array of vectors
	return: [vector!] 		; vector
	/local
	yValue	[red-value!]
	xValue	[byte-ptr!]	
	xValue2	[byte-ptr!]
	p8		[float-ptr!]
	p8*		[float-ptr!]
	p4		[float32-ptr!]
	p4*		[float32-ptr!]
	vectBlk	[red-vector!] 
	vect	[red-vector!]
	s		[series!]
	idx		[integer!]
	idy		[red-value!]	
	ny		[integer!]
	nx		[integer!]
	i		[integer!] 
	j		[integer!] 
	unit	[integer!]
][
	ny: block/rs-length? bArray
	yValue: block/rs-head bArray
	vectBlk: as red-vector! yValue
	xValue: vector/rs-head vectBlk
	nx: vector/rs-length? vectBlk
	s: GET_BUFFER(vectBlk)
	unit: GET_UNIT(s)
	
	vect: vector/make-at stack/push* nx * ny TYPE_FLOAT unit
	xValue2: vector/rs-head vect
	p4*: as float32-ptr! xValue2
	p8*: as float-ptr! xValue2
	i: 1 
	idx: 1
	while [i <= nx] [
		j: 0 
		while [j < ny] [
			idy: yValue + j
			vectBlk: as red-vector! idy 
			xValue: vector/rs-head vectBlk
			switch unit [ 
				4 [p4: as float32-ptr! xValue p4*/idx: p4/i]
				8 [p8: as float-ptr! xValue p8*/idx: p8/i]
			]
			idx: idx + 1
			j: j + 1
		]
		i: i + 1
	]
	s: GET_BUFFER(vect)
	;-- set the tail properly
	switch unit [
		4 [s/tail: as cell! (as float32-ptr! s/offset) + (nx * ny)]
		8 [s/tail: as cell! (as float-ptr! s/offset) + (nx * ny)]
	]   
    as red-vector! stack/set-last as cell! vect  ;-- return the new vector      		
]

rcvArray2Vector: routine [
"Block of vectors (Array) to matrix (vector)"
	array 		[block!] 	; array of vectors
	return: 	[vector!]	;1-D vector
	/local
	headX		[red-value!]
	tailX		[red-value!]
	x* 			[red-vector!]
	vectBlkX	[red-vector!]
	vx 			[byte-ptr!]
	s			[series!]
	unit		[integer!]
	nx			[integer!]
	ny			[integer!]
	y			[integer!]
	x			[integer!]
	idx			[integer!]
	p4			[float32-ptr!]
	p8			[float-ptr!]
][
	headX: block/rs-head array
	tailX: block/rs-tail array
	ny: block/rs-length? array
	vectBlkX: as red-vector! headX
	vx: vector/rs-head vectBlkX
    nx: vector/rs-length? vectBlkX
    s: GET_BUFFER(vectBlkX)
	unit: GET_UNIT(s)	
	x*: vector/make-at stack/push* nx * ny TYPE_FLOAT unit		 
	y: 0
	while [headX < tailX] [
		vectBlkX: as red-vector! headX
		vx: vector/rs-head vectBlkX
    	p4: as float32-ptr! vector/rs-head x*
		p8: as float-ptr! vector/rs-head x*
		x: 0
		while [x < nx] [
			idx: y * nx + x + 1
			switch unit [
				4 [p4/idx: as float32! vector/get-value-float vx unit]
				8 [p8/idx: vector/get-value-float vx unit]
			]
			vx: vx + unit
			x: x + 1
		]
		y: y + 1
		headX: headX + 1
	]
	s: GET_BUFFER(x*)
	switch unit [
		4 [s/tail: as cell! (as float32-ptr! s/offset) + (nx * ny)]
		8 [s/tail: as cell! (as float-ptr! s/offset) + (nx * ny)]
	]
	as red-vector! stack/set-last as cell! x* 
]


rcvFFTImage: func [
"A generic function for image FFT"
	src			[image!]
	return: 	[image!]
	/forward /backward
][
	dst:  	 rcvCreateImage src/size			;--for returned image
	matLog:  matrix/init 3 64 src/size			;--for log scale matrix
	matIntF: matrix/init 2 32 src/size			;--integer matrix
	matIntB: matrix/init 2 32 src/size			;--integer matrix
	matRe: 	 matrix/init 3 64 src/size			;--real
	matIm: 	 matrix/init 3 64 src/size			;--imaginary
	matAm:   matrix/init 3 64 src/size			;--amplitude
	rcvImage2Mat src matIntF					;--grayscale image to matrix
	matRe:  rcvMatInt2Float matIntF 64 1.0		;--integer mat to float mat
	arrayR: rcvMat2Array matRe 					;--array of real
	arrayI: rcvMat2Array matIm 					;--array of imaginary
	
	;--forward FFT with 1/N scaling
	rcvFFT2D arrayR arrayI 1 1	
	;--get FFT magnitude				
	matAm/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI
	;--rotate the 4 quadrants and center matrix						
	matAm/data: rcvTransposeArray rcvFFT2DShift rcvMat2Array matAm src/size	
	;--scale image with log-10
	matLog: rcvLogMatFloat matAm 1.0			
	matIntF: rcvMatFloat2Int matLog 32 255.0	
	
	; backward FFT without scaling
	rcvFFT2D arrayR arrayI -1 0		
	;--FFT amplitude			
	matAm/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI								
	;--scale image with log-10
	matLog: rcvLogMatFloat matAm 255.0			
	matIntB: rcvMatFloat2Int matLog 32 255.0
	case [
		forward 	[rcvMat2Image matIntF dst]	;--to red image
		backward	[rcvMat2Image matIntB dst]	;--to red image
	]
	dst
]

rcvFFTMat: func [
"Return amplitude matrices calculated by FFT"
	matRe	[object!]
	matIm	[object!]
	return: [object!]
	/forward /backward
][
	if matrix/_matSimilar? matRe matIm [
		if all [matRe/type = 3 matIm/type = 3] [
			mSize: 	as-pair matRe/cols matRe/rows
			matAmF:	matrix/init 3 64 mSize
			matAmB:	matrix/init 3 64 mSize
			arrayR: rcvMat2Array matRe 				
			arrayI: rcvMat2Array matIm 	
			
			;--forward FFT with scaling				
			rcvFFT2D arrayR arrayI 1 1
			;--FFT magnitude			
			matAmF/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI
			;4-quadrant rotation
			matAmF/data: rcvTransposeArray rcvFFT2DShift rcvMat2Array matAmF mSize
			
			; backward FFT without scaling 
			rcvFFT2D arrayR arrayI -1 0	
			matAmB/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI
			
			case [
				forward 	[return matAmF]	
				backward	[return matAmB]
			]			
		]
	]
]

;--testing

rcvFFTConvolve: func [
"FFT convolution of 2 images"
	src1		[image!]
	src2		[image!]
	return: 	[image!]
][
	dst:  	 	rcvCreateImage src1/size
	matInt1: 	matrix/init 2 32 src1/size
	matInt2: 	matrix/init 2 32 src2/size
	matLog:  	matrix/init 3 64 src1/size
	matI1:	  	matrix/init 3 64 src1/size
	matI2:	  	matrix/init 3 64 src2/size
	matAm:   	matrix/init 3 64 src1/size
	matAm1:   	matrix/init 3 64 src1/size
	matAm2:   	matrix/init 3 64 src2/size
	matR:		matrix/init 3 64 src1/size
	matI:		matrix/init 3 64 src1/size
	;--image to matrix
	rcvImage2Mat src1 matInt1
	rcvImage2Mat src2 matInt2
	;--transform to float matrices
	matR1:  	rcvMatInt2Float matInt1 64 1.0
	matR2:  	rcvMatInt2Float matInt2 64 1.0
	
	;--we need arrays for FFT
	arrayR1: 	rcvMat2Array matR1
	arrayR2: 	rcvMat2Array matR2
	arrayI1: 	rcvMat2Array matI1
	arrayI2: 	rcvMat2Array matI2
	
	;--Forward FFT for both images with scaling 1/n
	rcvFFT2D arrayR1 arrayI1 1 1	
	rcvFFT2D arrayR2 arrayI2 1 1
	matI1/data: rcvArray2Vector arrayI1
	matI2/data: rcvArray2Vector arrayI2
	matAm1/data: rcvFFTAmplitude rcvArray2Vector arrayR1 rcvArray2Vector arrayI1
	matAm2/data: rcvFFTAmplitude rcvArray2Vector arrayR2 rcvArray2Vector arrayI2
	
	;--Product of both matrices
	matR: matrix/HadamardProduct matAm1 matAm2
	matI: matrix/HadamardProduct matI1 matI2
	arrayR: rcvMat2Array matR
	arrayI: rcvMat2Array matI
	
	;--Inverse FFT on product matrix
	rcvFFT2D arrayR arrayI -1 0	
	matAm/data: rcvFFTAmplitude rcvArray2Vector arrayR rcvArray2Vector arrayI
	matAm/data: rcvTransposeArray rcvFFT2DShift rcvMat2Array matAm src1/size
	matLog: rcvLogMatFloat matAm 255.0	
	matInt1: rcvMatFloat2Int matLog 32 255.0
	;--return result image
	rcvMat2Image matInt1 dst
	dst
]



