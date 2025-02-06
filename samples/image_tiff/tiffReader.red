#! /usr/local/bin/red
Red [
	Title:   "TIFF"
	Author:  "ldci"
	File: 	 %tiffReader.red
	Needs:	 View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/tiff/rcvTiff.red

; **************test program variables and functions*********
dSize: 512
gsize: as-pair dSize dSize
img: make image! reduce [gSize black]
margins: 10x5
isFile: false

loadImage: does [
	tmpf: request-file/filter ["All Tiff Files" "*.tif;*.tiff"]
	isFile: false
	if not none? tmpf [
		canvas/image: black
		f1/text: f2/text: f3/text: f4/text: f5/text: ""
		sb1/text: sb2/text: ""
		tags/data: []
		;process tiff file and first image (page)
		page: 1
		t1: now/time/precise
		ret: rcvLoadTiffImage tmpf
		either ret [
			; only Uncompressed Tiff files
			if TImage/Compression = 1 [canvas/image: rcvTiff2RedImage] 	
			; for tags visualisation
			tags/data: tagList
			f1/text: rejoin ["Byte Order: " form byteOrder]
			f2/text: rejoin ["Image: " ImageType]
			either NumberOfPages = 1 [str: " page" ] [str: " pages"]
			f3/text: rejoin [to-string NumberOfPages str]
			f4/text: rejoin [TImage/BitsPerSample "-bit image"]
			f5/text: rejoin [page "/" NumberOfPages]
			either NumberOfPages = 1 [f5/visible?: sl/visible?: false] [f5/visible?: sl/visible?: true]   
			sb1/text: to-string tmpf
			sb2/text: rejoin ["Loaded and displayed in " form 1000.0 * round/to third now/time/precise - t1 0.001 " ms"]
			sl/data: 0%
 			isFile: true
 		][
 			canvas/image: rcvLoadImage tmpf
 			sb1/text: to-string tmpf sb2/text: "Not a Tiff File" 
 			isFile: false
 		]
	]
]

;***************** Red Program Interface ****************************
view win: layout [
	title "TIFF File reading"
	origin margins space margins
	button 100 "Load TIFF" 	[loadImage]	
	f1: field 130
	f2: field 120	
	f3: field 130
	f4: field 120	
	pad 300x0
	button 70 "Quit" 			[Quit]
	return 
	sb1: field 768
	sb2: field 256	
	return
	canvas:  base gsize img
	tags: text-list  gsize
	return
	sl: slider 400 [if isFile [
			page: to-integer  1 + (sl/data * (NumberOfPages - 1))
			f5/text: rejoin [page "/" NumberOfPages]
			rcvReadTiffImageData page
			tags/data: tagList
			canvas/image: rcvTiff2RedImage
		]
	]
	f5: field 100 right
	do [f5/visible?: sl/visible?: false]	
]
