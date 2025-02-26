Red [
	Title:   "Pixels test "
	Author:  "ldci"
	File: 	 %wpixel.red
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
rLimit: 512x512 - 4
lLimit: 0x0
tp: 0.0.0
canvas: none
drawRect: compose [line-width 3 pen red circle 8x8 8]


; ***************** Test Program ****************************
view win: layout [
		title "Write Pixels"
		style rect: base 255.255.255.240 24x24 loose draw []
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst react [
					pos: p1/offset - winBorder
					ppos: rcv2pair pos
					if all [pos/x >= lLimit/x pos/y >= lLimit/y
						pos/x < rLimit/x pos/y < rLimit/y
					]
					[rcvSetPixel dst ppos green rcvPokePixel dst ppos + 5 red
					canvas/image: dst
					]
		]
		at winBorder p1: rect
		do [p1/draw: drawRect]
]
