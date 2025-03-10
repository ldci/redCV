Red [
	Title:   "Conversions Operators "
	Author:  "ldci"
	File: 	 %rgbhsl.red
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

RGB2HSL: does [
	tt: dt [m1: rcvRGB2HSLb img]
	canvas/image: rcvRGB2HSLImage img
	msec:  (round/to third tt 0.01) * 1000 	
	f/text: rejoin ["Image Size: "  form img/size " in: " msec " msec"]
	bt3/enabled?: true
]

BGR2HSL: does [
	tt: dt [m1: rcvBGR2HSLb img]
	canvas/image: rcvBGR2HSLImage img
	msec: (round/to third tt 0.01) * 1000
	f/text: rejoin ["Image Size: "  form img/size " in: " msec " msec"]
	bt3/enabled?: true
]

HSL2BGR: does [
	tt: dt [canvas/image: rcvHSL2RGBb img m1]
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
		title "RGB <-> HSL"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 100 "RGB -> HSL"	[if isfile? [RGB2HSL]]
		bt2: button 100 "BGR -> HSL"	[if isfile? [BGR2HSL]]
		bt3: button 100 "HSL -> Color"	[if isfile? [HSL2BGR]]
		pad 10x0
		button 60 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: bt3/enabled?: false]
]
