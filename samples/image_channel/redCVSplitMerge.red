Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %redCVChannels.red
	Needs:	 'View
]
; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
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
	canvasRGB/image: none
	sb1/text: ""
	tmp: request-file 
	if not none? tmp [		
		fileName: to string! to-local-file tmp	
		;win/text: fileName
		rimg: load tmp	
		canvas/image: rimg
		imgR: make image! reduce [rimg/size black]
		imgG: make image! reduce [rimg/size black]
		imgB: make image! reduce [rimg/size black]
		imgRGB: make image! reduce [rimg/size black]
		isFile: true
	]
]

splitImage: function[][
	if isFile [
		t1: now/time/precise
		rcvSplit/red rimg imgR
		rcvSplit/green rimg imgG
		rcvSplit/blue rimg imgB
		canvasR/image: imgR
		canvasG/image: imgG
		canvasB/image: imgB
		sb1/text: copy "Rendered in "
		append sb1/text form round/to third (now/time/precise - t1) * 1000 0.01
		append sb1/text " ms"
	]	
]

mergeImage: function[][
	if isFile [
		t1: now/time/precise
		rcvMerge imgR imgG imgB imgRGB
		canvasRGB/image: imgRGB
		sb1/text: copy "Rendered in "
		append sb1/text form round/to third (now/time/precise - t1) * 1000 0.01
		append sb1/text " ms"
	]	
]

; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test with redCV"
		origin margins space margins
		button 60 "Load"	[loadImage]
		button 60 "Split"	[splitImage]
		button 60 "Merge"	[mergeImage]
		button 60 "Quit" 	[Quit]
		return 
		text 256  "Source"
		text 256  "Red"
		text 256  "Green"
		text 256  "Blue"
		text 256  "RGB"
		return
		canvas:  	base gSize black	
		canvasR: 	base gSize red
		canvasG: 	base gSize green
		canvasB: 	base gSize blue
		canvasRGB: 	base gSize white
		return
		sb1: field  1320
]