Red [
	Title:   "Wave test "
	Author:  "Francois Jouen"
	File: 	 %ImageWave1.red
	Needs:	 'View
]

#include %../../libs/redcv.red ; for redCV functions
margins: 5x10
img1: rcvCreateImage 512x512
dst:  rcvCreateImage img1/size
alpha: 20.0
beta: 128.0
op: 1

loadImage: does [
	tmp: request-file
	if not none? tmp [
		canvas/image/rgb: black
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		bb/image: img1
		canvas/image: dst
		process
	]
]

process: does [
	canvas/image/rgb: black
	if op = 1 [rcvWaveH img1 dst alpha beta]
	if op = 2 [rcvWaveV img1 dst alpha beta] 
	canvas/image: dst
]



; ***************** Test Program ****************************

view win: layout [
	title "Wave Test"
	origin margins space margins
	button 60 "Load"		[loadImage] 
	pad 65x0
	text 60 "Wave"
	drop-down 40 data ["1" "2"] 
			on-change [op: face/selected process]
			select 1
	text 60 "Alpha "
	aF: field 50 "20.0"		[if error? try [alpha: to-float af/text] [alpha: 8.0] process]
	text 60 "Beta"
	bF: field 50 "128.0"	[if error? try [beta: to-float bf/text] [alpha: 128.0] process]
	pad 100x0
	button 50 "Quit" 		[rcvReleaseImage img1 dst Quit]
	return
	bb: base 128x128 img1 
	canvas: base 512x512 dst
]

