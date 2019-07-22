#! /usr/local/bin/red
Red [
	Title:   "Line Detector "
	Author:  "Francois Jouen"
	File: 	 %lineDetector.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for redCV functions

isFile: false
dir: 1
gdir: ["Horizontal" "Vertical" "Left Diagonal" "Right Diagonal"]
iSize: 0x0
loadImage: does [
	isFile: false
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-file tmp
		win/text: rejoin ["Line Detection: " fileName]
		rimg1: rcvLoadImage tmp
		gray: rcvLoadImage/grayscale tmp
		currentImage: rcvCreateImage rimg1/size
		either cb/data [currentImage: rcvCloneImage gray]
					   [currentImage: rcvCloneImage rimg1]
		iSize: currentImage/size
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
	rcvLineDetection currentImage rimg2 iSize dir
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
	title "Line Detection"
	origin 10x10 space 10x10
	button "Load" [loadImage]
	cb: check "Grayscale" [either cb/data [currentImage: rcvCloneImage gray]
					   			[currentImage: rcvCloneImage rimg1]
					   			process]
	text "Direction"
	dp: drop-down 120 data gdir on-change [
		dir: to-integer face/selected
		if isFile [process]
	]
	select 1
	
	pad 325x0
	button "Quit" [Quit]
	return
	canvas1: base 256x256
	canvas2: base 512x512
	return
	text 256 "© Red Foundation 2019"
	f1: field 100
	f2: field 412 "Rendered"
]

