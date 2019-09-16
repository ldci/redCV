Red [
	Title:   "Red Computer Vision: Red/System routines"
	Author:  "Francois Jouen"
	File: 	 %rcvTools.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;general time function

rcvElapsed: function [
"Calculates elapsed time in ms. Requires time/now/precise"
	t1 [time!] 
	t2 [time!]
][
	h: 		first t2 - t1 * 3600
	m: 		second t2 - t1 * 360
	sec: 	third t2 - t1 * 1000
	round/to (h + m + sec) 0.01
]

rcvNSquareRoot: function [
"Returns nth root of Num"
	num 	[number!] 
	nroot 	[number!]
][
	num ** (1.0 / nroot)
]

; ******************** Tools **********************
minInt: routine [
	a 		[integer!] 
	b 		[integer!]
	return: [integer!]
][ 
		either (a < b) [a] [b]
]

minFloat: routine [
	a 		[float!] 
	b 		[float!]
	return: [float!]
][ 
		either (a < b) [a] [b]
]
maxInt: routine [
	a 		[integer!] 
	b 		[integer!]
	return: [integer!]
][ 
		either (a > b) [a] [b]
]

maxFloat: routine [
	a 		[float!] 
	b 		[float!]
	return: [float!]
][ 
		either (a > b) [a] [b]
]

rcvRound: routine [
	f 		[float!]
	return: [float!]
][
    either (f - floor f) > 0.5 [ceil f] [floor f] 
]


;Hypot is a mathematical function defined to calculate the length of the hypotenuse of a right-angle triangle. 
;It was designed to avoid errors arising due to limited-precision calculations performed on computers.
rcvHypot: routine [
	a		[float!]
	b		[float!]
	return: [float!]
	/local
	x
	y
	t
][
	if a < 0.0 [a: 0.0 - a] ; absolute value
	if b < 0.0 [b: 0.0 - b] ; absolute value
	x: maxFloat a b
	y: minFloat a b
	if x = 0.0 [return 0.0] ; avoid division by zero
	t: y / x
	x * sqrt(1.0 + (t * t))
]

{rcvSquish: routine [
	x	[float!]
][
	1.0 / (1.0 + exp (4.0 * x))
]}
