Red [
	Title:   "Logical Operators "
	Author:  "Francois Jouen"
	File: 	 %testLogical.red
	Needs:	 'View
]


; last Red Master required!
#include %../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../images/lena.jpg
img2: rcvRandomImage/uniform img1/size 255.255.255 ;
dst: rcvCreateImage img1/size

; ***************** Test Program ****************************
view win: layout [
		title "Logical Tests"
		origin margins space margins
		button 35 "SRC" [rcvCopy img1 dst ]		; routine
		button 35 "NOT" [rcvNot img1 dst ]
		button 35 "AND" [rcvAND img1 img2 dst]
		button 35 "OR"  [rcvOR img1 img2 dst]
		button 35 "XOR" [rcvXOR img1 img2 dst]
		button 35 "NAND"[rcvNAND img1 img2 dst]
		button 35 "NOR" [rcvNOR img1 img2 dst]
		button 35 "NXOR"[rcvNXOR img1 img2 dst]
		button 35 "MIN" [rcvMIN img1 img2 dst]
		button 35 "MAX" [rcvMAX img1 img2 dst]
		button 80 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2 
							rcvReleaseImage dst 
							Quit]
		return 
		text 35 "AND"
		button 35 "R" [rcvANDS img1 dst 255.0.0.0]
		button 35 "G" [rcvANDS img1 dst 0.255.0.0]
		button 35 "B" [rcvANDS img1 dst 0.0.255.0]
		text 35 "OR" 
		button 35 "R" [rcvORS img1 dst 255.0.0.0]
		button 35 "G" [rcvORS img1 dst 0.255.0.0]
		button 35 "B" [rcvORS img1 dst 0.0.255.0]
		text 35 "XOR" 
		button 35 "R" [rcvXORS img1 dst 255.0.0.0]
		button 35 "G" [rcvXORS img1 dst 0.255.0.0]
		button 35 "B" [rcvXORS img1 dst 0.0.255.0]
		return
		pad 2x0
		canvas: base 512x512 dst
		do [rcvCopy img1 dst]
]