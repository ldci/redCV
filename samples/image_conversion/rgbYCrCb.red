#!/usr/local/bin/red-view
Red [
	Author: "ldci"
	Needs: 	view
]

;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvColorSpace.red

;--RBG <->YCrCb conversion
;--we use OpenCV equations

delta: 128	;--solve problems with negative numbers by adding 128 to them
{
	delta: 
	128 for 8-bit images
	32768 for 16-bit images
	0.5 for floating-point images 
}

margins: 2x2
size: 512x512
m1: copy []  
m2: copy []
isFile?: false

loadImage: does [
	canvas/image: black
	tmp: request-file
	unless none? tmp [
		img1: load tmp
		img2: copy img1
		img3: copy img1
		canvas/image: img1
		f/text: rejoin ["Image Size: "  form img1/size]
		isFile?: true 
		bt1/enabled?: true
	]
]
;--RGB->YCrCb
;--Input range 0..255
;--Output range 0..255

toYCrCb: function[] [
	clear m1 
	tt: dt [
		rcvRGB2YCrCb img1 img2
		canvas/image: img2
	]
	bt2/enabled?: true
	bt3/enabled?: true
	msec:  (round/to third tt 0.01) * 1000
	f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
]

;--YCrCb->RGB
toRGB: function[] [
	clear m2
	tt: dt [
		rcvYCrCb2RGB img2 img3 
		canvas/image: img3
	]
	msec:  (round/to third tt 0.01) * 1000 
	f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
]

toBGR: function[] [
	clear m2
	tt: dt [
		rcvYCrCb2BGR img2 img3 
		canvas/image: img3
	]
	msec:  (round/to third tt 0.01) * 1000 
	f/text: rejoin ["Image Size: "  form img1/size " in: " msec " msec"]
]


; ***************** Test Program ****************************
view win: layout [
		title "RGB <> YCrCb"
		origin margins space margins
		across
		bt0: button 100 "Load RGB"		[loadImage]
		bt1: button 110 "RGB -> YCrCb"	[if isfile? [toYCrCb]]
		bt2: button 110 "YCrCb->BGR"	[if isfile? [toBGR]]
		bt3:  button 110 "YCrCb->Color"	[if isfile? [toRGB]]
		button 50 "Quit" 				[Quit]
		return
		canvas: base size
		return 
		f: field 512
		do [bt1/enabled?: bt2/enabled?: bt3/enabled?: false]
]