#!/usr/local/bin/red
Red [
	Title:   "Red and Optris Binary Files"
	Author:  "ldci"
	File: 	 %optrisRavi.red
	Needs:	 View
]

;--This code should work with all new Optris cameras.
;--We parse the ravi file in order to find mini and max temeperatures
;--mini and max temperatures are float values and concern the whole video
;--We have to find the mini and maxi int16 values for all frames
;--then we get frame offset and size. Ffmpeg is not required.
;--if min and max temperatures are not found, we must use  a calibration curve
;--since only the raw sensor data are stored in the file


OS: to-string system/platform
if any [OS = "macOS" OS = "Linux" ] [home: select list-env "HOME"] 
if any [OS = "MSDOS" OS = "Windows"][home: select list-env "USERPROFILE"]

appDir: to-file rejoin [home "/Programmation/Red/RedCV/samples/image_thermal/Optris/"]
change-dir to-file appDir

#include %../../../libs/thermal/Optris/optrisriff.red
#include %../../../libs/thermal/Optris/optrisroutines.red


imageSize: 160x120								;--default image size
imageLength: imageSize/x * imageSize/y * 2		;--size * 2 for low and high values
nbFrames: 10									;--for interface test								
optrisFile: none								;--optris ravi file
;mapFile: "lib/maps/Iron.png"					;--default palette	
mapFile: "../../../libs/thermal/Optris/maps/Iron.png"					
imgMap: load to-file mapFile					;--load default palette
colMap: []										;--color mapping block
bin: copy #{}									;--for grayscale image	
matV: make vector! []							;--int16 matrix
matGS: make vector! []							;--low byte matrix
matTemp: make vector! [float! 64 0]				;--float temperatures matrix 
minRange: 	0
maxRange: 	0
tempScale:	0.0
minV: 65535 
maxV: 0	
firstByte: 0	
addmovi?: false
fps: 20
frate: to-time 1 / fps	

;--we can use a lot of color maps 
palettes: [
	"Alarm_Red.png" 
	"Alarm_Green.png" 
	"Alarm_Blue.png" 
	"Blue_Hi.png" 
	"Gray_White_Cold.png" 
	"Gray_Black_Cold.png" 
	"Iron.png"
	"Iron_HI.png"
	"Rainbow_Medical.png" 
	"Rainbow.png"
	"Rainbow_HI.png" 
 ] 
 
minTemp: maxTemp: 0.0					;--minimal and maximal temperatures initialization
currentImage: 1							;--first image
isFile: false							;--not loaded binary file

;--load binary optris file
loadBin: does [
	sb/text: ""
	tmpf: request-file 
	if not none? tmpf[
		canvas1/image: none
		canvas2/image: none
		tempList/text: "° Celsius"
		optrisFile: read/binary tmpf
		either assertRIFFFile optrisFile [
			getFileInfo optrisFile
			getFileHeader optrisFile
			getStreamHeader optrisFile
			nbFrames: aviMainHeader/dwTotalFrames
			imgSize: as-pair bitMapInfoHeader/biWidth bitMapInfoHeader/biHeight
			fSize: bitMapInfoHeader/biSizeImage	
			f1/text: rejoin [form nbFrames " frames"]
			f11/text: form imgSize
			fps: getFrameRate optrisFile
			frate: to-time 1 / fps
			blk: getTempRange optrisFile
			minRange: 	blk/1
			maxRange: 	blk/2
			minTemp: 	blk/3
			maxTemp: 	blk/4
			tempScale: 	maxTemp - minTemp 			;--automatic scale
			f3/text: form minTemp
			f4/text: form maxTemp
			img1: make image! imgSize
			img2: make image! imgSize
			sb/text: "Patience! Calculating minimal and maximal values in raw data ..." 
			cOffset: 0
			imageLength: fSize
			;--get frames offset and size
			either hasix00? [frames: getAviMoviIndex optrisFile]
							[frames: getAviFrameIndex optrisFile]
			if frames/1/1 < firstOffset	[addMovi?: true]			
			
			;--In most of files, there are non-pixel values on the first line
			;--supplemenary first line stores some information such as width and height
			;--we have to skip this line * 2 since we have 16-bit values
				
			if odd? imgSize/y [
				cOffset: imgSize/x * 2
				imageLength: fSize  - (imgSize/x * 2)
			]
			f12/text: rejoin [form cOffset]
			do-events/no-wait
			getMinMaxValues nbFrames
			sb/text: "Done!"
			isFile: true
			currentImage: 1
			updateImages
		] [alert "Non ravi File"]
	]
]

;--we need to find min and max values in the whole video
;--we  use routines for faster processing

