Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master

margins: 5x5

#include %../../libs/redcv.red ; for red functions
mat: make vector! [integer! 16 [4 1 2 2 0 4 1 3 3 1 0 4 2 1 3 2]]
expected: make vector! [4 5 7 9 4 9 12 17 7 13 16 25 9 16 22 33] 
sum: rcvCreateMat 'integer! 16 4x4
sqsum: rcvCreateMat 'integer! 16 4x4


processMat: does [
	x: 0 y: 0
	b: copy []
	while [y < 4] [
		while [x < 4] [
		v: rcvGetInt2D sum 4x4 as-pair x y
		append b v
		x: x + 1
		]
		x: 0
	y: y + 1	
	]
	d/text: form b
]




; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Test" [
						  rcvIntegral mat sum sqsum 4x4 
						  probe sum
						  processMat
						  ;d/text: form sum
						  d2/text: form sqsum
						  ]
		button 100 "Quit" [Quit]
		return
		text 100 "Matrice" 
		s: field 400
		return
		text 100 "Expected" 
		e: field 400
		return
		text 100 "Result" 
		d: field 400
		return
		text 100 "Result SQ" 
		d2: field 400
		return
		do [s/text: form mat e/text: form expected ]
]