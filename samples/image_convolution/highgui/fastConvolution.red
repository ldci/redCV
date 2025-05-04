Red [
	Title:   "Fast Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %fastConvolution.red
	Needs:	 'View
]


#include %../../../libs/redcv.red ; for redCV functions
;a quick laplacian mask
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]


img1: rcvLoadImage %../../../images/building.jpg
img2: rcvCreateImage img1/size
img3: rcvCreateImage img1/size
channel: 1
rcv2Gray/average img1 img2								; Grayscaled image
rcvFastConvolve img2 img3 channel  mask 1.0 5.0			; fast convolution on channel 1

s1: rcvNamedWindow "Source"
s2: rcvNamedWindow "Gray"
d:  rcvNamedWindow "1-Channel Convolution"


rcvMoveWindow s1 100x100
rcvMoveWindow s2 400x100
rcvMoveWindow d  700x100

rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage  d img3
rcvResizeWindow d img1/size

do-events