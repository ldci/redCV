Red [
	Title:   "Test images operators Red VID "
	Author:  "ldci - DidC"
	File: 	 %opimage.red
	Version: 2.0.0
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvColorSpace.red
#include %../../libs/imgproc/rcvImgEffect.red
#include %../../libs/imgproc/rcvGaussian.red
#include %../../libs/math/rcvStats.red	

dst: make image! reduce [512x512 black]
isFile: false
margins: 10x10

loadImage: does [
	isFile: false
	canvas/image: none
	tmp: request-file
	if not none? tmp [
		t1: now/time/precise
		rimg:  rcvLoadImage  tmp
		dst: rcvCloneImage rimg
		testimg: rcvCloneImage rimg
		rimg2: rcvRandomImage/uniform rimg/size 255.255.255
		; if image does not fit screen, scale it
		scale: max 1 1 + max (2 * margins/x + rimg/size/x) / system/view/screens/1/size/x (4 * margins/y + sInfo/size/y + op1/size/y + rimg/size/y) / system/view/screens/1/size/y
		win/text: append append append to string! to-file tmp "(1:" scale ")"
		; redim window with min size
		win/size/x: to-integer (2 * margins/x + max 500 rimg/size/x / to-integer scale)
		win/size/y: to-integer (4 * margins/y + sInfo/size/y + op1/size/y + max 150 rimg/size/y / to-integer scale)
		; redim image view
		canvas/size: rimg/size / to-integer scale
		canvas/image: dst
		; update bottom positions and infos
		sInfo/offset/y: win/size/y - margins/y - 30 ;- sInfo/size/y 
		sBar1/text: form rimg/size
		sBar2/text: form rcvMean rimg
		sBar21/text: form rcvSTD rimg
		sBar3/text: form scale
		win/size/y: win/size/y + 50
		sBar4/data: third now/time/precise - t1
		isFile: true
		; reset operation selectors to none
		do-operation none
	]
	;show win
]

; List of operations
operations: [
	conversion [
		"Conversions"			[rcvCopyImage rimg dst]
		"GrayScale/Average"		[rcv2Gray/average rimg dst]
		"GrayScale/Luminosity"	[rcv2Gray/luminosity rimg dst]
		"GrayScale/lightness"	[rcv2Gray/lightness rimg dst]
		"Black and White"		[rcv2BW rimg dst]
		"White and Black"		[rcv2WB rimg dst]
		"Red Channel"			[rcvSplit/red rimg dst]
		"Green Channel"			[rcvSplit/green rimg dst]
		"Blue Channel"			[rcvSplit/blue rimg dst]
		"RGB => IRgBy"			[rcvIRgBy rimg dst 255]
		"RGB => BGR"			[rcv2BGRA rimg dst]
		"RBG => XYZ"			[rcvRGB2XYZ rimg testimg rcvCopyImage testimg dst]
		"XYZ => RGB"			[rcvXYZ2RGB testimg dst ]
		"Left Right Flip"		[rcvFlip/horizontal rimg dst]
		"Up Down Flip"			[rcvFlip/vertical rimg dst]
		"Both Flips"			[rcvFlip/both rimg dst]
	]
	logical [
		"Logical"	  			[rcvCopyImage rimg dst]
		"And Images"			[rcvAND rimg rimg2 dst]
		"Nand images"			[rcvNAND rimg rimg2 dst]
		"Or Images"				[rcvOR rimg rimg2 dst]
		"Nor Images"			[rcvNOR rimg rimg2 dst]
		"Xor Images"			[rcvXOR rimg rimg2 dst]
		"NXor Images"			[rcvNXor rimg rimg2 dst]
		"Not Image"				[rcvNot rimg dst]
		"And Red"				[rcvAndS rimg dst 255.0.0.0]
		"And Green"				[rcvAndS rimg dst 0.255.0.0]
		"And Blue"				[rcvAndS rimg dst 0.0.255.0]
		"Or Green"				[rcvORS rimg dst 0.255.0.0]
		"Xor Green"				[rcvXORS rimg dst 0.255.0.0]
		"Min Images"			[rcvMin rimg2 rimg dst]
		"Max Images"			[rcvMax rimg2 rimg dst]
		"Invert Image"			[rcvInvert rimg dst]
	]
	math [
		"Math"					[rcvCopyImage rimg dst]
		"Add Images"			[rcvAdd rimg rimg2 dst]
		"Substract Images"		[rcvSub rimg2 rimg dst]
		"Multiply Images"		[rcvMul rimg rimg2 dst]
		"Divide Images"			[rcvDiv rimg rimg2 dst]
		"Modulo images"			[rcvMod rimg rimg2 dst]
		"Remainder Images"		[rcvRem rimg rimg2 dst]
		"Add Scalar (128)"		[rcvAddS rimg dst 128]
		"Substract Scalar (64)"	[rcvSubS rimg dst 64]
		"Multiply by 2"			[rcvMulS rimg dst 2]
		"Divide by 2"			[rcvDivS rimg dst 2]
		"Modulo 128"			[rcvModS rimg dst 128]
		"Remainder 2"			[rcvRemS rimg dst 64]
		"Power 2"				[rcvPow rimg dst 2]
		"Left Shift 2" 			[rcvLSH rimg dst 2]
		"Right Shift 4"			[rcvRSH rimg dst 4]
		"Add 128.128.128.0"		[rcvAddT rimg dst 128.128.128 false]
		"Sub 128.128.128.0"		[rcvSubT rimg dst 128.128.128 false]
		"Abs Diff Images"		[rcvAbsDiff rimg rimg2 dst]
	]
]

do-operation: func [face [object! none!]] [
	; reset all combo to 1 but the used one
	foreach combo [op1 op2 op3] [unless same? face combo: get combo [combo/selected: 1]]
	;show win
	; no image: exit
	if any [not isFile  none? face] [exit]
	num: face/selected
	ope: face/extra
	; apply the chosen treatment
	t1: now/time/precise
	;canvas/image: do select operations/:ope face/data/:num
	do select operations/:ope face/data/:num
	sBar4/data: third now/time/precise - t1
	;show win
	
]

view win: layout [
	title "Operators test"
	origin margins space margins

	style btn: button 50; -1x26
	
	style drop-d: drop-down 120x24 
		on-create [
			ope: face/extra
			face/data: extract operations/:ope 2
			face/selected: 1
		] 
		on-change [do-operation face face/extra]
		
	style fld: field 100x20
	style txt: text middle -1x20

	btn "Load" [loadImage]
	op1: drop-d do  [op1/extra: 'conversion]
	op2: drop-d do [op2/extra: 'logical]
	op3: drop-d do [op3/extra: 'math]
	btn "Quit" [quit]
	return
	canvas: base dst 
	return
	sInfo: panel [origin 0x0 txt 70 "Image size:" sBar1: fld 80 
			txt 70 "Mean/SD:" sBar2: fld 75 sBar21: fld 75
			txt 40 "Scale:" sBar3: fld 30x20
			return
			txt 70 "Rendered:  " sBar4: fld 80
	]
	
]