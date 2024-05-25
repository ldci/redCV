#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "Toomas Vooglaid, François Jouen and Xie Qingtian"
	File: 	 %rcvMatrix2.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;-------------------------------matrix (mx)----------------------------------------------
;--mx is a special vector where matrix properties are inserted at the head of the vector
;--mType: matrix type as integer [1: Char, 2: Integer, 3: Float]
;--mBitSize: bit-size as integer [8 | 16 | 32 for integer! and char!, 32 | 64 for float!]
;--mSize: matrix size as pair with m rows and n columns (e.g 3x3)
;--mData: matrix values as block transformed into vector for fast computation 
;----------------------------------------------------------------------------------------

;--private undocumented functions
;--all indexing functions must take account the matrix header
;--this will probably be modified with Qingtian

;Indexes of Header elements
_TYPE: 1
_BITS: 2
_ROWS: 3
_COLS: 4
_HLEN: 4
;_HEADER: [mType mBitSize rows cols]

;--row x col index
_getIdx: func [
	mx			;--matrix
	row 		[integer!]
	col			[integer!]
	return: 	[integer!]
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	;--real index in vector with header offset
	;otherwise  mdata: rcvGetMatData mx
	;index? at mdata row - 1 * h/3 + col
	add _HLEN  index? at mx row - 1 * cols + col
] 

;--real row index
_getRowIdx: func [
	mx			;--matrix
	idx			[integer!]
	return: 	[integer!]
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	1 + to-integer idx - 1 / cols
]

;--real column index
_getColIdx: func [
	mx			;--matrix
	idx			[integer!]
	return: 	[integer!]
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	idx - 1 % cols + 1
]

;--get value : similar to rcvGetAt to be deleted?
_getAt: func [
	mx			;--matrix
	row			[integer!] 
	col			[integer!]
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	pick mx add _HLEN row - 1 * cols + col
]

_product: func [blk [block!] /local out][out: 1 forall blk [out: out * blk/1] out]

;--swap matrix dimensions
_swapDim: func [
    mx ;--matrix
    /local
        cols	[integer!]
][
    cols: mx/:_COLS 
    mx/:_COLS: mx/:_ROWS 
    mx/:_ROWS: cols
]

