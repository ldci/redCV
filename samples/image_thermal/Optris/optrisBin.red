#!/usr/local/bin/red
Red [
	Title:   "Red and Optris Binary Files"
	Author:  "ldci"
	File: 	 %optrisbin.red
	Needs:	 View
]


;--This code works with raw data from PI-160 Optris camera (160x120 frames)
;--Binary files contains n frames, and nothing else 
;--With this camera the image data buffer frame holds 16-bit values 
;--(two bytes per pixel, low byte first) related to the temperature
;--temperature =  high byte * 256 + low byte  * 0.1  - 100

home: select list-env "HOME"
appDir: to-file rejoin [home "/Programmation/Red/RedCV/samples/image_thermal/Optris/"]
change-dir to-file appDir

imageSize: 160x120								;--default image size PI-160
imageLength: imageSize/x * imageSize/y * 2		;--size * 2 for low and high values
nImages: 0										;--for interface test								
optrisFile: none								;--optris binary file
tempArray: copy []								;--temperatures array
;mapFile: "lib/maps/Iron.png"					;--default palette	

mapFile: "../../../libs/thermal/Optris/maps/Iron.png"					
imgMap: load to-file mapFile					;--load default palette
colMap: []										;--color mapping block
bin: copy #{}									;--binary frame

;--we can use a lot of palettes
palettes: [
	"Iron.png"
	"Iron_HI.png"
	"Rainbow_Medical.png" 
	"Rainbow.png"
	"Rainbow_HI.png" 
	"Alarm_Red.png" 
	"Alarm_Green.png" 
	"Alarm_Blue.png" 
	"Blue_Hi.png" 
	"Gray_White_Cold.png" 
	"Gray_Black_Cold.png" 
 ] 
 

minTemp: maxTemp: 0.0					;--minimal and maximal temperatures
currentImage: 1							;--first image
isFile: false							;--not loaded binary file

;--load binary optris file
loadBin: does [
	tmp: request-file 
	if not none? tmp[
		optrisFile: read/binary tmp
		len: to-integer length? optrisFile
		nImages: to-integer (len / imageLength)
		f1/text: rejoin [form nImages " images"]
		img1: make image! imageSize
		img1: make image! imageSize
		isFile: true
		currentImage: 1
		updateImages
	]
]

;--read current image
readImage: func [
	idx		[integer!] 	;--image number
][
	imageIROffset:  (idx - 1 * imageLength) + 1	; offset: n * 38400 + 1 Red is one-based
	binaryData: copy/part at optrisFile imageIROffset imageLength 	; get binay values
	clear bin														;-for grayscale image source
	clear tempArray
	minTemp: maxTemp: binaryData/2 * 256 + binaryData/1 - 1000.0 / 10.0
	foreach [lo hi] binaryData [
			v: lo or (hi << 8)
			temp: hi * 256 + lo  * 0.1  - 100		
			append tempArray form temp		;--store temperature	
			minTemp: min minTemp temp		;--minimal temperature
			maxTemp: max maxTemp temp		;--maximal temperature
			append/dup bin reduce [lo] 3	;--for image	
	]
	img1/rgb: bin							;--grayscale image
	
	;--now we want a colored image according to mapColor scale
	n: length? colMap
	img2: make image! imageSize				;--rgb image
	scale: maxTemp - minTemp 				;--automatic scale
	i: 1
	foreach temp tempArray [
		idx1: to-integer n * (maxTemp - to-float temp) / scale
		if idx1 = 0 [idx1: 1]
		if idx1 > imgMap/size/y [idx1: imgMap/size/y]
		img2/:i: colMap/:idx1
		i: i + 1
	]
	
	canvas1/image: img1
	canvas2/image: img2
	f2/text: rejoin [form idx "/" form nImages]
	f3/text: form minTemp
	f4/text: form maxTemp
	
]
;--pixel temperature
getTemperatures: does [
	clear tempList/data
	tempList/data: copy tempArray
]

;--color mapping
makeColorMap: does  [
	colMap: copy []
	n: imgMap/size/y - 1
	i: 0
	repeat i n [append colMap map/image/(i * imgMap/size/x + 1)]
]

;--read and show images
updateImages: does [
	if isFile [
		readImage currentImage
		if cb/data [getTemperatures]
	]
	sl/data: to-percent (currentImage / nImages)
]

;--Application window
mainwin: layout [
	Title "Optris Binary Data Reading [PI-160 *.bin]"
	space 5x5
	button "Load" [loadBin]
	f1: field 
	cb: check "Temperatures"
	dp: drop-down 150 data palettes
	select 1
	on-change [
		mapFile: rejoin ["../../../libs/thermal/Optris/maps/"pick face/data face/selected]
		imgMap: load to-file mapFile
		map/image: imgMap
		makeColorMap
		updateImages
	]
	
	pad 245x0 button "Quit" [Quit]
	return
	canvas1: base 320x240 black 
	on-time [
		currentImage: currentImage + 1
		either currentImage < nImages [updateImages] [face/rate: none]
	]
	canvas2: base 320x240 black
	map: base 25x240 imgMap
	tempList: text-list 50x240 data []
	return
	space 0x0
	button "<<" 40 	[currentImage: 1 updateImages]
	button "<"  40	[if currentImage > 1 [currentImage: currentImage - 1 updateImages]]
	button ">"  40	[if currentImage < nImages [currentImage: currentImage + 1 updateImages]]
	button ">>" 40	[currentImage: nImages updateImages]
	sl: slider 145 [
		currentImage: 1 + to-integer face/data * (nImages - 1)
		f2/text: form currentImage
		updateImages
	]
	space 5x5
	f2: field
	f3: field 50
	f4: field 50
	onoff: toggle 120 "Start" false [
		either canvas1/rate <> none [face/text: "Start"canvas1/rate: none] 
									[face/text: "Stop" canvas1/rate: 0:0:0.05]
	]
	do [makeColorMap]
]
view mainWin

