Red [
	Author: "Toomas Vooglaid"
	Date: 7-9-2017
	Last-update: 19-07-2020
]
mx: context [
	ctx: self
	mtx: object [
		rows: cols: data: none
		get-col: func [col][extract at data col cols]
		get-row: func [row][copy/part at data row - 1 * cols + 1 cols]
		remove-row: func [row][remove/part at data get-idx row 1 cols rows: rows - 1 show]
		remove-col: func [col][
			data: skip data col - 1
			loop rows [remove data data: skip data cols - 1]
			data: head data 
			cols: cols - 1 show
		]
		insert-row: func [block /at row /local len][
			row: any [row 1] 
			if (cols <> len: length? block) and (len <> 1) [
				cause-error 'user 'message ["Row's is not compatible!"]
			]
			either cols = length? block [ 
				insert system/words/at data (row - 1) * cols + 1 block
			][
				insert/dup system/words/at data (row - 1) * cols + 1 block/1 cols
			]
			rows: rows + 1
		]
		append-row: func [block][insert-row/at block rows + 1]
		set-at: func [row col what][poke data row - 1 * cols + col what]
		get-idx: func [row col][index? at data row - 1 * cols + col]
		get-at: func [row col][pick data row - 1 * cols + col]
		get-row-idx: func [idx][idx - 1 / cols + 1]
		get-col-idx: func [idx][idx - 1 % cols + 1]
		get-diagonal: func [i dir /local out][
			data: skip data i - 1 
			set [comp inc] switch dir [r [0 :+] l [1 :-]]
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
			data: head data
			out
		]
		get-order: does [to-pair reduce [rows cols]]
		to-float: does [forall data [data/1: system/words/to-float data/1]]
		swap-dim: has [c][c: cols cols: rows rows: c]
		square?: does [rows = cols]
		symmetric?: has [d][transpose d: copy data transpose equal? data d]
		diagonal?: function [][
			either square? [
				repeat i cols [
					repeat j rows [
						if (i <> j) and (0 <> get-at i j) [return false]
				]] 
				true
			][false]
		]
		zero?: does [0 = sum data];ctx/summa data]
		singular?: degenerate?: does [determinant = 0]
		invertible?: nonsingular?: nondegenerate?: does [not singular?]
		;summa: does [ctx/summa self/data]
		product: does [ctx/product self/data]
		sub: func [start [pair!] size [pair!] /put data' [block!] /local row sz][ ; TBD Unfinished
			either put [
				if all [1 = length? data' 1 < (sz: size/1 * size/2)][
					;loop sz - 1 [append data' data'/1]
					append/dup data' data'/1 sz - 1
				] 
				repeat row size/1 [
					change/part at self/data self/get-idx start/1 - 1 + row start/2 take/part data' size/2 size/2
					;probe self/get-idx start/1 - 1 + row start/2;at self/data self/get-idx start/1 - 1 + row start/2
				] 
			][
			
			]
		]
		sub-exclude: func [rs cs /local m2][ ; TBD
			m2: copy self
			switch type?/word rs [
				block! [
					sort/reverse rs
					;forall rs [
					;	remove
					;]
				]
				integer! []
				none! []
			]
			switch type?/word cs [
				block! []
				integer! []
				none! []
			]
		]
		transpose: does [ctx/transpose self]
		rotate: func [n][ctx/rotate n self]
		rotate-row: func [row n][ctx/rotate-row row n self]
		rotate-col: func [col n][ctx/rotate-col col n self]
		show: does [new-line/skip copy data true cols]
		pretty: function [/tight /box][;/bar /local d i col-lengths][ m to
			col-lengths: copy []
			repeat i cols [
				c: copy get-col i
				c: sort/compare c func [a b][(length? form a) > (length? form b)]
				append col-lengths length? form first c
			]
			cols2: copy []
			templ: copy []
			letters: copy []
			repeat n cols [
				append cols2 to-word rejoin ["_" n]
				append templ compose [
					pad/left (pick cols2 n) (pick col-lengths n)
					;(either bar and (n < cols) ["│"][""])⎡⎢⎤⎣⎥⎦  ⎾⏋⎿⏌  ⌈⌉⌊⌋
				]
			] 
			step: either tight [sum col-lengths][(sum col-lengths) + cols - 1] ;ctx/summa
			fill: either box [pad/with #"█" step #"█"][pad #" " step] ;to-char to-integer #{2580} 2584 2500 #"─"
			either tight [print rejoin [#"▄" pad/with #"▄" step #"▄" #"▄"]][print [#"┌" fill #"┐"]]
			foreach (cols2) data [
				either tight [print rejoin [#"█" rejoin templ #"█"]][print [#"│" reduce compose templ #"│"]]
			]
			either tight [print rejoin [#"▀" pad/with #"▀" step #"▀" #"▀" #"^/"]][print [#"└" pad fill step #"┘" #"^/"]]
		]
		swap-rows: func [r1 r2][ctx/swap-rows r1 r2 self]
		determinant: does [ctx/determinant self]
		trace: does [ctx/trace self]
		identity: func [/side d][either side [ctx/identity/side self d][ctx/identity self]]
		split-col: func [col][ctx/split-col col self]
		neighbours: func [row col /local out][
			out: copy []
			foreach [r c] case [
				all [row = 1 col = 1][[0 0 0 0 0 0 0 0 1 2 0 0 2 1 2 2]]
				all [row = 1 col = cols] [reduce [
						0 0 0 0 0 0 1 cols - 1 0 0 2 cols - 1 2 cols 0 0
					]] 
				all [row = rows col = 1] [reduce [
						0 0 rows - 1 1 rows - 1 2 0 0 rows 2 0 0 0 0 0 0
					]]
				all [row = rows col = cols] [reduce [
						rows - 1 cols - 1 rows - 1 cols 0 0 rows cols - 1 0 0 0 0 0 0 0 0
					]] 
				row = 1  [reduce [
						0 0 0 0 0 0 1 col - 1 1 col + 1 2 col - 1 2 col 2 col + 1
					]]
				row = rows [reduce [
						row - 1 col - 1 row - 1 col row - 1 col + 1 row col - 1 row col + 1 0 0 0 0 0 0
					]]
				col = 1 [reduce [
						0 0 row - 1 col row - 1 col + 1 0 0 row col + 1 0 0 row + 1 col row + 1 col + 1
					]]
				col = cols [reduce [
						row - 1 col - 1 row - 1 col 0 0 row col - 1 0 0 row + 1 col - 1 row + 1 col 0 0
					]]
				true [reduce [
						row - 1 col - 1 row - 1 col row - 1 col + 1 row col - 1 row col + 1 row + 1 col - 1 row + 1 col row + 1 col + 1
					]]
			][append out attempt [get-at r c]]
			out
		]
	]
	vector-op: func [op a b /local i][
		case [
			all [number? a number? b]	[return either op? :op [a op b][op a b]]
			all [number? a any-block? b][forall b [b/1: either op? :op [a op b/1][op a b/1]] return b]
			all [any-block? a number? b][forall a [a/1: either op? :op [a/1 op b][op a/1 b]] return a]
			all [any-block? a any-block? b][
				either (length? a) = (length? b) [
					forall a [i: index? a a/1: either op? :op [a/1 op pick b i][op a/1 pick b i]]
					return a
				][
					cause-error 'user 'message ["Vectors must be of the same length!"]
				]
			]
		]
	]
	product: func [blk /local out][out: 1 forall blk [out: out * blk/1]]
	;summa: 	 func [blk /local out][out: 0 forall blk [out: out + blk/1]]
	determinant: func [m /local i r l rw minor mid idx][
		either m/square? [
			switch/default m/cols [
				0	[1]
				1	[m/data/1]
				2 	[(m/data/1 * m/data/4) - (m/data/2 * m/data/3)]
			    3 	[
					r: make block! m/cols 
					l: make block! m/cols
					repeat i m/cols [
						insert r product m/get-diagonal i 'r
						insert l product m/get-diagonal i 'l
					]
					;(summa r) - (summa l)
					(sum r) - (sum l)
				]
			][
				mid: make block! m/cols
				rw: m/get-row 1
				forall rw [
					minor: copy/deep m
					minor/remove-row 1
					minor/remove-col idx: index? rw
					append mid -1 ** (idx + 1) * rw/1 * determinant minor
				]
				sum mid
			]
		][
			cause-error 'user 'message ["Matrix must be square to find determinant!"]
		]
	]
	trace: func [m][
		either m/square? [
			sum m/get-diagonal 1 'r ;summa
		][
			cause-error 'user 'message ["Trace is defined for square matrices only!"]
		]
	]
	acc: make mtx [rows: 1 cols: 1 data: [1]] 
	add: func [op m1 m2 /local i][
		either all [m1/cols = m2/cols m1/rows = m2/rows][;length? m1/data length? m2/data [ 
			acc/rows: m1/rows acc/cols: m1/cols clear acc/data
			repeat i length? m1/data [append acc/data m1/data/:i op m2/data/:i]
		][
			cause-error 'user 'message ["Matrices of unequal dimensions!"]
		]
		acc
	]
	multi: func [m1 m2 /local val i j k l][
		either equal? l: m1/cols m2/rows [
			acc/rows: m1/rows acc/cols: m2/cols clear acc/data
			repeat i m1/rows [
				repeat j m2/cols [
					val: 0
					repeat k l [val: (m1/get-at i k) * (m2/get-at k j) + val]
					append acc/data val
				]
			]
		][
			cause-error 'user 'message ["Dimensions don't match in multiplication!"]
		]
		acc
	]
	kronecker: func [m1 m2 /local m3 i j k l][
		m3: make mtx [rows: m1/rows * m2/rows cols: m1/cols * m2/cols data: make block! rows * cols]
		repeat i m1/rows [
			repeat j m2/rows [
				repeat k m1/cols [
					repeat l m2/cols [
						append m3/data (m1/get-at i k) * (m2/get-at j l)
		]]]]
		m3
	]
	transpose: func [m /local d i j r c][
		d: copy []
		repeat i c: m/cols [repeat j r: m/rows [append d m/get-at j i]]
		m/cols: r m/rows: c	m/data: d
		m
	]
	rotate: func [n [integer!] m /local data i][
		data: copy []
		switch n [
			1 or -3 [repeat i m/cols [append data copy reverse m/get-col i] m/swap-dim]
			2 or -2 [repeat i m/rows [append data reverse copy m/get-row m/rows + 1 - i]]
			3 or -1 [repeat i m/cols [append data copy m/get-col m/cols + 1 - i] m/swap-dim]
		]
		m/data: data 
		m
	]
	rotate-row: func [r n m /local start-idx][
		start-idx: m/get-idx r 1
		insert at m/data start-idx either negative? n [
			take/part at m/data start-idx - n m/cols + n 
		][
			take/part at m/data start-idx + m/cols - n n 
		]
		m
	]
	rotate-col: func [c n m /local rows][
		either block? c [
			switch type?/word n [
				integer! [forall c [rotate-col c/1 n m]]
				block! [forall c [rotate-col c/1 n/(index? c) m]]
			]
		][
			rows: m/get-col c
			insert rows either negative? n [
				take/part at rows 1 - n m/rows + n 
			][
				take/part at rows m/rows - n + 1 n 
			]
			forall rows [
				poke m/data m/get-idx index? rows c rows/1
			]
		]
		m
	]
	swap-rows: function [r1 r2 m][
		tmp: m/get-row r1 
		change/part at m/data r1 - 1 * m/cols + 1 m/get-row r2 m/cols 
		change/part at m/data r2 - 1 * m/cols + 1 tmp m/cols 
		m
	]
	identity: func [m /side d /local i][
		d: either side [case [d = 'l ['rows] d = 'r ['cols]]]['rows]
		either (side or m/square?) [
			data: make block! power m/:d 2
			repeat i m/:d [repeat j m/:d [append data either i = j [1][0]]]
			make mtx compose [cols: (m/:d) rows: (m/:d) data: (reduce [data])] 
		][
			cause-error 'user 'message ["You need to determine /side ['l | 'r] for non-square matrix!"]
		]
	]
	augment: func [m1 m2 /local i j][
		either m1/rows = m2/rows [
			repeat i m1/rows [
				k: m1/rows - i + 1
				j: m1/get-idx k m1/cols + 1
				insert at m1/data j m2/get-row k
			]
			m1/cols: m1/cols + m2/cols
		][
			cause-error 'user 'message ["Augmented matrix must have same number of rows as the other!"]
		]
		m1
	]
	rref: func [n /local m i j c val][
		m: copy/deep n 
		m/to-float
		repeat i m/rows [
			; make the pivot
			if 0 = (m/get-at i i) [
				c: at m/get-col i i + 1
				until [
					c: next c 
					if tail? c [
						cause-error 'user 'message ["Impossible to get reduced row eschelon form!"]
					] 
					0 < first c
				]
				m/swap-rows i index? c 
			]
			; reduce it to 1
			if 1 <> (val: m/get-at i i) [
				change/part at m/data m/get-idx i 1 vector-op :/ m/get-row i val m/cols
			]
			; reduce other rows at this column to 0 
			repeat j m/rows [
				if all [j <> i 0 <> (c: m/get-at j i)][
					change/part at m/data m/get-idx j 1 vector-op :- m/get-row j vector-op :* c m/get-row i m/cols
				]
			]
		]
		m
	]
	split-col: func [col m /local data i j cls][
		data: copy []
		cls: m/cols - col + 1
		repeat i m/rows [
			j: m/rows - i + 1
			insert data take/part at m/data m/get-idx j col cls 
		] 
		m/cols: col - 1
		reduce [m make mtx compose/deep [rows: (m/rows) cols: (cls) data: [(data)]]]
	]
	invert: func [m /local n][
		augment m identity m
		n: rref m
		m: first split-col m/rows + 1 m
		second split-col n/rows + 1 n
	]
	game-of-life: func [m /local out c i][
		out: copy []
		c: m/data
		forall c [
			s: sum m/neighbours m/get-row-idx i: index? c m/get-col-idx i ;summa
			append out case [
				all [c/1 = 1 s < 2][0]
				all [c/1 = 1 find [2 3] s][1]
				all [c/1 = 1 s > 3][0]
				all [c/1 = 0 s = 3][1]
				true [0]
			]
		]
		m/data: out
		m
	]
	
	;;un:  make mtx [rows: 1 cols: 1 data: [1]] 
	blk: make block! 25
	
	ops-rule: ['+ | '- | '* | '/ | quote % | '** | '>> | quote << | '>>> | 'and | 'or | 'xor | 'div | 'x | 'X | 'augment]
	set 'matrix func [spec /local dim dims rule result m w m1 m2 op op' var vars ops unary unaries d matrices res][
		vars: copy [] ops: copy [] matrices: copy [] unaries: copy []
		matrix-rule: [
			(m: none) [
				set dim pair! [set mdata block! | set w word! if (block? get/any w)(mdata: get w)] 
				(either (dim/1 * dim/2) = length? mdata: reduce mdata [
					m: make mtx [rows: dim/1 cols: dim/2 data: mdata]
				][
					either 1 = length? mdata [
						loop dim/1 * dim/2 - 1 [insert mdata mdata/1]
						m: make mtx [rows: dim/1 cols: dim/2 data: mdata]
					][
						cause-error 'user 'message ["Data length does not match dimensions!"]
					]
				]
				)
			|	set w word! if (object? get/any w)(
					either find words-of get w 'identity [ ; Is it mtx already?
						m: get w
					][
						set w m: make mtx get w ; Hopefully it is obj with 'rows, 'cols and 'data
					]
				)
			|	'v set m block! ;vector
			| 	set m number!
			]	(insert/only matrices m);(either block? m [insert/only matrices m][insert matrices m])
		]
		unary-rule: [
			set unary [
				'transpose 
			| 	'rotate set n integer! 
			| 	'swap copy dims 3 skip 
			| 	'determinant
			|	'trace
			| 	'invert
			| 	'rref
			|	(d: none) 'identity opt [set d ['l | 'r]] 
			|	'game-of-life
			](
				insert unaries switch unary [
					rotate [n] 
					swap [dims]
					identity [if d [d]]
				]
				insert unaries unary 
			) expr-rule (
				unary: take unaries 
				switch unary [
					rotate [n: take unaries]
					swap [dims: take unaries]
					identity [if find ['l 'r] first unaries [d: take unaries]]
				]
				switch/default unary [
					rotate [self/rotate n matrices/1]
					;swap [matrices/1/(to-word rejoin ["swap-" dims/1]) dims/2 dims/3]
					swap [self/(to-word rejoin ["swap-" dims/1]) dims/2 dims/3 matrices/1]
					trace [insert matrices self/trace matrices/1]
					determinant [insert matrices self/determinant matrices/1]
					identity [insert matrices either d [
						self/identity/side matrices/1 d
					][
						self/identity matrices/1
					]]
					rref [insert matrices self/rref matrices/1]
					invert [insert matrices self/invert matrices/1]
				][
					self/:unary matrices/1
				]
			)
		]
		op-probe: [ahead [ops-rule [pair! [block! | word!] | word! | block! | number!]]]
		op-rule: [
			set op' ops-rule (insert ops op') expr-rule (
				op': take ops 
				set [m2 m1] take/part matrices 2
				;probe reduce [m1 m2]
				case [
					op' = 'div [op: :/ either number? m1 [m1: to-float m1][m1/to-float]]
					find [x X augment] op' []
					true [op: get op']
				]
				case [
					all [number? m1 number? m2][res: m1 op m2]
					all [number? m1 block? m2][clear blk forall m2 [append blk m1 op m2/1] res: blk]
					all [block? m1 number? m2][clear blk forall m1 [append blk m1/1 op m2] res: blk]
					number? m1 [append clear blk m2/data forall blk [blk/1: m1 op blk/1] res: m2]
					number? m2 [blk: m1/data forall blk [blk/1: blk/1 op m2] res: m1]
					true [case [
						find exclude ops-rule ['x 'augment] op' [
							res: self/add :op m1 m2
						]
						(same? op' 'x) or (same? op' '×) [res: self/multi m1 m2]
						same? op' 'X [res: self/kronecker m1 m2]
						op' = 'augment [res: self/augment m1 m2]
					]]
				]
				insert matrices res ;probe matrices
			)
		]
		expr-rule: [
			set var set-word! (insert vars var) 
			expr-rule opt [op-probe op-rule] (var: take vars set var copy matrices/1)
		|	ahead paren! into rule ; block! ??
		|	unary-rule
		| 	matrix-rule
		|	op-probe op-rule
		]
		parse spec rule: [some [
			ahead block! into rule ; paren! ??
		| 	expr-rule
		|	s: (print ["No rule applied at: " :s])
		]]
		
		if m1: take matrices [either number? m1 [m1][probe type? m1 new-line/skip copy m1/data true m1/cols]]
	]
]