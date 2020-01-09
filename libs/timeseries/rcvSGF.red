Red [
	Title:   "Red Computer Vision: Savitzky-Golay filter"
	Author:  "Francois Jouen"
	File: 	 %rcvSGF.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;**********************Savitzky-Golay filter*****************************
;Coefficients tables

; Filtering
;cubic polynomials
sgTable1: [
[-3 12 17 12 -3 35]
[-2 3 6 7 6 3 -2 21]
[-21 14 39 54 59 54 39 14 -21 231]
[-36 9 44 69 84 89 84 69 44 9 -36 429]
[-11 0 9 16 21 24 25 24 21 16 9 0 -11 143]
[-78 -13 42 87 122 147 162 167 162 147 122 87 42 -13 -78 1105]
[-21 -6 7 18 27 34 39 42 43 42 39 34 27 18 7 -6 -21 323]
[-136 -51 24 89 144 189 224 249 264 269 264 249 224 189 144 89 24 -51 -136 2261]
[-171 -76 9 84 149 204 249 284 309 324 329 324 309 284 249 204 149 84 9 -76 -171 3059]
[-42 -21 -2 15 30 43 54 63 70 75 78 79 78 75 70 63 54 43 30 15 -2 -21 -42 805]
[-253 -138 -33 62 147 222 287 343 387 422 447 462 467 462 447 422 387 343 287 222 147 62 -33 -138 -253 5175]
]

;quartic  and quintic polynomials
sgTable2: [
[5 -30 75 131 75 -30 5 231]
[15 -55 30 135 179 135 30 -55 15 429]
[18 -45 -10 60 120 143 120 60 -10 -45 18 429]
[110 -198 -135 110 390 600 677 600 390 110 -135 -198 110 2431]
[2145 -2860 -2937 -165 3755 7500 10125 11063 10125 7500 3755 -165 -2937 -2860 2145 46189]
[195 -195 -260 -117 135 415 660 825 883 825 660 415 135 -117 -260 -195 195 4199]
[340 -255 -420 -290 18 405 790 1110 1320 1393 1320 1110 790 405 18 -290 -420 -255 340 7429]
[11628 -6460 -13005 -11220 -3940 6378 17655 28190 36660 42120 44003 42120 36660 28190 17655 6378 -3940 -11220 -13005 -6460 11628 260015]
[285 -114 -285 -165 30 261 495 705 870 975 1011 975 870 705 495 261 30 -165 -285 -114 285 6555]
[1265 -345 -1122 -1255 -915 -255 590 1503 2385 3155 3750 4125 4253 4125 3750 3155 2385 1503 590 -255 -915 -1255 -1122 -345 1265 30015]
]

;Derivating
;Derivative 1 quadratic
sgTable3: [
[-2 -1 0 1 2 10]
[-3 -2 -1 0 1 2 3 28] 
[-4 -3 -2 -1 0 1 2 3 4 60] 
[-5 -4 -3 -2 -1 0 1 2 3 4 5 110] 
[-6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 182] 
[-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 280] 
[-8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 408]
[-9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 570]
[-10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 770]
[-11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 1012]
[-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12 1300]
]

;Derivative 1 quartic
sgTable4: [
[1 -8 0 8 -1 12]
[22 -67 -58 0 58 67 -22 252]
[86 -142 -193 -126 0 126 193 142 -86 1188]
[300 -294 -532 -503 -296 0 296 503 532 294 -300 5148]
[1133 -600 -1578 -1796 -1489 -832 0 832 1489 1796 1578 600 -1133 24024]
[12922 -4121 -14150 -18334 -17842 -13843 -7506 0 7506 13843 17842 18334 14150 4121 -12922 334152]
[748 -90 -643 -930 -1002 -902 -673 -358 0 358 673 902 1002 930 643 98 -748 23256]
[6936 68 -4648 -7481 -8700 -8574 -7372 -5363 -2816 0 2816 5363 7372 8574 8700 7481 4648 -68 -6936 255816]
[84075 10032 -43284 -78176 -96947 -101900 -95338 -79564 -56881 -29592 0 29592 56881 79564 95338 101900 96947 78176 43284 10032 -84075 3634092]
[3938 815 -1518 -3140 -4130 -4567 -4530 -4098 -3350 -2365 -1222 0 1222 2365 3350 4098 4530 4567 4130 3140 1518 -815 -3938 197340]
[30866 8602 -8525 -20982 -29236 -33754 -35003 -33450 -29562 -23806 -16649 -8558 0 8558 16649 23806 29562 33450 35003 33754 29236 20982 8525 -8602 -30866 1776060]
]


; Derivative 1 quintic sextic
sgTable5: [
[-1 9 -45 0 45 -9 1 60]
[-254 1381 -2269 -2879 0 2879 2269 -1381 254 8580]
[-573 2166 -1249 -3774 -3084 0 3084 3774 1249 -2166 573 17160]
[-9647 27093 -12 -33511 -45741 -31380 0 31380 45741 33511 12 -27093 9647 291720]
[-78351 169819 65229 -130506 -266401 -279975 -175125 0 175125 279975 266401 130506 -65229 -169819 78351 2519400]
[-14404 24661 16679 -8761 -32306 -43973 -40483 -23945 0 23945 40483 43973 32306 8671 -16679 -24661 14404 503890]
[-255102 349928 322378 9473 -348823 -604484 -686099 -583549 -332684 0 332684 583549 686099 604484 348823 -9473 -322378 -349928 255102 9806280]
[-15033066 16649358 19052988 6402438 -10949942 -26040033 -34807914 -35613829 -28754154 -15977364 0 15977364 28754154 35613829 34807914 26040033 10949942 -6402438 -19052988 -16649358 15033066 637408200]
[-400653 359157 489687 265164 -106911 -478349 -752859 -878634 -840937 -654687 -357045 0 357045 654687 840937 878634 752859 478349 106911 -265164 -489687 -359157 400653 18747300]
[-8322182 6024183 9604353 6671883 544668 -6301491 -12139321 -15896511 -17062146 -15593141 -11820675 -6356625 0 6356635 11820675 15593141 17062146 15896511 12139321 6301491 -544668 -6671893 -9604353 -6024183 8322182 429214500]
]

; ********************** routines **********************************
rcvSGFiltering: routine [
"This routine is used to generate the different Savitzky-Golay filters"
	signal 		[vector!]
	filter 		[vector!]
	kernel		[block!]
	/local headS headBS headF  unit1 unit2 s 
	kBase kValue kLength
	sg i n nl nr length sglength offset
	val val2 pt64
	sum coef sumCoef fcoef fsumCoef
][
	headS: vector/rs-head signal
	headBS: vector/rs-head signal
	headF: vector/rs-head filter
	kBase: block/rs-head kernel
	kLength: (block/rs-length? kernel) - 2
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	length: vector/rs-length? signal
	
	nl: kLength / 2
	nr: kLength / 2
	sglength: nl + nr + 1
	;skip nl values 
	i: 0
	sum: 0.0
	while [i < nl] [
	 	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
    ;start filter
    while [i < (length - nr)] [
    	sg: 0.0
    	sum: 0.0
    	n: 0
    	while [n < sglength][
    		offset: (i - nl + n - 1) * unit1
    		val: vector/get-value-float headBS + offset  unit1
    		kValue: KBase + n 
    		coef: as red-integer! kValue
    		fcoef: as float! coef/value
    		sum: sum + (val * fcoef)
    		n: n + 1
    	]
    	kValue: kValue + 1
    	sumCoef: as red-integer! kValue
    	fsumCoef: as float! sumCoef/value
    	sg: sum / fsumCoef
    	if i = nl [val2: sg] ; for replacing first nl values
    	pt64: as float-ptr! headF
		pt64/value: sg
    	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1
    ]
    while [i < length] [
    	val: vector/get-value-float headS unit1
	 	pt64: as float-ptr! headF
		pt64/value: sg
    	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
    
    ; update first nl values
    headS: vector/rs-head signal
	headF: vector/rs-head filter
	i: 0
	while [i < nl] [
	 	pt64: as float-ptr! headF
		pt64/value: val2
	 	headS: headS + unit1
		headF: headF + unit2 
    	i: i + 1 
    ]
]

; *********************** Functions **************************
rcvSGFilter: function [
"Calculates second order polynomial Savitzky-Golay filter"
	signal 		[vector!]
	filter 		[vector!]
	opSG		[integer!]
][
	;pre defined sg coefficients for fast calculation (cubic polynomials)./
	case [
		opSG = 1  [kernel: sgTable1/1] 	;5
    	opSG = 2  [kernel: sgTable1/2]	;7 
    	opSG = 3  [kernel: sgTable1/3]  ;9 
    	opSG = 4  [kernel: sgTable1/4] 	;11
    	opSG = 5  [kernel: sgTable1/5] 	;13
    	opSG = 6  [kernel: sgTable1/6]	;15
    	opSG = 7  [kernel: sgTable1/7]	;17
    	opSG = 8  [kernel: sgTable1/8]	;19
    	opSG = 9  [kernel: sgTable1/9]	;21
    	opSG = 10 [kernel: sgTable1/10]	;23
    	opSG = 11 [kernel: sgTable1/11] ;25
    ]
    
    ;quartic  and quintic polynomials
    case [
    	opSG = 12  [kernel: sgTable2/1]	;7
    	opSG = 13  [kernel: sgTable2/2]	;9 
    	opSG = 14  [kernel: sgTable2/3] ;11
    	opSG = 15  [kernel: sgTable2/4] ;13
    	opSG = 16  [kernel: sgTable2/5]	;15
    	opSG = 17  [kernel: sgTable2/6]	;17
    	opSG = 18  [kernel: sgTable2/7]	;19
    	opSG = 19  [kernel: sgTable2/8]	;21
    	opSG = 20  [kernel: sgTable2/9] ;23
    	opSG = 21  [kernel: sgTable2/10];25
    ]
    
    
    ; we need float matrices
    t: type? first signal
    if t = integer! [signal * 1.0]
    t: type? first filter
    if t = integer! [filter * 1.0]
    rcvSGFiltering signal filter kernel
]

rcvSGCubicFilter: function [
"Calculates second order polynomial Savitzky-Golay filter"
	signal 		[vector!]
	filter 		[vector!]
	opSG		[integer!]
][
	
    kernel: sgTable1/:opSG
    ; we need float matrices
    t: type? first signal
    if t = integer! [signal * 1.0]
    t: type? first filter
    if t = integer! [filter * 1.0]
    if not none? kernel [rcvSGFiltering signal filter kernel]
]

rcvSGQuarticFilter: function [
"Calculates second order polynomial Savitzky-Golay filter"
	signal 		[vector!]
	filter 		[vector!]
	opSG		[integer!]
][
	
    kernel: sgTable2/:opSG
    ; we need float matrices
    t: type? first signal
    if t = integer! [signal * 1.0]
    t: type? first filter
    if t = integer! [filter * 1.0]
    if not none? kernel [rcvSGFiltering signal filter kernel]
]

rcvSGDerivative1: function [
"Calculates first derivative polynomial Savitzky-Golay filter"
	signal 		[vector!]
	filter 		[vector!]
	opSG		[integer!]
][
	;pre defined sg coefficients for fast calculation (Derivative 1 quadratic)
	case [
		opSG = 1  [kernel: sgTable3/1] 	;5
		opSG = 2  [kernel: sgTable3/2]	;7 
		opSG = 3  [kernel: sgTable3/3]	;9 
		opSG = 4  [kernel: sgTable3/4]	;11 
		opSG = 5  [kernel: sgTable3/5]	;13 
		opSG = 6  [kernel: sgTable3/6]	;15 
		opSG = 7  [kernel: sgTable3/7]  ;17
		opSG = 8  [kernel: sgTable3/8]  ;19
		opSG = 9  [kernel: sgTable3/9]  ;21
		opSG = 10 [kernel: sgTable3/10] ;23
		opSG = 11 [kernel: sgTable3/11] ;25
	]
	;Derivative 1 quartic)
	case [
		opSG = 12  [kernel: sgTable4/1] ;5
		opSG = 13  [kernel: sgTable4/2] ;7
		opSG = 14  [kernel: sgTable4/3]	;9
		opSG = 15  [kernel: sgTable4/4]	;11
		opSG = 16  [kernel: sgTable4/5]	;13
		opSG = 17  [kernel: sgTable4/6]	;15
		opSG = 18  [kernel: sgTable4/7]	;17	
		opSG = 19  [kernel: sgTable4/8]	;19
		opSG = 20  [kernel: sgTable4/9];21
		opSG = 21  [kernel: sgTable4/10];23
		opSG = 22  [kernel: sgTable4/11];25
	]
	
	;Derivative 1 quintic sextic
	case [
		opSG = 23 [kernel: sgTable5/1] 	;5
		opSG = 24 [kernel: sgTable5/2] 	;7
		opSG = 25 [kernel: sgTable5/3]	;11
		opSG = 26 [kernel: sgTable5/4]	;13
		opSG = 27 [kernel: sgTable5/5]	;15
		opSG = 28 [kernel: sgTable5/6]	;17
		opSG = 29 [kernel: sgTable5/7]	;19
		opSG = 30 [kernel: sgTable5/8]	;21
		opSG = 31 [kernel: sgTable5/9]	;23
		opSG = 32 [kernel: sgTable5/10]	;25
	]
	; we need float matrices
    t: type? first signal
    if t = integer! [signal * 1.0]
    t: type? first filter
    if t = integer! [filter * 1.0]
    rcvSGFiltering signal filter kernel
]