getMinMaxValues: func [
	nFrames		[integer!]
][
	minV: 65536
	maxV: 0
	repeat idx nFrames [
		frame: frames/:idx
		fOffset: frame/1 
		fSize: frame/2			
		either hasix00? [
			fOffset: fOffset 							
			fOffset: fOffset + (imgSize/x * 2)	;--correct offset to get pixel values
			fSize: fSize - (imgSize/x * 2)		;--and the correct size
		][
			fOffset: fOffset + 8
			if addMovi? [fOffset: fOffset + firstOffset]
		]
		binaryData: _getBinaryValue optrisFile fOffset fSize
		;binaryData: copy/part at optrisFile fOffset + 1 fSize ;--1-based
		v: to-integer reverse copy/part binaryData 2 
		if all [v > 4095 v < 65536] [l: 65535]
		if v < 4095 [l: 4095]
		minV: getMin binaryData l minV
		maxV: getMax binaryData l maxV
		p1/data: to percent! (idx / nFrames)
		pf/text: form round p1/data
		do-events/no-wait
		;--minimal and maximal values are found, exit
		if all [minV = 0 maxV = l][break]
	]
	if all [maxV = 65535 cOffset > 0] [minV: 65536 - 768] ;--for some files
	p1/data: 0% pf/text: ""
]

;--color mapping
makeColorMap: does  [
	colMap: copy []
	n: imgMap/size/y - 1
	i: 0
	repeat i n [append colMap map/image/(i * imgMap/size/x + 1)]
]

showTemp: does [
	clear tempList/text
	do-events/no-wait
	tempList/text: form matTemp
]


;--read and show images
updateImages: does [
	if isFile [
		sb/text: rejoin ["Processing frame " form currentImage]
		do-events/no-wait
		clear tempList/text
		readFrame currentImage
		if cb/data [showTemp]
	]
	sl/data: to-percent (currentImage / nbFrames)
]


;--read current frame
readFrame: func [
	idx		[integer!] 	;--frame number
][
	frame: frames/:idx
	fOffset: frame/1 
	fSize: frame/2
	;--offset from the start of the movi list
	either hasix00? [
		;fOffset: fOffset +  1							
		fOffset: fOffset + (imgSize/x * 2)	;--correct offset to get pixel values
		fSize: fSize - (imgSize/x * 2)		;--and the correct size
	][
		;fOffset: fOffset + 8
		if addMovi? [fOffset: fOffset + firstOffset]
	]
	
	binaryData: _getBinaryValue optrisFile fOffset fSize
	;binaryData: copy/part at optrisFile fOffset + 1 fSize	;-1-based
	v: to-integer reverse copy/part binaryData 2
	either v < 4095 [l: 4095] [l: 65535]
	f13/text: rejoin [to-hex/size binaryData/1 2 " " to-hex/size binaryData/2 2 ] 
	getTempInt16Values binaryData matV l	;--get 16-bit values
	getTempLowByte binaryData matGS l 3		;--get low byte values
	img1/rgb: to-binary to-block matGS		;--make grayscale image
	canvas1/image: img1						;--show image
	
	matTemp: getCelsiusValues matV minV maxV minTemp maxTemp ;--get temp
	;--now we want a colored image according to colorMap scale
	;--we do  have a temperature scale
	if maxTemp > 0.0 [makeColor matTemp colMap img2 minTemp maxTemp]
	;--we do not have temperature scale, use int values
	if maxTemp = 0.0 [makeColor2 matV colMap img2 minV maxV]
		
	canvas2/image: img2
	f2/text: rejoin [form idx "/" form nbFrames]
]

;--Application window
mainwin: layout [
	Title "Optris Ravi Files Reading [All PI-]"
	space 5x5
	button "Load" [loadBin]
	f1: field 
	f11: field
	f12: field 70 center
	f13: field 70 center
	cb: check "Temperatures"
	dp: drop-down 155 data palettes
	select 7
	on-change [
		mapFile: rejoin ["../../../libs/thermal/Optris/maps/"pick face/data face/selected]
		imgMap: load to-file mapFile
		map/image: imgMap
		makeColorMap
		updateImages
	]
	
	pad 85x0 button "Quit" [Quit]
	return
	canvas1: base 320x240 black 
	on-time [
		cb/data: false
		currentImage: currentImage + 1
		either currentImage <= nbFrames [updateImages] [face/rate: none]
	]
	canvas2: base 320x240 black
	map: base 25x240 imgMap
	tempList: area 145x240 "° Celsius"
	return
	space 0x0
	button "<<" 40 	[currentImage: 1 updateImages]
	button "<"  40	[if currentImage > 1 [currentImage: currentImage - 1 updateImages]]
	button ">"  40	[if currentImage <= nbFrames [currentImage: currentImage + 1 updateImages]]
	button ">>" 40	[currentImage: nbFrames updateImages]
	sl: slider 145  [
		currentImage: 1 + to-integer face/data * (nbFrames - 1)
		f2/text: form currentImage
		updateImages
	]
	space 5x5
	f2: field
	f3: field 70
	f4: field 70
	onoff: toggle 80 "Start" false [
		either canvas1/rate <> none [face/text: "Start"canvas1/rate: none] 
									[face/text: "Stop" canvas1/rate: frate]
	]
	return
	sb: field 450 p1: progress 150 pf: field 40
	do [makeColorMap]
]
view mainWin


