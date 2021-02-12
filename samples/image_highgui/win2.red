Red [
	Title:   "Red Computer Vision: Highgui tests"
	Author:  "Francois Jouen"
	File: 	 %rcvHighGui.red
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 'View
]

img1: load %../../images/lena.jpg
margins: 10x10

title: "Resizes "
append title form to-local-file %../../images/lena.jpg
win: layout [
		title title
		origin margins space margins
		image img1
]

view/flags/no-wait win 'resize

; Handles the resize of window content when resized
insert-event-func [
	if event/type = 'resize [
		win/pane/1/size: win/size - (margins * 2) 
	]
]

do-events
