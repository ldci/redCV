#! /usr/local/bin/red
Red [
	Title:   "Statistics/Normal distribution"
	Author:  "Francois Jouen"
	File: 	 %normalDist.red
]
{*
 * RosettaCode example: Statistics/Normal distribution in red
 * Based on c code sample
 * The random number generator rand() of the standard C library is obsolete
 * and should not be used in more demanding applications. There are plenty
 * libraries with advanced features (eg. GSL) with functions to calculate 
 * the mean, the standard deviation, generating random numbers etc. 
 * However, these features are not the core of the standard C library.
 *}

RAND_MAX: 2147483647 ; max int
NMAX: 1000000

mean: routine [values [block! ] return: [float!]
	/local
	n sum
	head tail
][
	head: block/rs-head values
	tail: block/rs-tail values
	n: block/rs-length? values
	sum: 0.0
	while [head < tail] [
		f: as red-float! head
		sum: sum + f
		head: head + 1
	]	
	
	sum / n
]

stddev: function [values [block! vector!] return: [float!]][
	n: length? values
	average: mean values
	sum: 0.0
	foreach v values [sum: sum + ((v - average) * (v - average))]
	sqrt sum / (n - 1)
]

;Normal random numbers generator - Marsaglia algorithm.
generate: function [n [integer!] return: [block!]] [
	m: n + (n % 2)
	values: copy []
	i: 1
	while [i < m] [
		rsq: 0.0
		while [any [(rsq >= 1.0) (rsq == 0.0)]][
			x: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
			y: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
			rsq: (x * x) + (y * y) 
		]
		f: sqrt ((-2.0 * log-e rsq) / rsq)
		append values x * f
        append values y * f;
		i: i + 2
	]
	values
]

printHistogram: function [values [block! vector!]] [
	n: length? values
	width: 50
	maxi: 0
	low: -3.05
	high: 3.05
	delta: 0.1
	nbins: to-integer ((high - low) / delta)
	bins: copy []
	i: 1
	s: copy ""
	repeat i nbins [append bins 0]
	i: 1
	while [i <= n][
		j: to-integer ((values/:i - low) / delta)
		if all [(1 <= j) (j < nbins)] [bins/:j: bins/:j + 1]
		i: i + 1
	]
	j: 1
	while [j <= nbins] [
		if maxi < bins/:j [maxi: bins/:j] 
		j: j + 1
	]
	j: 1
	while [j <= nbins] [
		lbin: round/to low + j * delta 0.001
		hbin: round/to low + (j + 1) * delta 0.001
		s: rejoin ["[" lbin " " hbin "] |"]
		pad/left s 17
		k: to-integer (to-float width * to-float bins/:j / to-float maxi)
		while [k >= 0] [
			append s "*"
			k: k - 1
		]
		append s rejoin [" " bins/:j * 100.0 / n "%"]
		print s
		j: j + 1
	]
]

; *********** Main ***************

random/seed now/time
print ["Generating " NMAX " random values. Be Patient"]
t1: now/time/precise
values: generate NMAX
print ["Mean: " round/to mean values 0.001]
print ["STD : " round/to stddev values 0.001]
print "Histogram" 
printHistogram values
t2: now/time/precise
print ["Done in " round/to (third t2 - t1) 0.001 " sec"]








