Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %Image2Matrix.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage img1/size

intSize: 8

mat: rcvCreateMat 'integer! intSize img1/size

print [length? mat lf ]
; ARGB images are converted to grayscale by rcvImage2Mat function
rcvImage2Mat img1 mat 				; Converts  image to 1 Channel matrix [0..255]  
rcvMat82Image mat img2 				; from matrix to red image

print [length? mat lf ]

s1: rcvNamedWindow "Source"
d:  rcvNamedWindow "1-Channel Matrix -> Red Image"


rcvMoveWindow s1 100x100
rcvMoveWindow d  400x100


rcvShowImage s1 img1
rcvShowImage d img2
rcvResizeWindow d 512x512

do-events