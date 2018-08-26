Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions

x: [9 3 1 5 1 2 0 1 0 2 2 8 1 7 0 6 4 4 5]
y: [1 0 5 5 0 1 0 1 0 3 3 2 8 1 0 6 4 4 5]

img: rcvCreateImage 256x256

calculate: does [
	dMatrix: rcvDTWDistances x y
	cMatrix: rcvDTWRun x y dMatrix
	dtw: rcvDTWGetDTW cMatrix
 	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	img: rcvCreateImage as-pair (length? cMatrix) (length? cMatrix)
	mat:  make vector! [integer! 32 0]
	foreach v dMatrix [
		ct: length? v 
		i: 1
		while [i <= ct][append mat to-integer v/:i i: i + 1]
	]
	mx:  rcvMaxMat mat
	mat * (255 / mx)
	rcvMat2Image mat img
	canvas/image: img 
]



view win: layout [
	title "Dynamic Time Warping"
	button "Calculate" [calculate]
	pad 105x0
	button "Quit" [Quit]
	return
	text 25 "x" f1: field 220
	return
	text 25 "y" f2: field 220
	return
	
	canvas: base 256x256 black img
	return
	fDTW: field 256
	do [f1/text: form x f2/text: form y]
]





