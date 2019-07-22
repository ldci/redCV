#! /usr/local/bin/red
Red [
	Needs:	 View
]

;Simple distance transform function using Borgefors fractional chamfer metric
; uses redCV array type

;define arrays and dimensions
b: make vector! reduce  ['float! 64 100];'
b + 999.0	; initialize vector
;DT Distance Transform Array
DT: copy []
i: 1 
repeat i 100 [append DT b]

;Local Distance Metric (LDM) and 3x3 mask arrays (DX and DY)
LDM: make vector! reduce  ['float! 64 9];'
DX: make vector!  reduce  ['float! 64 9];'
DY: make vector!  reduce  ['float! 64 9];'

;define chamfer values
a1: 2.2062
a2: 1.4141
a3: 0.9866
img: make image! reduce [100x100 gray]
color: 'red ;'

DT/50/50: 0.0; target point in centre of array

distToColor: func [dist[float!] factor [integer!]][
	to tuple! reduce [dist * factor dist * factor dist * factor]
]

calculateChamfer: does [
	;forward scan
	LDM/1: a1  LDM/2: a1  LDM/3: a1  LDM/4: a2  LDM/5: a3  LDM/6: a2  LDM/7: a1  LDM/8: a3  LDM/9: 0.0
	DX/1: -2.0  DX/2: -2.0  DX/3: -1.0  DX/4: -1.0  DX/5: -1.0  DX/6: -1.0  DX/7: -1.0  DX/8: 0.0   DX/9: 0.0
	DY/1: -1.0  DY/2: 1.0   DY/3: -2.0  DY/4: -1.0  DY/5: 0.0   DY/6: 1.0   DY/7: 2.0   DY/8: -1.0  DY/9: 0.0
	i: 3 
	while [i <= 97] [
		j: 3 
		while [j <= 97] [
			d0: DT/:i/:j
			k: 1 
			while [k <= 9] [
				r: to-integer (i + dx/:k)
				c: to-integer (j + dy/:k)
				d: DT/:r/:c
				d1: d + LDM/:k
				d0: min d1 d0
				k: k + 1
			]
			DT/:i/:j: d0
			j: j + 1
		]
		i: i + 1
	]
	
	;backwards scan
	LDM/1: 0.0  LDM/2: a3  LDM/3: a1  LDM/4: a2  LDM/5: a3  LDM/6: a2  LDM/7: a1  LDM/8: a1  LDM/9: a1
	DX/1: 0.0  DX/2: 0.0  DX/3: 1.0   DX/4: 1.0   DX/5: 1.0  DX/6: 1.0  DX/7: 1.0  DX/8: 2.0   DX/9: 2.0
	DY/1: 0.0  DY/2: 1.0  DY/3: -2.0  DY/4: -1.0  DY/5: 0.0  DY/6: 1.0  DY/7: 2.0  DY/8: -1.0  DY/9: 1.0

	i: 98 
	while [i > 2] [
		j: 98 
		while [j > 2] [
			d0: DT/:i/:j
			k: 1 
			while [k <= 9] [
				r: to-integer (i + dx/:k)
				c: to-integer (j + dy/:k)
				d: DT/:r/:c
				d1: d + LDM/:k
				d0: min d1 d0
				k: k + 1
			]
			DT/:i/:j: d0
			j: j - 1
		]
		i: i - 1
	]
	; trim off edges
	dt/1/1: dt/1/3
	dt/1/2: dt/1/3
	dt/2/1: dt/1/3
	dt/2/2: dt/1/3
	dt/100/100: dt/97/3
	dt/100/99: dt/97/3
	dt/99/100: dt/97/3
	dt/99/99: dt/97/3
	dt/98/100: dt/97/3
	dt/98/99: dt/97/3
	
]


showChamfer: does [
	i: 1 
	while [i <= 100] [
		j: 1
		while [j <= 100] [
			p: as-pair i j
			t: distToColor DT/:i/:j 5
			t: t and get color 
			;if j % 2 = 0 [poke img p t]
			if all [even? i even? j] [poke img p t]
			j: j + 1
		]
		i: i + 1
	]
]

colors: ["red" "blue" "green" "yellow" "cyan" ]


view win: layout [
	title "Chamfer"
	text "Color" 
	drop-down data colors
	on-change [
		color: to-word face/text
		calculateChamfer showChamfer
	]
	select 1
	pad 130x0
	button "Quit" [Quit]
	return
	canvas: base 400x400 img
	do [calculateChamfer showChamfer]
]
