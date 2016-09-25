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
rcvNamedWindow: function [title [string!] return: [window!]
"Creates a window"
][
	win: layout [
		title title
		canvas: image 256x256 black
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
	window/size: window/pane/1/size + 20x20
]

rcvMoveWindow: function [window [face!] position [pair!]
"Sets window position"
][
	window/offset: position
]

rcvShowImage: function [window [face!] image [image!]
"Shows image in window"
] [
	window/pane/1/image: image
	show window
]


