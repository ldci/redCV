Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %testImage2Mat.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage img1/size
img3: rcvCreateImage img1/size

intSize: 8
iSize: intSize / 8

mat: rcvCreateMat 'integer! intSize img1/size

print [length? mat lf ]

rcv2Gray/average img1 img2							; Grayscaled image
rcvImage2Mat img2 mat iSize							; Converts grayscaled image to 1 Channel matrix [0..255]  
rcvMat2Image mat img3 iSize							; from matrix to red image

print [length? mat lf ]

s1: rcvNamedWindow "Source"
s2: rcvNamedWindow "Gray"
d:  rcvNamedWindow "1-Channel Matrix -> Red Image"


rcvMoveWindow s1 100x100
rcvMoveWindow s2 400x100
rcvMoveWindow d  700x100

rcvShowImage s1 img1
rcvShowImage s2 img2

rcvShowImage d img3
rcvResizeWindow d 512x512

do-events