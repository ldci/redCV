Red [
	Title:   "Test images operators Red VID "
	Author:  "Francois Jouen - Didier Cadieu"
	File: 	 %opimage.red
	Needs:	 'View
]

;
fileName: ""
isFile: false

; all we need for computer vision with red
#include %libs/redcv.red ; for red functions


;interface
rimg: make image!  reduce [512x512 black]
rimg2: make image! reduce [512x512 black]

showTuple: function [ val [tuple!] return: [string!]][
	n: length? val
	s: copy ""
	append s reduce [val/1 "." val/2 "." val/3]
	if n = 4 [append s reduce ["." val/4]]
]

loadImage: does [
	isFile: false
	canvas/image/rgb: black
	canvas/size: 0x0
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		win/text: fileName
		rimg: load tmp
		;generate random image
		rimg2: rcvRandom rimg/size 127.127.100.0
		testimg: rcvRandom rimg/size 255.255.255.0
		; update faces
		if rimg/size/x >= 512 [
			win/size/x: rimg/size/x + 20
			win/size/y: rimg/size/y + 80
		] 
		canvas/size/x: rimg/size/x
		canvas/size/y: rimg/size/y
		canvas/image/size: canvas/size	
		canvas/offset/x: (win/size/x - rimg/size/x) / 2
		;canvas/offset/y: 40 + (win/size/y - rimg/size/y) / 2
		sBar1/offset/y: win/size/y - 30
		sBar2/offset/y: win/size/y - 30
		s: copy "" 
		append s reduce [rimg/size/x "X" rimg/size/y ]
		sBar1/text: s
		sBar2/text: showTuple rcvMeanImage rimg
		canvas/image: rimg
		isFile: true
		op/selected: 1
		op2/selected: 1
		op3/selected: 1
	]
]

img-convert: func [num [integer!]] [
	op2/selected: 1
	op3/selected: 1
	switch num [
		1 	[canvas/image: rimg]
		2 	[canvas/image: rcv2Gray/average rimg]
		3 	[canvas/image: rcv2Gray/luminosity rimg ]
		4 	[canvas/image: rcv2Gray/lightness rimg ]
		5 	[canvas/image: rcv2BW rimg]
		6	[canvas/image: rcvSplit/red rimg]
		7	[canvas/image: rcvSplit/green rimg]
		8	[canvas/image: rcvSplit/blue rimg]
		9 	[canvas/image: rcv2BGRA rimg]
		10  [canvas/image: rcvRGB2XYZ rimg testimg: canvas/image]
		11 	[canvas/image: rcvXYZ2RGB testimg]
		12  [canvas/image: rcvFlip/vertical rimg]
		13  [canvas/image: rcvFlip/horizontal rimg] 
		14  [canvas/image: rcvFlip/vertical rcvFlip/horizontal rimg]
	]
]

img-logical: func [num [integer!]] [
	op/selected: 1
	op3/selected: 1
	switch num [
			1  [canvas/image: rimg]
			2  [canvas/image: rcvAND rimg rimg2]
			3  [canvas/image: rcvNAND rimg rimg2]
			4  [canvas/image: rcvOR rimg rimg2]
			5  [canvas/image: rcvNOR rimg rimg2]
			6  [canvas/image: rcvXOR rimg rimg2]
			7  [canvas/image: rcvNXor rimg rimg2]
			8  [canvas/image: rcvNot rimg]
			9  [canvas/image: rcvAndS rimg 255.0.0.0]
			10 [canvas/image: rcvAndS rimg 0.255.0.0]
			11 [canvas/image: rcvAndS rimg 0.0.255.0]
			12 [canvas/image: rcvORS rimg 0.255.0.0]
			13 [canvas/image: rcvXORS rimg 0.255.0.0]
			14 [canvas/image: rcvMin rimg2 rimg]
			15 [canvas/image: rcvMax rimg2 rimg]
			16 [canvas/image: rcvInvert rimg]
	]
]

img-math: func [num [integer!]] [
	op/selected: 1
	op2/selected: 1
	switch num [
		1 	[canvas/image: rimg]
		2   [canvas/image: rcvAdd rimg rimg2]
		3   [canvas/image: rcvSub rimg2 rimg]
		4   [canvas/image: rcvMul rimg rimg2]
		5   [canvas/image: rcvDiv rimg rimg2]
		6	[canvas/image: rcvMod rimg rimg2]
		7	[canvas/image: rcvRem rimg rimg2]
		8 	[canvas/image: rcvAddS rimg 128]
		9 	[canvas/image: rcvSubS rimg 64]
		10 	[canvas/image: rcvMulS rimg 2]
		11 	[canvas/image: rcvDivS rimg 2]
		12 	[canvas/image: rcvModS rimg 128]
		13 	[canvas/image: rcvRemS rimg 64]
		14 	[canvas/image: rcvPow rimg 2]
		15 	[canvas/image: rcvLSH rimg 2]
		16 	[canvas/image: rcvRSH rimg 4]
		17 	[canvas/image: rcvAddS rimg 128.128.128.0]
		18 	[canvas/image: rcvSubS rimg 128.128.128.0]
		19  [canvas/image: rcvAbsDiff rimg rimg2]
	]
]

view win: layout [
	title "Red view"
	origin 10x10 space 10x10

	style btn: button -1x22
	style drop-d: drop-down 120x24 on-create [face/selected: 1]

	btn "Load" [loadImage]
	op: drop-d data [
		"Conversions" "GrayScale/Average" "GrayScale/Luminosity" "GrayScale/lightness" 
		"Black and White"  "Red Channel" "Green Channel" "Blue Channel" 
		"RGB => BGR"  "RBG => XYZ"  "XYZ => RGB" "Up Down Flip" "Left Right Flip" "V&H Flip"
	] select 1 on-change [if isFile [img-convert face/selected]]
	op2: drop-d data [
		"Logical" "And Images" "Nand images" "Or Images"  "Nor Images " "Xor Images"  "NXor Images" "Not Image"
		"And Red" "And Green" "And Blue""Or Green" "Xor Green" "Min Images" "Max Images" "Invert Image"
	] select 1 on-change [if isFile [img-logical face/selected]]
	op3: drop-d data [
		"Math" "Add Images" "Substract Images" "Multiply Images" "Divide Images" "Modulo images" "Remainder Images"
		"Add Scalar (128)" "Substract Scalar (64)" "Multiply by 2"
		"Divide by 2" "Modulo 128" "Remainder 2" "Power 2" "Left Shift 2" "Right Shift 4"
		"Add 128.128.128.0" "Sub 128.128.128.0" "Abs Diff Images"
	] select 1 on-change [if isFile [img-math face/selected]]
	btn "Quit" [quit]
	return
	canvas: base rimg
	return
	sbar1: field 100
	sbar2: field 100
]