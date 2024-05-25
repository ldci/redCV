Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %redCVChannels.red
	Needs:	 'View
]

;--similar to redChannels.red but uses redCV routines and is faster

;required libs
#include %../../libs/core/rcvCore.red

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
		imgR: make image! reduce [rimg/size black]	;--r channel image
		imgG: make image! reduce [rimg/size black]	;--g channel image
		imgB: make image! reduce [rimg/size black]	;--b channel image
		isFile: true
	]
]

splitImage: function[][
	if isFile [
		t1: now/time/precise
		rcvSplit/red rimg imgR		;--redCV routine r channel
		rcvSplit/green rimg imgG	;--redCV routine g channel
		rcvSplit/blue rimg imgB		;--redCV routine b channel
		canvasR/image: imgR			;--show result
		canvasG/image: imgG			;--show result
		canvasB/image: imgB			;--show result		
		t2: now/time/precise
		t: t2 - t1
		te:  round (third t * 1000) 0.01
		sb1/text: rejoin [ "Rendered in " form te  " ms"]
	]	
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test with redCV"
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