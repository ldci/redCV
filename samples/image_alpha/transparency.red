Red [
	Title:   "Alpha test "
	Author:  "ldci"
	File: 	 %transparency.red
	Needs:	 'View
]
;required libs
#include %../../libs/core/rcvCore.red

margins: 10x10
img1: rcvCreateImage 512x512
img2: rcvCreateImage 512x512

t: 255


loadImage: does [	
	isFile: false
	canvas/image: none
	tmp: request-file 
	unless none? tmp [		
		img1: load tmp	
		img2: rcvCreateImage img1/size
		rcvSetAlpha img1 img2 t
		canvas/image: img2
		isFile: true
	]
]




; ***************** Test Program ****************************
view win: layout [
		title "Alpha Tests"
		button "Load"	[loadImage]
		sl: slider 300  [t: 255 - (to integer! sl/data * 255)
						 	vf/data: form t
						 	rcvSetAlpha img1 img2 t
						 	do-events/no-wait
						]
		vf: field 30 "255"
		button 80 "Quit" [quit]
		return
		canvas: base 512x512 img2	
]