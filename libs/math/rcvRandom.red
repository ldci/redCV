Red [
	Title:   "Red Computer Vision: random"
	Author:  "Francois Jouen"
	File: 	 %rcvRandom.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; *************** some constant values *******************

RAND_MAX: 2147483647.0 ; max int
FLOAT_MAX: 1E100

umax: power (1 / (2 * pi)) 0.25
vmax: power (2 / (pi * exp 2)) 0.25
log2pi: log-e (2 * pi)


; *********** and useful functions and routines *********

randFloat: function [
"returns a decimal value beween 0 and 1. Base 16 bit" 
][
	x: random power 2 16
	(to float! x) / power 2 16
]
 


;********************************************
;***			CONTINUOUS LAWS			  ***
;********************************************

;
randGaussian: function [
"generate a Gaussian random variable with mean  and standard deviation"
	mean 	[float!] 
	stdev 	[float!] 
	/x /y 
][
	rsq: 0.0
	while [any [(rsq >= 1.0) (rsq == 0.0)]][
		x: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
		y: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
		rsq: (x * x) + (y * y) 
	]
	f: sqrt ((-2.0 * log-e rsq) / rsq)
	;return:[float!]
	case [
		x [return mean + x * f * stdev]
		y [return mean + y * f * stdev]
	]
]


;uniform law on (e.g. 1.0)
randUnif: function [i [float!] j [float!]]
[
	randFloat * (j - i) + i
]

;exponential law
randExp: function [] [
	negate log-e randFloat
]

;exponential law with a l degree (e.g. 1.0)
randExpm: function [l [float!]] [
	negate log-e (randFloat / l)
]

;normal law (e.g. 1.0)
randNorm: function [A [float!]] [
	u: randFloat * umax
	v: ((2 * randFloat) - 1) * vmax
	while [( v * v + (A + 4 * log-e u) * (u * u)) >= 0]
		[u: randFloat * umax v: ((2 * randFloat) -1) * vmax]
	 v / u
]	


;lognormal law
randLognorm: function [a [float!] b [float!] z [float!]] [
	return exp (a + b * z)
]	

; gamma law (e.g 1 1.0)
randGamma: func [k [integer!] l [float!]] [
	r: 0.0
	i: 0
	while [i < k] [
		r: r + randExpm l
		i: i + 1
	]
	r
]	

;geometric law in a disc	
randDisc: function []
[
	t: copy []
	u: 2 * randFloat - 1
	v: 2 * randFloat - 1
	
	append t u
	append t v
	while [((u * u) + (v * v)) > 1.0][
		t/1: u t/2: v 
		u: 2 * randFloat - 1
		v: 2 * randFloat - 1
	]
	t
]


;geometric law in a rectangle 

randRect: function [a [float!] b [float!] c [float!] d [float!]]
[
	t: copy []
	append t a + (b - a) * randFloat / 2
	append t c + ( d - c) * randFloat / 2
	t
]

;chi square law (e.g 2)
randChi2: function [v [integer!]] [
	z: 0
	i: 0
	while [i < v] [
		z: z + power (randNorm log2pi) 2
		i: i + 1
	]
	z	
] 

; Erlang law (e.g 2)
randErlang: function [n [integer!]] [
	t: 1.0
	i: 0
	while [i < n] [
		t: t * 1.0 - randFloat
		i: i + 1
	]
	negate log-e t
]

;Student law (e.g 3 1.0)
randStudent: function [ n [integer!] z [float!]] [
	v: randChi2 n
	z / (square-root (absolute (v / n)))
]


;Fisher law (e.g 1 1)
randFischer: function [ n [integer!] m [integer!]] [
	x: randChi2 n
	y: randChi2 m
	(x /  (n * 1.0)) / (y / (m * 1.0))
]

;Laplace Law (e.g 1.0)
randLaplace: function [a [float!]][
	u1: randFloat
	u2: randFloat
	either u1 < a [return negate a * log-e u2] [return a * log-e u2]
]


;beta law (e.g 1 1)
randBeta: function [a [integer!] b [integer!]]
[
	x1: randGamma a 1.0
	x2: randGamma b 1.0
	x1 / (x1 + x2)
]

;Weibull law (e.g 1.0 1.0)
randWeibull: function [a [float!] l [float!]] [
	x: randFloat
	power (negate 1 / a * log-e (1 - x)) 1 / l
]


; Rayleigh law
randRayleigh: function []
[
	randWeibull 2.0 0.5
]


;********************************************
;***			DISCRETE LAWS			  ***
;********************************************

;Bernouilli law (eg 0.5)
randBernouilli: function [p [float!] ] [ 
	u: randFloat	
	either  u < p [return 1][ return 0]
]

;binomial law (e.g. 1 0.5)
randBinomial: function [n [integer!] p [float!]] [
	x: 0
	i: 0
	while [i < n][
		if randFloat < p [x: x + 1]
		i: i + 1
	]
	x
]

;binomial negative law (e.g. 1 0.5)
randBinomialneg: function [n [integer!] p [float!]] [
	x: 0
	i: 0
	while [i < n] [
		while [randFloat >= p] [x: x + 1]
	i: i + 1
	]
	x
]

;geometric law (e.g. 0.25)
randGeo: func [p [float!]] [
	x: 0
	while [randFloat >= p] [ x: x + 1]
	x
]

; Poisson law (e.g. 1.5)
randPoisson: function [l [float!]] [
	j: 0.0
	p: f: exp (negate l)
	u: randFloat
	while [u > f ] [
		p: l * p / (j + 1)
		f: f + p
		j: j + 1
	]
	j 
]



