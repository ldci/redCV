#!/usr/local/bin/red-view
Red [
	Title:   "Pandore test"
	Author:  "ldci"
	File: 	 %convert.red
	needs: 	view
]

;--for reading pan images
#include %../../libs/pandore/panlibObj.red
isFile: false
pFile: none

loadPanImage: does [
	clear  f1/text
	pFile: request-file
	unless none? pFile [
		pandore/readPanHeader pFile				;--read pan file header
		pandore/readPanAttributes  pFile		;--read pan file properties
		pandore/readPanImage  pFile				;--read pan file data as binary
		f0/text:  pandore/pobject/potype/date	;--date of image creation 
		idx: pandore/pobject/poprop/colorspace	;--default RGB colorspace
		x: pandore/pobject/poprop/ncol			;--columns number
		y: pandore/pobject/poprop/nrow			;--rows number
		bands: pandore/pobject/poprop/nbands	;--bands number
		;--create a Red image with pan image data
		img: make image! reduce [as-pair x y pandore/pobject/data]
		canvas/image: img
		f1/text: rejoin [
				"Size: "
				as-pair x y " Type: " pandore/pobject/potype/ptype " " 
				bands " Band(s) "
		]
		isFile: true
	]
]

updateView: does [
	if isFile [
		img/rgb: black
		pandore/readPanImage pFile
		img/rgb: pandore/pobject/data
	]
]

mainWin: layout[
	title  "Pandore Images"
	button "Load Pandore Image"	[loadPanImage]
	f0: field 
	check  "Show Bands " false 	[pandore/pobject/split: face/data updateView]
	pad 80x0
	button "Quit"  				[quit]
	return
	canvas: base 512x512
	return
	f1: field  512
]
view mainWin
