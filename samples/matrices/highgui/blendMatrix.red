Red [
	Title:   "Matrix tests"
	Author:  "Francois Jouen"
	File: 	 %blenMatrix.red
	Needs:	 'View
]

#include %../../../libs/redcv.red ; for redCV functions
isize: 256x256
img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize
bitSize: 32
mat1: rcvCreateMat 'integer! bitSize isize
mat2: rcvCreateMat 'integer! bitSize  isize
matD: rcvCreateMat 'integer! bitSize  isize

rcvColorMat mat1 0
rcvColorMat mat2 255
;rcvRandomMat mat1 127
;rcvRandomMat mat2 127
rcvBlendMat mat1 mat2 matD 0.5

rcvMat2Image mat1 img1
rcvMat2Image mat2 img2
rcvMat2Image matD img3
s1: rcvNamedWindow "Mat 1"
s2: rcvNamedWindow "Mat 2"
d:  rcvNamedWindow "Mixed Matrices"	; creates a window
rcvResizeWindow d isize							; resizes the window
rcvResizeWindow s1 isize
rcvResizeWindow s2 isize
rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage d img3									; shows image

do-events
