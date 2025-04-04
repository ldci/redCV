Red [
	Title:   "Colors "
	Author:  "ldci"
	File: 	 %colorObject.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvColorSpace.red

margins: 10x10

img1: rcvCreateImage 256x256
src:  rcvCloneImage img1
dst:  rcvCloneImage img1

lower:  0.0.0
upper:  255.255.255


to-text: function [val][form to integer! 0.5 + 255 * any [val 0]]

to-color: function [r g b][
	color: 0.0.0
	if r [color/1: to integer! 256 * r]
	if g [color/2: to integer! 256 * g]
	if b [color/3: to integer! 256 * b]
	color
]

loadImage: does [
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		src:  rcvCloneImage img1
		dst:  rcvCloneImage img1
		canvas/image: img1
		canvas2/image: dst
		urSl/data: ugSl/data: ubSl/data: 100%
		lrSl/data: lgSl/data: lbSl/data: 0%
	]
	
]



; ***************** Test Program ****************************
view [
	title "Object Color Detection"
	style txt: text 50 right
	style value: text "0" 30 right ;bold
	button "Load" [loadImage]
	button "Quit" [Quit]
	return
	; lower tupple
	txt "1 [R/H]:" lrSl: slider 256 value react [face/text: to-text lrSl/data] return
	txt "2 [G/S]:" lgSl: slider 256 value react [face/text: to-text lgSl/data] return
	txt "3 [B/V]:" lbSl: slider 256 value react [face/text: to-text lbSl/data] 
	pad 0x-65 box1: base 150x90 react [face/color: to-color lrSl/data lgSl/data lbSl/data] return
	
	;upper tupple
	txt "1 [R/H]:" urSl: slider 256 value react [face/text: to-text urSl/data] return
	txt "2 [G/S]:" ugSl: slider 256 value react [face/text: to-text ugSl/data] return
	txt "3 [B/V]:" ubSl: slider 256 value react [face/text: to-text ubSl/data] 
	pad 0x-65 box2: base 150x90 react [face/color: to-color urSl/data ugSl/data ubSl/data] return
	
	cb: check "Use BGR -> HSV transform?" [
		either face/data [rcvBGR2HSV img1 src]
						 [rcvCopyImage img1 src]
	]
	
	
	return
	canvas:  base 256x256 img1
	canvas2: base 256x256 dst
				react [
					lower: box1/color
					upper: box2/color 
					rcvInrange src dst lower upper 0
				]
	do [urSl/data: ugSl/data: ubSl/data: 100% lrSl/data: lgSl/data: lbSl/data: 0%]
]