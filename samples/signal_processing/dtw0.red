Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/timeseries/rcvDTW.red


x: [9 3 1 5 1 2 0 1 0 2 2 8 1 7 0 6 4 4 5]
y: [1 0 5 5 0 1 0 1 0 3 3 2 8 1 0 6 4 4 5]

lx: length? x
ly: length? y
dMatrix: matrix/init/value 3 64 as-pair lx ly 0.0
cMatrix: matrix/init/value 3 64 as-pair lx ly 0.0 	
img: rcvCreateImage 256x256
plot: copy []
calculate: does [
	rcvDTWDistances x y dMatrix
	rcvDTWCosts x y dMatrix cMatrix 
	dtw: rcvDTWGetDTW cMatrix
 	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	img: rcvCreateImage as-pair (length? x) (length? y)
	mat: matrix/create 2 32 as-pair (length? x) (length? y) []
	mx:  matrix/maxi dMatrix
	foreach v dMatrix/data [append mat/data to-integer v] 
	mx:  matrix/maxi mat
	mat/data * (255 / mx)
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





