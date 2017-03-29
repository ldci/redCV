Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %Imageclip.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
dst:  rcvCreateImage img1/size
;drawBlk: rcvClipImage -156x-156 156x156 356x356 
;append drawBlk [img1] ; append to Draw block! the image instance
start: 156x156
end: start + 250
mode: to-word 'replace
poffset: negate start
drawBlk: compose [translate (poffset) clip (start) (end) image img1]

; ***************** Test Program ****************************
view/tight [
		title "Clip Tests"
		style rect: base glass 202x202 loose draw [line-width 2 pen green 
		box 0x0 200x200]
		origin margins space margins
		button 80 "Quit" 		[rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst react [
			sb/text: form p1/offset
			poffset: negate p1/offset
			drawBlk/2: poffset
			drawBlk/4: p1/offset
			drawBlk/5: p1/offset + 200
			
		]
		extrait: base 200x200 black draw drawBlk
		return
		sb: field 512
		at 10x50 p1: rect
		do [rcvCopyImage img1 dst]
]
