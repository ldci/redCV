Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/timeseries/rcvDTW.red

plot1: copy []
plot2: copy []
plot3: copy []


generateSeries: does [
	clear fDTW/text
	clear fDTW2/text
	x: copy []
	y: copy []
	i: 1
	count: 32
	while [i <= count] [
		append x random 255
		append y random 255
		i: i + 1
	]
	plot1: compose [line-width 2 pen green spline]
	plot2: compose [line-width 2 pen red spline]
	plot3: compose [line-width 2 pen yellow spline]
	step: 256 / count
	i: 0
	foreach v x [i: i + step p: as-pair i  v  append plot1 (p)]
	i: 0
	foreach v y [i: i + step p: as-pair i  v  append plot2 (p)]
	i: 0
	foreach v y [i: i + step p: as-pair i  v  append plot3 (p)]
	
	canvas1/draw: reduce [plot1]
	canvas2/draw: reduce [plot2]
	canvas3/draw: reduce [plot3]
]

; call DTW function
calculateDTW: does [
	r: rcvDTWCompute x y
	fDTW/text: copy "DTW x y: "
	append fDTW/text form r
	r: rcvDTWCompute y y
	fDTW2/text: copy "DTW y y*: "
	append fDTW2/text form r
]


; ***************** Test Program ****************************
view win: layout [
	title "Dynamic Time Warping"
	button "Generate series" [generateSeries calculateDTW]
	pad 590x0
	button "Quit" [Quit]
	return
	text 100 "X serie" pad 156x0
	text 100 "Y Serie" pad 156x0
	text 100 "Y* Serie"
	return
	canvas1: base 256x256 black draw plot1
	canvas2: base 256x256 black draw plot2
	canvas3: base 256x256 black draw plot3
	return
	fDTW: field 522
	fDTW2: field 256
]






