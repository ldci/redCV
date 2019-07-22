Red [
	Title:   "DTW tests "
	Author:  "Francois Jouen"
	File: 	 %dtw1.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions


plot1: copy []
plot2: copy []
img: rcvCreateImage 256x256
img2: rcvCreateImage 256x256
count: 64
matsize: count * count
dMatrix: make vector! reduce ['float! 64 matSize]
cMatrix: make vector! reduce ['float! 64 matSize]
xPath: copy []

random/seed now/time/precise

generateSeries: does [
	clear fDTW/text
	x: copy []
	y: copy []
	i: 1
	
	while [i <= count] [
		append x random 250
		append y random 250
		i: i + 1
	]
	
	plot1: compose [line-width 2 pen green spline]
	plot2: compose [line-width 2 pen red spline]
	step: 256 / count
	i: 0
	foreach v x [i: i + step p: as-pair i  v append plot1 (p)]
	i: 0
	foreach v y [i: i + step p: as-pair i  v append plot2 (p)]
	
	canvas1/draw: reduce [plot1]
	canvas2/draw: reduce [plot2]
]


calculateDTW: does [
	rcvDTWDistances x y dMatrix
	rcvDTWCosts x y dMatrix cMatrix
	dtw: rcvDTWGetDTW cMatrix
	rcvDTWGetPath x y cMatrix  xPath
	fDTW/text: copy "DTW x y: "
	append fDTW/text form dtw
	
	; distance map
	img: rcvCreateImage as-pair (length? x) (length? y)
	mat:  make vector! [integer! 32 0]
	
	foreach v dMatrix [append mat to-integer v]
	mx:  rcvMaxMat mat
	mat * (255 / mx)
	rcvMat2Image mat img
	canvas3/image: img 
	
	; cost map
	img2: rcvCreateImage as-pair (length? x) (length? x)
	mat2:  make vector! [integer! 32 0]
	foreach v cMatrix [append mat2 to-integer v]
	mx:  rcvMaxMat mat2
	fc:  complement (mx / 255)
	mat2 / fc
	rcvMat2Image mat2 img2
	;optimum warping path
	plot4: compose [line-width 1 pen blue line]
	foreach v xPath  [append plot4 (v)]
	canvas4/image: draw img2 plot4
]


; ***************** Test Program ****************************
view win: layout [
	title "red CV: Dynamic Time Warping"
	button "Generate series" [generateSeries calculateDTW]
	fDTW: field 126
	pad 720x0
	button "Quit" [Quit]
	return
	text 100 "X serie" pad 156x0
	text 100 "Y Serie" pad 156x0
	text 100 "Distance Map" pad 156x0
	text     "Optimum Warping Path"
	return
	canvas1: base 256x256 black draw plot1
	canvas2: base 256x256 black draw plot2
	canvas3: base 256x256 black img
	canvas4: base 256x256 white img2
]






