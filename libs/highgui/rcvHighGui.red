Red [
	Title:   "Red Computer Vision: Highgui"
	Author:  "Francois Jouen"
	File: 	 %rcvHighGui.red
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

; some highgui functions for RedCV quick test
; routines are not required
; under progress ...
;show window is OK for Win10 but not for mac OS???
; so we use a window resize to update changes


screenSize: system/view/screens/1/size
winBorder: 20x40 ; OK mac OS

rcvNamedWindow: function [title [string!] return: [window!]
"Creates and returns a window"
][
	win: layout [
		title title
		image 256x256
	]
	view/no-wait win
	win
]


rcvDestroyWindow: function [window [face!]
"Destroys a window"
][
	unview/only window
]

rcvDestroyAllWindows: function [
"Destroys all windows"
][
	unview/all
]

rcvResizeWindow: function [window [face!] wSize [pair!] 
"Sets window size"
][
	window/pane/1/size: wSize
	window/size: window/pane/1/size + winBorder
]

rcvMoveWindow: function [window [face!] position [pair!]
"Sets window position"
][
	window/offset: position
]

rcvShowImage: function [window [face!] image [image!] /full
"Shows image in window"
] [
	window/pane/1/image: image
	window/size: window/pane/1/size + winBorder
	show window
]

rcvDrawPlot: function [window [face!] plot [block!] /clear
"Draws in window"
] [
	if clear [window/pane/1/image: black]
	window/pane/1/draw: plot
	show window
]


