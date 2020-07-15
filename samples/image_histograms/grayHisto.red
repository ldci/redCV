Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %GrayHisto.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 256x256
img1: rcvCreateImage msize
histo1: make vector! 256
histo11: make vector! 256
histo2: make vector! 256
smooth: false 
isFile: false
recycle/off ; for keeping matrices alive


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
		isFile: true
		processMat
		showPlot
	]
]


processMat: does [
	if isFile [
		rcvMat2Image mat img1
		histo1: rcvHistoMat mat
		if smooth [histo11: rcvSmoothHistogram histo1]
		maxi: rcvMaxMat histo1
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
		title "Grayscale Image Histogram"
		origin margins space margins
		button 100 "Load image" 		[loadImage]
		check 150 "Smooth Histogram" 	[smooth: face/data processMat showPlot]
		pad 170x0
		button 80 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base black msize
]
