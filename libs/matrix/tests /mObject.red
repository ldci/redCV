Red [
]

matrix: make object! [
	;--matrix values
	data:	[]	;-- data 
	rows: 	0	;--rows
	cols: 	0	;--cols
	unit:	0	;--unit
	
	;-- matrix methods
	get-order: does [to-pair reduce [rows cols]]
	get-col: func [col][extract at data col cols]
	get-row: func [row][copy/part at data row - 1 * cols + 1 cols]
]

getMatObject: routine [
	mObj	[object!]
	/local
	size	[integer!]
	s 		[red-value!]
	p		[int-ptr!] 
	pf		[float-ptr!]
	x		[integer!]
	y		[integer!]
	m
	n
	u
	d
	i
	blk
	head
	tail
	v vf
][
	size: object/get-size mObj
	s: object/get-values mObj
	print ["Object Size: " size lf]
	p: as int-ptr! s
	;s is a red-value! -> skip header (2 + size)
	p: p + 6 m: p/value
	p: p + 4 n: p/value
	p: p + 4 u: p/value 
	print-wide [m n u lf]
	
	;first we have a block with data
	blk: as red-block! s
	head: block/rs-head blk
	tail: block/rs-tail blk
	print ["Data block size: "  block/rs-length? blk lf]
	if u < 8 [
		i: 1
		while [head < tail] [
			v: as red-integer! head
			print-wide [i ": "  v/value lf]
			i: i + 1
			head: head + 1
		]
	]
	
	if u = 8 [
		i: 1
		while [head < tail] [
			vf: as red-float! head
			print-wide [i ": "  vf/value lf]
			i: i + 1
			head: head + 1
		]
	]
]

print "Char Matrix"
m1: copy matrix
m1/rows: 3
m1/cols: 3
m1/unit: 1
m1/data: [1 2 3 4 5 6 7 8 9] 
getMatObject m1
{print lf
print "Integer Matrix"
m2: copy matrix
m2/rows: 2
m2/cols: 2
m2/unit: 4
m2/data: [1 2 3 4] 
getMatObject m2
print lf 
print "Float Matrix"
m3: copy matrix
m3/rows: 2
m3/cols: 2
m3/unit: 8
m3/data: [0.5 1.3 4.7 0.6] 
getMatObject m3}

print "Test"

print ["Matrix Order: " m1/get-order]
i: 1
while [i <= m1/rows] [
	print ["Row " i ": " m1/get-row i]
	i: i + 1
]
print ""
i: 1
while [i <= m1/rows] [
	print ["Col " i ": " m1/get-col i]
	i: i + 1
]

;array: [[1 2 3] [4 5 6] [7 8 9]]






