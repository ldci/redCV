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

;************** 1-D Fast Fourier Transform **********************
; Thanks to Mel Cepstrum and Toomas Voglaid :)
; routines and functions require float values!


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
	*re		[float-ptr!] 
	*im 	[float-ptr!]
	tre 	[float!] 
	tim 	[float!] 
	m		[integer!]
	n 		[integer!] 
	i 		[integer!] 
	i1 		[integer!] 
	i2 		[integer!] 
	j 		[integer!] 
	k 		[integer!]  
	l  		[integer!] 
	l1 		[integer!] 
	l2 		[integer!]
	u1 		[float!]  
	u2 		[float!] 
	c1 		[float!] 
	c2 		[float!] 
	z		[float!]
	f		[float!]
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
	if scaling = 0 [f: 1.0]	; no scaling
	if scaling = 1 [f: 1.0 / as float! n]
	if scaling = 2 [f: 1.0 / sqrt as float! n]
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
	s		[series!]
	i		[integer!] 
	n		[integer!]
	px*		[float-ptr!]
][
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
	i		[integer!] 
	n		[integer!]
	px*		[float-ptr!]
	f		[float!]
][
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
		f: (as float! i) / (n * delta)
		px*/value: f
		px*: px* + 1
		i: i + 1
	]
	either n % 2 = 0 [n*: n / 2 + 1][n*: n / 2]
	i: 0 
	while [i <= n*] [
		f: (as float! i) / (n * delta)
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
	p4		[int-ptr!]
	p4*		[int-ptr!]
	p4**	[int-ptr!]
	s		[series!]
	n*		[integer!]
	n		[integer!]
	idx		[integer!]
	unit	[integer!]
	vf1		[float!]
	vf2		[float!]
	vi1		[integer!]
	vi2		[integer!]
][
	n: vector/rs-length? x		; length
	head: vector/rs-head x		; head
	s: GET_BUFFER(x)			; series
	unit: GET_UNIT(s)			; unit
	either unit <= 4 [xx: vector/make-at stack/push* n TYPE_INTEGER unit] 
					 [xx: vector/make-at stack/push* n TYPE_FLOAT unit] 
	
	x*: vector/rs-head xx		; head
	either n % 2 = 0 [n*: n / 2 - 1][n*: (n - 1) / 2]
	idx: 0
	either unit <= 4 [
		while [idx <= n*] [
			p4: as int-ptr! head + (idx * unit)
			vi1: p4/value
			p4: as int-ptr! head + (idx + n* + 1 * unit)
			vi2: p4/value
			p4*:  as int-ptr! x* + (idx * unit)
			p4**: as int-ptr! x* + (idx + n* + 1 * unit)
			p4*/value: 	vi2			; swap value
			p4**/value: vi1			; temp value
			idx: idx + 1
		]
	][
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
	n: vector/rs-length? x		; length
	xx: vector/make-at stack/push* n TYPE_FLOAT 8
	s: GET_BUFFER(x)			; series
	unit: GET_UNIT(s)			; unit
	head: vector/rs-head x		; head
	tail: vector/rs-tail x		; tail
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


;************** 2-D Fast Fourier Transform **********************
;Perform a 2D FFT inplace given a complex 2D array
;The direction dir, 1 for forward, -1 for reverse
;Only float matrices!!!

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
	nx 			[integer!]
	ny			[integer!]
	idx			[integer!]
	x 			[integer!]
	y			[integer!]
	unit		[integer!]
][
	unit: 8
	headX: block/rs-head re
	tailX: block/rs-tail re
	headY: block/rs-head im
	vectBlkY: as red-vector! headY
	vectBlkX: as red-vector! headX
    nx: vector/rs-length? vectBlkX
    ny: block/rs-length? re 
	;Transform the rows
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
	; transform cols
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
	array		[block!]
	return: 	[block!]
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
	either unit <= 4 [x*: vector/make-at stack/push* nx * ny TYPE_INTEGER unit] 
					 [x*: vector/make-at stack/push* nx * ny TYPE_FLOAT unit] 
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
	p4		[int-ptr!]
	p4*		[int-ptr!]
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
	either unit <= 4 [vect: vector/make-at stack/push* nx * ny TYPE_INTEGER unit] 
					 [vect: vector/make-at stack/push* nx * ny TYPE_FLOAT unit] 
	xValue2: vector/rs-head vect
	p4*: as int-ptr! xValue2
	p8*: as float-ptr! xValue2
	i: 1 
	idx: 1
	while [i <= nx] [
		j: 0 
		while [j < ny] [
			idy: yValue + j
			vectBlk: as red-vector! idy 
			xValue: vector/rs-head vectBlk
			either unit <= 4 
				[p4: as int-ptr! xValue p4*/idx: p4/i]
				[p8: as float-ptr! xValue p8*/idx: p8/i]
			idx: idx + 1
			j: j + 1
		]
		i: i + 1
	]
	s: GET_BUFFER(vect)
    s/tail: as cell! (as float-ptr! s/offset) + (nx * ny)   ;-- set the tail properly
    as red-vector! stack/set-last as cell! vect        		;-- return the new vector
]

rcvFFTImage: func [
"A simple function for image FFT"
	src			[image!]
	return: 	[image!]
	/forward /backward
][
	dst:  	 rcvCreateImage src/size			; for returned image
	matLog:  rcvCreateMat 'float! 64 src/size	; for log scale matrix
	matIntF: rcvCreateMat 'integer! 32 src/size	; integer matrix
	matIntB: rcvCreateMat 'integer! 32 src/size	; integer matrix
	matRe: 	 rcvCreateMat 'float! 64 src/size	; real
	matIm: 	 rcvCreateMat 'float! 64 src/size	; imaginary
	rcvImage2Mat src matIntF					; grayscale image to matrix
	rcvMatInt2Float matIntF matRe 255.0			; integer mat to float mat
	arrayR: rcvMat2Array matRe src/size			; array of real
	arrayI: rcvMat2Array matIm src/size			; array of imaginary
	rcvFFT2D arrayR arrayI 1 1					; forward FFT with scaling
	matR: 	rcvArray2Mat arrayR					; real vector
	matI: 	rcvArray2Mat arrayI					; imaginary vector
	mat:  	rcvFFTAmplitude matR matI			; FFT amplitude
	arrayS: rcvMat2Array mat src/size			; we need an array	for shift
	mat: 	rcvFFT2DShift arrayS src/size		; centered mat
	arrayC: rcvTransposeArray mat				; rotated mat
	rcvLogMatFloat arrayC matLog				; scale amplitude  by log is better
	rcvMatFloat2Int matLog matIntF 255.0		; to integer matrix	
	rcvFFT2D arrayR arrayI -1 0					; backward FFT without scaling
	matR: rcvArray2Mat arrayR					; real vector
	matI: rcvArray2Mat arrayI					; imaginary vector
	rcvLogMatFloat (matR + matI) matLog			; scale amplitude  by log is better
	rcvMatFloat2Int matLog matIntB 255.0 		; to integer matrix (real + imaginary)	
	case [
		forward 	[rcvMat2Image matIntF dst]	; to red image
		backward	[rcvMat2Image matIntB dst]	; to red image
	]
	dst
]




