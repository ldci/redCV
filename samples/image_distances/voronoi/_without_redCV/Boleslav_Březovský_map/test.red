#! /usr/local/bin/red
Red [
]

; tests for distances between 2 pairs
;=num^(1/n) pour calculer la nieme racine de num
;#system-global [#include %fact.reds]

; old to be deleted
_rcvGetEuclidianDistance: function [p [pair!] cg [pair!] return: [float!]
][
	x2: (p/x - cg/x) * (p/x - cg/x)
	y2: (p/y - cg/y) * (p/y - cg/y)
	sqrt (x2 + y2) 
]

rcvGetEuclidianDistance: func [a b /local d][
	d: b - a
	square-root (d/x ** 2) + (d/y ** 2)
]

rcvGetManhattanDistance: func [a b /local d ][
	d: absolute b - a
	d/x + d/y
]

rcvGetMinkowskiDistance: func [a b p /local d s ][
	d: absolute b - a
	s: (d/x ** p) + (d/y ** p)
	s ** (1.0 / p)  ; nth root 
]

rcvGetChebyshevDistance: func [a b /local d ][
	d: absolute b - a
	max d/x d/y
]

; fractional distances

rcvGetCamberraDistance: func [a b][
	absolute ((to-float a/x - to-float b/x) / (to-float a/x + to-float b/x)) 
	+ ((to-float a/y - to-float b/y) / (to-float a/y + to-float b/y))
	
]


rcvGetSorensenDistance: func [a b][
	absolute ((to-float a/x - to-float b/x) + (to-float a/y - to-float b/y))
	/ ((to-float a/x + to-float b/x) + (to-float a/y + to-float b/y))
]

;max dist value 1.0
rcvDistance2Color: func [dist [number!] t [tuple!]][
	t * dist
]

asColor: routine [
    r [integer!]
    g [integer!]
    b [integer!]
    /local arr1 [integer!]
][
    arr1: (b % 256 << 16) or (g % 256 << 8) or (r % 256)
    stack/set-last as red-value! tuple/push 3 arr1 0 0
]



_rcvDistance2Color: routine [
		dist 	[float!] 
		t 		[tuple!]
		/local
		tp r g b
		rf gf bf
		arr1
][
	r: t/array1 and FFh 
	g: t/array1 and FF00h >> 8 
	b: t/array1 and 00FF0000h >> 16 
	rf: as integer! (dist * r)
	gf: as integer! (dist * g)
	bf: as integer! (dist * b)
	arr1: (bf << 16) or (gf << 8 ) or rf
	stack/set-last as red-value! tuple/push 3 arr1 0 0
]


p1: 1x1
p2: 5x5

d1: rcvGetEuclidianDistance  p1 p2	;OK
d2: rcvGetManhattanDistance  p1 p2	;0K
d3: rcvGetMinkowskiDistance  p1 p2 1 ; OK same as Manhattan
d4: rcvGetMinkowskiDistance  p1 p2 2 ; OK same as euclidian
d5: rcvGetMinkowskiDistance  p1 p2 3 ; OK 
d6: rcvGetChebyshevDistance	 p1 p2	 ; OK
d7: rcvGetCamberraDistance 	 p1 p2	 ; OK
d8: rcvGetSorensenDistance 	 p1 p2	 ; OK

print "Distance tests"
print ["A: " p1 "B: " p2]
print ["Euclidian: " d1]
print ["Manhattan: " d2]
print ["Minkowski p=1: " d3]
print ["Minkowski p=1: " d4]
print ["Minkowski p=3: " d5]
print ["Chebyshev: " d6]
print ["Camberra: " d7] ; OK 1.333
print ["Sorensen: " d8] ; OK 0.666

d9: _rcvDistance2Color 0.1 127.200.250
print type? d9

print ["127.200.250: " d9 lf]
print "Done"
