Red [
	Title:   "Test image operators Red VID "
	Author:  "Francois Jouen"
	File: 	 %channels.red
	Needs:	 'View
]

;
fileName: ""
isFile: false


;interface 
rimg: make image!  reduce [512x512 black]


loadImage: does [	
	isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file 
	if not none? tmp [		
		fileName: to string! to-local-file tmp	
		win/text: fileName
		rimg: load tmp	
		; update faces
		win/size/x: rimg/size/x + 20
		win/size/y: rimg/size/y + 50
		canvas/size/x: rimg/size/x
		canvas/size/y: rimg/size/y
		canvas/image/size: canvas/size	
		canvas/image: rimg
		isFile: true
		]
]

split: function[source [image!] channel [integer!] return: [image!]][
	rgb1: extract/index source/rgb 3 1
	rgb2: extract/index source/rgb 3 2
	rgb3: extract/index source/rgb 3 3
	rgb: rgb1 
	append rgb rgb2
	append rgb rgb3
	w: round(source/size/x / 1)
	h: round(source/size/y / 1)
	make image! reduce [as-pair w h rgb]
]


btnLoad: make face! [
	type: 'button text: "Load" offset: 10x10 size: 60x22
	actors: object [
			on-click: func [face [object!] event [event!]][loadImage]
	]
]

btnConv: make face! [
	type: 'button text: "Split" offset: 80x10 size: 60x22
	actors: object [
			on-click: func [face [object!] event [event!]][ 
			canvas/image: split rimg 3
			]
	]
]



btnQuit: make face! [
	type: 'button text: "Close" offset: 470x10 size: 50x22
	actors: object [
			on-click: func [face [object!] event [event!]][quit]
	]
]


canvas: make face! [
	type: 'base offset: 10x40 size: 512x512
	image: rimg
]


win: make face! [
	type: 'window text: "Red View" size: 532x580
	pane:  []
]


append win/pane btnLoad
append win/pane btnConv
append win/pane btnQuit
append win/pane canvas
view win