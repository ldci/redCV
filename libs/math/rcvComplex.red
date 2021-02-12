#!/usr/local/bin/red
Red [
	Title:   "Red Computer Vision: Complex Number"
	Author:  "Francois Jouen and Toomas Vooglaid"
	File: 	 %rcvComplex.red
	Tabs:	 4
	Rights:  "Copyright (C) 2020 Red Foundation. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;--thanks to Robert Davies (http://www.robertnz.net/) 

complex: context [
	;--we need some hyperbolic functions not supported by red
	
	sinh: func [
	"hyperbolic sine of x"
		x		[float!]
		return: [float!]
	][
		(exp x - exp negate x) / 2.0
	]
	
	cosh: func [
	"hyperbolic cos of x"
		x		[float!]
		return: [float!]
	][
		(exp x + exp negate x) / 2.0
	]
	
	tanh: func [
	"hyperbolic tangent of x"
		x		[float!]
		return: [float!]
	][
		sinh x / cosh x
	]
	;or tanh: (exp x - exp negate x) / (exp x + exp negate x)


	;--Complex Number Object
	complexR: object [
		re:	0.0	;--Real part (float!) 
		im: 1.0	;--Imaginary part (float!)
	]
	
	cCreate: func [
	"Creates a complex number from a block of integer or float values"
		values	[block!]
		return:	[object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: to-float values/1
		_z/im: to-float values/2
		_z
	]
	
	cNegate: func [
	"Returns the opposite of a complex number"
		z		[object!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy z 
		_z/re: negate z/re 
		_z/im: negate z/im 
		_z
	]
	
	cConjugate: func [
	"Returns the cConjugate of a complex number"
		z		[object!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy z
		_z/im: negate _z/im 
		_z
	]
	
	cReal: func [
	"Returns cReal part of complex number"
		z		[object!]
		return: [float!]
	][
		z/re
	]
	
	cImaginary: func [
	"Returns cImaginary part of complex number"
		z		[object!]
		return: [float!]
	][
		z/im
	]
	
	cModulus: func [
	"Returns z cModulus as a float"
		z		[object!]
		return: [float!]
	][
		square-root ((z/re * z/re) + (z/im * z/im))
	]
	
	cArgument: func [
	"Return z cArgument as an angle in radians or degrees"
		z		[object!]
		return: [float!]
		/degrees
	][	
		either degrees [arctangent z/im / z/re][arctangent/radians z/im / z/re]
	]
	
	cLog: func [
	"Returns the natural logarithm of any complex number" 
		z		[object!]
		return:	[object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: log-e cModulus z
		_z/im: cArgument z
		_z
	]
	
	
	cExp: func [
	"Raises E (the base of natural logarithm) to the power specified"
		z		[object!]
		return:	[object!]
	][
		_z: copy complexR
		_z/re: exp z/re * cos z/im
		_z/im: sin z/im
		_z
	]
	
	;--to be improved
	cPow: func [
		z		[object!]
		n		[integer!]
		return:	[object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR 
		rn: power cModulus z n
		_z/re: rn * cos (n * cArgument z) 
		_z/im: rn * sin (n * cArgument z) 
		_z
	]
	
	;--trigonometric functions
	
	cSin: func [
	"Returns the trigonometric sine of complex number"
		z		[object!]
		return:	[object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR 
		_z/re: sin z/re * cosh z/im
		_z/im: cos z/re * sinh z/im
		_z
	]
	
	cCos: func [
	"Returns the trigonometric cosine of complex number"
		z		[object!]
		return:	[object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR 
		_z/re: cos z/re * cosh z/im
		_z/im: sin z/re * sinh z/im
		_z
	]
	
	cTan: func [
	"Returns the trigonometric tangent of complex number"
		z		[object!]
		return:	[object!]
		/local 
		_z		[object!]
		__z		[object!]
	][
		_z: copy complexR 
		_z/re: tan z/re
		_z/im: tanh z/im
		__z: copy complexR 
		__z/re: 1.0
		__z/im: tan z/re * tanh z/im
		cDivide _z __z
	]
	
	
	cSinh: func [
	"Returns hyperbolic sine of complex number"
		z		[object!]
		return:	[object!]
		/local iota _z
	][
		iota: cCreate [0.0 1.0]
		_z: cSin cProduct iota z
		cDivide _z iota
	]
	
	cCosh: func [
	"Returns hyperbolic sine of complex number"
		z		[object!]
		return:	[object!]
		/local iota _z
	][
		iota:   cCreate [0.0 1.0]
		cProduct iota z
	]
	
	cTanh: func [
	"Returns hyperbolic tangent of complex number"
		z		[object!]
		return:	[object!]
		/local iota _z
	][
		iota: cCreate [0.0 1.0]
		_z: cTan cProduct iota z
		cDivide _z iota
	]
	
	
	;--Conversions
	toPolar: func [
	"Breaks a complex number into its polar component"
		z		[object!]
		return: [block!]
	][
		reduce [cModulus z cArgument z]
	]
	

	toCartesian: func [
	"Returns cartesian coordinates from polar components"
		polar	[block!]
		return:	[block!]
	][
		reduce [polar/1 * cos polar/2  polar/1 * sin polar/2]
	]
	
	toComplex: func [
	"Creates a complex number from two values in polar notation"
		polar	[block!]
		return: [object!]
		/rounding		
	][
		_z: copy complexR
		_z/re: polar/1 * cos polar/2
		_z/im: polar/1 * sin polar/2
		if rounding [
			_z/re: round/to _z/re 0.01
			_z/im: round/to _z/im 0.01
		]
		_z
	]
	
	;--Thanks to André Lichnerowicz (1915-1998)
	;--we use a object compatible with redCV matrix object
	
	toMatrix: func [
	"Transforms complex number to a 2x2 matrix"
		z		[object!]
		return:	[object!]
	][
		;matrix/cCreate 3 64 2x2 reduce [z/re 0.0 - z/im z/im z/re]
		mdata: reduce [z/re negate z/im z/im z/re]
		mx: object [
				type: 3
				bits: 64
				rows: 2
				cols: 2
				data: make vector! reduce [type bits rows * cols]
		]
		mx/data: mdata
		mx
	]
	
	;--complex numbers operators
	cAdd: func [
	"Adds 2 complex numbers"
		z1		[object!]
		z2		[object!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: z1/re + z2/re
		_z/im: z1/im + z2/im
		_z
	]
	
	cSubtract: func [
	"Subtracts 2 complex numbers"
		z1		[object!]
		z2		[object!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: z1/re - z2/re
		_z/im: z1/im - z2/im
		_z
	]
	
	;(a+bi)(c+di) = (ac−bd) + (ad+bc)i; fast
    cProduct: func [
	"Multiplies 2 complex numbers"
		z1		[object!]
		z2		[object!]
		return: [object!]
		/local 
		_z			[object!]
	][
		_z: copy complexR
		_z/re: (z1/re * z2/re) - (z1/im * z2/im)
		_z/im: (z1/re * z2/im) + (z1/im * z2/re)
		_z
	]
    ;FOIL Method (Firsts, Outers, Inners, Lasts)			
	cFoilProduct: func [
	"Multiplies 2 complex numbers"
		z1		[object!]
		z2		[object!]
		return: [object!]
		/local 
		_z			[object!]
		p1 p2 p3 p4	[float!]
	][
		_z: copy complexR
		p1: z1/re * z2/re		;--cReal cProduct
		p2: z1/re * z2/im		;--cImaginary cProduct
		;we have to process i
		p3: z1/im * z2/re		;--we get i*i
		p4: z1/im * z2/im * -1	;-- * i^2 = -1
		_z/re: p1 + p4			;--cReal part
		_z/im: p2 + p3			;--cImaginary part
		_z
	]
	
	cDivide: func [
	"Divides 2 complex numbers"
		z1		[object!]
		z2		[object!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		c: cConjugate z2
		p1: cProduct z1 c
		p2: cProduct z2 c
		_z/re:  p1/re / p2/re 
		_z/im:  p1/im / p2/re
		_z
	]
	
	scalarProduct: func [
	"Multiplies a complex number by a scalar"
		z		[object!]
		scalar	[float!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: z/re * scalar
		_z/im: z/im * scalar
		_z
	]
	
	scalarDivision: func [
	"Divides a complex number by a scalar"
		z		[object!]
		scalar	[float!]
		return: [object!]
		/local 
		_z		[object!]
	][
		_z: copy complexR
		_z/re: z/re / scalar
		_z/im: z/im / scalar
		_z
	]
	
	;--for printing complex numbers
	sAlgebraic: func [
	"Returns algebraic notation of a complex number as a string"
		z		[object!]
		return: [string!]
	][
		;s:  "0.0+1.0i"	;--algebraic representation of z
		s: form z/re
		if z/im >= 0.0 [append s "+"]
		append s form z/im
		append s "i"
		s
	]
	
	sPolar: func [
	"Returns polar notation of a complex number as a string"
		z		[object!]
		return: [string!]
	][
		;x + iy =	r cos θ + i r sin θ
		;cis is just shortcut for cos θ + i sin θ
		str: form cModulus z
		append str " cis " 
		append str cArgument z
		str
	]
];--end of context




