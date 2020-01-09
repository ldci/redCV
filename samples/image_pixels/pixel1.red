Red [
	Title:   "Pixels test "
	Author:  "Francois Jouen"
	File: 	 %pixel1.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/tiff/rcvTiff.red	

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
;drawRect: compose [line-width 2 pen red box 0x0 24x24 line 0X0 0x24 24x0]
drawRect: [line-width 2 pen blue fill-pen green triangle 0X0 24x0 0x24]



loadImage: does [
    isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
	; reads also tiff images :)
		if error? try [img1: rcvLoadImage tmp]
					  [ret: rcvLoadTiffImage tmp
					  if ret [img1: rcvTiff2RedImage]		   
		] 
	
		dst:  rcvCloneImage img1
		canvas/image: dst
		dst: to-image canvas ; force image in 512x512
		p1/draw: drawRect
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Image Pixel As Tuple"
		style rect: base 255.255.255.240 24x24 loose draw []
		button "Load Image" [loadImage] 
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst react [
					pos: p1/offset - winBorder
					if (pos > rLimit) and (pos < lLimit)
					[	s: form pos
						append append s " : " form rcvGetPixel dst pos
						f/text: s
					]
		]
		
		return
		f: field 512
		at winBorder p1: rect
		do [p1/draw: drawRect]
]
