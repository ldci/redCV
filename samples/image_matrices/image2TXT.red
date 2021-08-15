Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %Image2TXT.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256
bitSize: 32

img1: rcvCreateImage isize
op: 5 ;--Grayscale

loadImage: does [
	canvas1/image/rgb: black
	clear a/text
	tmp: request-file/filter ["Image Files" "*.bmp;*.png;*.jpg"]
	if not none? tmp [
		img1: rcvLoadImage tmp
		canvas1/image: img1
		f/text: form img1/size
	]
]

convert: does [
	tmpF: request-file/save/filter ["Text File" "*.txt"]
	if not none? tmpF [	
		either rd1/data [bImg: rcvImg2IntBlock img1 op]
						[bImg: rcvImg2FloatBlock img1 op]
		nLines: length? bImg
		write tmpF rejoin [form bImg/1 newline]
		i: 2 
		while [i <= nLines][
			write/append tmpF rejoin [form bImg/:i newline]
			i: i + 1
		]
		a/text: read tmpF
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Export Image to Text"
		button "Load" [loadImage] 
		text "Export as"
		rd1: radio "Integer" true
		rd2: radio "Float"
		drop-down 110 data ["RGBA" "Red Channel" "Green Channel" "Blue Channel" "Alpha Channel" "GrayScale"]
		select 6
		on-change [op: face/selected - 1]
		button "Save As" [convert]
		pad 165x0
		button 60 "Quit" [rcvReleaseImage img1 Quit]
		return
		text 156 "Source"  f: field 90
		text 256 "Text Export"
		return
		canvas1: base isize img1
		a: area 512x256
]
