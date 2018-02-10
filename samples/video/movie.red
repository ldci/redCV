Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %movie.red
	Needs:	 View redCV
]

#include %../../libs/redcv.red ; for redCV functions


margins: 5x5
iSize: 640x480
imgSize: 0x0
nImages: rgbSize: urgbSize: 0
img: rcvCreateImage iSize
currentImg: 1
duration: 0.0
fps: 0
freq: to-time compose [0 0 0.0]
zComp: 0
headerSize: 36
f: none
isFile: false


readImage: func [n [integer!]][
	if isFile[
		f5/text: form n
		idx: movie/:n										; get image offset
		rgbSize: to-integer copy/part skip f idx 4			; get compressed size
		urgbSize: to-integer copy/part skip f idx + 4 4		; get uncompressed size
		rgb: copy/part skip f idx + 8 rgbSize				; get binary values 
		;decompress if necessary
		either zComp = 0 [img/rgb: rgb] [img/rgb: rcvDecompressRGB rgb urgbSize]
		canvas/image: img									; update image container
	]
]

updateSlider: does [sl/data: to-percent (currentImg / to-float nImages)]

readAllImages: does [
	either currentImg < nImages [currentImg: currentImg + 1 readImage  currentImg]
								[currentImg: 0]
	updateSlider
]

readHeader: func [file [file!]][
	f: read/binary/part file headerSize				; 36 bytes for the header
	s: to-string copy/part f 4  					; should be "RCAM"			
	nImages: to-integer copy/part skip f 4 4		; number of images in movie
	imgSize/x: to-integer copy/part skip f 8 4		; image X size	
	imgSize/y: to-integer copy/part skip f 12 4		; image Y size
	duration: to-float copy/part skip f 16 8		; movie duration in sec
	fps: to-integer copy/part skip f 24 4			; frames/sec
	zComp: to-integer copy/part skip f 28 4			; compressed or uncompressed data
	s: to-string copy/part skip f 32 4  			; should be "DATA"
	; update fields and variables
	either zComp = 0 [f6/text: rejoin [ form zComp " : Uncompressed video"]] 
					 [f6/text: rejoin [ form zComp " : ZLib compressed video"]]
	f1/text: rejoin [form nImages " frames"]
	f2/text: form imgSize
	f3/text: rejoin [form round duration " sec"]
	f4/text: rejoin [form fps " FPS"]
	freq: to-time compose [0 0 (1.0 / fps)]
]

loadMovie: func [] [
	tmp: request-file/filter ["Red Video Files" "*.rvf"]
	if not none? tmp [
		readHeader tmp 						; read movie header
		f: read/binary/seek tmp headerSize 	; go to first image
		movie: copy []
		i: 0 
		; makes image offset index
		nextIndex: headerSize ; 36 bytes
		while [i < nImages] [
			index: nextindex
			rgbSize: to-integer copy/part f 4
			nextindex: index + rgbSize + 8
			f: skip f rgbSize + 8
			append movie index
			i: i + 1
		]	
		isFile: true 
		sl/data: 0%
		f: read/binary tmp			; head of file 
		img: rcvCreateImage imgSize ; we need a red image! for displaying video
		currentImg: 1
		readImage currentImg 
		win/text: copy form tmp
	]
]

view win: layout [
	title "Reading red movie"
	origin margins space margins
	button "Load" [loadMovie]
	f1: field 150
	f2: field 100
	f3: field 100
	f4: field 100
	pad 40x0
	button "Quit" [quit]
	return
	canvas: base iSize img
	return
	sl: slider 615 [
				n: nImages - 1
				currentImg: to-integer (sl/data * n) + 1 
				readImage  currentImg]
	bt: base 20x20 black on-time [readAllImages]
	return
	button "<<" [currentImg: 1 readImage currentImg sl/data: 0%]
	button ">>" [currentImg: nImages readImage currentImg updateSlider]
	button "<"  [if currentImg > 1 [currentImg: currentImg - 1 readImage currentImg]
				updateSlider]
	button ">"  [if currentImg < nImages [currentImg: currentImg + 1 readImage currentImg]
				updateSlider]
	onoff: button "Start/Stop" on-click [
		if isFile [
			either bt/rate = none [bt/color: green bt/rate: freq] 
			[bt/color: black bt/rate: none]
		]
	]
	f5: field 75
	f6: field 190
	do [bt/rate: none]
]

