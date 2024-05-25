Red[
	Title:   "Red Computer Vision: rcvHaar Wavelet"
	Author:  "Francois Jouen"
	File: 	 %rcvWavelet.red
	Tabs:	 4
	Rights:  "Copyright (C) 2021 François Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

rcvHaar: routine [
	signal 				[vector!] 
	m					[float!]
	/local
	headS				[byte-ptr!]
	count halfCount i	[integer!] 
	odd even unit		[integer!]
	moy diff			[red-block!]
	s 					[series!]
	v1 v2 				[float!]
	v3 					[red-float!]	
][
	headS: vector/rs-head signal
	s: GET_BUFFER(signal)
	unit: GET_UNIT(s)
	count: as integer! (pow 2.0 m); we need 2^n dimension
	moy: as red-block! stack/push*	;--for means
	block/make-at moy 1				;--create a block
	diff: as red-block! stack/push*	;--for differences
	block/make-at diff 1			;--create a block
	while [count > 1][
		block/rs-clear moy
		block/rs-clear diff
		halfCount: count / 2
		; means and differences
		i: 0
		while [i < halfCount] [
			even: 	i * 2 
			odd: 	even + 1
			v1: vector/get-value-float headS + (even * unit) unit
			v2: vector/get-value-float headS + (odd * unit) unit
			v3: float/box (v1 + v2) / 2.0				; means	
			block/rs-append moy as red-value! v3
			v3: float/box  v1 - (v1 + v2 / 2.0)			;differences
			block/rs-append diff as red-value! v3		
			i: i + 1	
		]
		; replace vector values by calculated means and differences
		i: 0
		while [i < halfCount] [
			vector/set-value headS + (i * unit) block/rs-abs-at moy i unit
			vector/set-value headS + (i + halfCount * unit) block/rs-abs-at diff i unit
			i: i + 1
		]
		count: count / 2
	]
]

rcvHaarInverse: routine [
	signal 				[vector!] 
	m					[float!]
	/local
	headS				[byte-ptr!]
	temp				[red-block!]
	s 					[series!]
	unit count i 		[integer!]
	dimension halfCount	[integer!]
	v1 v2 				[float!]
][
	headS: vector/rs-head signal
	s: GET_BUFFER(signal)
	unit: GET_UNIT(s)
	dimension:  as integer! (pow 2.0 m)
	count: 2
	while [count <= dimension]  [
		halfCount: count / 2
		temp: as red-block! stack/push*
		block/make-at temp 1
		;calculate l and r values
		i: 0
		while [i < halfCount] [
			v1: vector/get-value-float headS + (i * unit) unit
			v2: vector/get-value-float headS + (i + halfCount * unit) unit
			block/rs-append temp as red-value! float/box (v1 + v2)
			block/rs-append temp as red-value! float/box (v1 - v2)
			i: i + 1
		]
		;write transform
		i: 0
		while [i < count] [
			vector/set-value headS + (i * unit) block/rs-abs-at temp i unit
			i: i + 1
		]
		count: count * 2
	]
]

rcvHaarNormalized: routine [
	signal 				[vector!] 
	m					[float!]
	/local
	headS				[byte-ptr!]
	count halfCount i	[integer!] 
	odd even unit		[integer!]
	moy diff			[red-block!]
	s 					[series!]
	v1 v2 				[float!]
	v3 					[red-float!]
	sqrt2				[float!]
][
	headS: vector/rs-head signal
	s: GET_BUFFER(signal)
	unit: GET_UNIT(s)
	count: as integer! (pow 2.0 m); we need 2^n dimension
	moy: as red-block! stack/push*	;--for means
	block/make-at moy 1				;--create a block
	diff: as red-block! stack/push*	;--for differences
	block/make-at diff 1			;--create a block
	sqrt2: sqrt 2.0
	while [count > 1][
		block/rs-clear moy
		block/rs-clear diff
		halfCount: count / 2
		; means and differences
		i: 0
		while [i < halfCount] [
			even: 	i * 2 
			odd: 	even + 1
			v1: vector/get-value-float headS + (even * unit) unit
			v2: vector/get-value-float headS + (odd * unit) unit
			v3: float/box v1 + v2 / sqrt2				; means	
			block/rs-append moy as red-value! v3
			v3: float/box v1 - v2 / sqrt2		;differences
			block/rs-append diff as red-value! v3		
			i: i + 1	
		]
		; replace vector values by calculated means and differences
		i: 0
		while [i < halfCount] [
			vector/set-value headS + (i * unit) block/rs-abs-at moy i unit
			vector/set-value headS + (i + halfCount * unit) block/rs-abs-at diff i unit
			i: i + 1
		]
		count: count / 2
	]
]

rcvHaarNormalizedInverse: routine [
	signal 				[vector!] 
	m					[float!]
	/local
	headS				[byte-ptr!]
	temp				[red-block!]
	s 					[series!]
	unit count i 		[integer!]
	dimension halfCount	[integer!]
	v1 v2 				[float!]
][
	headS: vector/rs-head signal
	s: GET_BUFFER(signal)
	unit: GET_UNIT(s)
	dimension:  as integer! (pow 2.0 m)
	count: 2
	while [count <= dimension]  [
		halfCount: count / 2
		temp: as red-block! stack/push*
		block/make-at temp 1
		;calculate l and r values
		i: 0
		while [i < halfCount] [
			v1: vector/get-value-float headS + (i * unit) unit
			v2: vector/get-value-float headS + (i + halfCount * unit) unit
			block/rs-append temp as red-value! float/box v1 + v2 / sqrt 2.0
			block/rs-append temp as red-value! float/box v1 - v2 / sqrt 2.0
			i: i + 1
		]
		;write transform
		i: 0
		while [i < count] [
			vector/set-value headS + (i * unit) block/rs-abs-at temp i unit
			i: i + 1
		]
		count: count * 2
	]
]
