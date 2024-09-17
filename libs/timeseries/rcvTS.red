Red [
	Title:   "Red Computer Vision: Time Series"
	Author:  "Francois Jouen"
	File: 	 %rcvTS.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016-2019 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


;************** Time Series Routines *************************

rcvTSStats: routine [
	 signal 		[vector!]
     blk	 	 	[block!]
     op				[integer!]
     /local
     headS tailS 		[byte-ptr!]
     unit		        [integer!]
     sum1 sum2 a b num  [float!]
     length mean sd		[float!]
     mini maxi val		[float!]
     s					[series!] 
     f 
     
][
	 block/rs-clear blk
	 sum1: 0.0
	 sum2: 0.0
	 mean: 0.0
	 sd: 0.0
	 maxi: 0.0
	 mini: 1.7976931348623158E+308; max float value
	 length: (as float! vector/rs-length? signal)
	 headS: vector/rs-head signal
	 tailS: vector/rs-tail signal
	 s: GET_BUFFER(signal)
	 unit: GET_UNIT(s)
	 while [headS < tailS][
	 	switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit]
	 		1 [val: vector/get-value-float headS unit]
	 	]
	 	either val >= maxi [maxi: val] [maxi: maxi]
	 	either val <  mini [mini: val] [mini: mini]
		sum1: sum1 + val
		sum2: sum2 + (val * val)
		headS: headS + unit
	]
	mean: sum1 / length
	a: sum1 * sum1
	b: a / length
	num: (sum2 - b);
    if num < 0.0 [num: 0.0 - num]
    sd: sqrt (Num / (length - 1.0)) 
    f: float/box mean
    block/rs-append blk as red-value! f 
    f: float/box sd
    block/rs-append blk as red-value! f
    f: float/box mini
    block/rs-append blk as red-value! f
    f: float/box maxi
    block/rs-append blk as red-value! f
]


rcvTSSDetrend: routine [
	signal 	[vector!]
	filter 	[vector!]
	mean	[float!]
	op		[integer!]
	/local headS headF tailS unit1 unit2 s
	val val2 pt64 p4
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	
	while [headS < tailS][
		switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit1
	 			 val2: as integer! (val - mean)
	 			 p4: as int-ptr! headF
	 			 p4/value: switch unit2 [
					1 [val2 and FFh or (p4/value and FFFFFF00h)]
					2 [val2 and FFFFh or (p4/value and FFFF0000h)]
					4 [val2]
				]
	 		]
	 		1 [val: vector/get-value-float headS unit1
	 			pt64: as float-ptr! headF
				pt64/value: val - mean]
	 	]
		headS: headS + unit1
		headF: headF + unit2
	]
]


rcvTSSNormalize: routine [
	signal 	[vector!]
	filter 	[vector!]
	mean	[float!]
	sd		[float!]
	op		[integer!]
	/local headS headF tailS unit1 unit2 s
	val val2 pt64 p4
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	
	while [headS < tailS][
		switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit1
	 			 val2: as integer! ((val - mean) / sd)
	 			 p4: as int-ptr! headF
	 			 p4/value: switch unit2 [
					1 [val2 and FFh or (p4/value and FFFFFF00h)]
					2 [val2 and FFFFh or (p4/value and FFFF0000h)]
					4 [val2]
				]
	 		]
	 		1 [val: vector/get-value-float headS unit1
	 			pt64: as float-ptr! headF
				pt64/value: (val - mean) / sd]
	 	]
		headS: headS + unit1
		headF: headF + unit2
	]
]


rcvTSMMFiltering: routine [
	signal 	[vector!]
	filter 	[vector!]
	filterSize	[integer!]
	op		[integer!]
	/local headS headF tailS tailF unit1 unit2 s
	n val val2 pt64 p4
	idx
	sum1
	mm
][ 
	headS: vector/rs-head signal
	tailS: vector/rs-tail signal
	headF: vector/rs-head filter
	tailF: vector/rs-tail filter
	s: GET_BUFFER(signal)
	unit1: GET_UNIT(s)
	s: GET_BUFFER(filter)
	unit2: GET_UNIT(s)
	while [headS < (tailS - filterSize)] [
		n: 0
		sum1: 0.0
		while [n < filterSize] [
			idx: headS + (n * unit1)
			switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! idx unit1]
	 			1 [val: vector/get-value-float idx unit1]
	 		]
			sum1: sum1 + val
			n: n + 1
		]
		mm: sum1 / as float! filterSize
		switch op [
	 		0	[p4: as int-ptr! headF
	 			p4/value: switch unit2[
					1 [(as integer! mm) and FFh or (p4/value and FFFFFF00h)]
					2 [(as integer! mm) and FFFFh or (p4/value and FFFF0000h)]
					4 [as integer! mm]
				]
	 			 
			]
	 		1	[pt64: as float-ptr! headF
				pt64/value: mm]
		]
		headS: headS + unit1
		headF: headF + unit2
	]
	
	;calculates mean for the last values (filterSize)
	sum1: 0.0
	while [headS < tailS] [
		switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! headS unit1]
	 			1 [val: vector/get-value-float headS unit1]
	 		]
	 	sum1: sum1 + val
	 	headS: headS + unit1
	]
	mm: sum1 / as float! filterSize
	
	while [headF < tailF] [
		switch op [
	 		0	[p4: as int-ptr! headF
	 			p4/value: switch unit2[
					1 [(as integer! mm) and FFh or (p4/value and FFFFFF00h)]
					2 [(as integer! mm) and FFFFh or (p4/value and FFFF0000h)]
					4 [as integer! mm]
				]
	 			 
			]
	 		1	[pt64: as float-ptr! headF
				pt64/value: mm]
		]
		headF: headF + unit2
	]
]

