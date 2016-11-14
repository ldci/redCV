Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master

margins: 5x5

#include %../../libs/redcv.red ; for red functions
mat: make vector! [integer! 8 [4 1 2 2 0 4 1 3 3 1 0 4 2 1 3 2]]
expected: make vector! [4 5 7 9 4 9 12 17 7 13 16 25 9 16 22 33] 
sum: rcvCreateMat 'integer! 8 4x4
sqsum: rcvCreateMat 'integer! 8 4x4


; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Test" [rcvIntegral mat sum sqsum 4x4 
						  d/text: form sum]
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
		do [s/text: form mat e/text: form expected ]
]