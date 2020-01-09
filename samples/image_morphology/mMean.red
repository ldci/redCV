Red [
	Title:   "Morphological operators"
	Author:  "Francois Jouen"
	File: 	 %mMean.red
	Needs:	 'View
]


#include %../../libs/core/rcvCore.red
#include %../../libs/imgproc/rcvMorphology.red

margins: 10x10
img1: rcvCreateImage 512x512
clone: rcvCloneImage img1
dst:  rcvCreateImage img1/size
; shapes for SE
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/cross knlSize
it: 0
		 
loadImage: does [
	isFile: false
	canvas/image/rgb: black
	tmp: request-file
	if not none? tmp [
		fileName: to string! to-local-file tmp
		img1: load tmp
		dst:  rcvCreateImage img1/size
		rcvCopyImage img1 dst 
		clone: rcvCloneImage img1
		canvas/image: dst
		it: 0 iter/text: form it
		sl/data: 0% 
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Morphological Operators: Mean"
		origin margins space margins
		button 60 "Load" 	[loadImage]
		button 70 "Source" 	[it: 0 iter/text: form it
							sl/data: 0% 
							rcvCopyImage img1 dst 
							clone: rcvCloneImage img1]	
		pad 280x0				
		button 60 "Quit" 	[rcvReleaseImage img1 
							rcvReleaseImage dst 
							rcvReleaseImage clone
							Quit]
		return
		text 60 "Shape" 	
		drop-down 90 
			data ["Cross" "Rectangle" "Vertical" "Horizontal"]
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
					3	[knl: rcvCreateStructuringElement/vline knlSize]
					4	[knl: rcvCreateStructuringElement/hline knlSize]
				]
			]
		text 90 "Kernel Size"
		dpk: drop-down 60
			data ["3x3" "5x5" "7x7" "9x9" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		sl: slider 100 [
			it: it: it + 1
			iter/text: form it
			rcvMMean clone dst knlSize knl 
			rcvCopyImage dst clone
		]
		
		iter: field 30	"0"	
		return 
		canvas: base 512x512 dst	
]
