Red [
	Title:   "Statistics/Normal distribution"
	Author:  "ldci"
	File: 	 %rsnormalDist.red
]
{*
 * Based on RosettaCode example: Statistics/Normal distribution
 * This version allows to use mean and standard deviation for generating 
 * different distributions
 * This version uses Red/System routines for a faster calculation.
 * This code must be executed in terminal
 *}

NMAX: 100000;10000000

; only with float 
mean: routine [
	values 	[vector!] 
	return: [float!]
	/local
	n sum
	head tail
	f
][
	head: vector/rs-head values
	tail: vector/rs-tail values
	n: vector/rs-length? values
	sum: 0.0
	while [head < tail] [
		f: vector/get-value-float head 8 
		sum: sum + f
		head: head + 8
	]	
	sum / (as float! n)
]

stddev: routine [
	values 	[vector!]
 	return: [float!]
 	/local
 	n sum
	head tail
	f fv
	average
][
	average: mean values
	head: vector/rs-head values
	tail: vector/rs-tail values
	n: (vector/rs-length? values) - 1
	sum: 0.0
	while [head < tail] [
		f: vector/get-value-float head 8 
		fv: f -  average
		sum: sum + (fv * fv)
		head: head + 8
	]	
	sqrt (sum / (as float! n))
]

;Normal random numbers generator - Marsaglia algorithm.

generate: routine [
	n 		[integer!] 
	values 	[vector!]
	mean	[float!]
	std		[float!]
	/local
	head m i f rsq x y r r2
	p
] [
	m: n + (n % 2)
	head: vector/rs-head values
	i: 1
	while [i < m] [
		rsq: 0.0
		while [any [(rsq >= 1.0) (rsq = 0.0)]][
			r: 2.0 * (as float! _random/rand)
			r2: as float! _random/rand 
			x: r / r2 - 1.0
			r: 2.0 * (as float! _random/rand)
			r2: as float! _random/rand 
			y: r / r2 - 1.0
			rsq: (x * x) + (y * y) 
		]
		f: sqrt ((-2.0 * log-e rsq) / rsq)
		p: as float-ptr! head
		p/value: (mean + x * f * std)
		head: head + 8
		p: as float-ptr! head
		p/value: (mean + y * f * std)
		head: head + 8
		i: i + 2
	]
]


printHistogram: routine [
	values 	[vector!]
	bins	[vector!]
	/local
	headV  headB idx p pf
	n width maxi low high delta nbins i j k
	v s unit
	lbin hbin cs
] [
	headV: vector/rs-head values
	n: vector/rs-length? values
	headB: vector/rs-head bins
	idx: vector/rs-head bins
	s: GET_BUFFER(bins)
	unit: GET_UNIT(s)
	width: 50
	maxi: 0
	low: -3.05
	high: 3.05
	delta: 0.1
	nbins: as integer! ((high - low) / delta)
	vector/rs-clear bins
	loop nbins [vector/rs-append-int bins 0]
	i: 0
	j: 0
	while [i < n] [
		pf: as float-ptr! headV
		j: as integer! ((pf/value - low) / delta)
		if all [1 <= j j < nbins] [
			idx: headB + (j * unit)
			p: as int-ptr! idx
			p/value: p/value + 1
		]
		headV: headV + 8 ; float 64 unit
		i: i + 1
	]
	
	j: 0
	while [j < nbins] [
		idx: headB + (j * unit)
		p: as int-ptr! idx
		if maxi < p/value [maxi: p/value] 
		j: j + 1
	]
	j: 0
	while [j < nbins] [
		idx: headB + (j * unit)
		p: as int-ptr! idx
		lbin: (low + (as float! j) * delta) 
		hbin: (low + (as float! (j + 1)) * delta)
		printf["[%5.2f %5.2f] |" lbin hbin]
		k: (width * p/value /  maxi)
		while [k >= 0] [
			print  "*"
			k: k - 1
		]
		v: as float! p/value * 100
		v: v / (as float! n)
		printf["  %-.1f%%" v]
		print lf
		j: j + 1
	]
	
]

; *********** Main ***************

random/seed now/time
print ["Generating" NMAX "random values. Be Patient"]
t1: now/time/precise
values: make vector! compose [float! 64 (NMAX)]
bins: make vector!
generate NMAX values 0.0 1.0
print ["Mean: " round/to mean values 0.001]
print ["STD : " round/to stddev values 0.001]
print "Generating Histogram" 
printHistogram values bins
t2: now/time/precise
print ["Done in " round/to (third t2 - t1) 0.001 " sec"]








