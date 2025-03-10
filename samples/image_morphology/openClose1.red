Red [
	Title:   "Morphological operators"
	Author:  "ldci"
	File: 	 %openClose1.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvMorphology.red
; this version calls rcvErode and rcvDilate or in reverse order

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
		 0 0 1 0 0
]

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
			data ["Cross" "Rectangle" "Vertical" "Horizontal" "Custom"] 
			select 1
			on-change [shape: face/selected
			switch shape [
					1	[knl: rcvCreateStructuringElement/cross knlSize]
					2	[knl: rcvCreateStructuringElement/rectangle knlSize]
					3	[knl: rcvCreateStructuringElement/vline knlSize]
					4	[knl: rcvCreateStructuringElement/hline knlSize]
					5	[knl: copy custom knlSize: 5x5 dpk/selected: 2]
				]
			]
		text 90 "Kernel Size"
		dpk: drop-down 60
			data ["3x3" "5x5" "7x7" "9x9" "11x11"]
			select 1	
			on-change [knlSize: to pair! face/text]	
		return 
		canvas: base 512x512 dst	
]
