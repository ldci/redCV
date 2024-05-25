Red []
;from Qingtian
#system [
	matrix: context [
		#enum matrix-fields! [
			MAT_OBJ_TYPE	;-- 0
			MAT_OBJ_BITS	;-- 1
			MAT_OBJ_ROWS	;-- 2
			MAT_OBJ_COLS	;-- 3
			MAT_OBJ_DATA	;-- 4
		]

		get-data: func [
			mObj	[red-object!]
			return: [red-vector!]
			/local
				val [red-value!]
		][
			val: object/get-values mObj
			as red-vector! val + MAT_OBJ_DATA
		]
	]
]

mx: object [
	type: [integer!]	;-- offset: 0
	bits: [integer!]	;-- offset: 1
	rows: [integer!]	;-- offset: 2
	cols: [integer!]	;-- offset: 3
	data: [vector!]		;-- offset: 4
]

getMatObject: routine [
	mObj	[object!]
	/local
		vec  [red-vector!]
		s	 [series!]
		unit [integer!]
		p	 [byte-ptr!]
		end	 [byte-ptr!]
][
	vec: matrix/get-data mObj
	;@@ all the code below can be putted in matrix/get-data
	;@@ so the routine getMatObject just be a wrapper.

	print ["vec length: " vector/rs-length? vec lf]

	;-- print all the values
	s: GET_BUFFER(vec)
	unit: GET_UNIT(s)
	p: (as byte-ptr! s/offset) + (vec/head << (log-b unit))
	end: as byte-ptr! s/tail

	while [p < end][
		switch vec/type [
			TYPE_CHAR TYPE_INTEGER [
				print [vector/get-value-int as int-ptr! p unit " "]
			]
			TYPE_FLOAT [
				print [vector/get-value-float p unit " "]
			]
		]
		p: p + unit
	]
	print lf
]

m1: copy mx
m1/type: 2
m1/bits: 16
m1/rows: 3
m1/cols: 3
m1/data: make vector! [1 2 3 4 5 6 7 8 9] 

getMatObject m1