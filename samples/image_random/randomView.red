Red [
	Title:   "Random Distribution "
	Author:  "ldci"
	File: 	 %randomView.red
	Needs:	 View
]

NMAX: 1000000
margins: 5x5
n: NMAX
moy: 0.0
std: 1.0 
img: make image! reduce [640x480 black]

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


getBins: routine [
	values 	[vector!]
	bins	[vector!]
	return: [integer!]
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
		if all [1 <= j j <= nbins] [
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
	maxi
]




generateDist: does [
	random/seed now/time/precise
	clear stat/data
	plot: compose [line-width 2 pen green line 320x0 320x405 pen off 
			pen green line 0x405 640x405 fill-pen red pen red]
	s: rejoin ["Generating " n " random values. Be Patient"]
	sb/text: s 
	do-events/no-wait
	if error? try [n: to-integer f1/text] [n: NMAX]
	if error? try [std: to-float f2/text] [std: 1.0]
	values: make vector! compose [float! 64 (n)]
	bins: make vector!
	generate n values moy std
	maxi: getBins values bins
	nBins: length? bins
	radius: 3.0
	low: -3.05
	high: 3.05
	delta: 0.1
	xstep: to-integer (640 / nBins)
	append bins bins/1 ; for the last point since red is 1-based 
	i: 1
	repeat i nBins + 1 [
		x: 10 + (i * xstep)
		y: 400 - ((50.0 * bins/:i / maxi) * 6.5)
		p: as-pair x y
		append plot 'circle 
		append plot p
		append plot radius
		;'
		lbin: round/to (low + i * delta) 0.001
		hbin: round/to (low + i + 1 * delta) 0.001
		v: round/to (bins/:i * 100.0) / n 0.01
		s: rejoin ["[" form lbin " " form hbin "]: " v "%" ]
		append stat/data s
		canvas/image: draw img plot
		do-events/no-wait
	]
	s: rejoin ["Mean: " round/to mean values 0.001 " STD : " round/to stddev values 0.001
	" " stat/data/(nBins / 2 + 1)]
	sb/text: s 
]


view win: layout [
	title "Gaussian Random Distribution "
	origin margins space margins
	text 75 "Sample" f1: field 80 "1 000 000" [if error? try [n: to-integer face/text] [n: NMAX]]
	text 50 "STD"	 f2: field 40 "1.0" [if error? try [std: to-float face/text] [std: 1.0]]
	button "Generate"	[generateDist]
	button "Clear"		[img: make image! reduce [640x480 black] canvas/image: img 
						clear stat/data clear sb/text]
	pad 360x0
	button "Quit" [quit]
	return
	canvas: base 640x480 img
	stat: text-list 200x480 data []
	return
	sb: field 640
	text 200 center "© Red Foundation 2019"
	do [f1/text: form n]
]	

