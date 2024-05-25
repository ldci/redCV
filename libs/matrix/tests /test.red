Red [
]

#system-global [#include %matrix.reds]


createMat: routine [
	m		[integer!]	;--rows
	n		[integer!]	;--cols
	type	[integer!]	;--mByte, mInteger or mFloat
	return:	[integer!]
	/local 
	_m		[red-mat!] 
	blk		[red-block!]
	p
][
	_m: matrix/make m n type
	print-wide [size? _m _m/rows _m/cols _m/data lf]
	print-wide ["Unit: " _m/unit "Size:" matrix/rs-length? _m lf]
	as integer! (as byte-ptr! _m)
]


readMat: routine [
	address	 [integer!]
	/local
	p
][
	p: as int-ptr! address
	print-wide [p/value lf]
	p: p + 1
	print-wide [p/value lf]
]



;-tests
m1: createMat 3 3 0
m2: createMat 4 3 1

probe m1
probe m2
;readMat m1
;readMat m2

;m3: createMat 3 3 2
;probe m3





