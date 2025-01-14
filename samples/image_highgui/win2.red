#! /usr/local/bin/red-view
Red [
	Title:   "Red Computer Vision: Highgui tests"
	Author:  "Francois Jouen"
	File: 	 %win2.red
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
	Needs:	 'View
]
img1: load %../../images/mandrill.jpg

margins: 10x10

title: "Resize "
append title form to-local-file %mandrill.jpg
win: layout [
		title title
		origin margins space margins
		image img1
]

view/flags/no-wait win 'resize

; Handles the resize of window content when resized

insert-event-func 'newsize [
	if event/type = 'resize [
		win/pane/1/size: win/size - (margins * 2) 
	]
]

do-events
