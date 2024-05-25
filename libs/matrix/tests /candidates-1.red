#!/usr/local/bin/red
Red [
]

#include %rcvMatrix2.red

;--to be included in rcvMatrix2.red
;--internal 
;--matrices control
_matSizeEQ?: func [
"Matrices have equivalent size?"
	mx1		[vector!]	;--matrix
	mx2		[vector!]	;--matrix
	return:	[logic!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	all [h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
]

_matTypeEQ?: func [
"Matrices have equivalent type?"
	mx1		[vector!]	;--matrix
	mx2		[vector!]	;--matrix
	return:	[logic!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	h1/:_TYPE = h2/:_TYPE 
]

_matDepthEQ?: func [
"Matrices have equivalent bit-size?"
	mx1		[vector!]	;--matrix
	mx2		[vector!]	;--matrix
	return:	[logic!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	h1/:_BITS = h2/:_BITS	
]

_matSimilar?: func [
"Matrices are similar?"
	mx1		[vector!]	;--matrix
	mx2		[vector!]	;--matrix
	return:	[logic!]
][
	h1: rcvGetMatHeader mx1
	h2: rcvGetMatHeader mx2
	All [h1/:_BITS = h2/:_BITS h1/:_BITS = h2/:_BITS 
	h1/:_ROWS = h2/:_ROWS h1/:_COLS = h2/:_COLS]	
]

;--basic operator
_matOp: func [
	mx1		[vector!]	;--matrix
	mx2		[vector!]	;--matrix
	op		[integer!]	;--operator 
	return:	[vector!]	;--matrix
	/local
	h		[block!]
	b1		[vector!]
	b2		[vector!]
	mData	[vector!]
	t		[word!]
	sz      [pair!]
][
	h: rcvGetMatHeader mx1
	b1: rcvGetMatData mx1 
	b2: rcvGetMatData mx2 
	mData: switch op [
		0 [b1 + b2]		;--Add
		1 [b1 - b2]		;--Substract
		2 [b1 AND b2]	;--and
		3 [b1 OR b2]	;--or
		4 [b1 XOR b2]	;--xor
	]
	sz: as-pair h/:_COLS h/:_ROWS
	rcvCreateMat h/:_TYPE h/:_BITS sz to-block mData
]

;--scalar operator
_matScalarOp: func [
	mx		[vector!]	;--matrix
	op		[integer!]	;--operator
	value	[number!]	;--scalar value
	return:	[vector!]	;--matrix
	/local
	_mx		[vector!]
	v		[vector!]
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
				3 [v / value]	;--Divide
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

;--functions

rcvMatAdd: func [
"Add 2 matrices"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	either _matSimilar? m1 m2 [_matOp m1 m2 0]
	[cause-error 'user 'message ["The two matrices must be similar"]]
]

rcvMatSubtract: func [
"Substract 2 matrices"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	either _matSimilar? m1 m2 [_matOp m1 m2 1] 
	[cause-error 'user 'message ["The two matrices must be similar"]]
]

rcvMatAnd: func [
"m1 and m2"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	either _matSimilar? m1 m2 [_matOp m1 m2 2] 
	[cause-error 'user 'message ["The two matrices must be similar"]]
]

rcvMatOr: func [
"m1 or m2"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	either _matSimilar? m1 m2 [_matOp m1 m2 3] 
	[cause-error 'user 'message ["The two matrices must be similar"]]
]

rcvMatXor: func [
"m1 xor m2"
	m1		[vector!];--matrix
	m2		[vector!];--matrix
	return:	[vector!];--matrix
][
	either _matSimilar? m1 m2 [_matOp m1 m2 4] 
	[cause-error 'user 'message ["The two matrices must be similar"]]
]

;--Scalar operations 

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

rcvMatScalarProduct: function [
"Matrix * value (scalar product)"
	mx 		[vector!];--matrix 
	value 	[number!];--value
][
	_matScalarOp mx value 2
]

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
"Matrix left shiht "
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


;--matrix operators

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

; TO BE ADDED

;rcvMatInverse
;rcvMatDivision
;rcvMatStandardProduct
;rcvMatHadamardProduct
;rcvMatKroneckerProduct




