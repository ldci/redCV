#!/usr/local/bin/red
Red [
	Title:   "Red Language: Matrix functions"
	Author:  "Toomas Vooglaid, François Jouen and Xie Qingtian"
	File: 	 %matrix-obj.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;-------------------------------matrix (mx)-----------------------------------------------------------
;--mx is an object where matrix properties are stored in integer! fields and data is stored as vector!
;--matrix constructor takes following arguments:
;--mType: matrix type as integer [1: Char, 2: Integer, 3: Float]
;--mBits: bit-size as integer [8|16|32 for char! and integer!, 32|64 for float!]
;--mSize: matrix size as pair with COLSxROWS (e.g 3x3)
;--mData: matrix values as block transformed into vector for fast computation 

; When address is given as pair MxN it follows Red semantics of COLxROW
; When address is given as two integers M an N, the order is ROW COL as conventional in math literature
;------------------------------------------------------------------------------------------------------

matrix: context [
	;********************* Private internal functions ************************
	;--row x col, return index
	_getIdx: func [
		mx		[object! vector!]
		row 	[integer!]
		col		[integer!]
		/only
			cols
		return: [integer!]
	][
		either all [only vector? mx] [
			index? at mx row - 1 * cols + col
		][
			index? at mx/data row - 1 * mx/cols + col
		]
	] 
	
	;given index of element, return number of row
	_getRowIdx: func [
		mx		[object!]
		idx		[integer!]
		return: [integer!]
	][
		1 + to-integer idx - 1 / mx/cols
	]
	
	;given index of element, return number of column
	_getColIdx: func [
		mx		[object!] ;--matrix
		idx		[integer!]
		return: [integer!]
	][
		idx - 1 % mx/cols + 1
	]

	;--get value at given row and col
	_getAt: func [
		mx		[object! vector!]
		row		[integer!] 
		col		[integer!]
		/only
			cols [integer!]
	][
		either all [only vector? mx] [
			pick mx row - 1 * cols + col
		][
			pick mx/data row - 1 * mx/cols + col
		]
	]
	
	;--set value at given row and col
	_setAt: func [
		mx		[object! vector!]
		row		[integer!] 
		col		[integer!]
		value 	[scalar!]
		/only
			cols [integer!]
	][
		either all [only vector? mx] [
			poke mx row - 1 * cols + col value
		][
			poke mx/data row - 1 * mx/cols + col value
		]
	]
	
	_product: func [blk [block!] /local out][out: 1 forall blk [out: out * blk/1] out]
	
	;--swap matrix dimensions
	_swapDim: func [
		mx 		 [object!]
		/local
			cols [integer!]
	][
		cols: mx/cols 
   	 	mx/cols: mx/rows 
		mx/rows: cols
	]
	
	_matSizeEQ?: func [
	"Have matrices equivalent size?"
		m1		[object!]
		m2		[object!]
		return:	[logic!]
	][
		all [
			m1/rows = m2/rows 
			m1/cols = m2/cols
		]	
	]
	
	_matTypeEQ?: func [
	"Have matrices equivalent type?"
		m1		[object!]
		m2		[object!]
		return:	[logic!]
	][
		m1/type = m2/type 
	]

	_matDepthEQ?: func [
	"Have matrices equivalent bit-size?"
		m1		[object!]
		m2		[object!]
		return:	[logic!]
	][
		m1/bits = m2/bits
	]

	_matSimilar?: func [
	"Are matrices similar?"
		m1		[object!]
		m2		[object!]
		return:	[logic!]
	][
		all [
			m1/type = m2/type
			m1/bits = m2/bits
			m1/rows = m2/rows 
			m1/cols = m2/cols
		]	
	]
	
	;--basic math operator for two matrices
	_matOp: func [
		m1		 [object!]
		m2		 [object!]
		op		 [integer!]	;--operator
		return:	 [object!]	;--matrix
		/local
			mData [object!]
	][
		
		either _matSimilar? m1 m2 [	
			switch op [
				0 [mData: m1/data  +  m2/data]	;--Add
				1 [mData: m1/data  -  m2/data]	;--Substract
				2 [mData: m1/data AND m2/data]	;--and
				3 [mData: m1/data OR  m2/data]	;--or
				4 [mData: m1/data XOR m2/data]	;--xor
				5 [mData: m1/data  *  m2/data]	;--* Hadamard
			]
			make m1 [data: mData]
		][cause-error 'user 'message ["The two matrices must be similar"]]
	]
	
	;--scalar operator on matrix
	_matScalarOp: func [
		mx		[object!]	;--matrix
		op		[integer!]	;--operator
		value	[number!]	;--scalar value
		return:	[object!]	;--matrix
		/local
			new	[vector!]   ;--matrix data
			val	[number!]
	][
		new: copy mx/data
		case [
			all [op >= 0 op < 8][
				switch op [
					0 [new + value]	;--Add
					1 [new - value]	;--Subtract
					2 [new * value]	;--Multiply
					3 [				;--Divide
						forall new [
							val: new/1 / value
							if integer? new/1 [val: to-integer val]
							new/1:  val
						]
					]		
					4 [new  %  value]	;--Remainder
					5 [new AND value]	;--and
					6 [new OR  value]	;--or
					7 [new XOR value]	;--xor
				]
			]
			all [op >= 8 op <= 10][
				switch op [
					8  [forall new [new/1:  new/1 >>  value]]	;-->>
					9  [forall new [new/1:  new/1 <<  value]]	;--<<
			   		10 [forall new [new/1:  new/1 >>> value]]	;-->>>
				]
			]
		]
		make mx [data: new]
	]
	
	_rowOp: func [;Modifying
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to operate with"
		op			[integer!]	;--operator
		return: 	[object!]   ;--matrix
		/local 
			row  	[vector!]
			idx  	[integer!]
		
		][
		either mx/cols = length? data [ 
			row: getRow mx r
			row: to-block switch op [	
				0	[row  +  data] 	;--add
				1	[row  -  data]	;--subtract
				2	[row  *  data]	;--multiply
				3	[row  /  data]	;--divide
				4	[row  %  data]	;--remainder
				5	[row AND data]	;--and	
				6	[row OR  data]	;--or
				7	[row XOR data]	;--xor
			]
			idx: _getIdx mx r 1
			change/part at mx/data idx row mx/cols
			mx
		][
			cause-error 'user 'message "Argument of wrong length to _rowOp!"
		]
	]
	
	;--Reduced Row Eschelon Form ***
	_matRREF: func [
		mx 			[object!]
		return: 	[object!] ;--matrix
		/local 
			m1 		[object!]
			c		[vector!]
			i		[integer!] 
			j 		[integer!]
			sz		[pair!]
			val		[scalar!]
			data	[block!]
	][
		sz: as-pair mx/cols mx/rows
		data: to-block mx/data
		switch mx/type [
			1 [forall data [data/1: 1.0 * to-integer data/1]]
			2 [forall data [data/1: 1.0 * data/1]]
		]
		
		m1: create 3 32 sz data
		repeat i mx/rows [
			; make the pivot
			if zero? (_getAt m1 i i) [
				c: at getCol m1 i i + 1
				until [
					c: next c 
					if tail? c [
						cause-error 'user 'message ["Impossible to get reduced row eschelon form!"]
					] 
					0 < first c
				]
				switchRows m1 i index? c 
			]
			; reduce it to 1
			if 1 <> (val: _getAt m1 i i) [
				ri: _getIdx m1 i 1
				data: to-block divide (getRow m1 i) val ;May be better do it in-place?
				change/part at m1/data ri data mx/cols
			]
			; reduce other rows at this column to 0 
			repeat j mx/rows [
				if all [j <> i 0 <> (c: _getAt m1 j i)][
					ri: _getIdx m1 j 1
					data: to-block (getRow m1 j) - (c * getRow m1 i) ;May be better do it in-place?
					change/part at m1/data ri data mx/cols
				]
			]
		]
		m1
	]
	
	_changeData: func [
		mx		[object!] "Matrix"
		data	[block!]  "New data"
		/local
			type [word!]
	][
		either equal? mx/rows * mx/cols length? data [
			type: pick [char! integer! float!] mx/type
			mx/data: make vector! reduce [type mx/bits data]
		][
			cause-error 'user 'message "Changed data must be of same length as original"
		]
	]
	
	;--Matrix copy; may be not needed: `make mx []` is enough?
	_copy: func [
		mx [object!] "Matrix"
		return: [object!]
	][
		make mx [data: copy mx/data]
	]
	
	;********************** Matrices Creation ************************ 
	create:	func [
	"Create rows x columns matrix"
		mType 	[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
   		mBits 	[integer!] 	"8|16|32 for char! and integer!, 32|64 for float!"
		mSize 	[pair!]		"Size of matrix (COLSxROWS)"
		mData 	[block!]   	"Matrix data" 
		return: [object!]	;--matrix
		/local 
			wType [word!]
	][
		wType: pick [char! integer! float!] mType
		object [
			type: mType
			bits: mBits
			rows: mSize/y
			cols: mSize/x
			data: make vector! reduce [wType bits mData]
		]
	]
	
	init: func [
	"Create and initialize COLSxROWS matrix"
		mType 	[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
		mBits 	[integer!] 	"8|16|32 for char! and integer!, 32|64 for float!"
		mSize 	[pair!]		"Size of matrix (COLSxROWS)"
		/value
			val [scalar!]
		/rand
		/bias
			base [scalar!]
		return:  [vector!] ;--matrix

		/local
			v	 	[scalar!]
			data 	[block!]
			wType 	[word!]
			mx		[object!]
	][
		wType: pick [char! integer! float!] mType
		mx: object [
			type: mType
			bits: mBits
			rows: mSize/y
			cols: mSize/x
			data: make vector! reduce [wType bits rows * cols]
		]
		if value [
			data: mx/data
			if rand [random/seed now]
			forall data [
				v: val
				case/all [
					rand [v: random v]
					bias [v: base + v]
				]
				data/1: v
			]
		]
		mx
	]
	
	scalar: func [
	"Create a scalar matrix"
		mType 	 [integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
		mBits 	 [integer!] 	"8|16|32 for char! and integer!, 32|64 for float!"
		mSize 	 [pair!]		"Size of matrix (COLSxROWS)"
		scalar	 [scalar!] 		"Scalar value"
		return:  [object!]  	;--matrix  
		/local
			cols [integer!]
			rows [integer!]
			i	 [integer!]
			j	 [integer!]
			data [block!]
			mx	 [object!]
	][
		cols: mSize/x
		rows: mSize/y
		either rows = cols [
			data: make block! cols * rows
			switch mType [
				1	[v0: to-char 0  v1: to-char scalar]
				2	[v0: 0		    v1: to-integer scalar]
				3	[v0: to-float 0 v1: to-float scalar]
   			]
			mx: init mType mBits mSize v0
			repeat i rows [_setAt mx i i v1]
			mx
		][
			cause-error 'user 'message ["Square matrix required for `scalar`"]
		]
	]
	
	identity: func [
	"Create an identity matrix (I)"
   		mType 	[integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
		mBits 	[integer!] 	"8|16|32 for char! and integer!, 32|64 for float!"
		mSize 	[pair!]		"Size of matrix (COLSxROWS)"
		return: [object!]	;--matrix
	][
		scalar mType mBits mSize 1
	]
	
	zero: func [
	"Create a null (0) matrix"
   		mType   [integer!] 	"Type of matrix: 1-char, 2-integer, 3-float"
		mBits 	[integer!] 	"8|16|32 for char! and integer!, 32|64 for float!"
		mSize 	[pair!]		"Size of matrix (COLSxROWS)"
		return: [object!]	;--matrix
	][
		scalar mType mBits mSize 0
	]

	header:	func [
	"Return matrix header as a block" 
		mx 		[object!] "Matrix"
		return: [block!] 
	][
		reduce [mx/type mx/bits mx/rows mx/cols]
	]

	order:	func [
	"Return matrix size as a pair"
		mx 		[object!] 	"Matrix"
		return: [pair!]
	][
		;COLSxROWS
		as-pair mx/cols mx/rows
	]
	
	show: func [
	"Form matrix"
		mx [object!]
	][
		probe new-line/skip to-block mx/data true mx/cols
	]
	
	;********************** Matrix Porperties ***********************
	square?: func [
	"Square matrix?"
		mx		[object!] "Matrix"
		return: [logic!]
	][
		mx/rows = mx/cols
	]
	
	null?: func [
	"Null matrix?"
		mx		[object!] "Matrix"
		return: [logic!]
	][
		;0 = to-integer determinant mx
		and~ zero? mini mx
			 zero? maxi mx
	]
	
	singular?: func [
	"Singular matrix?"
		mx		[object!] "Matrix"
		/only
		return: [logic!]
		
	][
		either only [
			error? try [determinant mx]
		][
			zero? determinant mx
		]
	]
	
	nonSingular?: func [
	"Non singular matrix?"
		mx		[object!] "Matrix"
		return: [logic!]
	][
		not singular? mx
	]
	
	degenerate?: func [
	"Degenerate matrix?"
		mx		[object!] "Matrix"
		return: [logic!]
	][
		zero? determinant mx
	]
	
	nonDegenerate?: func [
	"Non degenerate matrix?"
		mx		[object!] "Matrix" 
		return: [logic!]
	][
		not degenerate? mx
	]
	
	invertible?: func [
	"Invertible matrix?"
		mx		[object!] "Matrix"
		/only	"Returns false instead of error"
		return: [logic!]
		
	][
		either only [
			not singular?/only mx
		][
			not singular? mx
		]
	]
	
	diagonal?: func [
	"Diagonal matrix?"
		mx		 [object!] "Matrix"
		return:  [logic!]
		/local
			rows [integer!]
			cols [integer!]
			i 	 [integer!]
			j 	 [integer!]
	][
		either matrix/square? mx [
			cols: mx/cols
			rows: mx/rows
			repeat i cols [
				repeat j rows [
					if (i <> j) AND (0 <> to-integer matrix/_getAt mx i j) [return false]
				]
			]
			true
		][false]
	]
	
	symmetric?: func [
	"Symmetric matrix?"
		mx 		[object!] "Matrix"
		return: [logic!]
	][
		;--It must be square, and is equal to its own transpose(AT)
   	 	either square? mx [ 
			m1: transpose _copy mx
			equal? mx/data m1/data
		][false]
	]
	
	
	upper?: func [
        mx [object!] "Matrix"
        return: [logic! none!]
    ][
        all [
            square? mx
            repeat r mx/rows - 1 [
                repeat c r [
                    if not zero? _getAt mx r + 1 c [return false]
                ] true
            ]
        ]
    ]
    
    lower?: func [
        mx [object!] "Matrix"
        return: [logic! none!]
    ][
        all [
            square? mx
            repeat r mx/rows - 1 [
                repeat c mx/cols - r [
                    if not zero? _getAt mx r r + c [return false]
                ] true
            ]
        ]
    ]



	
	determinant: func [
	"Get matrix determinant"
		mx 			[object!] "Matrix"
		return:		[number!]
		/local 
			i 		[integer!]
			r 		[block!]
			l 		[block!]
			row 	[vector!]
			minor 	[vector!]
			mid 	[block!]
			idx		[integer!]
			data	[vector!]
	][
		data: copy mx/data 
		either square? mx [
			switch/default mx/cols [
				0 [1]
				1 [data/1]
				2 [(data/1 * data/4) - (data/2 * data/3)]
				3 [	
					r: make block! mx/cols l: make block! mx/cols
					repeat i mx/cols [
						insert r _product diagonal mx i 'r
						insert l _product diagonal mx i 'l
					]
					(sum r) - (sum l)
				]
		 	][
				mid: make block! mx/cols
				row: getRow mx 1 
				forall row [
			   	 	minor: _copy mx
					minor/data: copy mx/data
					removeRow minor 1
					removeCol minor idx: index? row
					append mid -1 ** (idx + 1) * row/1 * determinant minor
				]
				sum mid
			]
		][
			cause-error 'user 'message ["Matrix must be square to find determinant!"]
		]
	]
	
	diagonal: func [
	"Get matrix main diagonal"
		mx		[object!]   "Matrix"
		i	 	[integer!]  "Index"
		dir 	[word!]		"'l(eft) or 'r(ight)"
		return: [block!]
		/local
	   	 	out  [block!]
			data [vector!]
			cols [integer!]
	][
		data: at mx/data i
		cols: mx/cols
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
		mx 		[object!] "Matrix"
	][
		either square? mx [
			sum diagonal mx 1 'r
		][
			cause-error 'user 'message ["Trace is defined for square matrices only!"]
		]
	]
	;'
	
	eigens: func [
	"Matrix eigen values" ;For 2x2 matrices only so far
		mx 		[object!] "Matrix"
		/local
			tr	[number!]
	   	 	det	[number!]
			l1	[number!]
			l2	[number!]
	][
		tr: trace mx
		det: determinant mx
		l1: (tr + sqrt tr ** 2 - (4 * det)) / 2
		l2: (tr - sqrt tr ** 2 - (4 * det)) / 2
		reduce [l1 l2]
	]

	;********************** Matrix Elements Access ************************ 
	
	getAt: func [
	"Get value at COLxROW coordinate"
		mx 		[object!] "Matrix"
		coord	[pair!]	  "Value coordinates as a pair"
	][
		;col: coord/1 row: coord/2
		pick mx/data coord/2 - 1 * mx/cols + coord/1
	]
	
	setAt: func [
	"Set value at COLxROW coordinate"
		mx 		[object!]	"Matrix"
		coord	[pair!]		"Matrix coordinates as a COLxROW pair"
		value	[scalar!]	"Value to set"
		return: [object!]	;--matrix
	][
		;col: coord/x row: coord/y
		poke mx/data coord/y - 1 * mx/cols + coord/x value
		mx
	]
	
	;********************** Matrix Rows & Columns ************************ 
	getCol: func [
	"Return a new matrix from column n (vector)"
		mx 		[object!]  	"Matrix"
		col 	[integer!] 	"Column number"
		return: [vector!] 	;--column vector
	][
		make vector! extract to-block at mx/data col mx/cols
		;make vector! extract/index to-block mx/data mx/cols col   ;also
		;extract/index mx/data mx/cols col                ;extract on vector! is buggy
	]
	
	getRow: func [
	"Return a new matrix from row n (vector)"
		mx		[object!]  	"Matrix" ;--matrix
		row 	[integer!] 	"Number of row to get"
		return: [vector!]	;--row vector
	][
		;make vector! to-block                          ;redundant
		copy/part at mx/data row - 1 * mx/cols + 1 mx/cols
	]
	
	removeRow: func [
	"Remove row in matrix"
		mx		[object!] 	"Matrix" ;--matrix
		row		[integer!]  "Row to remove"
		return: [object!]	;--matrix
		/local
			idx [integer!]
	][
		idx: _getIdx mx row 1
		remove/part at mx/data idx mx/cols
		mx/rows: mx/rows - 1
		mx
	]
	
	removeCol: func [
	"Remove column in matrix"
		mx		[object!] 	"Matrix" ;--matrix
		col		[integer!]  "Column to remove"
		return: [object!]	;--matrix
		/local
			data [vector!]
	][
		data: at mx/data col
		loop mx/rows [remove data data: skip data mx/cols - 1]
		mx/cols: mx/cols - 1
		mx
	]
	
	insertRow: func [
	"Insert row in matrix"
		mx		 [object!] "Matrix"
		block 	 [block!]  "Data to insert (needs to be of compatible length or length 1)"
		/at 
			row  [integer!] 
		return:  [object!]
		/local 
			len  [integer!]
			cols [integer!]
	][
		cols: mx/cols
		row: any [row 1] 
		case [
			cols = len: length? block [ 
				insert system/words/at mx/data row - 1 * cols + 1 block
			]
			len = 1 [
				; For block of length 1 row is filled with this element
				insert/dup system/words/at mx/data row - 1 * mx/cols + 1 block/1 mx/cols
			]
			true [
				cause-error 'user 'message ["Inserted row is incompatible!"]
			]
		]
		mx/rows: mx/rows + 1
		mx
	]
	
	appendRow: func [
	"Append row to matrix"
		mx		[object!] "Matrix"
		block 	[block!]  "Data to append"
		return: [object!]
	][
		insertRow/at mx block mx/rows + 1
	]
	
	insertCol: func [
	"Insert column in matrix"
		mx		[object!] "Matrix"
		block 	[block!]  "Data to insert (needs to be of compatible length or length 1)"
		/at 
			col [integer!] 
		return: [object!]	;--matrix
		/local 
			len [integer!]
			i	[integer!]
	][
		either (same? type? _getAt mx 1 1  type? first block) [
			col: any [col 1] 
			mx/cols: mx/cols + 1
			case [
				any [mx/rows = len: length? block len = 1] [ 
					repeat row mx/rows [
						i: either len = 1 [1][row]
						insert system/words/at mx/data row - 1 * mx/cols + col block/:i
					]
				]
				true [cause-error 'user 'message ["Inserted column is incompatible!"]]
			]
			mx
		][
			cause-error 'user 'message [
				"Elements of inserted column must be of same type as the other!"
			]
		]
	]
	
	appendCol: func [
	"Append column in matrix"
		mx 		[object!]  	"Matrix"
		block 	[block!]	
		return: [object!]	;--matrix
	][
		insertCol/at mx block mx/cols + 1
	]
	
	augment: func [
	"Matrix augmentation"
		m1 		[object!] "Matrix 1"
		m2 		[object!] "Matrix 2"
		return: [object!]
		/local 
			i	[integer!] 
			j	[integer!] 
			k	[integer!]
	][
		either all [m1/type = m2/type m1/bits = m2/bits][
			either m1/rows = m2/rows [
				repeat i m1/rows [
					k: m1/rows - i + 1
					j: _getIdx m1 k m1/cols + 1
					insert at m1/data j to-block getRow m2 k
				]
				m1/cols: m1/cols + m2/cols
			][
				cause-error 'user 'message ["Augmented matrix must have same number of rows as the other!"]
			]
			m1
		][
			cause-error 'user 'message ["Augmented matrix must be of same type and bitSize as the other!"]
		]
	]
	
	switchCols: function [
	"Switch cols in matrix"
		mx 		[object!]  "Matrix"
		c1 		[integer!] "First col to switch"
		c2 		[integer!] "Col with which to switch"
		return: [object!]
		/local
			val [scalar!]
			r   [integer!]
	][
		repeat r mx/rows [
			val: _getAt mx r c1
			_setAt mx r c1 _getAt mx r c2
			_setAt mx r c2 val
		] 
		mx
	]
	
	switchRows: function [
	"Switch rows in matrix"
		mx 		[object!]  "Matrix"
		r1 		[integer!] "First row to switch"
		r2 		[integer!] "Row with which to switch"
		return: [object!]
		/local
			val [scalar!]
			c   [integer!]
	][
		repeat c mx/cols [
			val: _getAt mx r1 c
			_setAt mx r1 c _getAt mx r2 c
			_setAt mx r2 c val
		]
		mx
	]
	
	split: func [
	"Split matrix"
		mx 		 [object!]  	"Matrix"
		col 	 [integer!] 	"Column number at which to split matrix" 
		return:  [object!]		;--matrix
		/local 
			data [block!] 
			r 	 [integer!]
			row  [integer!]
			cols [integer!]
			rows [integer!]
			idx	 [integer!]
	][
		rows: mx/rows
		cols: mx/cols - col + 1
		data: make block! cols * rows
		_mx: _copy mx		;--copy to avoid to modify original matrix
		repeat r rows [
			row: rows - r + 1
			idx: _getIdx _mx row col
			insert data to-block take/part at _mx/data idx cols 
		] 
		_mx/cols: _mx/cols - cols
		create _mx/type _mx/bits as-pair cols rows data
	]
	
	
	slice: func [
	"Split matrix"
		mx 		 [object!] 		"Matrix" 
		srow	 [integer!]		"Starting row"
		erow	 [integer!]		"Ending row"		
		scol 	 [integer!] 	"Starting column"	
		ecol	 [integer!]		"Ending column"	
		return:  [object!]		;--matrix
		/local 
			data [block!] 
			r 	 [integer!]
			row  [integer!]
			cols [integer!]
			rows [integer!]
			idx	 [integer!]
	][
		rows: erow - srow + 1
		cols: ecol - scol + 1
		data: make block! cols * rows
		_mx: _copy mx		;--copy to avoid to modify original matrix
		row: erow
		repeat r rows [
			col: scol
			idx: _getIdx _mx row col
			insert data to-block take/part at _mx/data idx cols
			row: row - 1 
		] 
		_mx/cols: mx/cols - cols
		_mx/rows: mx/rows - rows
		create _mx/type _mx/bits as-pair cols rows data
	]

	;************************** Row and cols ops *****************************
	
	rowScalarProduct: func [
	"Scalar multiplication of a matrix row"
		mx		[object!]	"Matrix"
		r		[integer!]	"Selected row"
		val		[number!]	"Scalar value"
		return: [object!]	;--matrix
		/local
			row [block!]
			idx [integer!]
	][
		row: to block! val * getRow mx r
		idx: _getIdx mx r 1
		change/part at mx/data idx row mx/cols
		mx
	]
	
	
	rowAdd: func [
	"Vector addition to a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to add to row"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 0
	]
	
	rowSub: func [
	"Subtract vector from a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to subtract from row"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 1
	]
	
	rowProduct: func [
	"Vector product of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to multiply with"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 2
	]
	
	rowDivision: func [
	"Vector division of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to divide with"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 3
	]
	
	rowRemainder: func [
	"Vector remainder of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data for reminder calculation"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 4
	]
	
	rowAnd: func [
	"Vector AND of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to be AND-ed"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 5
	]
	
	rowOr: func [
	"Vector OR of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to be OR-ed"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 6
	]
	
	rowXor: func [
	"Vector XOR of a matrix row"
		mx 			[object!]  "Matrix"
		r 			[integer!] "Row number"
		data 		[vector!]  "Data to be XOR-ed"
		return: 	[object!]  ;--matrix
	][
		_rowOp mx r data 7
	]
	
	;********************** Matrix Transform ************************ 
	transpose: func [
	"Transpose matrix"
		mx 		 [object!]  "Matrix"
		return:  [object!]	;--matrix
		/local 
			data [vector!]
			rows [integer!]
			cols [integer!]
	][			
		rows: mx/rows
		cols: mx/cols
		data: copy mx/data
		repeat col cols [
			repeat row rows [
				_setAt/only mx/data col row _getAt/only data row col cols rows
			]
		]
		mx/cols: rows 
		mx/rows: cols
		mx
	]
	
	negative: func [
	"Negate integer or float matrices" 
		mx		[object!]  "Matrix"
		return: [object!]
	][
		if mx/type <> 'char! [
			data: mx/data
			forall data [data/1: negate data/1]
			mx
		]
	]
	
	rotate: func [
	"Rotate matrix"
		mx 		 [object!]  "Matrix" 
		n		 [integer!] "Positive (cw) or negative (ccw) rotation (-3 <= x <= 3)"
		return:  [object!]	;?
		/local 
			data [block!]
			i	[integer!]
			len  [integer!]
			rows [integer!]
			cols [integer!]
	][
		cols: mx/cols
		rows: mx/rows
		data: make block! len: rows * cols
		switch n [
			1 or -3 [repeat i cols [append data reverse to-block getCol mx i] _swapDim mx]
			2 or -2 [repeat i rows [append data reverse to-block getRow mx rows + 1 - i]]
			3 or -1 [repeat i cols [append data to-block getCol mx cols + 1 - i] _swapDim mx]
		]
		_changeData mx data
		mx
	]
	
	;'Are the following two needed?
comment [rotateRow: func [
	"Row rotation"
		mx				[object!]  	"Matrix"
		r		 		[integer!] 	"Row to rotate"
		n		 		[integer!] 	"Steps to rotate"
		return: 		[object!]	;--matrix
   	 	/local 
			start-idx 	[integer!]
			cols		[integer!]
			si			[integer!]
	][
		cols: mx/cols
		start-idx: _getIdx mx r 1
   		either negative? n [
			si: start-idx - n
			n: cols + n
		][
			si: start-idx + cols - n
		]
		insert at mx/data start-idx to block! take/part at mx/data si n 
		mx
	]

	rotateCol: func [ 
	"Column(s) rotation"
		;This is a bit more complicated
		mx 		[object!] 			"Matrix"
		c 		[block! integer!] 	"Col(s) to rotate"
		n 		[block! integer!] 	"Rotation steps: common to all cols (integer!) or steps for each col (block!) separately"
		return: [object!]			;--matrix
		/local 
		rws		[block!]
		rows	[integer!]
		rs		[integer!]
	][
		rows: mx/rows
		either block? c [
			switch type?/word n [
				integer! [forall c [rotateCol mx c/1 n]]
				block!   [forall c [rotateCol mx c/1 n/(index? c)]]
			]
		][
	   		rws: to-block getCol mx c
			either negative? n [
				rs: 1 - n
				n: rows + n
			][
				rs: rows - n + 1
			]
			insert rws take/part at rws rs n 
			forall rws [
				poke mx/data _getIdx mx index? rws c rws/1
			]
		]
		mx
	]
]
	
	invert: func [
	"Matrice inversion"
		mx		 [object!]  "Matrix"
		return:  [object!] 	;--matrix
		/local
			rows [integer!]
			size [pair!]
			id	 [object!]
			m1	 [object!]
	][
		rows: mx/rows
		either invertible?/only mx [
			size: to-pair rows
			id: identity mx/type mx/bits size
			m1: _matRREF augment _copy mx id
			split m1 rows + 1
		][
			cause-error 'user 'message "Matrix is not invertible"
		]
	]
	
	;********************** Matrix Computation ************************
	product: func [
	"Matrix product as float value"
		mx		 [object!]	"Matrix"
		/local
			data [vector!]
			prod [float!]
	][
		prod: 1.0
		data: mx/data
		forall data [prod: prod * data/1] 
		prod
	]
	
	sigma: func [
	"Matrix sum as float value"
		mx		[object!]	"Matrix" 
		return: [float!]
	][
		to-float sum mx/data
	]
	
	mean: function [
	"Matrix mean as float value"
		mx 		[object!]	"Matrix"
		return: [float!]	
		/local
			n	[integer!]
			sig	[float!]
	][
		n: length? mx/data
		sig: sigma mx
		to float! sig / n
	]
	
	mini: func [
	"Min value of the matrix as number"
		mx 		[object!]	"Matrix"
		return:	[number!]
		/local
			data 	[vector!]
	][
		data: copy mx/data ;--do not modify matrix
		first sort data
	]
	
	maxi: func [
	"Max value of the matrix as number"
		mx 		[object!]	"Matrix"
		return:	[number!]
		/local
			data [vector!]
	][
		data: copy mx/data ;--do not modify matrix
		last sort data
	]
	
	;--matrix operators
	addition: func [
	"Add 2 matrices"
		m1		[object!]	"Matrix 1"
		m2		[object!]	"Matrix 2"
		return:	[object!]	;--matrix
	][
		_matOp m1 m2 0
	]
	
	subtraction: func [
	"Substract 2 matrices"
		m1		[object!]	"Matrix 1"
		m2		[object!]	"Matrix 2"
		return:	[object!]	;--matrix
	][
		_matOp m1 m2 1
	]
	
	standardProduct: func [
	"Standard multiplication of 2 matrices"
		m1		 [object!]	"Matrix 1"
		m2		 [object!]	"Matrix 2"
		return:  [object!]	;--matrix
		/local
			data [block!]
			val  [scalar!]
			i 	 [integer!]
			j 	 [integer!]
			k 	 [integer!]
			ref  [datatype!]
	][
		data: make block! m1/rows * m2/cols
		ref: type? _getAt m1 1 1
		either equal? m1/cols m2/rows [
			repeat i m1/rows [
				repeat j m2/cols [
					val: 0
					repeat k m1/cols [
						val: (_getAt m1 i k) * (_getAt m2 k j) + val
						if ref <> type? val [
							val: switch m1/type [
								1 [to char! val]
								2 [to integer! val]
								3 [to float! val]
							]
						]
					]
					append data val
				]
			]
			create m1/type m1/bits as-pair m2/cols m1/rows data
		][
			cause-error 'user 'message ["Dimensions don't match in multiplication!"]
		]
	]
	
	HadamardProduct: func [
	"Hadamard product of 2 matrices"
		m1		[object!]	"Matrix 1"
		m2		[object!]	"Matrix 2"
		return: [object!]	;--matrix
	][
		_matOp m1 m2 5
	]
	
	KroneckerProduct: func [
	"Kronecker product of 2 matrices"
		m1			[object!]	"Matrix 1"
		m2			[object!]	"Matrix 2"
		return: 	[object!] 	;--matrix 
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
			val		[scalar!]
	][
		type:  m1/type bits:  m1/bits
		cols1: m1/cols rows1: m1/rows
		cols2: m2/cols rows2: m2/rows
		ref: type? _getAt m1 1 1
		rows: rows1 * rows2
		cols: cols1 * cols2
		data: make block! rows * cols
		repeat i rows1 [
			repeat j rows2 [
				repeat k cols1 [
					repeat l cols2 [
						val: (_getAt m1 i k) * (_getAt m2 j l)
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
		create type bits as-pair cols rows data
	]
	
	division: func [
	"Matrix division"
		m1		[object!]	"Matrix 1"
		m2		[object!]	"Matrix 2"
		/right
		return: [object!] ;--matrix
	][
		either right [
			standardProduct m1 invert m2
		][
			standardProduct invert m2 m1
		]
	]
	
	;--scalars

	scalarAddition: function [
	"Matrix + value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 0 value
	]
	
	scalarSubtraction: function [
	"Matrix - value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
	_matScalarOp mx 1 value
	]
	
	scalarProduct: function [
	"Matrix * value (scalar product)"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 2 value
	]
	
	scalarDivision: function [
	"Matrix / value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 3 value
	]
	
	scalarRemainder: function [
	"Matrix % value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 4 value
	]
	
	scalarAnd: function [
	"Matrix AND value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 5 value
	]
	
	scalarOr: function [
	"Matrix OR value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 6 value
	]
	
	scalarXor: function [
	"Matrix XOR value"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 7 value
	]
	
	scalarRightShift: function [
	"Matrix right shift"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 8 value
	]
	
	scalarLeftShift: function [
	"Matrix left shiht"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 9 value
	]
	
	scalarRightShiftUnsigned: function [
	"Matrix right shift (unsigned)"
		mx 		[object!]	"Matrix"
		value 	[number!]	"Scalar value"
	][
		_matScalarOp mx 10 value
	]

	;************* Decomposition *****************
	;the identity matrix of size n is the n × n square matrix 
	;with ones on the main diagonal and zeros elsewhere
	
	getIdentity: func [
	"Get (left or right) identity matrix for a given matrix"
		mx 			[object!]	"Matrix" 
		/side 				"If not square matrix"
			d 		[word!] "Side on which identity is used ('l | 'r) (default 'l)"
		return: 	[object!]	;--matrix
	][
		d: either side [
			switch/default d [l [mx/rows] r [mx/cols]][
				cause-error 'user 'message "Side should be 'l for left multiplication and 'r for right multiplication"
			]
		][mx/rows]
		either any [side square? mx] [
			identity mx/type mx/bits to-pair d 
		][
			cause-error 'user 'message ["You need to determine /side ['l | 'r] for non-square matrix!"]
		]
	]
	
	;lower–upper (LU) decomposition creates  a matrix as the product 
	;of a lower triangular matrix and an upper triangular matrix
	;only for float!  matrices
	
	LU: func [
        mx [object!]
        return: [block!]
        /local
            L [object!]
            U [object!]
            r [integer!]
            c [integer!]
            lambda [scalar!]
            value [scalar!]
    ][
        either invertible? mx [
            L: getIdentity mx
            U: _copy mx
            repeat c U/cols - 1 [
                repeat r U/cols - c [
                    if not zero? value: _getAt U c + r c [
                        _setAt L c + r c lambda: value / _getAt U c c
                        rowSub U c + r lambda * getRow U c
                        ;matrix/show U
                    ]
                ]
            ]
            reduce [L U]
        ][
            cause-error 'user 'message "Matrix cannot be LU-decomposed"
        ]
        
    ]

];--end of context

