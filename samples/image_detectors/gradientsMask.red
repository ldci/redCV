#! /usr/local/bin/red
Red [
	Title:   "Gradient Filter "
	Author:  "ldci"
	File: 	 %gradientsMask.red
	Needs:	 View
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red



isFile: false
dir: 1
gdir: ["North" "Northeast" "East" "Southeast" "South" "Southwest" "West" "Northwest"]
loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: rejoin ["Gradient Masks: " fileName]
		rimg1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		currentImage: rcvCreateImage rimg1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage rimg1]
		rimg2:  rcvCloneImage currentImage
		canvas1/image: rimg1
		f1/text: form rimg1/size
		dp/selected: 1
		dir: 1
		isFile: true
		process
	]
]

process: does [
	t1: now/time/precise
	rcvGradientMasks currentImage rimg2 dir
	canvas2/image: rimg2
	t2: now/time/precise
	f2/text: rejoin ["Rendered in : " form round/to ((third t2 - t1) * 1000.0) 0.01 " msec"]
]


quitRequested: does [
	if isFile [
		rcvReleaseImage rimg1
		rcvReleaseImage rimg2
		rcvReleaseImage gray
		rcvReleaseImage currentImage
	]
	quit
]


view win: layout [
	title "Gradient Masks"
	origin 10x10 space 10x10
	button "Load" [loadImage]
	cb: check "Grayscale" [either cb/data [currentImage: rcvCloneImage gray]
					   			[currentImage: rcvCloneImage rimg1]
					   			process]
	text "Gradient Direction" 
	dp: drop-down data gdir on-change [
		dir: to-integer face/selected
		if isFile [process]
	]
	select 1
	pad 310x0
	button "Quit" [quitRequested]
	return
	canvas1: base 256x256
	canvas2: base 512x512
	return
	text 256 "© Red Foundation 2019"
	f1: field 100
	f2: field 412 "Rendered"
]

