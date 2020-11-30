Red [
	Title:   "Morphological operators"
	Author:  "Francois Jouen"
	File: 	 %erodeDilate.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvMorphology.red

margins: 10x10
img1: rcvCreateImage 512x512
clone: rcvCloneImage img1
dst:  rcvCreateImage img1/size
; shapes for SE
shape: 1
knlSize: 3x3
knl: rcvCreateStructuringElement/rectangle knlSize
it: 0
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
		fileName: to string! to-file tmp
		win/text: fileName
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
		title "Morphological Operators: Erosion & Dilatation"
		origin margins space margins
		button 60 "Load" 	[loadImage]
		button 65 "Source" 	[it: 0 iter/text: form it rcvCopyImage img1 dst clone: rcvCloneImage img1]									
		button 65 "Erode" 	[it: it + 1 iter/text: form it rcvErode clone dst knlSize knl rcvCopyImage dst clone]
		button 70 "Dilate" 	[it: it + 1 iter/text: form it rcvDilate clone dst knlSize knl rcvCopyImage dst clone]
		text "Iterations" 
		iter: field 30	"0"					
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
