Red [
	Title:   "pbm Image Reader "
	Author:  "Francois Jouen"
	File: 	 %pbmImageReader.red
	Needs:	 'View
]

; required libs
#include %../../libs/pbm/rcvPbm.red


magicN: 	#{5000}
colorMax: 	0.0
imgComment: copy ""
img: make image! 10x10


loadImage: does [
	tmpF: request-file
	if not none? tmpF [
		canvas/image: none
		f0/text: ""
		f1/text: ""
		f2/text: ""
		f3/text: ""
		magicN: rcvGetMagicNumberPBM tmpF
		f0/text: to-string magicN
		if any [magicN = MAGIC_P5 magicN = MAGIC_P6][
			img: rcvReadPBMByteFile tmpF magicN
		]
		if any [magicN = MAGIC_P1 magicN = MAGIC_P2 magicN = MAGIC_P3][
			img: rcvReadPBMAsciiFile tmpF magicN
		]
		showImage
	]
]

showImage: does [
	f1/text: form imgComment
	f2/text: form img/size
	f3/text: form colorMax 
	if cb/data [
		canvas/size: img/size
		mainWin/size/x: canvas/size/x + 20
		mainWin/size/y: canvas/size/y + 90
		mainWin/offset/x: (system/view/screens/1/size/x) / 2 - (mainWin/size/x / 2)
		mainWin/offset/y: (system/view/screens/1/size/y) / 2 - (mainWin/size/y / 2)
	]
	canvas/image: img
]


mainWin: layout [
	title "Reading PBM Files"
	button "Load" 	[loadImage]
	cb: check "Scale Image" 
	button "Quit"	[Quit]
	return 
	f0: field 50
	f1: field 280
	f2: field 100
	f3: field 50
	return
	canvas: base 512x512
]
view mainWin


 



