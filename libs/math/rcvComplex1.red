Red [
	Title:   "Red Computer Vision: Complex Number routines"
	Author:  "Francois Jouen"
	File: 	 %rcvComplex.red
	Tabs:	 4
	Rights:  "Copyright (C) 2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;since Red does not support complex numbers (z = a + ib), we use vectors and array of vectors  
;e.g a: make vector! [1.0 0.0]
;samples of complex numbers 3+4i, 5-2i, -8+7i
;fondamental i2 = -1

rcvMathComplex: routine [
    a 		[vector!]
    b 		[vector!]
    op		[integer!]
    return: [vector!]
    /local
        ptra [float-ptr!]
        ptrb [float-ptr!]
        ptrc [float-ptr!]
        c    [red-vector!]
        s    [series!]
        d	 [float!]	 
][
	;-- thanks to Qingtian
    ;-- make a new vector to store the result
    c: vector/make-at stack/push* 2 TYPE_FLOAT 8    ;-- slot, size, type, unit
    ptra: as float-ptr! vector/rs-head a
    ptrb: as float-ptr! vector/rs-head b
    ptrc: as float-ptr! vector/rs-head c
    ;-- process math operator
	switch  op [
   	 	OP_ADD [ptrc/1: (ptra/1 + ptrb/1) ptrc/2: (ptra/2 + ptrb/2)] 	;-- 0
   	 	OP_SUB [ptrc/1: (ptra/1 - ptrb/1) ptrc/2: (ptra/2 - ptrb/2)] 	;-- 1
   	 	OP_MUL [ ptrc/1: (ptra/1 * ptrb/1) - (ptra/2 * ptrb/2)
    			ptrc/2: (ptra/1 * ptrb/2) + (ptra/2 * ptrb/1)]		 	;-- 2	
    	OP_DIV [ptrc/1:  (ptra/1 * ptrb/1) + (ptra/2 * ptrb/2)
				ptrc/2:  (0.0 - ptra/1 * ptrb/2)  + (ptra/2 * ptrb/1)
				d: (ptrb/1 * ptrb/1) + (ptrb/2 * ptrb/2)
				ptrc/1: ptrc/1 / d
				ptrc/2:  ptrc/2 / d ]									;-- 3
	]
    s: GET_BUFFER(c)
    s/tail: as cell! (as float-ptr! s/offset) + 2   ;-- set the tail properly
    as red-vector! stack/set-last as cell! c        ;-- return the new vector
]

rcvAddComplex: function [
"Adds 2 complex numbers"
	a 		[vector!]
    b 		[vector!]
    return: [vector!]
][
	rcvMathComplex a b 0
]

rcvSubComplex: function [
"Substracts 2 complex numbers"
	a 		[vector!]
    b 		[vector!]
    return: [vector!]
][
	rcvMathComplex a b 1
]

rcvMulComplex: function [
"Multiply 2 complex numbers"
	a 		[vector!]
    b 		[vector!]
    return: [vector!]
][
	rcvMathComplex a b 2
]

rcvDivComplex: function [
"Divides 2 complex numbers"
	a 		[vector!]
    b 		[vector!]
    return: [vector!]
][
	rcvMathComplex a b 3
]


rcvMakeComplexArray: function [
"Makes an array of complex numbers"
	input	[vector!]
	return: [block!]
][
	cInput: copy []												
	len: length? input
	repeat i len [
		cNumber: make vector! [float! 64 2] ; real and imaginary float
		cNumber/1: input/(i)
		cNumber/2: 0.0
		append/only cinput cNumber; complex number
	]
]

