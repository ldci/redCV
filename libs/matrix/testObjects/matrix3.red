Red []
;How to access matrix object with routines
;Thanks to Qingtian :)
#system [
	mat: context [
		#enum matrix-fields! [
			MAT_OBJ_TYPE	;-- 0
			MAT_OBJ_BITS	;-- 1
			MAT_OBJ_ROWS	;-- 2
			MAT_OBJ_COLS	;-- 3
			MAT_OBJ_DATA	;-- 4
		]
		get-type: func [
			mObj	[red-object!]
			return: [integer!]
			/local
			val		[red-value!]
			int		[red-integer!]
		][
			val: object/get-values mObj
			int: as red-integer! val + MAT_OBJ_TYPE
			int/value
		]
		
		get-bits: func [
			mObj	[red-object!]
			return: [integer!]
			/local
			val		[red-value!]
			int		[red-integer!]
		][
			val: object/get-values mObj
			int: as red-integer! val + MAT_OBJ_BITS
			int/value
		]
		
		get-unit: func [
			mObj	[red-object!]
			return: [integer!]
			/local
			vec		[red-vector!]
			s		[series!]
		][
			vec: mat/get-data mObj
			s: GET_BUFFER(vec)
			GET_UNIT(s)
		]
		
		get-rows: func [
			mObj	[red-object!]
			return: [integer!]
			/local
			val		[red-value!]
			int		[red-integer!]
		][
			val: object/get-values mObj
			int: as red-integer! val + MAT_OBJ_ROWS
			int/value
		]
		
		get-cols: func [
			mObj	[red-object!]
			return: [integer!]
			/local
			val		[red-value!]
			int		[red-integer!]
		][
			val: object/get-values mObj
			int: as red-integer! val + MAT_OBJ_COLS
			int/value
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



#include %matrix-obj.red

getMatType: routine [
	mObj	[object!]
	return:	[integer!]
	/local
	int		[red-integer!]
][
	mat/get-type mObj
]

getMatBits: routine [
	mObj	[object!]
	return:	[integer!]
	/local
	int		[red-integer!]
][
	mat/get-bits mObj
]

getMatOrder: routine [
	mObj	[object!]
	return:	[pair!]
	/local
	rows	[integer!]
	cols	[integer!]
	order	[red-pair!]
][
	order: pair/make-at stack/push* 0 0
	rows: mat/get-rows mObj
	cols: mat/get-cols mObj
	order/x: cols
	order/y: rows
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
		vec  	[red-vector!]
][
	vec: mat/get-data mObj
	as red-vector! stack/set-last as cell! vec
]



result: does [
	print ["Matrix Type:        " getMatType m1]
	print ["Matrix Bit Size:    " getMatBits m1]
	print ["Matrix Order:       " getMatOrder m1]
	print ["Matrix Data Length: " getMatDataLength m1]
	print ["Matrix data:        " getMatData m1 lf]
]


;********************** Tests ************************

random/seed now/time
print "Char Matrix"
m1: matrix/init/value/rand 1 8 3x3 to-char 127
result
print "Integer Matrix"
m1: matrix/init/value/rand 2 32 3x3 255	
result
print "Float Matrix"
m1: matrix/init/value/rand 3 64 3x3 255.0
result

;--now we test with a redCV routine

rcvGetMatUnit: routine [
"Returns matrice unit"
	mObj  	[object!] ;--replace [vector!]
	return: [integer!]
	/local
	s		[series!] 
	vec 	[red-vector!]
] [
	vec: mat/get-data mObj
	s: GET_BUFFER(vec)
	GET_UNIT(s)
]

print ["Test redCV Get Unit:" rcvGetMatUnit m1]
