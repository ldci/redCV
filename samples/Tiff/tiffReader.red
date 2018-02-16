#! /usr/local/bin/red
Red [
	Title:   "TIFF"
	Author:  "Francois Jouen"
	File: 	 %tiffReader.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for red functions
; **************test program variables and functions*********
dSize: 512
gsize: as-pair dSize dSize
img: make image! reduce [gSize black]


isFile: false

loadImage: does [
	canvas/image: black
	f1/text: f2/text: f3/text: f4/text: ""
	sb1/text: sb2/text: ""
	clear tags/data
	tmpf: request-file; /filter ["*.tif" "*.tiff"]
	isFile: false
	if not none? tmpf [
		;process tiff file and first image (page)
		page: 1
		t1: now/time/precise
		ret: rcvLoadTiffImage tmpf
		either ret [
			canvas/image: rcvTiff2RedImage 
			t2: now/time/precise
			; for tags visualisation
			tags/data: tagList
			f1/text: rejoin ["Byte Order: " form byteOrder]
			f2/text: rejoin ["Image: " ImageType]
			either NumberOfPages = 1 [str: " page" ] [str: " pages"]
			f3/text: rejoin [to-string NumberOfPages str]
			f4/text: form page
			either NumberOfPages = 1 [f4/visible?: sl/visible?: false] [f4/visible?: sl/visible?: true]   
			sb1/text: to-string tmpf
			sb2/text: rejoin ["Loaded and displayed in " form t2 - t1]
			sl/data: 0%
 			isFile: true
 		] [sb1/text: to-string tmpf sb2/text: "Not a Tiff File" isFile: false]
	]
]

;***************** Red Program Interface ****************************
view win: layout [
	title "TIFF File reading"
	button 100 "Load TIFF" 	[loadImage]	
	f1: field 130
	f2: field 120	
	f3: field 120	
	pad 440x0
	button 70 "Quit" 			[Quit]
	return
	canvas:  base gsize img
	tags: text-list  gsize
	return
	sl: slider 440 [if isFile [
			page: to-integer  1 + (sl/data * (NumberOfPages - 1))
			f4/text: form page
			rcvReadTiffImageData page
			tags/data: tagList
			canvas/image: rcvTiff2RedImage
		]
	]
	f4: field 60
	return 
	sb1: field 768
	sb2: field 246		
]
