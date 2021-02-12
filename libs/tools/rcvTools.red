Red [
	Title:   "Red Computer Vision: Red tools"
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
	d: 		t2 - t1
	h: 		first d * 3600
	m: 		second d * 60
	sec: 	(third d) * 1000 	; in ms	
	to-integer (h + m + sec)	; return in rounded ms 
]


; ******************** Tools **********************
rcvNSquareRoot: function [
"Returns the nth root of Num"
	num 	[number!] 
	nroot 	[number!]
][
	num ** (1.0 / nroot)
]


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

rcvAbsInt: routine [
	n		[integer!]
	return:	[integer!]
][
	either n >= 0 [n] [0 - n]
]

rcvAbsFloat: routine [
	n		[float!]
	return:	[float!]
][
	either n >= 0.0 [n] [0.0 - n]
]


;Hypot is a mathematical function defined to calculate the length of the hypotenuse of a right-angle triangle. 
;It was designed to avoid errors arising due to limited-precision calculations performed on computers.
rcvHypot: routine [
	a		[float!]
	b		[float!]
	return: [float!]
	/local
		x y t [float!]
][
	if a < 0.0 [a: 0.0 - a] ; absolute value
	if b < 0.0 [b: 0.0 - b] ; absolute value
	x: maxFloat a b
	y: minFloat a b
	if x = 0.0 [return 0.0] ; avoid division by zero
	t: y / x
	x * sqrt(1.0 + (t * t))
]

rcvExp: routine [
"returns exponential value"
	value	[float!]
	return: [float!]
][
	;--use Euler's number e
	pow 2.718281828459045235360287471 value
]


rcvLog-2: routine [
"Return the base-2 logarithm"
	value	[float!]
	return: [float!]
][
	(log-e value) / 0.6931471805599453
]

rcvSquish: routine [
"For image transform"
	x	[float!]
][
	1.0 / (1.0 + rcvExp (4.0 * x))
]

randf: routine [
"returns a decimal value beween 0 and 1"
	m 		[float!]
	return: [float!]
][
	(m * as float! _random/rand) / 2147483647.0 - 1.0
]

randf2: function [
"returns a decimal value beween 0 and 1"
][
	random/seed now/time/precise
	random 1.0
]

