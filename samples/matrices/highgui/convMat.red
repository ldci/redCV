Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %ConvMat.red
	Needs:	 'View
]

#include %../../../libs/redcv.red ; for redCV functions

msize: 128x128
img1: rcvCreateImage msize
img2: rcvCreateImage msize
img3: rcvCreateImage msize

mat1: rcvCreateMat 'integer! 8 msize
mat2: rcvCreateMat 'integer! 16 msize
mat3: rcvCreateMat 'integer! 32 msize
mat4: rcvCreateMat 'float! 64 msize

rcvRandomMat mat1 127 and FFh ; not FFh
;rcvRandomMat mat2 FFFFh 	; OK
;rcvRandomMat mat3 FFFFFFh  ; OK



st: now/time/precise
rcvConvertMatScale/std mat1 mat2 FFh FFFFh		; 8 to 16 ; 0K
rcvConvertMatScale/std mat1 mat3 FFh FFFFFFh	; 8 to 32 ;0K

rcvMatInt2Float mat2 mat4 FFFFh

print now/time/precise - st

print [mat1/64  " " to integer! (mat1/64 / 255.00) * FFh]
print [mat2/64 " " to integer! (mat1/64 / 255.00) * FFFFh]
print [mat3/64 " " to integer! (mat1/64 / 255.00) * FFFFFFh]
print [mat4/64 " "]


s1: rcvNamedWindow "8-bit"
s2: rcvNamedWindow "8 -> 16-bit"
s3: rcvNamedWindow "8 -> 32-bit"


rcvMat2Image mat1 img1
rcvMat2Image mat2 img2 ; truncated to the bit-size
rcvMat2Image mat3 img3 ;truncated to the bit-size

rcvMoveWindow s1 100x100
rcvMoveWindow s2 400x100
rcvMoveWindow s3  700x100
rcvShowImage s1 img1
rcvShowImage s2 img2
rcvShowImage s3 img3



do-events