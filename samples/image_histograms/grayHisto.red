Red [
	Title:   "Histogram tests "
	Author:  "ldci"
	File: 	 %grayHisto.red
	Needs:	 'View
]


;--required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/math/rcvHistogram.red	

margins: 5x5
msize: 262x256
bitSize: 8
img1: 	rcvCreateImage msize
histo1: matrix/init 2 bitSize 256x1 
smooth: false 
isFile: false
recycle/off ; avoid GC for matrices


loadImage: does [
	isFile: false
	canvas1/image: none
	canvas2/draw: none
	canvas2/image: black
	tmp: request-file
	if not none? tmp [
		img1:  rcvLoadImage  tmp
		isFile: true
		processMat
		showPlot
	]
]


processMat: does [
	if isFile [
		mat: matrix/init 2 bitSize img1/size	;--n-bit matrix
		rcvImage2Mat img1 mat					;--image to mat
		rcvMat2Image mat img1					;--mat to image -> grayscale
		histo1/data: rcvHistoMat mat			;--process histogram
		
		;--change scale
		if smooth [histo11: rcvSmoothHistogram histo1]
		either smooth [histo2: rcvConvertMatIntScale histo11 matrix/maxi histo1 200] 
					  [histo2: rcvConvertMatIntScale histo1 matrix/maxi histo1 200] 
		canvas1/image: img1
	]
]

showPlot: does [
	plot: copy [line-width 1 pen green line]
	repeat i 256 [
		append plot as-pair i + 2 256
		append plot as-pair i + 2 256 - histo2/data/:i
	]
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
