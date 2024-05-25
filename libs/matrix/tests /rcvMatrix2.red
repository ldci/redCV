#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Toomas Vooglaid, Francois Jouen and Xie Qingtian"
	File: 	 %rcvMatrix2.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;-------------------------------Matrix (mx)----------------------------------------------
;--mx is a special vector where matrix properties are inserted at the head of matrix
;--mType: matrix type as integer [1: Char, 2: Integer, 3: Float]
;--bitSize: bit-size as integer [8 | 16 | 32 for integer! and char!, 32 | 64 for float!]
;--mSize: matrix size as pair with m rows and n columns (e.g 3x3)
;--mData: matrix values as block transformed into vector for fast computation 
;----------------------------------------------------------------------------------------

;--private undocumented functions
;--all indexing functions must take account the matrix header
;--this will probably be modified with Qingtian

;Index of Rows and Cols
_ROWS: 3
_COLS: 4
_HLEN: 4
;_HEADER: [mType bitSize rows cols]

;--row x col index with header offset
_getIdx: func [
	mx			;--matrix
	row 		[integer!]
	col			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	add _HLEN index? at mx row - 1 * cols + col
] 

;--real row index with header offset
_getRowIdx: func [
	mx			;--matrix
	idx			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	add _HLEN  1 + to-integer idx - 1 / cols
]

;--real column index with header offset
_getColIdx: func [
	mx			;--matrix
	idx			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	add _HLEN idx - 1 % cols + 1
]

;--get value : similar to rcvGetAt to be deleted?
_getAt: func [
	mx		;--matrix
	row			[integer!] 
	col			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	add _HLEN  pick mx row - 1 * cols + col
]

;--public functions

rcvCreateMat2: function [
"Creates rows x columns matrix"
    mType 	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    bitSize [integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize 	[pair!]    "Size of matrix (COLSxROWS)"
    mData 	[block!]   "Matrix data"
][
    cols: mSize/x
    rows: mSize/y
    t: pick [char! integer! float!] mType 
    v: make vector! reduce [t bitSize mData]
	d: reduce [mType bitSize rows cols]
	if find [1 3] mType [
		forall d [
			d/1: switch mType [
				1 [to-char d/1] 
				3 [to-float d/1]
			]
		]
	]
	insert v d
    v
]

;--matrix methods
rcvGetMatHeader: func [
"Return matrix properties (block)" 
	mx 		[vector!] "Matrix"
	/local
		h 	[block!] "Header"
][
	h: to-block copy/part mx _HLEN 
	forall h [h/1: to-integer h/1] 
	h
]
rcvGetMatData: func [
"Return matrix values (vector)"
	mx		;--matrix
][
	copy skip mx _HLEN	;--we need copy to extract data
]

rcvGetMatOrder:	 func [
"Return matrix size (pair)"
	mx			;--matrix
	/local
		rows	[integer!]
		cols	[integer!]
		_		[integer!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	;COLSxROWS
	as-pair to-integer cols to-integer rows
]

;--similar routine in rcvMatrix.red
rcvGetAt: func [
"Get value at mxn coordinate"
	mx			;--matrix
	row 		[integer!]
	col			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	add _HLEN  pick mx row - 1 * cols + col
]

;--similar routine in rcvMatrix.red
rcvSetAt: func [
"Set value at mxn coordinate"
	mx			;--matrix
	row 		[integer!]
	col			[integer!]
	value		[char! integer! float!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	poke mx row - 1 * cols + col + _HLEN value
]

rcvGetCol: func [
"Return a new matrix column n (vector)"
	mx			;--matrix
	col 		[integer!]
	return: 	[vector!]
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	make vector! extract at to-block mx col + _HLEN cols
]

rcvGetRow: func [
"Return a new matrix row n (vector)"
	mx			;--matrix
	row 		[integer!]
	return: 	[vector!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	make vector! copy/part at to-block mx row - 1 * cols + 1 + _HLEN cols
]

rcvRemoveRow: func [
"Remove row in matrix"
	mx			;--matrix
	row			[integer!] "Row to remove"
	/local
		cols	[integer!]
		idx		[integer!]
][
	cols: to integer! mx/:_COLS
	idx: _getIdx mx row 1
	remove/part at mx idx cols
	mx/:_ROWS: mx/:_ROWS - 1
	mx
]

rcvRemoveCol: func [
"Remove column in matrix"
	mx			;--matrix
	col			[integer!] "Column to remove"
	/local
		rows	[integer!]
		cols	[integer!]
		_		[integer!]
		data	[block!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	data: skip mx add _HLEN col - 1
	loop rows [remove data data: skip data cols - 1]
	mx/:_COLS: mx/:_COLS - 1
	mx
]

rcvInsertRow: func [
"Insert row in matrix"
	mx			;--matrix	
	block 		[block!] 
	/at 
		row 	[integer!] 
	/local 
		len 	[integer!]
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	row: any [row 1] 
	case [
		all [cols <> len: length? block len <> 1] [
			cause-error 'user 'message ["Row is not compatible!"]
		]
		cols = len [ 
			insert system/words/at mx add _HLEN row - 1 * cols + 1 block
		]
		true [
			insert/dup system/words/at mx add _HLEN row - 1 * cols + 1 block/1 cols
		]
	]
	mx/:_ROWS: mx/:_ROWS + 1
]

rcvAppendRow: func [
"Append row in matrix"
	mx 			;--matrix	
	block 		[block!]
	/local
		rows	[integer!]
][
	rows: to integer! mx/:_ROWS
	rcvInsertRow/at mx block rows + 1
]



