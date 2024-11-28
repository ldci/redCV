Red [
	Title:   "Draw tests "
	Author:  "Francois Jouen"
	File: 	 %DrawOnImage.red
	Needs:	 'View
]

img: make image! reduce [512x512 white]
isFile: false
margins: 5x5

plot: copy [line-width 2 pen red line 0x0 512x512 pen off pen green line 0x512 512x0 
	box 10x10 50x50 box 55x55 75X75 text 210x5 "Hello Red"
]

loadImage: function [ n [integer!] return: [image!]]
[
	tmp: request-file
	if not none? tmp [
		img: load tmp
	]
	img
]



view win: layout [
		title "Image Tests"
		origin margins space margins
		button "Load" 		[img: loadImage 1 isFile: true 
							canvas/image: img
							sbar/data: length? img/rgb]
		button 60 "Draw" 	[if isFile [canvas/image: draw img plot]]
		button 60 "Quit" 	[Quit]
		return 
		canvas: base 512x512 img
		return
		sbar: field 250
]
