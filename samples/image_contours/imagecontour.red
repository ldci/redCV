Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %ImageContour.red
	Needs:	 'View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/math/rcvStats.red

isize: 256x256
bitSize: 32

img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize
mat:  matrix/init/value 2 bitSize iSize 0

lPix: 0x0
rPix: 0x0
uPix: 0x0
dPix: 0x0
matSize: 0x0
fgVal: 1
bgVal: 0
hForm: wform: 0
surface: 0
isLoad: false

loadImage: does [
	canvas1/image: none
	canvas2/image: none
	canvas3/image: none
	clear r/text
	clear f1/text
	clear f2/text
	clear f3/text
	clear f4/text
	clear f5/text
	clear f6/text
	clear f6/text
	isLoad: false
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		clone: rcvCreateImage img1/size
		w: img1/size/x
		h: img1/size/y
		canvas1/image: img1
		matSize: 	img1/size
		mat:		matrix/init/value 2 bitSize matSize 0
		rcv2WB img1 img2 
		dp/selected: 2
		fgVal: 1 
		bgVal: 0
		f5/text: form img1/size/x * img1/size/y 
		append f5/text " pixels"
		isLoad: true
		processImage
	]
]

processImage: does [
	visited: matrix/init/value 2 bitSize matSize 0
	rcvImage2Mat img2 mat 		; process image to a bytes matrix [0..255] 
	surface: rcvCountNonZero mat; get shape surface in pixels
	if fgVal = 0 [surface: matSize/x * matSize/y  - surface]
	bmat: rcvMakeBinaryMat mat	; processImages to a binary matrix [0..1]
	rcvMat2Image mat img2 		; processImages matrix to red image
	rcvCopyImage img2 clone		;
	
	lPix: rcvMatleftPixel bmat fgVal
	rPix: rcvMatRightPixel bmat fgVal
	uPix: rcvMatUpPixel bmat fgVal
	dPix: rcvMatDownPixel bmat fgVal
	hForm: setHeight dPix uPix  
	wform: setWidth rPix lPix
	
	luPix: as-pair lPix/x uPix/y 
	ruPix: as-pair rPix/x uPix/y 
	rdPix: as-pair rPix/x dPix/y 
	ldPix: as-pair lPix/x dPix/y 
	
	f1/text: form luPix
	f2/text: form ruPix
	f3/text: form ldPix
	f4/text: form rdPix
	f6/text: form surface
	append f6/text " pixels"
	
	border: copy []
	rcvMatGetBorder bmat fgVal border
	
	plot: compose [line-width 1 
		pen green
		line (luPix) (ruPix) (rdPix) (ldPix) (luPix)
		pen red
	]
	
	
	foreach p border [append append append plot 'box (p) (p + 1)] 
	;foreach p border [rcvSetPixel clone p red]
	canvas2/image: draw clone plot
	
]

getCodes: does [
	foreach p border [rcvSetContourValue visited p 255]
	rcvMat2Image visited img3
	canvas3/image: img3
	count: length? border
	p: first border
	i: 1
	s: copy ""
	clear r/text
	perimeter: 0.0
	while [i < count] [
		d: rcvMatGetChainCode visited p 255
		rcvSetContourValue visited  p 0 ; pixel is visited
		if d >= 0 [append s form d]; only external pixels -1: internal pixels
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	r/text: s
	f7/text: form perimeter 
]

setHeight: function [p1 [pair!] p2 [pair!] return: [integer!]][
	p1/y - p2/y + 1
]

setWidth: function [p1 [pair!] p2 [pair!] return: [integer!]][
	p1/x - p2/x + 1
]


; ***************** Test Program ****************************
view win: layout [
		title "Image Contour and Freeman Chain Code"
		button "Load" 	[loadImage]
		button "B&W"  	[rcv2BW img1 img2 fgVal: 0 bgVal: 1 dp/selected: 1
						if isLoad [processImage]];
		button "W&B"	[rcv2WB img1 img2 fgVal: 1 bgVal: 0 dp/selected: 2
						if isLoad [processImage]]
		text "Foreground Value" 
		dp: drop-down 40 data ["0" "1"]
			select 2
			on-change [
				fgVal: face/selected - 1
				either fgVal = 0 [bgVal: 1] [bgVal: 0]
				if isLoad [processImage]
			]
		
		button "Freeman Chain Code" [if isLoad [getCodes]]
		pad 150x0 
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseImage img3
							rcvReleaseMat mat
							rcvReleaseMat bmat
							if isLoad [
								rcvReleaseMat visited
								rcvReleaseImage clone
								rcvReleaseMat visited
							]
							Quit]
		return
		text "Source" f5: field 165 ;pad 174x0 
		text "Surface" f6: field 165; pad 174x0
		text "Perimeter" f7: field 170
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base iSize img3
		return
		pad 35x0
		text 80 "Top Left" f1: field 80
		text 80 "Top Right" f2: field 80
		text 80 "Bottom Left" f3: field 80
		text 80 "Bottom Right" f4: field 80
		return
		r: area 788x100 wrap
]
