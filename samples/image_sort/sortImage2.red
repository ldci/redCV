Red [
	Title:   "Sort test "
	Author:  "Francois Jouen"
	File: 	 %sortImage2.red
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
		if flag = 1 [rcvXSortImage img1 img2 reverse]
		if flag = 2 [rcvYSortImage img1 img2 reverse]
	canvas2/image: img2
	]
]


view win: layout [
	title "Sorting Images"
	button "Load" [loadImage]
	r1: radio "Lines" true [flag: 1 process]
	r2: radio "Columns" [flag: 2 process]
	cb: check "Reverse" [reverse: face/data process]
	pad 400x0
	button "Quit" [quit]
	return
	canvas1: base size black
	canvas2: base size black
	return
	text 150 "© Red Foundation 2019"
]