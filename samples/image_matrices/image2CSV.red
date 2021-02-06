Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %Image2CSV.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256
bitSize: 32

img1: rcvCreateImage isize


loadImage: does [
	canvas1/image/rgb: black
	clear a/text
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		canvas1/image: img1
		convert
	]
]

convert: does [
	f/text: form img1/size
	either rd1/data [bb: rcvImg2IntBlock img1 5]
					[bb: rcvImg2FloatBlock img1 5]
	write %temp.txt to-csv/with bb tab
	a/text: read %temp.txt
]

; ***************** Test Program ****************************
view win: layout [
		title "Export Image to CSV"
		button "Load" [loadImage] 
		text "Export as"
		rd1: radio "Integer" true
		rd2: radio "Float"
		f: field 
		pad 280x0
		button 60 "Quit" [	rcvReleaseImage img1 
							Quit]
		return
		text 256 "Source"  
		text 256 "CSV Export"
		return
		canvas1: base isize img1
		a: area 512x256
]
