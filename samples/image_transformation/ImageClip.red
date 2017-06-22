Red [
	Title:   "Flip tests "
	Author:  "Francois Jouen"
	File: 	 %Imageclip.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
winBorder: 10x50
img1: rcvLoadImage %../../images/lena.jpg
dst:  rcvCreateImage img1/size
rLimit: 0x0
lLimit: 512x512
start: 0x0
end: start + 200
poffset: negate start
;drawBlk: compose [translate (poffset) clip (start) (end) image img1]

drawBlk: rcvClipImage poffset start end img1
drawRect: compose [line-width 2 pen green box 0x0 200x200]

; ***************** Test Program ****************************
view/tight [
		title "Clip Tests"
		style rect: base 255.255.255.240 202x202 loose draw []
		origin margins space margins
		button 80 "Show Roi" [p1/draw: drawRect extrait/draw: drawBlk]
		button 80 "Hide Roi" [p1/draw: [] extrait/draw: []]
		button 80 "Quit" 	 [rcvReleaseImage img1 dst Quit]
		return 
		canvas: base 512x512 dst react [
			
			if (p1/offset/x > lLimit/x) AND (p1/offset/y > lLimit/y)[
				if (p1/offset/x  < rLimit/x) AND (p1/offset/y  < rLimit/y)[
					start: p1/offset - winBorder
					end: start + 200
					poffset: negate start
					sb/text: form start		
					drawBlk/2: poffset 
					drawBlk/4: start
					drawBlk/5: end
				]
			]
			
		]
		extrait: base 200x200 white draw []
		return
		sb: field 512
		at winBorder p1: rect
		do [rcvCopyImage img1 dst lLimit: canvas/offset rLimit: canvas/size + canvas/offset - p1/size ]
]
