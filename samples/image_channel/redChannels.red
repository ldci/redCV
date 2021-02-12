#! /usr/local/bin/red
Red [
	Title:   "Test image operators Red VID "
	Author:  "Francois Jouen"
	File: 	 %channels.red
	Needs:	 'View
]

;' version without redCV but is really slow

fileName: ""
isFile: false
margins: 10x10
gSize: 256x256


loadImage: does [	
	isFile: false
	canvas/image: none
	canvasR/image: none
	canvasG/image: none
	canvasB/image: none
	sb1/text: ""
	tmp: request-file 
	if not none? tmp [		
		fileName: to string! to-local-file tmp	
		rimg: load tmp	
		canvas/image: rimg
		isFile: true
	]
]

splitImage: function[][
	if isFile [
		t1: now/time/precise
		rgb1: extract/index rimg/rgb 3 1
		rgb2: extract/index rimg/rgb 3 2
		rgb3: extract/index rimg/rgb 3 3
		rgb: copy #{}
		foreach v rgb1 [append/dup rgb v 3 ]
		imgR: make image! reduce [rimg/size rgb]
		rgb: copy #{}
		foreach v rgb2 [append/dup rgb v 3]
		imgG: make image! reduce [rimg/size rgb]
		rgb: copy #{}
		foreach v rgb3 [append/dup rgb v 3]
		imgB: make image! reduce [rimg/size rgb]
		canvasR/image: imgR
		canvasG/image: imgG
		canvasB/image: imgB
		sb1/text: copy "Rendered in "
		append sb1/text form now/time/precise - t1
	]	
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test with Red"
		origin margins space margins
		button 60 "Load"	[loadImage]
		button 60 "Split"	[splitImage]
		button 60 "Quit" 	[Quit]
		return 
		text 256  "Source"
		text 256  "Red"
		text 256  "Green"
		text 256  "Blue"
		return
		canvas:  base gSize black	
		canvasR: base gSize red
		canvasG: base gSize green
		canvasB: base gSize blue
		return
		sb1: field  1054
]