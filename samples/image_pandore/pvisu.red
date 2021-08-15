#!/usr/local/bin/red
Red [
	Title:   "Pandore test"
	Author:  "Francois Jouen"
	File: 	 %pvisu.red
	Needs:	 'View
]

{Replace Qt pvisu. To be installed in pandore/bin
You must compile a release version (red -r pvisu.red)
Uses filename as argument: bin/pvisu test.pan
}

#include %lib/panlibObj.red
isFile: false
pFile: none
canvas: none

updateView: does [
	if isFile [
		img/rgb: black
		pandore/readPanImage pFile
		img/rgb: pandore/pobject/data
	]
]

;tmp:  rejoin [get-current-dir system/script/args]
tmp: system/script/args
tmp: trim/with tmp "'"
pFile: to-file tmp
pandore/readPanHeader pFile
pandore/readPanAttributes  pFile
pandore/readPanImage  pFile
idx: pandore/pobject/poprop/colorspace
x: pandore/pobject/poprop/ncol
y: pandore/pobject/poprop/nrow
bands: pandore/pobject/poprop/nbands
img: make image! reduce [as-pair x y pandore/pobject/data]


mainWin: layout[
	title  "Pan Images"
	check  "Show Bands " false 	[pandore/pobject/split: face/data updateView]
	pad 340x0
	button "Quit"  				[quit]
	return
	canvas: base 512x512
	return
	f: field  512
	do [canvas/image: img isFile: true
		f/text: rejoin [
			as-pair x y " Type: " pandore/pobject/potype/ptype " " 
			bands " Band(s) "]
	]
]
mainWin/text: tmp
view mainWin
