Red [
	Title:   "Test image operators and camera Red VID "
	Author:  "ldcin"
	File: 	 %tracking2.red
	Needs:	 'View
]



;required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red
#include %../../libs/imgproc/rcvMorphology.red
#include %../../libs/imgproc/rcvColorSpace.red

iSize: 320x240
rimg: rcvCreateImage iSize
hsv: rcvCloneImage rimg
mask: rcvCloneImage rimg
r1: rcvCloneImage rimg

margins: 5x5
threshold: 32

lower:  50.50.50
upper:  255.255.255
cam: none
canvas: none

knlSize: 3x3
knl: rcvCreateStructuringElement/cross knlSize

as-color: function [r g b][
	color: 0.0.0
	if r [color/1: to integer! 256 * r]
	if g [color/2: to integer! 256 * g]
	if b [color/3: to integer! 256 * b]
	color
]

to-text: function [val][form to integer! 0.5 + 255 * any [val 0]]


processImage: does [
	rimg: rcvResizeImage cam/image iSize
	rcvRGB2HSV rimg hsv
	rcvInrange hsv mask lower upper 0
	;morphological opening (remove small objects from the foreground)
	; erode dilate
	rcvErode mask r1 knlSize knl rcvCopyImage r1 mask
	rcvDilate mask r1 knlSize knl rcvCopyImage r1 mask
	;morphological closing (fill small holes in the foreground)
	rcvDilate mask r1 knlSize knl rcvCopyImage r1 mask
	rcvErode mask r1 knlSize knl rcvCopyImage r1 mask
	cmask/image: hsv
	canvas/image: r1
	cam/image: none
	recycle
]


view win: layout [
		title "Object Detection"
		origin margins space margins
		style value: text "0" 30 left bold
		style txt: text 40 right
		; lower range
		text 100 "Low"
		txt "Red:"   Rl: slider 190 vRl: value 
		txt "Green:" Gl: slider 190 vGl: value 
		txt "Blue:"  Bl: slider 190 vBl: value 
		box1: base 30x20 react [
			vRl/text: to-text Rl/data
			vGl/text: to-text Gl/data
			vBl/text: to-text bl/data
			box1/color: as-color Rl/data Gl/data Bl/data
			lower: as-color Rl/data Gl/data Bl/data
			]
		return
		;upper range
		text 100 "High" 
		txt "Red:"   Ru: slider 190 vRu: value 
		txt "Green:" Gu: slider 190 vGu: value 
		txt "Blue:"  Bu: slider 190 vBu: value 
		box2: base 30x20 react [
			vRu/text: to-text Ru/data
			vGu/text: to-text Gu/data
			vBu/text: to-text bu/data
			box2/color: as-color Ru/data Gu/data Bu/data
			upper: as-color Ru/data Gu/data Bu/data
			]
		return
		text 320 "Source" text 320 "HSV transform" text 250 "Object tracking"
		return
		cam: camera iSize
		cmask: base iSize mask
		canvas: base iSize rimg on-time [processImage]
		return
		text 100 "Select camera" 
		cam-list: drop-list 220 on-create [face/data: cam/data]
		onoff: button "Start/Stop" 100 on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: black
					cmask/image: black
				][
					cam/selected: cam-list/selected
					rimg: rcvResizeImage to-image cam iSize ; resize image
					hsv: rcvCloneImage rimg
					mask: rcvCloneImage rimg
					r1: rcvCloneImage rimg
					canvas/rate: 0:0:0.4;  max 1/25 fps in ms			
				]
		]
		pad 475x0	
		btnQuit: button "Quit" 60x24 on-click [
			rcvReleaseImage rimg
			rcvReleaseImage hsv
			rcvReleaseImage mask
			rcvReleaseImage r1
			quit
		]
		
		do [cam-list/selected: 1 canvas/rate: none
			Rl/data: Gl/data: bL/data: 50.0 / 255.0
			Ru/data: Gu/data: BU/data: 1.0
		]
]
	
	


