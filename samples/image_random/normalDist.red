Red [
	Title:   "Statistics/Normal distribution"
	Author:  "Francois Jouen"
	File: 	 %normalDist.red
]
{*
 * Based on RosettaCode example: Statistics/Normal distribution
 * This version allows to use mean and standard deviation 
 * for generating different distributions
 * This version uses standard Red language and is not very fast.
 *}

RAND_MAX: 2147483647 ; max int
NMAX: 10000000

mean: function [values [block! vector!] return: [float!]][
	n: length? values
	sum: 0.0
	foreach v values [sum: sum + v]
	sum / n
]

stddev: function [values [block! vector!] return: [float!]][
	n: length? values
	average: mean values
	sum: 0.0
	foreach v values [sum: sum + ((v - average) * (v - average))]
	sqrt sum / (n - 1)
]

gaussian: function [mean [float!] stdev [float!] /x /y return:[float!]
][
	rsq: 0.0
	while [any [(rsq >= 1.0) (rsq == 0.0)]][
		x: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
		y: (2.0 * random RAND_MAX) / RAND_MAX - 1.0
		rsq: (x * x) + (y * y) 
	]
	f: sqrt ((-2.0 * log-e rsq) / rsq)
	case [
		x [return mean + x * f * stdev]
		y [return mean + y * f * stdev]
	]
]


;Normal random numbers generator - Marsaglia polar algorithm.
generate: function [n [integer!] return: [block!]] [
	m: n + (n % 2)
	values: copy []
	i: 1
	while [i < m] [
		append values gaussian/x 0.0 1.0
        append values gaussian/y 0.0 1.0
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
print ["Generating" NMAX "random values. Be Patient"]
t1: now/time/precise
values: generate NMAX
print ["Mean: " round/to mean values 0.001]
print ["STD : " round/to stddev values 0.001]
print "Generating Histogram" 
printHistogram values
t2: now/time/precise
print ["Done in " round/to (third t2 - t1) 0.001 " sec"]