_matSizeEQ?: func [
"Have matrices equivalent size?"
	mx1		;--matrix
	mx2		;--matrix
	return:	[logic!]
	/local
	h1		[block!]
	h2		[block!]
	
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	all [h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
]

_matTypeEQ?: func [
"Have matrices equivalent type?"
	mx1		;--matrix
	mx2		;--matrix
	return:	[logic!]
	/local
	h1		[block!]
	h2		[block!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	h1/:_TYPE = h2/:_TYPE 
]

_matDepthEQ?: func [
"Have matrices equivalent bit-size?"
	mx1		;--matrix
	mx2		;--matrix
	return:	[logic!]
	/local
	h1		[block!]
	h2		[block!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	h1/:_BITS = h2/:_BITS	
]

_matSimilar?: func [
"Are matrices similar?"
	mx1		;--matrix
	mx2		;--matrix
	return:	[logic!]
	/local
	h1		[block!]
	h2		[block!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	All [h1/:_TYPE = h2/:_TYPE h1/:_BITS = h2/:_BITS 
	h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
]

;--basic math operator
_matOp: func [
	mx1		;--matrix
	mx2		;--matrix
	op		[integer!]	;--operator
	return:	[vector!]	;--matrix
	/local
	h		[block!]
	b1		[vector!]
	b2		[vector!]
	mData	[vector!]
][
	either _matSimilar? mx1 mx2 [	
		h: rcvGetMatHeader mx1
		b1: make vector! to-block  rcvGetMatData mx1
		b2: make vector! to-block  rcvGetMatData mx2
		switch op [
			0 [mData: b1  +  b2]	;--Add
			1 [mData: b1  -  b2]	;--Substract
			2 [mData: b1 AND b2]	;--and
			3 [mData: b1 OR  b2]	;--or
			4 [mData: b1 XOR b2]	;--xor
			5 [mData: b1  *  b2]	;--* Hadamard
		]
		rcvCreateMat h/:_TYPE h/:_BITS as-pair h/:_COLS h/:_ROWS to-block mData
	][cause-error 'user 'message ["The two matrices must be similar"]]
]

;--scalar operator
_matScalarOp: func [
	mx		;--matrix
	op		[integer!]	;--operator
	value	[number!]	;--scalar value
	return:	[vector!]	;--matrix
	/local
	_mx		[vector!] ;--matrix
	v		[vector!] ;--matrix
	val		[number!]
][
	_mx: copy mx
	v: rcvGetMatData _mx
	case [
		all [op >= 0 op < 8][
			switch op [
				0 [v + value]	;--Add
				1 [v - value]	;--Substract
				2 [v * value]	;--Multiply
				3 [forall v [
					val: v/1 / value
					if type? v/1 = integer! [val: to-integer val]
					v/1:  val
					]
				]		
				4 [v % value]	;--Remainder
				5 [v AND value]	;--and
				6 [v OR  value]	;--or
				7 [v XOR value]	;--xor
			]
		]
		all [op >= 8 op < 10][
			switch op [
				8 [forall v [v/1:  v/1 >> value]]	;-->>
				9 [forall v [v/1:  v/1 << value]]	;--<<
			   10 [forall v [v/1:  v/1 >>> value]]	;-->>>
			]
		]
	]
	change skip _mx _HLEN to-block v
	_mx
]

;--Reduced Row Eschelon Form
_matRREF: func [
	mx 		;--matrix
	return: [vector!] ;--matrix
	/local 
		m1 		;--matrix
		c		;--matrix
		h		[block!]		
		i		[integer!] 
		j 		[integer!]
		t		[integer!]
		sz		[pair!]
		val		[char! integer! float!]
		data	[block!]
][
	h: rcvGetMatHeader mx
	t: h/:_TYPE
	sz: as-pair h/:_COLS h/:_ROWS
	data: to-block skip mx _HLEN
	switch t [
		1 [forall data [data/1: 1.0 * to-integer data/1]]
		2 [forall data [data/1: 1.0 * data/1]]
	]
	m1: rcvCreateMat 3 32 sz data
	repeat i h/:_ROWS [
		; make the pivot
		if zero? (rcvGetAt m1 i i) [
			c: at rcvGetCol m1 i i + 1
			until [
				c: next c 
				if tail? c [
					cause-error 'user 'message ["Impossible to get reduced row eschelon form!"]
				] 
				0 < first c
			]
			rcvMatSwitchRows m1 i index? c 
		]
		; reduce it to 1
		if 1 <> (val: rcvGetAt m1 i i) [
			ri: _getIdx m1 i 1
			data: to-block divide (rcvGetRow m1 i) val
			change/part at m1 ri data h/:_COLS
		]
		; reduce other rows at this column to 0 
		repeat j h/:_ROWS [
			if all [j <> i 0 <> (c: rcvGetAt m1 j i)][
				ri: _getIdx m1 j 1
				data: to-block (rcvGetRow m1 j) - (c * rcvGetRow m1 i)
				change/part at m1 ri data h/:_COLS
			]
		]
	]
	m1
]

;********************** Matrix Creation ************************ 
rcvCreateMat: function [
"Creates rows x columns matrix"
    mType 	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    mBitSize [integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize 	[pair!]    "Size of matrix (COLSxROWS)"
    mData 	[block!]   "Matrix data or length"
	return: [vector!];--matrix
][
    cols: mSize/x
    rows: mSize/y
    t: pick [char! integer! float!] mType
	v: make vector! reduce [t mBitSize mData]
	d: reduce [mType mBitSize rows cols]
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

rcvInitMat: function [
"Initialise and Create rows x columns matrix"
    mType 	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    mBitSize [integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize 	[pair!]    "Size of matrix (COLSxROWS)"
	/value
		val [char! integer! float!]
	/rand
	/bias
		base [char! integer! float!]
	/local
		t		[integer!]
		v		[char! integer! float!]
		rows	[integer!]
		cols	[integer!]
		mData 	[block!]
	return: 	[vector!] ;--matrix
][
	t: pick [char! integer! float!] mType
	cols: mSize/x
    rows: mSize/y
	mData: make vector! reduce [t mBitSize rows * cols]
	if value [
		if rand [random/seed now]
		forall mData [
			v: val
			case/all [
				rand [v: random v]
				bias [v: base + v]
			]
			mData/1: v
		]
	]
	rcvCreateMat mType mBitSize mSize to-block mData
]

rcvCreateMatScalar: function [
"Creates a scalar matrix"
	mType 	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    mBitSize [integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize 	[pair!]    "Size of matrix (COLSxROWS)"
    scalar	[integer!] "Scalar value"
    return: [vector!]  ;--matrix  
][
	cols: mSize/x
    rows: mSize/y
    either rows = cols[
    	data: copy []
    	switch mType [
    		1	[v0: to-char 0 v1: to-char scalar]
    		2	[v0: 0 v1: scalar]
    		3	[v0: to-float 0 v1: to-float scalar]
   		]
    	repeat i rows [repeat j cols [append data either i = j [v1][v0]]]
    	rcvCreateMat mType mBitSize mSize data
    ][
    	cause-error 'user 'message ["Square matrix required"]
    ]
]

rcvCreateMatIdentity: function [
"Creates I identity matrix"
    mType     	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    mBitSize 	[integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize     	[pair!]    "Size of matrix (COLSxROWS)"
    return: 	[vector!]	;--matrix
][
    rcvCreateMatScalar mType mBitSize mSize 1
]

rcvCreateMatZero: function [
"Creates zero (null) matrix"
    mType     	[integer!] "Type of matrix: 1-char, 2-integer, 3-float"
    mBitSize 	[integer!] "8 | 16 | 32 for integer! and char!, 32 | 64 for float!"
    mSize     	[pair!]    "Size of matrix (COLSxROWS)"
    return: 	[vector!]	;--matrix
][
    rcvCreateMatScalar mType mBitSize mSize 0
]

rcvGetMatHeader: func [
"Return matrix properties (block)" 
	mx 		[vector!] "Matrix"
	return: [block!]
	/local
		h 	[block!] "Header"
][
	h: to-block copy/part mx _HLEN 
	forall h [h/1: to-integer h/1] 
	h
]

rcvGetMatData: func [
"Return matrix values (vector)"
	mx 		[vector!] "Matrix"
	return: [vector!]	;--matrix
][
	copy skip mx _HLEN	;--we need copy to extract data
]

rcvGetMatOrder:	 func [
"Return matrix size (pair)"
	mx 		[vector!] "Matrix"
	return: [pair!]
	/local
		rows [integer!]
		cols [integer!]
		_ 	 [integer!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	;COLSxROWS
	as-pair to-integer cols to-integer rows
]

;********************** Matrix Porperties ************************ 

rcvGetTrace: func [
"Get trace of square matrix"
    mx 		;--matrix
][
    either rcvMatSquare? mx [
        sum rcvGetDiagonal mx 1 'r
    ][
        cause-error 'user 'message ["Trace is defined for square matrices only!"]
    ]
]

;'
rcvGetDiagonal: func [
"Get matrix main diagonal"
    mx    	;--matrix
    i     	[integer!]
    dir 	[word!]
    /local
        out  [block!]
        data [vector!]
        cols [integer!]
][
    data: at rcvGetMatData mx i
    cols: to integer! mx/:_COLS
    out: collect [
        while [not tail? data][
            keep data/1 
            data: case [
                all [dir = 'r 0 = ((index? data) % cols)] [next data];'
                all [dir = 'l 1 = ((index? data) % cols)] [skip data 2 * cols - 1];'
                true [skip data cols + either dir = 'r [1][-1]];'
            ]
        ]
    ]
    out
]

rcvGetDeterminant: func [
"Get matrix determinant"
    mx 			;--matrix 
	/local 
        i 		[integer!]
        r 		[block!]
        l 		[block!]
        rw 		[vector!]
        minor 	[vector!]
        mid 	[block!]
        idx		[integer!]
        cols	[integer!]
        data	[vector!]
][
    cols: to integer! mx/:_COLS
    data: rcvGetMatData mx
    either rcvMatSquare? mx [
        switch/default cols [
            0 [1]
            1 [data/1]
            2 [(data/1 * data/4) - (data/2 * data/3)]
            3 [	r: make block! cols l: make block! cols
                repeat i cols [
                    	insert r _product rcvGetDiagonal mx i 'r
                    	insert l _product rcvGetDiagonal mx i 'l
                ]
                (sum r) - (sum l)
            ]
         ][
            mid: make block! cols
            rw: rcvGetRow mx 1 
            forall rw [
                minor: copy mx
                rcvRemoveRow minor 1
                rcvRemoveCol minor idx: index? rw
                append mid -1 ** (idx + 1) * rw/1 * rcvGetDeterminant minor
            ]
            sum mid
        ]
    ][
		cause-error 'user 'message ["Matrix must be square to find determinant!"]
    ]
]

rcvGetEigens2: func [
"Matrix eigen values"
    mx 		[vector!];--matrix
    /local
        tr	[number!]
        det	[number!]
        l1	[number!]
        l2	[number!]
][
    tr: rcvGetTrace mx
    det: rcvGetDeterminant mx
    l1: (tr + sqrt tr ** 2 - (4 * det)) / 2
    l2: (tr - sqrt tr ** 2 - (4 * det)) / 2
    reduce [l1 l2]
]

rcvMatSquare?: func [
"Square matrix?"
	mx			[vector!] "matrix"
	return: 	[logic!]
	/local
		rows 	[integer!]
		cols 	[integer!]
		_		[integer!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	rows = cols
]

rcvMatZero?: func [
"Null matrix?"
	mx		[vector!] ;--matrix
	return: [logic!]
][
	0 = to-integer rcvGetDeterminant mx
]

rcvMatSingular?: func [
"Singular matrix?"
	mx		[vector!] ;--matrix
	/only
	return: [logic!]
][
	either only [
		error? try [rcvGetDeterminant mx]
	][
		zero? rcvGetDeterminant mx
	]
]

rcvMatDegenerate?: func [
"Degenerate matrix?"
	mx		[vector!] ;--matrix
	return: [logic!]
][
	zero? rcvGetDeterminant mx
]

rcvMatInvertible?: func [
"Invertible matrix?"
	mx		[vector!] ;--matrix
	/only
	return: [logic!]
][
	either only [
		not rcvMatSingular?/only mx
	][
		not rcvMatSingular? mx
	]
]
;do we need nonsingular? nondegenerate?

rcvMatDiagonal?: func [
"Diagonal matrix?"
	mx		[vector!] ;--matrix
	return: [logic!]
	/local
	cols	[integer!]
	rows	[integer!]
	i		[integer!]
	j		[integer!]
][
	either rcvMatSquare? mx [
		cols: to integer! mx/:_COLS
		rows: to integer! mx/:_ROWS
		repeat i cols [
			repeat j rows [
				if (i <> j) AND (0 <> to-integer rcvGetAt mx i j) [return false]
			]
		]
		true
	][false]
]

rcvMatSymmetric?: func [
"Symmetric matrix?"
    mx 		[vector!] ;--matrix
    return: [logic!]
][
    ;--It must be square, and is equal to its own transpose(AT)
    either rcvMatSquare? mx [ 
        equal? skip mx _HLEN skip rcvMatTranspose copy mx _HLEN
    ][false]
]


;symmetric?: has [d [block!]][transpose d: copy data transpose equal? data d]

;********************** Matrix Elements Access ************************ 
;--similar routine in rcvMatrix.red
rcvGetAt: func [
"Get value at mxn coordinate"
	mx 			[vector!] ;--matrix
	row 		[integer!]
	col			[integer!]
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	pick mx add _HLEN row - 1 * cols + col
]

;--similar routine in rcvMatrix.red
rcvSetAt: func [
"Set value at mxn coordinate"
	mx 			[vector!] ;--matrix
	row 		[integer!]
	col			[integer!]
	value		[char! integer! float!]
	return: 	[vector!] ;--matrix
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	poke mx row - 1 * cols + col + _HLEN value
	mx
]

;********************** Matrix Rows & Columns ************************ 
rcvGetCol: func [
"Return a new matrix column n (vector)"
	mx 			[vector!] ;--matrix
	col 		[integer!]
	return: 	[vector!] ;--matrix
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	make vector! extract at to-block mx col + _HLEN cols
]

rcvGetRow: func [
"Return a new matrix row n (vector)"
	mx			[vector!]  "Matrix" ;--matrix
	row 		[integer!] "Number of row to get"
	return: 	[vector!]	;--matrix
	/local
		cols 	[integer!]
][
	cols: to integer! mx/:_COLS
	make vector! copy/part at to-block mx row - 1 * cols + 1 + _HLEN cols
]

rcvRemoveRow: func [
"Remove row in matrix"
	mx			[vector!] 	"Matrix" ;--matrix
	row			[integer!]  "Row to remove"
	return: 	[vector!]	;--matrix
	/local
		cols 	[integer!]
		idx  	[integer!]
][
	cols: to integer! mx/:_COLS
	idx: _getIdx mx row 1
	remove/part at mx idx cols
	mx/:_ROWS: mx/:_ROWS - 1
	mx
]

rcvRemoveCol: func [
"Remove column in matrix"
	mx			[vector!] 	"Matrix" ;--matrix
	col			[integer!] "Column to remove"
	return: 	[vector!]	;--matrix
	/local
		rows 	[integer!]
		cols 	[integer!]
		_	 	[integer!]
		data 	[vector!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	data: skip mx add _HLEN col - 1
	loop rows [remove data data: skip data cols - 1]
	mx/:_COLS: mx/:_COLS - 1
	mx
]

rcvInsertRow: func [
"Insert row in matrix"
	mx		 [vector!] "Matrix" ;--matrix
	block 	 [block!]  "Data to insert (needs to be of compatible length or length 1)"
	/at 
		row  [integer!] 
	return:  [vector!]
	/local 
		len  [integer!]
		cols [integer!]
][
	cols: to integer! mx/:_COLS
	row: any [row 1] 
	case [
		cols = len: length? block [ 
			insert system/words/at mx add _HLEN row - 1 * cols + 1 block
		]
		len = 1 [
			; For block of length 1 row is filled with this element
			insert/dup system/words/at mx add _HLEN row - 1 * cols + 1 block/1 cols
		]
		true [
			cause-error 'user 'message ["Inserted row is incompatible!"]
		]
	]
	mx/:_ROWS: mx/:_ROWS + 1
	mx
]

rcvAppendRow: func [
"Append row in matrix"
	mx			[vector!] "Matrix" ;--matrix
	block 		[block!]  "Data to append"
	/local
		rows	[integer!]
][
	rows: to integer! mx/:_ROWS
	rcvInsertRow/at mx block rows + 1
]

rcvInsertCol: func [
"Insert column in matrix"
	mx			[vector!] "Matrix"
	block 		[block!]  "Data to insert (needs to be of compatible length or length 1)"
	/at 
		col 	[integer!] 
	return: 	[vector!]	;--matrix
	/local 
		len  	[integer!]
		rows 	[integer!]
		i		[integer!]
		_		[integer!]
][
	either same? type? rcvGetAt mx 1 1  type? first block [
		set [_ _ rows cols] rcvGetMatHeader mx
		col: any [col 1] 
		cols: cols + 1
		case [
			any [rows = len: length? block len = 1] [ 
				repeat row rows [
					i: either len = 1 [1][row]
					insert system/words/at mx add _HLEN row - 1 * cols + col block/:i
				]
			]
			true [cause-error 'user 'message ["Inserted column is incompatible!"]]
		]
		mx/:_COLS: mx/:_COLS + 1
		mx
	][
		cause-error 'user 'message [
			"Elements of inserted block must be of same type and mBitSize as the other!"
		]
	]
]

rcvMatAppendCol: func [
"Append column in matrix"
	mx 			[vector!]	;--matrix
	block 		[block!]	
	return: 	[vector!]	;--matrix
	/local
		cols	[integer!]
][
	cols: to integer! mx/:_COLS
	rcvInsertCol/at mx block cols + 1
]

rcvMatAugment: func [
"Matrix augmentation"
	m1 			[vector!] ;--matrix
	m2 			[vector!] ;--matrix
	/local 
		i		[integer!] 
		j		[integer!] 
		k		[integer!]
		rows1	[integer!]
		cols1	[integer!]
		rows2	[integer!]
		cols2	[integer!]
][
	either all [m1/:_TYPE = m2/:_TYPE m1/:_BITS = m2/:_BITS][
		set [_ _ rows1 cols1] rcvGetMatHeader m1
		set [_ _ rows2 cols2] rcvGetMatHeader m2
		either rows1 = rows2 [
			repeat i rows1 [
				k: rows1 - i + 1
				j: _getIdx m1 k cols1 + 1
				insert at m1 j to-block rcvGetRow m2 k
			]
			m1/:_COLS: m1/:_COLS + cols2
		][
			cause-error 'user 'message ["Augmented matrix must have same number of rows as the other!"]
		]
		m1
	][
		cause-error 'user 'message ["Augmented matrix must be of same type and mBitSize as the other!"]
	]
]

rcvMatSplit: func [
"Split matrix"
	mx 			;--matrix
	col 		[integer!] 
	return: 	[vector!]	;--matrix
	/local 
		data	[block!] 
		i 		[integer!]
		j 		[integer!]
		cls		[integer!]
		type	[integer!]
		mBitSize	[integer!]
		rows	[integer!]
		cols	[integer!]
		idx		[integer!]
][
	set [type mBitSize rows cols] rcvGetMatHeader mx
	data: copy []
	cls: cols - col + 1
	repeat i rows [
		j: rows - i + 1
		idx: _getIdx mx j col
		insert data to-block take/part at mx idx cls 
	] 
	mx/:_COLS: mx/:_COLS - cls
	rcvCreateMat type mBitSize as-pair cls rows data
]

;****************** Elementary row operations ******************

rcvMatSwitchRows: function [
"Switch rows in matrix"
	mx 			[vector!]  ;--matrix
	r1 			[integer!] "First row to switch"
	r2 			[integer!] "Row with which to switch"
	/local
		cols 	[integer!]
		row1 	[block!]
		row2 	[block!]
][
	cols: to integer! mx/:_COLS
	row1: to-block rcvGetRow mx r1 
	row2: to-block rcvGetRow mx r2
	change/part at mx add _HLEN r1 - 1 * cols + 1 row2 cols 
	change/part at mx add _HLEN r2 - 1 * cols + 1 row1 cols 
	mx
]

rcvMatRowAdd: func [
"Add data to row"
	mx 			[vector!]  ;--matrix
	r 			[integer!] "Row number"
	data 		[vector!]  "Data to be added to row"
	return: 	[vector!]  ;--matrix
	/local 
		cols 	[integer!]
		row  	[vector!]
		idx  	[integer!]
][
	cols: to integer! mx/:_COLS
	either cols = length? data [ 
		row: rcvGetRow mx r
		row: to-block row + data
		idx: _getIdx mx r 1
		change/part at mx idx row cols
		mx
	][
		cause-error 'user 'message "Only data with the length of matrix columns can be added to row!"
	]
]

rcvMatRowProduct: func [
"Scalar multiplication of a matrix row"
	mx		[vector!]
	r		[integer!]
	val		[number!]
	return: [vector!]
	/local
		row  [block!]
		cols [integer!]
][
	cols: to integer! mx/:_COLS
	row: to block! val * rcvGetRow mx r
	idx: _getIdx mx r 1
	change/part at mx idx row cols
	mx
]

;********************** Matrix Transform ************************ 

rcvMatTranspose: func [
"Transpose matrix"
	mx 		[vector!]  "Matrix"
	return: [vector!]
	/local 
		d 		[block!]
		i		[integer!] 
		j		[integer!] 
		r		[integer!]
		c		[integer!]
		rows 	[integer!]
		cols 	[integer!]
		_		[integer!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	r: mx/:_ROWS
	c: mx/:_COLS
	d: make block! length? mx
	repeat i cols [
		repeat j rows [
			append d rcvGetAt mx j i
		]
	]
	mx/:_COLS: r mx/:_ROWS: c
	change skip mx _HLEN d
	mx
]

rcvMatNegate: func [
"Negate integer of float matrices" 
	mx	[vector!];--matrix
	/local
	v	[vector!]
][
	v: rcvGetMatData mx
	if type? v/1 <> char! [
		forall v [v/1: negate v/1]
		change skip mx _HLEN to-block v
	]
]


rcvMatRotate: func [
"Rotate matrix"
    mx         [vector!] 
    n          [integer!] 
    return: [vector!]
    /local 
        data [block!]
        i      [integer!]
        len  [integer!]
        rows [integer!]
        cols [integer!]
][
    set [_ _ rows cols] rcvGetMatHeader mx
    data: make block! len: rows * cols
    switch n [
        1 or -3 [repeat i cols [append data reverse to-block rcvGetCol mx i] _swapDim mx]
        2 or -2 [repeat i rows [append data reverse to-block rcvGetRow mx rows + 1 - i]]
        3 or -1 [repeat i cols [append data to-block rcvGetCol mx cols + 1 - i] _swapDim mx]
    ]
    change/part skip mx _HLEN data len
    mx
]

rcvMatRotateRow: func [
"Row rotation"
    mx        [vector!]  "Matrix"
    r         [integer!] "Row to rotate"
    n         [integer!] "Steps to rotate"
    return: [vector!]
    /local 
        start-idx 	[integer!]
        cols		[integer!]
        si			[integer!]
][
    cols: to integer! mx/:_COLS
    start-idx: _getIdx mx r 1
    either negative? n [
        si: start-idx - n
        n: cols + n
    ][
        si: start-idx + cols - n
    ]
    insert at mx start-idx to block! take/part at mx si n 
    mx
]

rcvMatRotateCol: func [ 
"Column(s) rotation"
	;This is a bit more complicated
    mx 		[vector!] 			"Matrix"
    c 		[block! integer!] 	"Col(s) to rotate"
    n 		[block! integer!] 	"Rotation steps: common to all cols (integer!) or steps for each col (block!) separately"
    return: [vector!]
    /local 
        rws		[block!]
        rows	[integer!]
        rs		[integer!]
][
    rows: to integer! mx/:_ROWS
    either block? c [
        switch type?/word n [
            integer! [forall c [rcvMatRotateCol mx c/1 n]]
            block! [forall c [rcvMatRotateCol mx c/1 n/(index? c)]]
        ]
    ][
        rws: to-block rcvGetCol mx c
        either negative? n [
            rs: 1 - n
            n: rows + n
        ][
            rs: rows - n + 1
        ]
        insert rws take/part at rws rs n 
        forall rws [
            poke mx _getIdx mx index? rws c rws/1
        ]
    ]
    mx
]

rcvMatInvert: func [
"Matrice inversion"
	mx			;--matrix 
	return: 	[vector!] ;--matrix
	/local
		type	[integer!]
		mBitSize	[integer!]
		rows	[integer!]
		cols	[integer!]
		size	[pair!]
		id		;--matrix
		m1		;--matrix
		m2		;--matrix
		;itype
][
	set [type mBitSize rows cols] rcvGetMatHeader mx
	either rcvMatInvertible?/only mx [
		size: to-pair rows
		id: rcvCreateMatIdentity type mBitSize size
		m1: _matRREF rcvMatAugment copy mx id
		rcvMatSplit m1 1 + to-integer m1/:_ROWS
	][
		cause-error 'user 'message "Matrix is not invertible"
	]
]

;********************** Matrix Compute ************************ 

rcvMatProduct: func [
"Matrix product as float value"
	mx		;--matrix
	/local
	data	[vector!]
	prod	[float!]
][
	prod: 1.0
	data: rcvGetMatData mx
	forall data [prod: prod * data/1] prod
]

rcvMatSum: func [
"Matrix sum as float value"
	mx		;--matrix 
][
	to-float sum rcvGetMatData mx
]

rcvMatMean: function [
"Matrix mean as float value"
	mx 		[vector!] ;--matrix 
	return: [float!]
	/local
		n
		sigma
		data  [vector!]
][
	data: rcvGetMatData mx
	n: length? data
	sigma: sum data
	to float! sigma / n
]

rcvMatMin: func [
"Min value of the matrix as number"
	mx [vector!]		;--matrix
	/local
		data [vector!]
][
	data: sort rcvGetMatData mx
	first data
]

rcvMatMax: func [
"Max value of the matrix as number"
	mx [vector!]		;--matrix
	/local
		data [vector!]
][
	data: sort rcvGetMatData mx
	last data
]

;--matrix operators
rcvMatAddition: func [
"Add 2 matrices"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	_matOp m1 m2 0
]

rcvMatSubtraction: func [
"Substract 2 matrices"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	_matOp m1 m2 1
]

rcvMatStandardProduct: func [
"Standard multiplication of matrices"
	m1 			[vector!]		;--matrix
	m2 			[vector!]		;--matrix
	return: 	[vector!]		;--matrix
	/local
		type	[integer!]	
		bits	[integer!]
		cols1	[integer!]
		rows1	[integer!]
		cols2	[integer!]
		rows2	[integer!]
		data	[block!]
		val 	[char! integer! float!]
		i 		[integer!]
		j 		[integer!]
		k 		[integer!]
		ref  	[datatype!]
		-		[integer!]
][
	set [type bits rows1 cols1] rcvGetMatHeader m1
	set [_ _  rows2 cols2] rcvGetMatHeader m2
	data: make block! rows1 * cols2
	ref: type? rcvGetAt m1 1 1
	either equal? cols1 rows2 [
		repeat i rows1 [
			repeat j cols2 [
				val: 0
				repeat k cols1 [
					val: (rcvGetAt m1 i k) * (rcvGetAt m2 k j) + val
					if ref <> type? val [
						val: switch type [
							1 [to char! val]
							2 [to integer! val]
							3 [to float! val]
						]
					]
				]
				append data val
			]
		]
		rcvCreateMat type bits as-pair cols2 rows1 data
	][
		cause-error 'user 'message ["Dimensions don't match in multiplication!"]
	]
]

rcvMatDivide: func [
"Matrix division"
	m1		;--matrix
	m2		;--matrix
	/right
	return: [vector!] ;--matrix
][
	either right [
		rcvMatStandardProduct m1 rcvMatInvert m2
	][
		rcvMatStandardProduct rcvMatInvert m2 m1
	]
]

rcvMatHadamardProduct: func [
"Hadamard product of 2 matrices"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return: [vector!];--matrix
][
	_matOp m1 m2 5
]

rcvMatKroneckerProduct: func [
"Kronecker product of 2 matrices"
	m1 			;--matrix 
	m2 			;--matrix  
	return: 	[vector!] ;--matrix 
	/local 
		data 	[block!]
		type	[integer!]
		bits	[integer!]
		rows1	[integer!]
		cols1	[integer!]
		rows2 	[integer!]
		cols2	[integer!]
		rows 	[integer!]
		cols	[integer!]
		i 		[integer!]
		j 		[integer!]
		k 		[integer!]
		l		[integer!]
][
	set [type bits rows1 cols1] rcvGetMatHeader m1
	set [_ _  rows2 cols2] rcvGetMatHeader m2
	data: make block! rows1 * cols2
	ref: type? rcvGetAt m1 1 1
	rows: rows1 * rows2
	cols: cols1 * cols2
	data: make block! rows * cols
	repeat i rows1 [
		repeat j rows2 [
			repeat k cols1 [
				repeat l cols2 [
					val: (rcvGetAt m1 i k) * (rcvGetAt m2 j l)
					if ref <> type? val [
						val: switch type [
							1 [to char! val]
							2 [to integer! val]
							3 [to float! val]
						]
					]
					append data val
					;append data (rcvGetAt m1 i k) * (rcvGetAt m2 j l)
				]
			]
		]
	]
	rcvCreateMat type bits as-pair cols rows data
]

;--scalars

rcvMatScalarAddition: function [
"Matrix + value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 0
]

rcvMatScalarSubtraction: function [
"Matrix - value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 1
]

rcvMatScalarProduct: func [
"Matrix * value (scalar product)"
	mx		[vector!]
	scalar	[integer! float!]
	return: [vector!]
	/local
		m2 [vector!]
][
	m2: copy mx
	scalar * skip m2 _HLEN
	m2
]

{ or
rcvMatScalarProduct: function [
"Matrix * value (scalar product)"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 2
]}

rcvMatScalarDivision: function [
"Matrix / value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 3
]

rcvMatScalarRemainder: function [
"Matrix % value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 4
]

rcvMatScalarAnd: function [
"Matrix AND value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 5
]

rcvMatScalarOr: function [
"Matrix OR value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 6
]

rrcvMatScalarXor: function [
"Matrix XOR value"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 7
]

rcvMatScalarRightShift: function [
"Matrix right shift"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 8
]

rcvMatScalarLeftShift: function [
"Matrix left shiht"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 9
]

rcvMatScalarRightShiftUnsigned: function [
"Matrix right shift (unsigned)"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 10
]



;************* Decomposition *****************

rcvGetIdentity: func [
"Get (left or right) identity matrix for a given matrix"
	mx 			[vector!] 
	return: 	[vector!]
	/side "If not square matrix"
		d 		[word!] "Side on which identity is used (l | r) (default 'l)"
	/local 
		i 		[integer!]
		j		[integer!]
		rows	[integer!]
		cols	[integer!]
		_		[integer!]
		data	[block!]
][
	set [_ _ rows cols] rcvGetMatHeader mx
	d: either side [
		switch/default d [l [rows] r [cols]][
			cause-error 'user 'message "Side should be 'l for left multiplication and 'r for right multiplication"
		]
	][rows]
	either any [side rcvMatSquare? mx] [
		data: make block! power d 2
		repeat i d [repeat j d [append data either i = j [1][0]]]
		rcvCreateMat 2 16 to-pair d data 
	][
		cause-error 'user 'message ["You need to determine /side ['l | 'r] for non-square matrix!"]
	]
]

;********************* General function **********************
rcvMatApply: func [
	mx 		[vector!]
	fn		[any-function!]
	return: [vector!]
][
	mx: skip mx _HLEN
	forall mx [mx/1: fn mx/1]
	head mx
]

;********************** Matrix Form ************************ 
rcvMatShow: func [
"Form matrix"
	mx
	/local
		data [block!]
		cols [integer!]
][
	data: to-block rcvGetMatData mx
	cols: to integer! mx/:_COLS
	probe new-line/skip data true cols
]








