#!/usr/local/bin/red
Red [
	Title:   "Resize test"
	Author:  "Francois Jouen"
	File: 	 %resize3.red
	Needs:	 'View
]

;--'pbs with resizing

loadImage: does [
	tmp: request-file/filter ["Image Files" "*.png;*.jpg;*.bmp"]
	unless none? tmp [
		offset: canvas/offset + 10
		img: load tmp
		canvas/size: img/size
		mainWin/size: img/size + offset
		f/text: form canvas/size
		canvas/image: img
	]
]

mainWin: layout [
	title "Resizing Image"
	button "Load Image" [loadImage]
	text 70 "Image Size"
	f: field 70 "320x240"
	button "Quit" [quit] return
	canvas: base 320x240 black
]

;--Thanks to Gregg Irwin  
;--resize event processing
;--this should be modified: (Runtime Error 1: access violation)
view/flags/options mainWin [resize] [
    actors: object [
        	on-resizing: function [face [object!] event [event!]
        	][
            	win: face
            	;--create runtime error for some files
            	canvas/size: win/size - offset	
            	;--seems to be specific to macOS
            	f/text: form canvas/size
        	]
    ]
]