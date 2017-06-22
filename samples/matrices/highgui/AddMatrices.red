Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %AddMatrices.red
	Needs:	 'View
]

#include %../../../libs/redcv.red ; for redCV functions
img1: rcvLoadImage %../../../images/lena.jpg ;cross.png;
img2: rcvCreateImage img1/size
img3: rcvCreateImage img1/size


; uses 16-bit matrices to avoid rounding effects
mat1: rcvCreateMat 'integer! 8 img1/size
mat2: rcvCreateMat 'integer! 16 img1/size
mat3: rcvCreateMat 'integer! 16 img1/size
mat4: rcvCreateMat 'integer! 16 img1/size

rcvImage2Mat img1 mat1 							; Converts  image to 1 Channel matrix [0..255]
rcvMat2Image mat1 img1							; to Red image


rcvConvertMatScale/std mat1 mat2 127 16000		 ; converts scale

rcvRandomMat mat3 32768							; random mat
rcvMat2Image mat3 img2						; to Red Image


mat4: rcvAddMat mat2 mat3 						; add both matrices
;rcvAddMat mat2 mat3 mat4
rcvMat2Image mat4 img3						; from matrix to red image



s1: rcvNamedWindow "Source Matrix"
s2: rcvNamedWindow "Random Matrix"
d:  rcvNamedWindow " -> Red Image"


rcvMoveWindow s1 100x100
rcvMoveWindow s2 400x100
rcvMoveWindow d  700x100


rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage d img3

do-events