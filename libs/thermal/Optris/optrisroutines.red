Red [
	Title:   "Red and Optris Binary Files"
	Author:  "ldci"
	File: 	 %optrisroutines.red
	Needs:	 View
]

;--some routines for a faster processing

getMin: routine [
"Get the minimal value in raw data as an integer"
	bin 		[binary!] 
	l			[integer!]
	mini 		[integer!]
	return:		[integer!]
	/local
	head tail 	[byte-ptr!] 
	lo hi int16 [integer!]	
][
	head: binary/rs-head bin		;--byte pointer
	tail: binary/rs-tail bin		;--byte pointer
	while [head < tail][
		lo: as integer! head/value	;--low byte
		head: head + 1
		hi: as integer! head/value	;--high byte
		head: head + 1
		int16: lo or (hi << 8)		;--16-bit integer value
		if int16 > l [int16: int16 and FFh]
		if int16 < mini [mini: int16]
	]
	mini
]

getMax: routine [
"Get the maximal value in raw data as an integer"
	bin 		[binary!] 
	l			[integer!]
	maxi 		[integer!]
	return:		[integer!]
	/local
	head tail 	[byte-ptr!] 
	lo hi int16 [integer!]	
][
	head: binary/rs-head bin		;--byte pointer
	tail: binary/rs-tail bin		;--byte pointer
	while [head < tail][
		lo: as integer! head/value	;--low byte
		head: head + 1
		hi: as integer! head/value	;--high byte
		head: head + 1
		int16: lo or (hi << 8)		;--16-bit integer value
		if int16 > l [int16: int16 and FFh]
		if int16 > maxi [maxi: int16]
	]
	maxi
]

getTempInt16Values: routine [
"Convert binary data as 16-bit integer values"
	bin 			[binary!] 
	mat				[vector!]
	l				[integer!]
	/local
	head tail 		[byte-ptr!] 
	lo hi int16 	[integer!]
][
	vector/rs-clear mat
	head: binary/rs-head bin				;--byte pointer
	tail: binary/rs-tail bin				;--byte pointer
	while [head < tail][
		lo: as integer! head/value			;--low byte (OK)
		head: head + 1
		hi: as integer! head/value			;--high byte (OK)
		head: head + 1
		int16: lo or (hi << 8)				;--16-bit integer value (OK)
		if int16 > l [int16: int16 and FFh]	;--for some outlier values (OK)
		vector/rs-append-int mat int16
	]
]

getTempLowByte: routine [
"Get low byte value"
	bin 			[binary!]
	mat				[vector!]
	l				[integer!]				;--65536 max value
	nChan			[integer!]				;--Nb of channels for image
	/local
	head tail 		[byte-ptr!] 
	lo hi int16 	[integer!]
][
	vector/rs-clear mat
	head: binary/rs-head bin				;--byte pointer
	tail: binary/rs-tail bin				;--byte pointer
	while [head < tail][
		lo: as integer! head/value			;--low byte (OK)
		head: head + 1
		hi: as integer! head/value			;--high byte (OK)
		head: head + 1
		int16: lo or (hi << 8)				;--16-bit integer value (OK)
		if int16 > l [int16: int16 and FFh]	;--for some outlier values
		loop nChan [vector/rs-append-int mat int16 >> 4 and FFh];-- for a grayscale img
	]
]

getCelsiusValues: routine [
"Int16 values to ° as float"
	mat		[vector!]
	minV	[integer!]
	maxV	[integer!]
	minT	[float!]
	maxT	[float!]
	return:	[vector!]
	/local
	head 			[int-ptr!]
	int16  n i 		[integer!]
	f scalef ratio	[float!]
	celsius scale	[float!]	
 	s 				[series!]
 	x*				[red-vector!] 
 	px* 			[float-ptr!]
][
	n: vector/rs-length? mat
	scale: maxT - minT
	scaleF: as float! (maxV - minV)
	head: as int-ptr! vector/rs-head mat
	x*: vector/make-at stack/push* n TYPE_FLOAT 8
	px*: as float-ptr! vector/rs-head x*
	i: 1
	while [i <= n] [
		int16: vector/get-value-int head 4
		f: as float! (int16 - minV)
		ratio: f / scaleF
		celsius: as float! minT + (ratio * scale)
		px*/i: celsius
		head: head + 1
		i: i + 1
	]
	s: GET_BUFFER(x*)
	s/tail: as cell! (as float-ptr! s/offset) + n
	as red-vector! stack/set-last as cell! x* 	
]

