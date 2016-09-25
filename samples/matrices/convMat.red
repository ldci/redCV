Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %ConvMat.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions

msize: 128x128
img1: rcvCreateImage msize
img2: rcvCreateImage msize
img3: rcvCreateImage msize

mat1: rcvCreateMat 'integer! 8 msize
mat2: rcvCreateMat 'integer! 16 msize
mat3: rcvCreateMat 'integer! 32 msize

rcvRandomMat mat1 FFh
;rcvRandomMat mat2 FFFFh
;rcvRandomMat mat3 FFFFFFh


st: now/time/precise
rcvConvertMatScale/normal mat1 mat2 FFh FFFFh
rcvConvertMatScale/normal mat1 mat3 FFh FFFFFFh


print now/time/precise - st

print mat1/2
print [mat2/2 " " to integer! (mat1/2 / 255.00) * FFFFh]
print [mat3/2 " " to integer! (mat1/2 / 255.00) * FFFFFFh]



s1: rcvNamedWindow "8-bit"
s2: rcvNamedWindow "16-bit"
s3: rcvNamedWindow "32-bit"

rcvMat82Image mat1 img1
rcvMat162Image mat2 img2
rcvMat322Image mat3 img3

rcvMoveWindow s1 100x100
rcvMoveWindow s2 400x100
rcvMoveWindow s3  700x100
rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage s3 img3



do-events