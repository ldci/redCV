Red [
	Title:   "pbm Image Writer "
	Author:  "ldci"
	File: 	 %pbmImageWriter.red
	Needs:	 'View
]

; required libs
#include %../../libs/pbm/rcvPbm.red

isFile: false
colMax: 255
magic: to-binary "P3"
src: make image! 10x10

loadImage: does [
	tmpF: request-file
	if not none? tmpF [
		f1/text: ""
		f2/text: ""
		clear canvas2/text
		canvas1/image: none
		src: load tmpF
		canvas1/image: src
		f1/text: form src/size
		f2/text: form colMax
		isFile: true
	]
]

saveImage: does [
	;/filter ["All Portable BitMap Files" "*.pbm;*.pgm;*.ppm"]
	tmpF: request-file/save
	if not none? tmpF [
		clear canvas2/text
		;ppm
		if any [magic = MAGIC_P1 magic = MAGIC_P2 magic = MAGIC_P3][
			rcvWritePBMAsciiFile tmpF magic src colMax
		]
		;pgm
		if any [magic = MAGIC_P5 magic = MAGIC_P6 ][
			rcvWritePBMByteFile  tmpF magic src colMax
		]
		blk: read/binary tmpF
		canvas2/text: form blk
	]
]


mainWin: layout [
	title "Writing PBM Files"
	button "Load" 		[loadImage]
	text 50 "Format" 
	dp: drop-down 50 data ["P1" "P2" "P3" "P5" "P6"]
	on-change [
		idx: face/selected
		magic: to-binary face/data/:idx
	]
	select 3
	text 50 "Size" 
	f1: field
	text 100 "Color Max"
	f2: field 
	button "Save BitMap"	[saveImage]
	button "Quit"		[Quit]
	return 
	canvas1: base 512x512
	canvas2: area 512x512
]
view mainWin