Red [
	Title:   "Matrix tests "
	Author:  "ldci"
	File: 	 %Image2CSV.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red

isize: 256x256							;--fix image size
bitSize: 32								;--integer 32-bit

img1: rcvCreateImage isize				;--create image
delimiter: comma						;--default separator

loadImage: does [
	tmp: request-file
	unless none? tmp [
		canvas1/image/rgb: black
		clear a/text
		img1: rcvLoadImage tmp			;--read image
		canvas1/image: img1				;--show image
		f/text: form img1/size
	]
]

convert: does [
	tmpF: request-file/save/filter ["CSV File" "*.csv;*.txt"]
	if not none? tmpF [
		;--save as integer or float values
		either rd1/data [bImg: rcvImg2IntBlock img1 0]
						[bImg: rcvImg2FloatBlock img1 5]
		write tmpF to-csv/with bImg delimiter	
		a/text: read tmpF
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Export Image to CSV"
		button "Load" [loadImage] 
		text "Export as"
		rd1: radio "Integer" true
		rd2: radio "Float"
		drop-down 100 data ["Comma" "Semicolon" "Tabulation" "Space"]
		select 1
		on-change [
			switch face/selected [
				1 [delimiter: comma]
				2 [delimiter: #";"]
				3 [delimiter: tab]
				4 [delimiter: space]
			] 
		]
		button "Save As" [convert]
		pad 175x0
		button 60 "Quit" [rcvReleaseImage img1 Quit]
		return
		text 156 "Source"  
		f: field  90
		text 256 "CSV Export"
		return
		canvas1: base isize img1
		a: area 512x256 wrap
]
