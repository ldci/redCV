#! /usr/local/bin/red
Red [
	Needs:	 View
]

;define arrays and dimensions
b: make vector! reduce  ['float! 64 100]
b + 999.0	; initialize vector
;'
DT: copy []
i: 1 
repeat i 100 [append/only DT b]
DT/50/50: 0.0
;'Local Distance Metric (LDM) and mask arrays
LDM: make vector! reduce  ['float! 64 9]
DX: make vector! reduce  ['float! 64 9]
DY: make vector! reduce  ['float! 64 9]

;define chamfer values
a1: 2.2062
a2: 1.4141
a3: 0.9866
img: make image! reduce [100x100 black]
color: white; 255.0.0 


distToColor: function [dist[float!] factor [integer!]][
	to tuple! reduce [dist * factor dist * factor dist * factor]
]

forwardChamfer: function [DT [block!] LMD [vector!] DX [vector!] DY [vector!]] [
	nLines: to-integer length? DT
	nCols: to-integer length? DT/1
	;forward scan
	LDM/1: a1  LDM/2: a1  LDM/3: a1  LDM/4: a2  LDM/5: a3  LDM/6: a2  LDM/7: a1  LDM/8: a3  LDM/9: 0.0
	DX/1: -2.0  DX/2: -2.0  DX/3: -1.0  DX/4: -1.0  DX/5: -1.0  DX/6: -1.0  DX/7: -1.0  DX/8: 0.0   DX/9: 0.0
	DY/1: -1.0  DY/2: 1.0   DY/3: -2.0  DY/4: -1.0  DY/5: 0.0   DY/6: 1.0   DY/7: 2.0   DY/8: -1.0  DY/9: 0.0
	i: 3 
	while [i <= (nLines - 3)] [
		j: 3 
		while [j <= (nCols - 3)] [
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
]

backwardChamfer: function [DT [block!] LMD [vector!] DX [vector!] DY [vector!]] [
	nLines: to-integer length? DT
	nCols: to-integer length? DT/1
	;backward scan
	LDM/1: 0.0  LDM/2: a3  LDM/3: a1  LDM/4: a2  LDM/5: a3  LDM/6: a2  LDM/7: a1  LDM/8: a1  LDM/9: a1
	DX/1: 0.0  DX/2: 0.0  DX/3: 1.0   DX/4: 1.0   DX/5: 1.0  DX/6: 1.0  DX/7: 1.0  DX/8: 2.0   DX/9: 2.0
	DY/1: 0.0  DY/2: 1.0  DY/3: -2.0  DY/4: -1.0  DY/5: 0.0  DY/6: 1.0  DY/7: 2.0  DY/8: -1.0  DY/9: 1.0

	i: nLines - 2 
	while [i > 2] [
		j: nCols - 2 
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
]
edgesChamfer: function [DT [block!]] [
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

showChamfer: function [DT [block!] img [image!]] [
	nLines: to-integer length? DT
	nCols: to-integer length? DT/1
	i: 1 
	while [i <= nLines] [
		j: 1
		while [j <= nCols] [
			p: as-pair i j
			t: distToColor DT/:i/:j 5
			t: t and color 
			poke img p t
			j: j + 1
		]
		i: i + 1
	]
]

process: does [
	t1: now/time/precise
	forwardChamfer DT LDM DX DY
	backwardChamfer DT LDM DX DY
	edgesChamfer DT
	showChamfer DT img
	t2: now/time/precise
	elapsed: round (third t2 - t1 * 1000) 0.001
	f/text: rejoin ["Rendered in: " elapsed " ms"]

]


view win: layout [
	title "Chamfer"
	text 40 "Color" 
	base 20x20 red 		[color: face/color process]
	base 20x20 blue 	[color: face/color process]
	base 20x20 green 	[color: face/color process]
	base 20x20 yellow 	[color: face/color process]
	base 20x20 cyan 	[color: face/color process]
	text 50 "Random"
	rb: base 20x20 white [color: random white face/color: color  process]
	pad 55x0
	button 50 "Quit" [Quit]
	return
	canvas: base 400x400 img
	return
	f: field 400
	do [rb/color: random white]
]
