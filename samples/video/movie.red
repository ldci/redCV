#! /usr/local/bin/red
Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %movie.red
	Needs:	 View redCV
]

margins: 5x5
fn: %video.rvf
iSize: 640x480
imgSize: 0x0
cSize: 0x0
n: 0
nImages: 0
strSize: 0
f: none
isFile: false
rgbSize: 0
img: make image! reduce [iSize black] 

activeImage: 1
duration: 0.0
fps: 0
compression: 0
freq: none

readImage: func [n [integer!]][
	if isFile [
		f5/text: form n
		img/rgb: movie/:n
	]
	canvas/image: img
]

readAllImages: does [
	either activeImage < nImages [activeImage: activeImage + 1 readImage activeImage]
								  [activeImage: 1]
]

loadMovie: func [] [
	;tmp: request-file/filter ["Red Video Files" "*.rvf"] ; pb with -t macOS
	tmp: request-file
	if not none? tmp [
		f: read/binary tmp
		; read header
		s: to-string copy/part f 4  ; should be "RCAM"
		f: skip f 4					;
		nImages: to-integer copy/part f 4
		
		f: skip f 4
		imgSize/x: to-integer copy/part f 4
		f: skip f 4
		imgSize/y: to-integer copy/part f 4
		
		rgbSize: (imgSize/x * imgSize/y) * 3
		f: skip f 4
		duration: to-float copy/part f 8
		f: skip f 8
		fps: to-integer copy/part f 4
		f: skip f 4
		compression: to-integer copy/part f 4
		either compression = 0 [f6/text: rejoin [ form compression " : Uncompressed video"]] 
							[f6/text: rejoin [ form compression " : ZLib compressed video"]]
		f1/text: rejoin [form nImages " frames"]
		f2/text: form imgSize
		f3/text: rejoin [form round duration " sec"]
		f4/text: rejoin [form fps " FPS"]
		freq: to-time compose [0 0 (1.0 / fps)]
		f: skip f 4
		
		; read red movie data
		movie: copy []
		i: 0 
		while [i < nImages] [
			if i > 0 [f: skip f rgbSize]
			rgb: copy/part f rgbSize
			append movie rgb
			i: i + 1
		]
		img: make image! reduce [imgSize rgb]
		isFile: true 
		activeImage: 1
		readImage activeImage 
	]
]

view win: layout [
	title "Reading red movie"
	origin margins space margins
	button "Load" [loadMovie]
	f1: field 100
	f2: field 100
	f3: field 100
	f4: field 100
	bt: base 20x20 on-time [readAllImages]
	button "Quit" [quit]
	return
	canvas: base iSize img
	return
	button "<<" [activeImage: 1 readImage activeImage]
	button ">>" [activeImage: nImages readImage activeImage]
	button ">"  [if activeImage < nImages [activeImage: activeImage + 1 readImage activeImage]]
	button "<"  [if activeImage > 1 [activeImage: activeImage - 1 readImage activeImage]]
	button "<>" [if isFile [bt/rate: freq]]
	button "||" [bt/rate: none]
	f5: field 60
	f6: field 160
	do [bt/rate: none]
]

