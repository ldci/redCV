Red [
	Title:   "Test images convolution Red VID "
	Author:  "ldci"
	File: 	 %convolution3.red
	Needs:	 'View
]


fileName: ""
isFile: false

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

knl: [0.0 0.0 0.0
	  0.0 1.0 0.0 
	  0.0 0.0 0.0]
	  

		  
		  
rimg: rcvCreateImage 512x512
gray: rcvCreateImage 512x512
dst: rcvCreateImage 512x512
cImg: rcvCreateImage 512x512

sumW: 0
factor: 1.0
delta: 0.0

convolveImage: does [
	sb1/text: copy ""
	t1: now/time/precise
	if error? try [knl/1: to float! k1/text] [knl/1: 0]
	if error? try [knl/2: to float! k2/text] [knl/2: 0]
	if error? try [knl/3: to float! k3/text] [knl/3: 0]
	if error? try [knl/4: to float! k4/text] [knl/4: 0]
	if error? try [knl/5: to float! k5/text] [knl/5: 0]
	if error? try [knl/6: to float! k6/text] [knl/6: 0]
	if error? try [knl/7: to float! k7/text] [knl/7: 0]
	if error? try [knl/8: to float! k8/text] [knl/8: 0]
	if error? try [knl/9: to float! k9/text] [knl/9: 0]
	rcvConvolve cImg dst knl factor delta
	sb1/text: rejoin [round/to third now/time/precise - t1 0.001 " sec"]
]


loadImage: does [
	isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: rejoin ["redCV Convolution: " fileName]
		gray: rcvLoadImage/grayscale tmp
		rimg: rcvLoadImage tmp
		cImg rcvCreateImage rimg/size
		dst: rcvCreateImage rimg/size
		either cb/data [cImg: rcvCloneImage gray]
					   [cImg: rcvCloneImage rimg]
		dst: rcvCloneImage cImg
		src/image: dst
		canvas/image: dst
		isFile: true
	]
]

view win: layout [
	title "redCV Convolution"
	origin 10x10 space 10x10
	button 60 "Load" [loadImage]
	cb: check "Gray" false [
						either cb/data [cImg: rcvCloneImage gray]
					   	[cImg: rcvCloneImage rimg] 
					   	dst: rcvCloneImage cImg
						canvas/image: dst
					   ]
	
	pad 540x0
	button 60 "Quit" [quit]
	return
	
	k1: field 50 k2: field 50 k3: field 50 
	text 60 "Multiplier" sl1: slider 390 [
		sumW: to-integer face/data * 256
		either sumW > 0 [factor: 1.0 / sumW] [factor: 1.0]
		st/text: form sumW
		ft/text: form factor
		if isFile [convolveImage]
	]
	st: field 50 "0"
	ft: field  50 "1.0"
	return
	k4: field 50 k5: field 50 k6: field 50
	
	text 60 "Delta" sl2: slider 450 [delta: 0.0 + (face/data * 256.0) dt/data: form delta
		if isFile [convolveImage] 
	]
	dt: field 50 "0.0"
	return
	k7: field 50 k8: field 50 k9: field 50
	return
	button 170 "Process" [if isFile [convolveImage]]
	text "Rendered in: " sb1: field 100x24
	
	return
	src: base 256x256
	
	canvas: base 512x512 dst 
	do [k1/text: form knl/1 k2/text: form knl/2 k3/text: form knl/3 
	k4/text: form knl/4 k5/text: form knl/5 k6/text: form knl/6 
	k7/text: form knl/7 k8/text: form knl/8 k9/text: form knl/9]
]