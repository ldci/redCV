Red [
	Title:   "Pixels test "
	Author:  "ldci"
	File: 	 %pixel2.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red


margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
winBorder: 10x50
rLimit: 512x512 - 6
lLimit: 0x0
tp: 0
canvas: none
pos: 0x0
drawRect: compose [line-width 2 pen red circle 8x8 8]


loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst: rcvResizeImage img1 512x512 ; force image in 512x512
		canvas/image: dst
		p1/draw: drawRect
		ppos: rcv2pair pos
		b/color: rcvGetPixel dst ppos
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Image Pixel as Integer"
		style rect: base 255.255.255.240 24x24 loose draw []
		button "Load Image" [loadImage] 
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst react [
					pos: p1/offset - winBorder
					ppos: rcv2pair pos
					if all [pos/x >= lLimit/x pos/y >= lLimit/y
						pos/x < rLimit/x pos/y < rLimit/y
					] [	
						tp: rcvGetPixelAsInteger dst ppos
						b/color: rcvGetPixel dst ppos
					]
					s: form pos
					append append s " : " form tp 
					f/text: s
		]
		
		return
		f: field 400 
		b: base 102x20 black
		at winBorder p1: rect
		do [p1/draw: drawRect]
]
