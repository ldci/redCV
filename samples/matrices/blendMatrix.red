Red [
	Title:   "Matrix tests"
	Author:  "Francois Jouen"
	File: 	 %blenMatrix.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
img1: rcvCreateImage 512x512
img2: rcvCreateImage 512x512
img3: rcvCreateImage 512x512
mat1: rcvCreateMat 'integer! 8 512x512
mat2: rcvCreateMat 'integer! 8 512x512
matD: rcvCreateMat 'integer! 8 512x512

rcvColorMat mat1 127
rcvRandomMat mat2 255
rcvBlendMat mat1 mat2 matD 0.5

rcvMat82Image mat1 img1
rcvMat82Image mat2 img2
rcvMat82Image matD img3
s1: rcvNamedWindow "Mat 1"
s2: rcvNamedWindow "Mat 2"
d:  rcvNamedWindow "Mixed Matrices"	; creates a window
rcvResizeWindow d 512x512							; resizes the window
rcvResizeWindow s1 512x512
rcvResizeWindow s2 512x512
rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage d img3									; shows image

do-events
