Red []
;Thanks to Qingtian :)

#system [
	mat: context [
		#enum Matrix-fields! [
			MAT_OBJ_TYPE	;-- 0
			MAT_OBJ_BITS	;-- 1
			MAT_OBJ_ROWS	;-- 2
			MAT_OBJ_COLS	;-- 3
			MAT_OBJ_DATA	;-- 4
		]
		get-type: func [
			mObj	[red-object!]
			return: [red-integer!]
			/local
			val		[red-value!]
		][
			val: object/get-values mObj
			as red-integer! val + MAT_OBJ_TYPE
		]
		
		get-bits: func [
			mObj	[red-object!]
			return: [red-integer!]
			/local
			val		[red-value!]
		][
			val: object/get-values mObj
			as red-integer! val + MAT_OBJ_BITS
		]
		
		get-rows: func [
			mObj	[red-object!]
			return: [red-integer!]
			/local
			val		[red-value!]
		][
			val: object/get-values mObj
			as red-integer! val + MAT_OBJ_ROWS
		]
		
		get-cols: func [
			mObj	[red-object!]
			return: [red-integer!]
			/local
			val		[red-value!]
		][
			val: object/get-values mObj
			as red-integer! val + MAT_OBJ_COLS
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
	];--end of context
];--end of Red/System

mx: object [
	type: [integer!]	;-- offset: 0
	bits: [integer!]	;-- offset: 1
	rows: [integer!]	;-- offset: 2
	cols: [integer!]	;-- offset: 3
	data: [vector!]		;-- offset: 4
]

getMatType: routine [
	mObj	[object!]
	return:	[integer!]
	/local
	int		[red-integer!]
][
	int: mat/get-type mObj
	int/value
]

getMatBits: routine [
	mObj	[object!]
	return:	[integer!]
	/local
	int		[red-integer!]
][
	int: mat/get-bits mObj
	int/value
]

getMatOrder: routine [
	mObj	[object!]
	return:	[pair!]
	/local
	rows	[red-integer!]
	cols	[red-integer!]
	order	[red-pair!]
][
	order: pair/make-at stack/push* 0 0
	rows: mat/get-rows mObj
	cols: mat/get-cols mObj
	order/x: cols/value
	order/y: rows/value
	as red-pair! stack/set-last as cell! order
]

getMatDataLength: routine [
	mObj	[object!]
	return:	[integer!]
	/local
		vec  [red-vector!]
][
	vec: mat/get-data mObj
	vector/rs-length? vec 
]

getMatData: routine [
	mObj	[object!]
	return:	[vector!]
	/local
		vec  [red-vector!]
][
	vec: mat/get-data mObj
	as red-vector! stack/set-last as cell! vec
]

m1: copy mx
m1/type: 2
m1/bits: 16
m1/rows: 3
m1/cols: 3
m1/data: make vector! [1 2 3 4 5 6 7 8 9] 
print ["Matrix Type:        " getMatType m1]
print ["Matrix Bit Size:    " getMatBits m1]
print ["Matrix Order:       " getMatOrder m1]
print ["Matrix Data Length: " getMatDataLength m1]
print ["Matrix data:        " getMatData m1]
