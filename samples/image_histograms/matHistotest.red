Red [
	Title:   "Statitical tests "
	Author:  "Francois Jouen"
	File: 	 %MatHisto.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/math/rcvHistogram.red	
#include %../../libs/highgui/rcvHighGui.red

msize: 256x256
img: rcvCreateImage msize

mat: matrix/init/value/rand 2 8 msize 255
rcvMat2Image mat img

vHisto1: rcvHistogram mat 
tmp: copy vHisto1
sort tmp
maxi: last tmp
mHisto2: rcvConvertMatIntScale mat maxi 255
img2: rcvCreateImage msize


s1: rcvNamedWindow "8-bit"
rcvShowImage s1 img


do-events