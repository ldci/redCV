Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %GrayHisto.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 256x256
img1: rcvCreateImage msize
histo1: make vector! 256
histo11: make vector! 256
histo2: make vector! 256
smooth: false 
isFile: false


loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1:  rcvLoadImage  tmp
		mat: rcvCreateMat 'integer! 8 img1/size
		canvas1/image: img1
		rcvImage2Mat img1 mat ; -> Grayscale image
		smooth: false 
		isFile: true
	]
]


processMat: does [
	if isFile [
		rcvMat2Image mat img1
		histo1: rcvHistogram mat
		if smooth [histo11: rcvSmoothHistogram histo1]
		tmp: copy histo1
		sort tmp
		maxi: last tmp
		either smooth [rcvConvertMatScale/std histo11 histo2  maxi 200 ] 
		[rcvConvertMatScale/std histo1 histo2  maxi 200] ; change scale
		canvas1/image: img1
	]
]

showPlot: does [
	coord: as-pair 1 256 - histo2/1
	plot: copy [line-width 1 pen green line]
	i: 1 
	while [i <= 256] [  coord: as-pair (i) (250)
						append plot coord
						coord: as-pair (i) (250 - histo2/(i))
						append plot coord
						i: i + 1]
	canvas2/draw: reduce [plot] 
]



; ***************** Test Program ****************************
view win: layout [
		title "Histogram Tests"
		origin margins space margins
		button 120 "Load image" 		[loadImage]
		button 120 "Process Image"		[processMat showPlot]
		check 150 "Smooth Histogram" 	[smooth: face/data processMat showPlot]
		button 80 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base black msize
]
