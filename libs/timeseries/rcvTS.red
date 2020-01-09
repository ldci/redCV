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
     length
     sum sum2 a b num
     mean sd
     mini maxi
     val
     headS tailS unit
     f s 
][
	 block/rs-clear blk
	 sum: 0.0
	 sum2: 0.0
	 mean: 0.0
	 sd: 0.0
	 maxi: 0.0
	 mini: 10000.00
	 length: as float! vector/rs-length? signal
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
	 	either val < mini [mini: val] [mini: mini]
		sum: sum + val
		sum2: sum2 + (val * val)
		headS: headS + unit
	]
	mean: sum / length
	a: Sum * Sum
	b: a / length
    num: (sum2 - b);
    if num < 0.0 [num: 0.0 - num]
    sd: sqrt  (Num / (length - 1))
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
	sum
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
		sum: 0.0
		while [n < filterSize] [
			idx: headS + (n * unit1)
			switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! idx unit1]
	 			1 [val: vector/get-value-float idx unit1]
	 		]
			sum: sum + val
			n: n + 1
		]
		mm: sum / as float! filterSize
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
	sum: 0.0
	while [headS < tailS] [
		switch op [
	 			0 [val: as float! vector/get-value-int as int-ptr! headS unit1]
	 			1 [val: vector/get-value-float headS unit1]
	 		]
	 	sum: sum + val
	 	headS: headS + unit1
	]
	mm: sum / as float! filterSize
	
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









