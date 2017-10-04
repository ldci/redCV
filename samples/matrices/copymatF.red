Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master
#include %../../libs/redcv.red ; for red functions

margins: 5x5
; float 32 or 64-bit
mat: make vector! [float! 32 [4.0 1.0 2.0 2.0 0.0 4.0 1.0 3.0 3.0 1.0 0.0 4.0 2.0 1.0 3.0 2.0]]
sum: make vector! [float! 32 16]



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