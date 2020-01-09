Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %ImageContour.red
	Needs:	 'View
]

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvFreeman.red
#include %../../libs/math/rcvDistance.red
#include %../../libs/math/rcvStats.red


isize: 256x256
bitSize: 32

img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize
clone: rcvCreateImage isize

mat:  rcvCreateMat 'integer! bitSize isize
bmat:  rcvCreateMat 'integer! bitSize isize
lPix: rPix: uPix: dPix: 0x0
matSize: 0x0
fgVal: 1
bgVal: 0
hForm: wform: 0
surface: 0
perim: 0
isLoad: false
cg: 0x0
stats: copy []

setHeight: function [p1 [pair!] p2 [pair!] return: [integer!]][
	p1/y - p2/y + 1
]

setWidth: function [p1 [pair!] p2 [pair!] return: [integer!]][
	p1/x - p2/x + 1
]

loadImage: does [
	rcvZeroImage img1
	rcvZeroImage img2
	rcvZeroImage img3
	rcvZeroImage clone
	canvas3/draw: copy []
	clear f1/text
	clear f2/text
	clear f3/text
	clear f4/text
	clear f5/text
	clear f6/text
	clear f7/text
	isLoad: false
	tmp: request-file
	if not none? tmp [
		fgVal: 1 
		bgVal: 0
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		clone: rcvCreateImage img1/size
		w: img1/size/x
		h: img1/size/y
		matSize: img1/size
		mat:  rcvCreateMat 'integer! bitSize matSize
		bmat: rcvCreateMat 'integer! bitSize matSize
		visited: rcvCreateMat 'integer! bitSize matSize
		rcv2WB img1 img2 
		canvas2/image: img2
		canvas1/image: img1
		f5/text: form img1/size/x * img1/size/y 
		append f5/text " pixels"
		dp/selected: 2
		fgVal: 1 
		bgVal: 0
		isLoad: true
		processImage
	]
]

processImage: does [
	rcvImage2Mat img2 mat 		; process image to a bytes matrix [0..255] 
	surface: rcvCountNonZero mat; get shape surface in pixels
	if fgVal = 0 [surface: matSize/x * matSize/y  - surface]
	rcvMakeBinaryMat mat bmat	; processImages to a binary matrix [0..1]
	rcvMat2Image mat img2 		; processImages matrix to red image
	rcvCopyImage img2 clone		; copy image for drawing
	lPix: rcvMatleftPixel bmat matSize fgVal
	rPix: rcvMatRightPixel bmat matSize fgVal
	uPix: rcvMatUpPixel bmat matSize fgVal
	dPix: rcvMatDownPixel bmat matSize fgVal
	hForm: setHeight dPix uPix  
	wform: setWidth rPix lPix
	f1/text: form as-pair lPix/x uPix/y 
	f2/text: form as-pair rPix/x uPix/y
	f3/text: form as-pair rPix/x dPix/y
	f4/text: form as-pair lPix/x dPix/y
	f6/text: form surface
	append f6/text " pixels"
]


getContour: does [
	; get all shape contours
	border: copy []
	rcvMatGetBorder bmat matSize fgVal border
	foreach p border [rcvSetInt2D visited matSize p 1]
	; get only out contours with Freeman chain code
	outBorder: copy []
	inBorder: copy []
	perim: length? border
	f7/text: form perim
	append f7/text " pixels"
	
	p: first border
	i: 1
	while [i <= perim] [
		d: rcvMatGetChainCode visited matSize p fgVal
		if d <> -1 [append outBorder p]
		idx: (p/y * w + p/x) + 1	
		visited/:idx: 0; pixel is visited
		;get the next pixel to process
		p: rcvGetContours p d
		i: i + 1
	]
	; get only in contours with difference 
	inBorder: difference border outBorder
	
	; draw results
	plot: compose [line-width 1 pen green]
	foreach p outborder [append append append plot 'box (p) (p + 1)] 
	append append plot 'pen red
	inborder: skip inborder 1
	foreach p inborder [append append append plot 'box (p) (p + 1)] 
	canvas2/image: draw clone plot
]


processContour: function [srcBorder [block!] return: [block!]] [
	btheta: copy []
	brho: copy []
	maxRho: 0.0
	foreach p srcBorder [
		; use x y coordinates and calculate rho and theta
		rho: rcvGetEuclidianDistance p cg
		if rho >= maxRho [maxRho: rho]	; maxRho for normalization
		theta: rcvGetAngleRadian p - cg ; [-pi +pi]
		append btheta  theta
		append brho rho
	]
	
	; normalization [0.0 .. 1.0]
	normf: 1.0 / maxRho
	tmpv: make vector! reduce brho
	tmpv * normf
	brho: to block! tmpv
	
	; get coordinates
	points: copy []
	i: length? brho
	j: 1
	while [j <= i] [
		blk: copy []
		append blk btheta/:j
		append blk brho/:j
		append/only points blk
		j: j + 1
	]
	points
]



getSignature: does [
	rcvZeroImage img3
	plot2: compose [line-width 1 pen green fill-pen green]
	
	cg: rcvGetMatCentroid bmat matSize 	; get shape centroid	
	if cb1/data [
		points: processContour outBorder
		; draw shape
		foreach n points [
			i: first n
			i: 180.0 + (i * 55.0)
			v: second n
			v: 255.0 - (v * 200.0)
			p: as-pair i v
			append append append plot2 'circle (p) 1 
		]
	
	]
	
	if cb2/data [
		points: processContour inBorder
		append append plot2 'pen red
		append append plot2 'fill-pen  red
		; draw shape
		foreach n points [
			i: first n
			i: 180.0 + (i * 55.0)
			v: second n
			v: 255.0 - (v * 200.0)
			p: as-pair i v
			append append append plot2 'circle (p) 1 
		]
	]
	canvas3/draw: reduce [plot2]
]



onQuit: does [
	rcvReleaseImage img1 
	rcvReleaseImage img2
	rcvReleaseImage img3
	rcvReleaseMat mat
	rcvReleaseMat bmat
	if isLoad [
		rcvReleaseMat visited
		rcvReleaseImage clone
	]
	Quit
]

; ***************** Test Program ****************************
view win: layout [
		title "Image Contour and Polar Signature"
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
		
		cb1: check "Show External" 
		cb2: check "Show Internal"
		button "Contour and Signature" [if isLoad [getContour getSignature]] 
		pad 20x0
		button 60 "Quit" [onQuit]
		return
		text "Source" f5: field 165 
		text "Surface" f6: field 165
		text "Perimeter" f7: field 80
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base 360x256 img3
		return
		text 80 "Top Left" f1: field 80
		text 80 "Top Right" f2: field 80
		text 80 "Bottom Left" f3: field 80
		text 80 "Bottom Right" f4: field 80
		do [cb1/data: true cb2/data: false]
]
