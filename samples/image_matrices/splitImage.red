Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %splitImage.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256
bitSize: 8
img1:  rcvCreateImage isize
imgC1: rcvCreateImage img1/size					; create image for rgb
imgC2: rcvCreateImage img1/size
imgC3: rcvCreateImage img1/size
imgD:  rcvCreateImage img1/size					; and merged image
isFile: false

; loads any supported Red image 
loadImage: does [
	isFile: false
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	canvas3/image/rgb: black
	canvas4/image/rgb: black
	canvas5/image/rgb: black
	tmp: request-file
	unless none? tmp [
		img1: rcvLoadImage tmp						;--load image
		imgC1: rcvCreateImage img1/size				;--create image for rgb
		imgC2: rcvCreateImage img1/size				;--create image for rgb
		imgC3: rcvCreateImage img1/size				;--create image for rgb
		imgD:  rcvCreateImage img1/size				;--create image for rgb			
		mat0: matrix/init 2 bitSize img1/size 		;--create all matrices we need for argb
		mat1: matrix/init 2 bitSize img1/size		;--create all matrices we need for argb
		mat2: matrix/init 2 bitSize img1/size		;--create all matrices we need for argb
		mat3: matrix/init 2 bitSize img1/size		;--create all matrices we need for argb
		canvas1/image: img1
		isFile: true
	]
]

; splits image into 4 matrices
split: does [
	if isFile [
		b: rcvSplit2Mat img1 bitSize				;--split image into 4 channels
		mat0: b/1									;--r channel
		mat1: b/2									;--g channel
		mat2: b/3									;--b channel
		mat3: b/4									;--alpha channel
		rcvMat2Image mat1 imgC1						;--get r channel
		rcvMat2Image mat2 imgC2 					;--get g channel					
		rcvMat2Image mat3 imgC3 					;--get b channel 
		canvas2/image: imgC1						;--show r channel
		canvas3/image: imgC2						;--show g channel
		canvas4/image: imgC3						;--show b channel
	]
]

;merges image from 4 matrices whatever the bitSize
merge: does [
	if isFile [
		rcvMerge2Image mat0 mat1 mat2 mat3 imgD		;--merge all matrices in a rgb image
		canvas5/image: imgD
	]
]

; Clean App Quit
quitApp: does [
	rcvReleaseImage img1 
	rcvReleaseImage imgC1
	rcvReleaseImage imgC2
	rcvReleaseImage imgC3
	rcvReleaseImage imgD
	if isFile [
		rcvReleaseMat mat0
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
	]
	Quit
]


; ***************** Test Program ****************************
view win: layout [
		title "Split Image"
		button "Load" 		[loadImage]
		button "Split" 		[split]
		button "Merge" 		[merge]
		button 60 "Quit" 	[quitApp]
		return
		text 100 "Source" 
		pad 156x0 text 100 "Red Channel"
		pad 156x0 text 100 "Green Channel"
		pad 156x0 text 100 "Blue Channel"
		pad 156x0 text 100 "Merged image"
		return
		canvas1: base isize img1
		canvas2: base isize imgC1
		canvas3: base isize imgC2
		canvas4: base isize imgC3	
		canvas5: base isize imgD
]

