#!/usr/local/bin/red
Red [
	needs: view
]

#include %../../libs/pandore/panlibObj.red
isFile: false
pFile: none

loadPanImage: does [
	clear  f/text
	pFile: request-file
	unless none? pFile [
		pandore/readPanHeader pFile
		pandore/readPanAttributes  pFile
		pandore/readPanImage  pFile
		idx: pandore/pobject/poprop/colorspace
		x: pandore/pobject/poprop/ncol
		y: pandore/pobject/poprop/nrow
		bands: pandore/pobject/poprop/nbands
		img: make image! reduce [as-pair x y pandore/pobject/data]
		canvas/image: img
		;canvas/size: img/size
		f/text: rejoin [
				as-pair x y " Type: " pandore/pobject/potype/ptype " " 
				bands " Band(s) "]
				
		;probe pandore/pobject/potype
		;probe pandore/pobject/poprop
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
	title  "Pan Images"
	button "Load"				[loadPanImage]
	check  "Show Bands " false 	[pandore/pobject/split: face/data updateView]
	pad 260x0
	button "Quit"  				[quit]
	return
	canvas: base 512x512
	return
	f: field  512
]
view mainWin
