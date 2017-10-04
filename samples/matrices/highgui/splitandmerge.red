Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %splitmerge.red
	Needs:	 'View
]

#include %../../../libs/redcv.red 					; for redCV functions
img1: rcvLoadImage %../../../images/lena.jpg		; load image
imgC1: rcvCreateImage img1/size					; create image for rgb
imgC2: rcvCreateImage img1/size
imgC3: rcvCreateImage img1/size
imgD: rcvCreateImage img1/size					; and merged image

bitSize: 32										; matrix bit size (8, 16 or 32)
mat0: rcvCreateMat 'integer! bitSize img1/size	; create all matrices we need for argb
mat1: rcvCreateMat 'integer! bitSize img1/size
mat2: rcvCreateMat 'integer! bitSize img1/size
mat3: rcvCreateMat 'integer! bitSize img1/size

rcvSplit2Mat img1 mat0 mat1 mat2 mat3			; split image in ARGB matrices

rcvMerge2Image mat0 mat1 mat2 mat3 imgD			; and merge matrices 

s1:  rcvNamedWindow "Source"
d1:  rcvNamedWindow "r"
d2:  rcvNamedWindow "g"
d3:  rcvNamedWindow "b"
d4:  rcvNamedWindow "Merged"

rcvMoveWindow s1  400x100
rcvMoveWindow d1  100x400
rcvMoveWindow d2  400x400
rcvMoveWindow d3  700x400
rcvMoveWindow d4  400x700

rcvMat2Image mat1 imgC1 
rcvMat2Image mat2 imgC2 
rcvMat2Image mat3 imgC3 

rcvShowImage s1 img1
rcvShowImage d1 imgC1
rcvShowImage d2 imgC2
rcvShowImage d3 imgC3
rcvShowImage d4 imgD


do-events