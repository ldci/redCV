Red [
	Title:   "Morphological operators"
	Author:  "Francois Jouen"
	File: 	 %morpho.red
	Needs:	 'View
]

; last Red Master required!
#include %../../libs/redcv.red ; for redCV functions
margins: 10x10
img1: rcvCreateImage 512x512
clone: rcvCloneImage img1
dst:  rcvCreateImage img1/size
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize

custom: [0 0 1 0 0
		 0 1 1 1 0
		 1 1 1 1 1
		 0 1 1 1 0
		 0 0 1 0 0]

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
		isFile: true
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Morphological Operators: Open & Close"
		origin margins space margins
		button 60 "Load" 	[loadImage]
		button 65 "Source" 	[rcvCopyImage img1 dst clone: rcvCloneImage img1 ]									
		button 65 "Open" 	[rcvErode clone dst knlSize knl
							rcvCopyImage dst clone
							rcvDilate clone dst knlSize knl 
							]
		button 65 "Close" 	[rcvDilate clone dst knlSize knl
							rcvCopyImage dst clone
							rcvErode clone dst knlSize knl
							]	
		button 60 "Quit" 	[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return
		text 60 "Shape" 	
		drop-down 90
			data ["Cross" "Rectangle" "Custom"] 
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
					3	[knl: copy custom knlSize: 5x5 dpk/selected: 3]
				]
			]
		text 90 "Kernel Size"
		dpk: drop-down 60
			data ["3x3" "4x4" "5x5" "6x6" "7x7" "8x8" "9x9" "10x10" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		return 
		canvas: base 512x512 dst	
]
