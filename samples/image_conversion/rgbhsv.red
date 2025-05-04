Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbhsv.red
	Needs:	 'View
]


;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

;************************* Test Program ****************************

margins: 5x5
size: 512x512
isFile?: false
m1: copy []
img: none!

RGB2HSV: does [
	tt: dt [m1: rcvRGB2HSVb img]
	canvas/image: rcvRGB2HSVImage img
	msec:  (round/to third tt 0.01) * 1000 	
	f/text: rejoin ["Image Size: "  form img/size " in: " msec " msec"]
	bt3/enabled?: true
]

BGR2HSV: does [
	tt: dt [m1: rcvBGR2HSVb img]
	canvas/image: rcvBGR2HSVImage img
	msec: (round/to third tt 0.01) * 1000
	f/text: rejoin ["Image Size: "  form img/size " in: " msec " msec"]
	bt3/enabled?: true
]

HSV2BGR: does [
	tt: dt [canvas/image: rcvHSV2RGBb img m1]
	msec: (round/to third tt 0.01) * 1000
	f/text: rejoin ["Image Size: "  form img/size " in: " msec " msec"]
]


loadImage: does [
	canvas/image: black
	tmp: request-file
	unless none? tmp [
		img: load tmp
		canvas/image: img
		f/text: rejoin ["Image Size: "  form img/size]
		isFile?: true 
		bt1/enabled?: bt2/enabled?: true
	]
]

view win: layout [
		title "RGB <-> HSV"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 100 "RGB -> HSV"	[if isfile? [RGB2HSV]]
		bt2: button 100 "BGR -> HSV"	[if isfile? [BGR2HSV]]
		bt3: button 100 "HSV -> Color"	[if isfile? [HSV2BGR]]
		pad 10x0
		button 60 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: bt3/enabled?: false]
]
