#! /usr/local/bin/red
Red [
	Title:   "Test image operators Red VID "
	Author:  "ldci"
	File: 	 %redChannels.red
	Needs:	 'View
]

;--'version without redCV is pretty slow but illustrates how Red extract is powerfull

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
	unless none? tmp [		
		fileName: to string! to-local-file tmp	
		rimg: load tmp	
		canvas/image: rimg
		isFile: true
	]
]

splitImage: function[][
	if isFile [
		t1: now/time/precise
		rgb1: extract/index rimg/rgb 3 1			;--r channel values
		rgb2: extract/index rimg/rgb 3 2			;--g channel values
		rgb3: extract/index rimg/rgb 3 3			;--b channel values
		rgb: copy #{}								;--make r channel image
		foreach v rgb1 [append/dup rgb v 3 ]
		imgR: make image! reduce [rimg/size rgb]
		rgb: copy #{}								;--make g channel image
		foreach v rgb2 [append/dup rgb v 3]
		imgG: make image! reduce [rimg/size rgb]
		rgb: copy #{}								;--make b channel image
		foreach v rgb3 [append/dup rgb v 3]
		imgB: make image! reduce [rimg/size rgb]
		canvasR/image: imgR							;--show result
		canvasG/image: imgG							;--show result
		canvasB/image: imgB							;--show result
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