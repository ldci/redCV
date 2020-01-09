Red [
	Title:   "Sort test "
	Author:  "Francois Jouen"
	File: 	 %sortImage1.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/math/rcvStats.red	

isFile: false
size: 400x400
reverse: false
flag: 1

loadImage: does [
    isFile: false
	tmp: request-file
	if not none? tmp [
		img1: rcvloadImage tmp
		img2: make image! reduce [img1/size black]
		canvas1/image: img1
		canvas2/image: img2
		isFile: true
		process
	]
]

process: does [
	if isFile [
		rcvSortImage img1 img2
		canvas2/image: img2
	]
]


view win: layout [
	title "Sorting Images"
	button "Load" [loadImage]
	button "Quit" [quit]
	return
	canvas1: base size black
	canvas2: base size black
	return
	text 150 "© Red Foundation 2019"
]