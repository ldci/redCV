Red [
	Title:   "Red Computer Vision: Matrix functions"
	Author:  "François Jouen, Toomas Vooglaid and Qingtian Xie"
	File: 	 %routines-obj.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020-2021 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;**********************NEW MATRIX OBJECT**************************
;--How to access matrix object with routines
;--Thanks to Qingtian Xie:)

#system [
	mat: context [
		;--pure Red/S  code
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

;--now some routines and functions

getMatType: routine [
	mObj	[object!]
	return:	[integer!]
][
	mat/get-type mObj
]

getMatBits: routine [
	mObj	[object!]
	return:	[integer!]
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

getMatUnit: routine [
"Returns matrice unit"
	mObj  	[object!]
	return: [integer!]
	/local
	s		[series!] 
	vec 	[red-vector!]
] [
	vec: mat/get-data mObj
	s: GET_BUFFER(vec)
	GET_UNIT(s)
]


getMatTypeAsString: function [
	mObj	[object!]
	return:	[string!]
][
	switch/default getMatType mObj [
		1 [return "Char!"]
		2 [return "Integer!"]
		3 [return "Float!"]
	][return "Unknown"]
]

