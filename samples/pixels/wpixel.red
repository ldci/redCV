Red [
	Title:   "Pixels test "
	Author:  "Francois Jouen"
	File: 	 %pixel2.red
	Needs:	 'View
]


#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
winBorder: 10x50
rLimit: 0x0
lLimit: 512x512
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
					if (pos > rLimit) and (pos < lLimit)
					[	
						rcvSetPixel dst pos green
						rcvPokePixel dst pos + 10 yellow
						canvas/image: dst
					]
		]
		
		at winBorder p1: rect
		do [p1/draw: drawRect]
]
