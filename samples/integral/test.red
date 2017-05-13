#! /usr/local/bin/red
Red [
Title:		"RedCV Tests"
]
expected: make vector! [4 5 7 9 4 9 12 17 7 13 16 25 9 16 22 33] 
mat: make vector! [4 1 2 2
				   0 4 1 3 
				   3 1 0 4 
				   2 1 3 2]
dst: make vector! 16
w: 4
h: 4
idx: 0

x: 0
while [x < w] [
		y: 0
		sum: 0
		while [y < h] [
			idx:  x + (y * w) + 1
			sum: sum + mat/(idx)
			either (x = 0) [dst/(idx): sum] [dst/(idx): dst/(idx - 1) + sum  ]
			y: y + 1
		]
		x: x + 1
]
print ["Source   "  mat]
print ["Expected "  expected]
print ["Obtained "  dst] 

