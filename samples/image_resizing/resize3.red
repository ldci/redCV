#!/usr/local/bin/red
Red [
	Title:   "Resize test"
	Author:  "Francois Jouen"
	File: 	 %resize3.red
	Needs:	 'View
]

_offset: 0x0

loadImage: does [
	tmp: request-file/filter ["Image Files" "*.png;*.jpg;*.bmp"]
	if not none? tmp [
		_offset: canvas/offset + 10
		img: load tmp
		canvas/size: img/size
		mainWin/size: _offset + img/size
		f/text: form canvas/size
		canvas/image: img
	]
]

mainWin: layout [
	title "Resizing Image"
	button "Load Image" [loadImage]
	f: field 70 "256x256"
	button "Quit" [quit] return
	canvas: base 256x256 black
]

;--Thanks to Gregg Irwin  
;--resize event processing
view/flags/options mainWin [resize] [
    actors: object [
        	on-resizing: function [face [object!] event [event!]
        	][
            	win: face
            	canvas/size: win/size - _offset
            	f/text: form canvas/size
        	]
    ]
]