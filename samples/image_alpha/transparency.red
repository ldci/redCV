Red [
	Title:   "Alpha test "
	Author:  "Francois Jouen"
	File: 	 %transparency.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvCreateImage 512x512

t: 255
; ***************** Test Program ****************************
view win: layout [
		title "Alpha Tests"
		sl: slider 380 [t: 255 - (to integer! sl/data * 255)
						vf/data: form t
						rcvSetAlpha img1 img2 t
						]
		vf: field 30 "255"
		button 80 "Quit" [quit]
		return
		canvas: base 512x512 img2	
		do [rcvSetAlpha img1 img2 255]
		
]