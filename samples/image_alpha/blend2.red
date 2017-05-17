Red [
	Title:   "Blend Operator "
	Author:  "Francois Jouen"
	File: 	 %blend2.red
	Needs:	 'View
]

;this version uses rcvSetIntensity and not rcvBlend

#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvLoadImage %../../images/lena.jpg
img2: rcvLoadImage %../../images/test.jpg
dst: rcvCreateImage img1/size
tmp1: rcvCreateImage img1/size
tmp2: rcvCreateImage img2/size
alpha: 0.5

blending: function [src1 [image!] src2 [image!] dst [image!] alpha	[float!]
][
	rcvSetIntensity src1 tmp1 alpha 
	rcvSetIntensity src2 tmp2  1.0 - alpha 
	rcvAdd tmp1 tmp2 dst
]



; ***************** Test Program ****************************
view win: layout [
		title "Blend Operator Test"
		text 60 "Image 1" 
		f1: field 50 "0.5"
		sl: slider 170 [alpha: face/data * 1.0
					f1/text: form alpha
					f2/text: form (1 - alpha)
					blending img1 img2 dst alpha
					]
		text 60 "Image 2" 
		f2: field 50  "0.5"
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							rcvReleaseImage tmp1
							rcvReleaseImage tmp2 
							rcvReleaseImage dst 
							Quit]
		return
		canvas: base 512x512 dst
		do [sl/data: alpha blending img1 img2 dst alpha]
]
