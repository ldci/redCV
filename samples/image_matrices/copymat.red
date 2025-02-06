Red [
	Title:   "Matrices"
	Author:  "ldci"
	File: 	 %copyMat.red
	Needs:	 'View
]

; required libs
#include %../../libs/matrix/rcvMatrix.red

margins: 5x5

; ***************** Test Program ****************************
view win: layout [
		title "Copy Matrix"
		origin margins space margins
		button 100 "Test Copy" [
						  mat: matrix/init/value/rand 2 32 5x4 25
						  s/text: form mat/data
						  ssum: matrix/_copy mat ; same as ssum: rcvCopyMat mat 
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