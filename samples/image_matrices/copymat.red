Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master
#include %../../libs/redcv.red ; for red functions

margins: 5x5
;8, 16 or 32-bit

mat: make vector! [integer! 32 [4 1 2 2 0 4 1 3 3 1 0 4 2 1 3 2 255 256 257 258]]
sum: make vector! [integer! 32 20]



; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Test" [
						  rcvCopyMat mat sum
						  d/text: form sum]
		button 100 "Quit" [Quit]
		return
		text 100 "Matrice" 
		s: field 400
		return
		text 100 "Result" 
		d: field 400
		return
		do [s/text: form mat ]
]