#!/usr/local/bin/red
Red [
	Title:   "Red Language: Matrix functions"
	Author:  "Toomas Vooglaid, François Jouen and Xie Qingtian"
	File: 	 %matrix.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


;-------------------------------matrix (mx)----------------------------------------------
;--mx is a special vector where matrix properties are stored in a header 
;--inserted at the head of the vector
;--matrix properties:
;--mType: matrix type as integer [1: Char, 2: Integer, 3: Float]
;--mBitSize: bit-size as integer [ 8 for char!, 8|16|32 for integer!, 32|64 for float!]
;--mSize: matrix size as pair with m rows and n columns (e.g 3x3)
;--Data are stored after the header:
;--mData: matrix values as block transformed into vector for fast computation 
;----------------------------------------------------------------------------------------


;_HEADER: [mType mBitSize rows cols]

;Header length
_HLEN: 4

;Indexes of header elements
_TYPE: 1
_BITS: 2
_ROWS: 3
_COLS: 4

matrix: context [
	;********************* Private internal functions ************************
	;--all indexing functions must take account the matrix header offset _HLEN
	;--row x col index
	_getIdx: func [
		mx			[vector!]
		row 		[integer!]
		col			[integer!]
		return: 	[integer!]
		/local
			cols 	[integer!]
	][
		cols: to integer! mx/:_COLS
		add _HLEN  index? at mx row - 1 * cols + col
	] 
	
	;--get value 
	_getAt: func [
		mx			[vector!]
		row			[integer!] 
		col			[integer!]
		/local
			cols 	[integer!]
	][
		cols: to integer! mx/:_COLS
		pick mx add _HLEN row - 1 * cols + col
	]
	
	;--set value 
	_setAt: func [
		mx			[vector!]
		row			[integer!] 
		col			[integer!]
		/local
			cols 	[integer!]
	][
		cols: to integer! mx/:_COLS
		poke mx row - 1 * cols + col + _HLEN value
	]
	
	_product: func [blk [block!] /local out][out: 1 forall blk [out: out * blk/1] out]
	
	;--swap matrix dimensions
	_swapDim: func [
    	mx 		[vector!]
    	/local
        cols	[integer!]
	][
    	cols: mx/:_COLS 
   	 	mx/:_COLS: mx/:_ROWS 
    	mx/:_ROWS: cols
	]
	
	_matSizeEQ?: func [
	"Have matrices equivalent size?"
		mx1		[vector!]
		mx2		[vector!]
		return:	[logic!]
		/local
		h1		[block!]
		h2		[block!]
	][
		h1: self/header mx1
		h2: self/header mx2
		all [h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
	]
	
	_matTypeEQ?: func [
	"Have matrices equivalent type?"
		mx1		[vector!]
		mx2		[vector!]
		return:	[logic!]
		/local
		h1		[block!]
		h2		[block!]
	][
		h1: self/header mx1
		h2: self/header mx2
		h1/:_TYPE = h2/:_TYPE 
	]

	_matDepthEQ?: func [
	"Have matrices equivalent bit-size?"
		mx1		[vector!]
		mx2		[vector!]
		return:	[logic!]
		/local
		h1		[block!]
		h2		[block!]
	][
		h1: self/header mx1
		h2: self/header mx2
		h1/:_BITS = h2/:_BITS	
	]

	_matSimilar?: func [
	"Are matrices similar?"
		mx1		[vector!]
		mx2		[vector!]
		return:	[logic!]
		/local
		h1		[block!]
		h2		[block!]
	][
		h1: self/header mx1
		h2: self/header mx2
		All [h1/:_BITS = h2/:_BITS h1/:_BITS = h2/:_BITS 
		h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
	]
	
	;--basic math operator
	_matOp: func [
		mx1		[vector!]
		mx2		[vector!]
		op		[integer!]	;--operator
		return:	[vector!]	;--matrix
		/local
		h		[block!]
		b1		[vector!]
		b2		[vector!]
		mData	[vector!]
	][
		either _matSimilar? mx1 mx2 [	
			h: self/header mx1
			b1: make vector! to-block  self/data mx1
			b2: make vector! to-block  self/data mx2
			switch op [
				0 [mData: b1  +  b2]	;--Add
				1 [mData: b1  -  b2]	;--Substract
				2 [mData: b1 AND b2]	;--and
				3 [mData: b1 OR  b2]	;--or
				4 [mData: b1 XOR b2]	;--xor
				5 [mData: b1  *  b2]	;--* Hadamard
			]
			self/create h/:_TYPE h/:_BITS as-pair h/:_COLS h/:_ROWS to-block mData
		][cause-error 'user 'message ["The two matrices must be similar"]]
	]
	
	;--scalar operator
	_matScalarOp: func [
		mx		[vector!]
		op		[integer!]	;--operator
		value	[number!]	;--scalar value
		return:	[vector!]	;--matrix
		/local
		_mx		[vector!] ;--matrix
		v		[vector!] ;--matrix
		val		[number!]
	][
		_mx: copy mx
		v: self/data _mx
		case [
			all [op >= 0 op < 8][
				switch op [
					0 [v + value]	;--Add
					1 [v - value]	;--Substract
					2 [v * value]	;--Multiply
					3 [forall v [
						val: v/1 / value
						if type? v/1 = integer! [val: to-integer val]
						v/1:  val]
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
	
	;--Reduced Row Eschelon Form ***
	_matRREF: func [
		mx 			[vector!]
		return: 	[vector!] ;--matrix
		/local 
			m1 		[vector!]
			c		[vector!]
			h		[block!]		
			i		[integer!] 
			j 		[integer!]
			t		[integer!]
			sz		[pair!]
			val		[char! integer! float!]
			data	[block!]
	][
		h: self/header mx
		t: h/:_TYPE
		sz: as-pair h/:_COLS h/:_ROWS
		data: to-block skip mx _HLEN
		switch t [
			1 [forall data [data/1: 1.0 * to-integer data/1]]
			2 [forall data [data/1: 1.0 * data/1]]
		]
		m1: self/create 3 32 sz data
		repeat i h/:_ROWS [
			; make the pivot
			if zero? (self/_getAt m1 i i) [
				c: at self/getCol m1 i i + 1
				until [
					c: next c 
					if tail? c [
					cause-error 'user 'message ["Impossible to get reduced row eschelon form!"]
					] 
					0 < first c
				]
				self/switchRows m1 i index? c 
			]
			; reduce it to 1
			if 1 <> (val: _getAt m1 i i) [
				ri: _getIdx m1 i 1
				data: to-block divide (self/getRow m1 i) val
				change/part at m1 ri data h/:_COLS
			]
			; reduce other rows at this column to 0 
			repeat j h/:_ROWS [
				if all [j <> i 0 <> (c: _getAt m1 j i)][
					ri: self/_getIdx m1 j 1
					data: to-block (self/getRow m1 j) - (c * self/getRow m1 i)
					change/part at m1 ri data h/:_COLS
				]
			]
		]
		m1
	]

	;********************** Matrices Creation ************************ 
	create:	func [
	"Create rows x columns matrix"
    	mType 		[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
   		mBitSize 	[integer!] 	"8 for char!, 8|16|32 for integer!, 32|64 for float!"
    	mSize 		[pair!]    	"Size of matrix (COLSxROWS)"
    	mData 		[block!]   	"Matrix data or length"
		return: 	[vector!]	;--matrix
		/local
			cols	[integer!]
			rows	[integer!]
			t		[word!]
			v		[vector!]
			d		[block!]
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
	
	init: func [
	"Create and initialize rows x columns matrix"
    	mType 		[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
    	mBitSize 	[integer!] 	"8 for char!, 8|16|32 for integer!, 32|64 for float!"
    	mSize 		[pair!]    	"Size of matrix (COLSxROWS)"
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
		return: [vector!] ;--matrix
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
		self/create mType mBitSize mSize to-block mData
	]
	
	scalar: func [
	"Create a scalar matrix"
		mType 		[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
    	mBitSize 	[integer!] 	"8 for char!, 8|16|32 for integer!, 32|64 for float!"
    	mSize 		[pair!]   	"Size of matrix (COLSxROWS)"
    	scalar		[integer!] 	"Scalar value"
    	return: 	[vector!]  	;--matrix  
    	/local
    	cols		[integer!]
    	rows		[integer!]
    	i			[integer!]
    	j			[integer!]
    	data		[block!]
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
    		self/create mType mBitSize mSize data
    	][
    		cause-error 'user 'message ["Square matrix required"]
    	]
	]
	
	identity: func [
	"Create an identity matrix (I)"
   		mType     	[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
    	mBitSize 	[integer!] 	"8 for char!, 8|16|32 for integer!, 32|64 for float!"
    	mSize     	[pair!]    	"Size of matrix (COLSxROWS)"
    	return: 	[vector!]	;--matrix
	][
    	self/scalar mType mBitSize mSize 1
	]
	
	zero: func [
	"Create a null (0) matrix"
   		mType     	[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
    	mBitSize 	[integer!] 	"8 for char!, 8|16|32 for integer!, 32|64 for float!"
    	mSize     	[pair!]    	"Size of matrix (COLSxROWS)"
    	return: 	[vector!]	;--matrix
	][
    	self/scalar mType mBitSize mSize 0
	]
	
	header:	func [
	"Return matrix header as a block" 
		mx 		[vector!] "Matrix"
		return: [block!]  "Header"
		/local
		h 		[block!] 
	][
		h: to-block copy/part mx _HLEN 
		forall h [h/1: to-integer h/1] 
		h
	]
	
	data: func [
	"Return matrix values as vector"
		mx 		[vector!]  	"Matrix"
		return: [vector!]	;--matrix
	][
		copy skip mx _HLEN	;--we need copy to extract data
	]
	
	order:	func [
	"Return matrix size as a pair"
		mx 		[vector!] 	"Matrix"
		return: [pair!]
		/local
		rows 	[integer!]
		cols 	[integer!]
		_ 	 	[integer!]
	][
		set [_ _ rows cols] self/header mx
		;COLSxROWS
		as-pair to-integer cols to-integer rows
	]
	
	show: func [
	"Form matrix"
		mx
		/local
		data [block!]
		cols [integer!]
	][
		data: to-block self/data mx
		cols: to integer! mx/:_COLS
		probe new-line/skip data true cols
	]
	
	;********************** Matrix Porperties ***********************
	square?: func [
	"Square matrix?"
		mx			[vector!] "Matrix"
		return: 	[logic!]
		/local
			rows 	[integer!]
			cols 	[integer!]
			_		[integer!]
	][
		set [_ _ rows cols] self/header mx
		rows = cols
	]
	
	null?: func [
	"Null matrix?"
		mx		[vector!] "Matrix"
		return: [logic!]
	][
		0 = to-integer self/determinant mx
	]
	
	singular?: func [
	"Singular matrix?"
		mx		[vector!] "Matrix"
		/only
		return: [logic!]
	][
		either only [
			error? try [self/determinant mx]
		][
			zero? self/determinant mx
		]
	]
	
	nonSingular?: func [
	"Non singular matrix?"
		mx		[vector!] "Matrix"
		return: [logic!]
	][
		not self/singular? mx
	]
	
	degenerate?: func [
	"Degenerate matrix?"
		mx		[vector!] "Matrix"
		return: [logic!]
	][
		zero? self/determinant mx
	]
	
	nonDegenerate?: func [
	"Non degenerate matrix?"
		mx		[vector!] "Matrix" 
		return: [logic!]
	][
		not self/degenerate? mx
	]
	
	invertible?: func [
	"Invertible matrix?"
		mx		[vector!] "Matrix"
		/only
		return: [logic!]
	][
		either only [
			not self/singular?/only mx
		][
			not self/singular? mx
		]
	]
	
	symmetric?: func [
	"Symmetric matrix?"
    	mx 		[vector!] "Matrix"
    	return: [logic!]
	][
    	;--It must be square, and is equal to its own transpose(AT)
   	 	either self/square? mx [ 
        	equal? skip mx _HLEN skip self/transpose copy mx _HLEN
    	][false]
	]
	
	determinant: func [
	"Get matrix determinant"
    	mx 			[vector!] "Matrix"
    	return:		[number!]
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
    	data: self/data mx
    	either self/square? mx [
        	switch/default cols [
            	0 [1]
            	1 [data/1]
            	2 [(data/1 * data/4) - (data/2 * data/3)]
            	3 [	r: make block! cols l: make block! cols
                	repeat i cols [
                    	insert r _product self/diagonal mx i 'r
                    	insert l _product self/diagonal mx i 'l
                	]
                	(sum r) - (sum l)
            	]
         	][
            	mid: make block! cols
            	rw: self/getRow mx 1 
            	forall rw [
               	 	minor: copy mx
                	self/removeRow minor 1
                	self/removeCol minor idx: index? rw
                	append mid -1 ** (idx + 1) * rw/1 * self/determinant minor
            	]
            	sum mid
        	]
    		][
			cause-error 'user 'message ["Matrix must be square to find determinant!"]
    		]
	]
	
	diagonal: func [
	"Get matrix main diagonal"
    	mx    	[vector!]   "Matrix"
    	i     	[integer!]  "Index"
    	dir 	[word!]		"l(eft) or r(ight)"
    	/local
       	 	out  [block!]
        	data [vector!]
        	cols [integer!]
	][
    	data: at self/data mx i
    	cols: to integer! mx/:_COLS
    	out: collect [
        	while [not tail? data][
            	keep data/1 
            	data: case [
                	all [dir = 'r 0 = ((index? data) % cols)] [next data]
               	 	all [dir = 'l 1 = ((index? data) % cols)] [skip data 2 * cols - 1]
                	true [skip data cols + either dir = 'r [1][-1]]
            	]
        	]
    	]
   	 out
	]
	
	;'
	trace: func [
	"Get trace of square matrix"
    	mx 		[vector!] "Matrix"
	][
    	either self/square? mx [
        	sum self/diagonal mx 1 'r
    	][
        	cause-error 'user 'message ["Trace is defined for square matrices only!"]
    	]
	]
	;'
	
	eigens: func [
	"Matrix eigen values"
   	 mx 		[vector!] "Matrix"
    	/local
        	tr	[number!]
       	 	det	[number!]
        	l1	[number!]
        	l2	[number!]
	][
    	tr: self/trace mx
    	det: self/determinant mx
    	l1: (tr + sqrt tr ** 2 - (4 * det)) / 2
    	l2: (tr - sqrt tr ** 2 - (4 * det)) / 2
    	reduce [l1 l2]
	]

	;********************** Matrix Elements Access ************************ 
	
	getAt: func [
	"Get value at nm coordinate"
	mx 			[vector!] "Matrix"
	coord		[pair!]	  "Value coordinates as a pair"
	
	/local
		row 		[integer!]
		col			[integer!]
		cols		[integer!]
	][
		col: coord/1
		row: coord/2
		cols: to integer! mx/:_COLS
		pick mx add _HLEN row - 1 * cols + col
	]
	
	SetAt: func [
	"Set value at nm coordinate"
	mx 			[vector!] 	"Matrix"
	coord		[pair!]	  	"Matrix coordinates as a pair"
	value		[char! integer! float!] "Value to set"
	return: 	[vector!] 	;--matrix
	/local
		row 	[integer!]
		col		[integer!]
		cols 	[integer!]
	][
		col: coord/1
		row: coord/2
		cols: to integer! mx/:_COLS
		poke mx row - 1 * cols + col + _HLEN value
		mx
	]
	
	;********************** Matrix Rows & Columns ************************ 
	getCol: func [
	"Return a new matrix from column n (vector)"
		mx 			[vector!]  	"Matrix"
		col 		[integer!] 	"Column number"
		return: 	[vector!] 	;--matrix
		/local
			cols 	[integer!]
	][
		cols: to integer! mx/:_COLS
		make vector! extract at to-block mx col + _HLEN cols
	]
	
	getRow: func [
	"Return a new matrix from row n (vector)"
		mx			[vector!]  	"Matrix" ;--matrix
		row 		[integer!] 	"Number of row to get"
		return: 	[vector!]	;--matrix
		/local
			cols 	[integer!]
	][
		cols: to integer! mx/:_COLS
		make vector! copy/part at to-block mx row - 1 * cols + 1 + _HLEN cols
	]
	
	removeRow: func [
	"Remove row in matrix"
		mx			[vector!] 	"Matrix" ;--matrix
		row			[integer!]  "Row to remove"
		return: 	[vector!]	;--matrix
		/local
			cols 	[integer!]
			idx  	[integer!]
	][
		cols: to integer! mx/:_COLS
		idx: self/_getIdx mx row 1
		remove/part at mx idx cols
		mx/:_ROWS: mx/:_ROWS - 1
		mx
	]
	
	removeCol: func [
	"Remove column in matrix"
		mx			[vector!] 	"Matrix" ;--matrix
		col			[integer!]  "Column to remove"
		return: 	[vector!]	;--matrix
		/local
			rows 	[integer!]
			cols 	[integer!]
			_	 	[integer!]
			data 	[vector!]
	][
		set [_ _ rows cols] self/header mx
		data: skip mx add _HLEN col - 1
		loop rows [remove data data: skip data cols - 1]
		mx/:_COLS: mx/:_COLS - 1
		mx
	]
	
	insertRow: func [
	"Insert row in matrix"
		mx		 [vector!] "Matrix"
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
	
	appendRow: func [
	"Append row in matrix"
		mx			[vector!] "Matrix"
		block 		[block!]  "Data to append"
		/local
			rows	[integer!]
	][
		rows: to integer! mx/:_ROWS
		rcvInsertRow/at mx block rows + 1
	]
	
	insertCol: func [
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
		either (same? type? self/_getAt mx 1 1  type? first block) [
			set [_ _ rows cols] self/header mx
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
	
	appendCol: func [
	"Append column in matrix"
		mx 			[vector!]  	"Matrix"
		block 		[block!]	
		return: 	[vector!]	;--matrix
		/local
			cols	[integer!]
	][
		cols: to integer! mx/:_COLS
		self/insertCol/at mx block cols + 1
	]
	
	augment: func [
	"Matrix augmentation"
		m1 			[vector!] "Matrix"
		m2 			[vector!] "Matrix"
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
			set [_ _ rows1 cols1] self/header m1
			set [_ _ rows2 cols2] self/header m2
			either rows1 = rows2 [
				repeat i rows1 [
					k: rows1 - i + 1
					j: _getIdx m1 k cols1 + 1
					insert at m1 j to-block self/getRow m2 k
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
	
	split: func [
	"Split matrix"
		mx 			[vector!]  	"Matrix"
		col 		[integer!] 	"Column number for splitting matrix" 
		return: 	[vector!]	;--matrix
		/local 
			data	[block!] 
			i 		[integer!]
			j 		[integer!]
			cls		[integer!]
			type	[integer!]
			mBitSize[integer!]
			rows	[integer!]
			cols	[integer!]
			idx		[integer!]
	][
		set [type mBitSize rows cols] self/header mx
		data: copy []
		cls: cols - col + 1
		repeat i rows [
			j: rows - i + 1
			idx: _getIdx mx j col
			insert data to-block take/part at mx idx cls 
		] 
		mx/:_COLS: mx/:_COLS - cls
		self/create type mBitSize as-pair cls rows data
	]

	;****************** Elementary row operations ******************

	switchRows: function [
	"Switch rows in matrix"
		mx 			[vector!]  "Matrix"
		r1 			[integer!] "First row to switch"
		r2 			[integer!] "Row with which to switch"
		/local
			cols 	[integer!]
			row1 	[block!]
			row2 	[block!]
	][
		cols: to integer! mx/:_COLS
		row1: to-block self/getRow mx r1 
		row2: to-block self/getRow mx r2
		change/part at mx add _HLEN r1 - 1 * cols + 1 row2 cols 
		change/part at mx add _HLEN r2 - 1 * cols + 1 row1 cols 
		mx
	]
	
	rowAdd: func [
	"Add data to row"
		mx 			[vector!]  "Matrix"
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
			row: self/getRow mx r
			row: to-block row + data
			idx: self/_getIdx mx r 1
			change/part at mx idx row cols
			mx
		][
			cause-error 'user 'message "Only data with the length of matrix columns can be added to row!"
		]
	]
	
	rowProduct: func [
	"Scalar multiplication of a matrix row"
		mx		[vector!]   "Matrix"
		r		[integer!]  "Selected row"
		val		[number!]	"Scalar value"
		return: [vector!]	;--matrix
		/local
			row  [block!]
			cols [integer!]
	][
		cols: to integer! mx/:_COLS
		row: to block! val * self/getRow mx r
		idx: self/_getIdx mx r 1
		change/part at mx idx row cols
		mx
	]
	
	;********************** Matrix Transform ************************ 
	transpose: func [
	"Transpose matrix"
		mx 		[vector!]  	"Matrix"
		return: [vector!]	;--matrix
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
		set [_ _ rows cols] self/header mx
		r: mx/:_ROWS
		c: mx/:_COLS
		d: make block! length? mx
		repeat i cols [
			repeat j rows [
				append d self/_getAt mx j i
			]
		]
		mx/:_COLS: r mx/:_ROWS: c
		change skip mx _HLEN d
		mx
	]
	
	negative: func [
	"Negate integer of float matrices" 
		mx		[vector!]  "Matrix"
		/local
			v	[vector!] 
	][
		v: self/data mx
		if type? v/1 <> char! [
			forall v [v/1: negate v/1]
			change skip mx _HLEN to-block v
		]
	]
	
	rotate: func [
	"Rotate matrix"
    	mx          [vector!]  "Matrix" 
    	n           [integer!] "Positive or negative rotation"
    	return: 	[vector!]
    	/local 
        	data [block!]
        	i    [integer!]
        	len  [integer!]
        	rows [integer!]
        	cols [integer!]
	][
    	set [_ _ rows cols] self/header mx
    	data: make block! len: rows * cols
    	switch n [
        	1 or -3 [repeat i cols [append data reverse to-block self/getCol mx i] self/_swapDim mx]
        	2 or -2 [repeat i rows [append data reverse to-block self/getRow mx rows + 1 - i]]
        	3 or -1 [repeat i cols [append data to-block self/getCol mx cols + 1 - i] self/_swapDim mx]
    	]
    	change/part skip mx _HLEN data len
    	mx
	]
	
	rotateRow: func [
	"Row rotation"
    	mx        		[vector!]  	"Matrix"
    	r         		[integer!] 	"Row to rotate"
    	n         		[integer!] 	"Steps to rotate"
    	return: 		[vector!]	;--matrix
   	 	/local 
        	start-idx 	[integer!]
        	cols		[integer!]
        	si			[integer!]
	][
    	cols: to integer! mx/:_COLS
    	start-idx: self/_getIdx mx r 1
   		either negative? n [
        	si: start-idx - n
       	 n: cols + n
    	][si: start-idx + cols - n]
    	insert at mx start-idx to block! take/part at mx si n 
    	mx
	]

	rotateCol: func [ 
	"Column(s) rotation"
		;This is a bit more complicated
    	mx 		[vector!] 			"Matrix"
    	c 		[block! integer!] 	"Col(s) to rotate"
    	n 		[block! integer!] 	"Rotation steps: common to all cols (integer!) or steps for each col (block!) separately"
    	return: [vector!]			;--matrix
    	/local 
        rws		[block!]
        rows	[integer!]
        rs		[integer!]
	][
    	rows: to integer! mx/:_ROWS
    	either block? c [
        	switch type?/word n [
            	integer! [forall c [self/rotateCol mx c/1 n]]
            	block! [forall c [self/rotateCol mx c/1 n/(index? c)]]
        	]
    	][
       		rws: to-block self/getCol mx c
        	either negative? n [
            	rs: 1 - n
            	n: rows + n
        	][
            	rs: rows - n + 1
        	]
        	insert rws take/part at rws rs n 
        	forall rws [
            	poke mx self/_getIdx mx index? rws c rws/1
        	]
    	]
    	mx
	]
	
	invert: func [
	"Matrice inversion"
		mx			[vector!]  	"Matrix"
		return: 	[vector!] 	;--matrix
		/local
			type		[integer!]
			mBitSize	[integer!]
			rows		[integer!]
			cols		[integer!]
			size		[pair!]
			id			[vector!]
			m1			[vector!]
			m2			[vector!]
	][
		set [type mBitSize rows cols] self/header mx
		either self/invertible?/only mx [
			size: to-pair rows
			id: self/identity type mBitSize size
			m1: self/_matRREF self/augment copy mx id
			self/split m1 1 + to-integer m1/:_ROWS
		][
			cause-error 'user 'message "Matrix is not invertible"
		]
	]
	
	;********************** Matrix Computation ************************
	product: func [
	"Matrix product as float value"
		mx		[vector!]	"Matrix"
		/local
		data	[vector!]
		prod	[float!]
	][
		prod: 1.0
		data: self/data mx
		forall data [prod: prod * data/1] prod
	]
	
	sigma: func [
	"Matrix sum as float value"
		mx		[vector!]	"Matrix" 
		return: 	[float!]
	][
		to-float sum self/data mx
	]
	
	mean: function [
	"Matrix mean as float value"
		mx 			[vector!]	"Matrix"
		return: 	[float!]	
		/local
			n		[integer!]
			sigma	[float!]
	][
		n: length? self/data mx
		sigma: sum self/data mx
		to float! sigma / n
	]
	
	mini: func [
	"Min value of the matrix as number"
		mx 		[vector!]	"Matrix"
		return:	[number!]
		/local
		data 	[vector!]
	][
		data: copy self/data mx ;--do not modify matrix
		first sort data
	]
	
	maxi: func [
	"Max value of the matrix as number"
		mx 	[vector!]	"Matrix"
		return:	[number!]
		/local
		data [vector!]
	][
		data: copy self/data mx ;--do not modify matrix
		last sort data
	]
	
	;--matrix operators
	addition: func [
	"Add 2 matrices"
		m1		[vector!]	"Matrix 1"
		m2		[vector!]	"Matrix 2"
		return:	[vector!]	;--matrix
	][
		self/_matOp m1 m2 0
	]
	
	subtraction: func [
	"Substract 2 matrices"
		m1		[vector!]	"Matrix 1"
		m2		[vector!]	"Matrix 2"
		return:	[vector!]	;--matrix
	][
		self/_matOp m1 m2 1
	]
	
	standardProduct: func [
	"Standard multiplication of 2 matrices"
		m1			[vector!]	"Matrix 1"
		m2			[vector!]	"Matrix 2"
		return: 	[vector!]	;--matrix
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
		set [type bits rows1 cols1] self/header m1
		set [_ _  rows2 cols2] self/header m2
		data: make block! rows1 * cols2
		ref: type? self/_getAt m1 1 1
		either equal? cols1 rows2 [
			repeat i rows1 [
				repeat j cols2 [
					val: 0
					repeat k cols1 [
						val: (self/_getAt m1 i k) * (self/_getAt m2 k j) + val
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
			self/create type bits as-pair cols2 rows1 data
		][
		cause-error 'user 'message ["Dimensions don't match in multiplication!"]
		]
	]
	
	HadamardProduct: func [
	"Hadamard product of 2 matrices"
		m1		[vector!]	"Matrix 1"
		m2		[vector!]	"Matrix 2"
		return: [vector!]	;--matrix
	][
		self/_matOp m1 m2 5
	]
	
	KroneckerProduct: func [
	"Kronecker product of 2 matrices"
		m1			[vector!]	"Matrix 1"
		m2			[vector!]	"Matrix 2"
		return: 	[vector!] 	;--matrix 
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
		set [type bits rows1 cols1] self/header m1
		set [_ _  rows2 cols2] self/header m2
		data: make block! rows1 * cols2
		ref: type? self/_getAt m1 1 1
		rows: rows1 * rows2
		cols: cols1 * cols2
		data: make block! rows * cols
		repeat i rows1 [
			repeat j rows2 [
				repeat k cols1 [
					repeat l cols2 [
						val: (self/_getAt m1 i k) * (self/_getAt m2 j l)
						if ref <> type? val [
							val: switch type [
								1 [to char! val]
								2 [to integer! val]
								3 [to float! val]
							]
						]
						append data val
					]
				]
			]
		]
		self/create type bits as-pair cols rows data
	]
	
	division: func [
	"Matrix division"
		m1		[vector!]	"Matrix 1"
		m2		[vector!]	"Matrix 2"
		/right
		return: [vector!] ;--matrix
	][
		either right [
			self/standardProduct m1 self/invert m2
		][
			self/standardProduct self/invert m2 m1
		]
	]
	
	;--scalars

	scalarAddition: function [
	"Matrix + value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 0
	]
	
	scalarSubtraction: function [
	"Matrix - value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
	self/_matScalarOp mx value 1
	]
	
	scalarProduct: function [
	"Matrix * value (scalar product)"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 2
	]
	
	scalarDivision: function [
	"Matrix / value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 3
	]
	
	scalarRemainder: function [
	"Matrix % value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 4
	]
	
	scalarAnd: function [
	"Matrix AND value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 5
	]
	
	scalarOr: function [
	"Matrix OR value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 6
	]
	
	scalarXor: function [
	"Matrix XOR value"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 7
	]
	
	scalarRightShift: function [
	"Matrix right shift"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 8
	]
	
	scalarLeftShift: function [
	"Matrix left shiht"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 9
	]
	
	scalarRightShiftUnsigned: function [
	"Matrix right shift (unsigned)"
		mx 		[vector!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		self/_matScalarOp mx value 10
	]

	;************* Decomposition *****************

	getIdentity: func [
	"Get (left or right) identity matrix for a given matrix"
		mx 			[vector!]	"Matrix" 
		return: 	[vector!]	;--matrix
		/side 				"If not square matrix"
			d 		[word!] "Side on which identity is used (l | r) (default 'l)"
		/local 
			i 		[integer!]
			j		[integer!]
			rows	[integer!]
			cols	[integer!]
			_		[integer!]
			data	[block!]
	][
		set [_ _ rows cols] self/header mx
		d: either side [
			switch/default d [l [rows] r [cols]][
				cause-error 'user 'message "Side should be 'l for left multiplication and 'r for right multiplication"
			]
		][rows]
		either any [side self/square? mx] [
			data: make block! power d 2
			repeat i d [repeat j d [append data either i = j [1][0]]]
			self/create 2 16 to-pair d data 
		][
			cause-error 'user 'message ["You need to determine /side ['l | 'r] for non-square matrix!"]
		]
	]
];--end of context