makeColor: routine [
"Map temperature and  color scale"
	mat 				[vector!]	;--Float matrix
	map					[block!]
	img					[image!]
	minT				[float!]
	maxT				[float!]
	/local
	pixel				[subroutine!]
	h idx				[integer!]
	handle a r g b		[integer!] 
	f n scale rt n2		[float!]						
	head tail			[byte-ptr!]
	bHead ptr			[red-value!]
	t					[red-tuple!]
	pix					[int-ptr!]
][
	handle: 0
    pix: image/acquire-buffer img :handle
    h: block/rs-length? map 
	n: as float! vector/rs-length? mat
	n2: as float! h
	head: vector/rs-head mat
	tail: vector/rs-tail mat
	bhead: block/rs-head map
	scale: maxT - minT
	ptr: bhead
	pixel: [(a << 24) OR (r << 16 ) OR (g  << 8) OR b]
	while [head < tail] [
		f: vector/get-value-float head 8
		rt: maxT - f / scale
		idx: as integer! (n2 * rt)
		if idx = 0 [idx: 1]
		ptr: bhead + idx
		t: as red-tuple! ptr
		a: 0
		r: t/array1 and FFh 
		g: t/array1 and FF00h >> 8
		b: t/array1 and FF0000h >> 16 
		pix/value: FF000000h or pixel
		head: head + 8
		pix: pix + 1
	]
	image/release-buffer img handle yes
]

makeColor2: routine [
"Map temperature and  color scale"
	mat 					[vector!]	;--Integer matrix
	map						[block!]
	img						[image!]
	minV					[integer!]
	maxV					[integer!]
	/local
	pixel					[subroutine!]
	h idx int				[integer!]
	handle a r g b			[integer!] 
	ff n scale rt n2		[float!]						
	head tail				[byte-ptr!]
	bHead ptr				[red-value!]
	t						[red-tuple!]
	pix						[int-ptr!]
	fint
][
	handle: 0
    pix: image/acquire-buffer img :handle
    h: block/rs-length? map 
	n: as float! vector/rs-length? mat
	n2: as float! h
	head: vector/rs-head mat
	tail: vector/rs-tail mat
	bhead: block/rs-head map
	scale: as float! (maxV - minV)
	ff: as float! maxV
	ptr: bhead
	pixel: [(a << 24) OR (r << 16 ) OR (g  << 8) OR b]
	while [head < tail] [
		int: vector/get-value-int as int-ptr! head 4
		fint: as float! int
		rt: ff - fint / scale
		idx: as integer! (n2 * rt)
		if idx = 0 [idx: 1]
		ptr: bhead + idx
		t: as red-tuple! ptr
		a: 0
		r: t/array1 and FFh 
		g: t/array1 and FF00h >> 8
		b: t/array1 and FF0000h >> 16 
		pix/value: FF000000h or pixel
		head: head + 4
		pix: pix + 1
	]
	image/release-buffer img handle yes
]

;--ATTENTION: These routines are zero-based

getBinAddress: routine [
"Address of binary data first value"
	bin		[binary!]
	return:	[integer!]
][
	as integer! binary/rs-head bin
]

;--if  we do not know the address of the first value
_getBinaryValue: routine [
	bin				[binary!]
	dataAddress 	[integer!] 
	dataSize 		[integer!] 
	return: 		[binary!]
	/local
	head			[byte-ptr!]
][
	head: binary/rs-head bin
	head: head + dataAddress
	as red-binary! stack/set-last as red-value! binary/load head dataSize
]

;--if we know the binary data address
getBinaryValue: routine [
	dataAddress 	[integer!] 
	dataSize 		[integer!] 
	return: 		[binary!]
][
	as red-binary! stack/set-last as red-value! binary/load as byte-ptr! dataAddress dataSize
]


