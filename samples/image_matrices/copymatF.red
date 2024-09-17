Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %testMat.red
	Needs:	 'View
]

; required last Red Master
; required libs

#include %../../libs/matrix/rcvMatrix.red

margins: 5x5
; float 32 or 64-bit
mat: matrix/create 3 64 5x4 [4.0 1.0 2.0 2.0 0.0 4.0 1.0 3.0 3.0 1.0 0.0 4.0 2.0 1.0 3.0 2.0]



; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Test Copy" [
						  mat: matrix/init/value/rand 3 64 5x4 25.0
						  s/text: form mat/data
						  ;ssum: rcvCopyMat mat; 
						  ssum: matrix/_copy mat
						  d/text: form ssum/data]
		button 100 "Quit" [Quit]
		return
		text 100 "Matrice" 
		s: field 400
		return
		text 100 "Copy" 
		d: field 400
		return
]