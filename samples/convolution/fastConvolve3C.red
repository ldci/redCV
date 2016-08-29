Red [
	Title:   "Fast Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %testImage2Mat.red
	Needs:	 'View
]

mask: [-1.0 0.0 -1.0
		0.0 4.0 0.0 
	   -1.0 0.0 -1.0]


#include %../../libs/redcv.red ; for redCV functions
img1: rcvLoadImage %../../images/baboon.jpg
img2: rcvCreateImage img1/size
img3: rcvCreateImage img1/size
img4: rcvCreateImage img1/size

rcvFastConvolve img1 img2 1 mask 1.0 0.0			; fast convolution on channel 1
rcvFastConvolve img1 img3 2 mask 1.0 0.0			; fast convolution on channel 2
rcvFastConvolve img1 img4 3 mask 1.0 0.0			; fast convolution on channel 3


s1: rcvNamedWindow "Source"
d1: rcvNamedWindow "Channel 1"
d2: rcvNamedWindow "Channel 2"
d3: rcvNamedWindow "Channel 3"


rcvMoveWindow s1 100x100
rcvMoveWindow d1 400x100
rcvMoveWindow d2  700x100
rcvMoveWindow d3  1000x100

rcvShowImage s1 img1
rcvShowImage d1 img2
rcvShowImage d2 img3
rcvShowImage d3 img4


do-events