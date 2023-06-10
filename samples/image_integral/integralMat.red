Red [
	Title:   "Integral"
	Author:  "Francois Jouen"
	File: 	 %integralMat.red
	Needs:	 'View
]

; required last Red Master

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvIntegral.red


margins: 5x5
msize: 256x256
bitSize: 8

img1: make image! reduce [msize black]	; src
img2: rcvCreateImage img1/size
img3: rcvCreateImage img1/size
mat1: matrix/init 2 bitSize img1/size
ssum: matrix/init 2 bitSize img1/size		; dst 1
sqsum: matrix/init 2 bitSize img1/size		; dst 2


loadImage: does [
	canvas1/image: black
	canvas2/image: black
	canvas3/image: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage  tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		mat1: matrix/init 2 bitSize img1/size
		ssum: matrix/init 2 bitSize img1/size		; dst 1
		sqsum: matrix/init 2 bitSize img1/size		; dst 2
		rcvImage2Mat img1 mat1
		rcvIntegral mat1 ssum sqsum
		rcvMat2Image mat1 img1
		rcvMat2Image ssum img2
		rcvMat2Image sqsum img3	
		canvas1/image: img1
		canvas2/image: img2
		canvas3/image: img3
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Integral Image"
		origin margins space margins
		button 100 "Load Image" 		[loadImage]
		button 100 "Quit" 				[rcvReleaseImage img1 
										rcvReleaseImage img2 
										rcvReleaseImage img3 
										Quit]
		return
		
		text 256 "Source" center  text 255 "Sum" center text 255 " Square Sum" center 
		return
		canvas1: base msize img1
		canvas2: base msize img2
		canvas3: base msize img3
]