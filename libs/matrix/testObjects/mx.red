Red [
]

mx: object [
	type: 	[integer!]
	bits:	[integer!]
	rows:	[integer!]
	cols:	[integer!]
	data: 	[vector!]
]

getMatObject: routine [
	mObj	[object!]
	/local
	size
	s
	p
	t b r c
	v
	pp
][
	size: object/get-size mObj
	s: object/get-values mObj
	print ["Object Size: " size lf]
	print ["Word: " object/get-words mObj lf]
	p: as int-ptr! s
	print [p lf]
	;s is a red-value! -> skip header (2)
	p: p + 2 t: p/value
	p: p + 4 b: p/value
	p: p + 4 r: p/value 
	p: p + 4 c: p/value
	print-wide [t b r c lf]
	p: p + 4
	v: as red-vector! p
	;print [vector/rs-length? v lf]
]

m1: copy mx
m1/type: 2
m1/bits: 16
m1/rows: 3
m1/cols: 3
m1/data: make vector! [1 2 3 4 5 6 7 8 9] 

getMatObject m1

probe m1/data