;--NEW
;--absolute deviation from median or mean
rcvTSDeviation: routine [
	 signal 			[vector!]
	 moment				[float!]
	 factor				[float!]
     op					[integer!]
     return:			[float!]
     /local
     headS tailS 		[byte-ptr!]
     unit		        [integer!]
     sum1 length 		[float!]
     val val2			[float!]
     s					[series!] 
     
][
	 sum1: 0.0
	 length: (as float! vector/rs-length? signal)
	 headS: vector/rs-head signal
	 tailS: vector/rs-tail signal
	 s: GET_BUFFER(signal)
	 unit: GET_UNIT(s)
	 while [headS < tailS][
	 	switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit]
	 		1 [val: vector/get-value-float headS unit]
	 	]
	 	val2: val - moment
	 	if val2 < 0.0 [val2: 0.0 - val2] ;--absolute difference
	 	val2: val2 * factor 			;--1.4826 for median constant
	 	sum1: sum1 + val2
		headS: headS + unit
	]
	sum1 / length
]

rcvTSMoment: routine [
	 signal 			[vector!]
	 moment				[float!]
	 exponent			[float!]
     op					[integer!]
     return:			[float!]
     /local
     headS tailS 		[byte-ptr!]
     unit		        [integer!]
     sum1 length  val	[float!]
     s					[series!] 
     
][
	 sum1: 0.0
	 length: (as float! vector/rs-length? signal)
	 headS: vector/rs-head signal
	 tailS: vector/rs-tail signal
	 s: GET_BUFFER(signal)
	 unit: GET_UNIT(s)
	 while [headS < tailS][
	 	switch op [
	 		0 [val: as float! vector/get-value-int as int-ptr! headS unit]
	 		1 [val: vector/get-value-float headS unit]
	 	]
	 	sum1: sum1 + pow (val - moment) exponent
		headS: headS + unit
	]
	sum1 / length
]

;--end NEWS

; *********************** Time Series Functions ********************

rcvTSCopySignal: function [
	"Makes a copy of original signal"
     signal [vector!]
     return: [vector!]
][
	original: copy signal
	original
]


rcvTSStatSignal: function [
	"Return mean, sd, minimal and maximal values of the signal serie"
     signal 		[vector!] ; integer or float
     return: 	 	[block!]
][
	blk: copy []					
	if (type? signal/1) = integer! 	[rcvTSStats signal blk 0] 
	if (type? signal/1) = float!	[rcvTSStats signal blk 1]
	blk
]


rcvTSSDetrendSignal: function [
"Removes linear trend in the signal by removing mean value of the serie"
	signal 	[vector!]
	filter 	[vector!]
][ 
	b: rcvTSStatSignal signal
	mean: b/1
	if (type? signal/1) = integer! 	[rcvTSSDetrend signal filter mean 0]
	if (type? signal/1) = float! 	[rcvTSSDetrend signal filter mean 1]
]


;Z norm
rcvTSSNormalizeSignal: function [
"Normalize data by replacing each value by a Z-normalized value"
	signal [vector!]
	filter 	[vector!]
][ 
	b: rcvTSStatSignal signal
  	mean: b/1
  	sd: b/2
	if (type? signal/1) = integer! 	[rcvTSSNormalize signal filter mean sd  0]
	if (type? signal/1) = float! 	[rcvTSSNormalize signal filter mean sd 1]
]

rcvTSMMFilter: function [
"Calculates a mobile mean  according to the number of points given by filterSize"
	signal 		[vector!]
	filter 		[vector!]
	filterSize 	[integer!]
][
	if (type? signal/1) = integer! [rcvTSMMFiltering signal filter filterSize 0]
	if (type? signal/1) = float!   [rcvTSMMFiltering signal filter filterSize 1]
]

;--NEWS
rcvTSMedian: function [
"Median value"
	signal 		[vector!]
	return:		[number!]
][
	sorted: copy signal
	n: length? sorted
	sort sorted
	if odd?  n [idx: (n + 1) / 2 val: sorted/:idx]
	if even? n [idx: n / 2 v1: sorted/:idx v2: sorted/(idx + 1) val: (v1 + v2) / 2]
	val
]

rcvTSMin: function [
"Minimal value"
	signal 		[vector!]
	return:		[number!]
][
	sorted: copy signal
	sort sorted
	sorted/1
]

rcvTSMax: function [
"Maximal value"
	signal 		[vector!]
	return:		[number!]
][
	sorted: copy signal
	sort sorted
	n: length? sorted
	sorted/:n
]
;--end NEWS








