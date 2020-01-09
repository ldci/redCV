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

mat: rcvCreateMat 'integer! 32 img/size
histo1: make vector! 256
histo2: make vector! 256

rcvRandomMat mat FFh

rcvMat2Image mat img
;histo1: rcvHistogram mat
histo1: rcvHistoMat mat 
tmp: copy histo1
sort tmp
maxi: last tmp
print [length? histo1 " " length? histo2 " " maxi] 
rcvConvertMatScale/std histo1 histo2  maxi 255 ; change scale

img2: rcvCreateImage msize


s1: rcvNamedWindow "8-bit"
rcvShowImage s1 img


do-events