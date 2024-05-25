#!/usr/local/bin/red
Red [
]

;convert -list colorspace

min3: func [
	a	[number!]
	b 	[number!]
	c	[number!]
	return: [number!]
	/local
	mini
][
	either a < b [mini: a] [mini: b]
	if c < mini [mini: c]
	mini
]


print min3 1 2 3
print min3 3 2 1
print min3 3 1 2
print min3 1 1 2
