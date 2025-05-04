Red [
	Title:   "Integral"
	Author:  "ldci"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master

margins: 5x5
bitSize: 8
; required libs

#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvIntegral.red


mx1: matrix/create 2 bitSize 4x4 [4 1 2 2 0 4 1 3 3 1 0 4 2 1 3 2]
expected: matrix/create 2 bitSize 4x4 [4 5 7 9 4 9 12 17 7 13 16 25 9 16 22 33] 
ssum: matrix/init/value 2 bitSize 4x4 0
sqsum: matrix/init/value 2 bitSize 4x4 0

;--for test
testMat: does [
	y: 1
	while [y <= 4] [
		x: 1
		while [x <= 4] [
			v:  rcvGetInt2D ssum x y
			v2: rcvGetInt2D sqsum x y
			print [v v2]
			x: x + 1
		]
	y: y + 1	
	]
]




; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Test" [
						  rcvIntegral mx1 ssum sqsum
						  ;testMat
						  d/text: form ssum/data
						  d2/text: form sqsum/data
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
		do [s/text: form mx1/data e/text: form expected/data ]
]