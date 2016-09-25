Red [
	Title:   "Histogram tests "
	Author:  "Francois Jouen"
	File: 	 %MatHisto.red
	Needs:	 'View
]

; required last Red Master

#include %../../libs/redcv.red ; for red functions

margins: 5x5
msize: 256x256
img1: rcvCreateImage msize
mat: rcvCreateMat 'integer! 8 img1/size
histo1: make vector! 256
histo2: make vector! 256

t: now/time/precise
random/seed to integer! t/second

processMat: does [
	rcvRandomMat mat 255 
	rcvMat82Image mat img1
	histo1: rcvHistogram mat
	tmp: copy histo1
	sort tmp
	maxi: last tmp
	rcvConvertMatScale/normal histo1 histo2  maxi 200 ; change scale
	canvas1/image: img1
]

showPlot: does [
	coord: as-pair 1 256 - histo2/1
	plot: copy [line-width 1 pen red line]
	i: 1 
	while [i <= 256] [  coord: as-pair (i) (256)
						append plot coord
						coord: as-pair (i) (256 - histo2/(i))
						append plot coord
						i: i + 1]
	canvas2/draw: reduce [plot] 
]



; ***************** Test Program ****************************
view win: layout [
		title "Histogram Tests"
		origin margins space margins
		button 100 "Generate Matrix"	[processMat showPlot]
		button 40 "Quit" 				[rcvReleaseImage img1 Quit]
		return
		canvas1: base msize img1
		canvas2: base black msize
]
