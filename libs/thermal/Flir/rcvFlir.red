#! /usr/local/bin/red
Red [
	Title:   "rcvFlir"
	Author:  "ldci"
	File: 	 %rcvFlir.red
	needs:   view
]


;--This module allows to process Flir thermal images
;--exiftool and magick convert are required
;--we need include %exif.red file in order to get default red words
;--this file is mandatory and is automatically updated for new images
#include %default_exif.red 	

;--this must be adapted according your OS
;--for macOS
;exifTool: "/usr/local/bin/exiftool"	;--native installation with no conflicts
;convertTool: "/usr/local/bin/convert"  ;--convert is a macOS program
;convertTool: "/usr/local/bin/magick"	;--use ImageMagick	

;--for windows
;exifTool: "C:\Users\fjouen\Programmation\exiftool"
;exifTool: "exiftool"
;convertTool: "magick"	

OS:  system/platform
if any [OS = 'macOS OS = 'Linux] [exifTool: "/usr/local/bin/exiftool" convertTool: "/usr/local/bin/magick"] 
if any [OS = 'MSDOS OS = 'Windows][exifTool: "exiftool" convertTool: "magick"]


SourceFile: ""
tmpDir: %.				

exifFile:  	%exif.txt		;--for decoding Flir image
exifFile2: 	%exif.red		;--get Red words
flirPal: 	copy []			;--for color palette
rgbjpg: 	"rgb.jpg"		;--Flir embedded visible image
rgbpng: 	"rgb.png"		;--Flir embedded visible image
irimg: 		"irimg.png"		;--Linear corrected Grayscale IR image
palimg: 	"palette.png"	;--Flir palette
rawimg:		"rawimg.png"	;--Corrected linear raw temperatures
tempimg:	"celsius.pgm"	;--For temperatures export 
extracted?: false
imgRatio: 0.0

;--OK
rcvGetFlirMetaData: func [
"Get all Flir file metadata values as red words"
	fileName	[string!]
][
	tmpDir: to-red-file rejoin [first split-path to-file filename "irtmp/"]
	if not exists? tmpDir [make-dir tmpDir]
	exifFile: to-red-file rejoin [tmpDir "exif.txt"]
	exifFile2: to-red-file rejoin [tmpDir "exif.red"]
	rgbjpg:  rejoin [tmpDir "rgb.jpg"]
	rgbpng:  rejoin [tmpDir "rgb.png"]
	irimg:   rejoin [tmpDir "irimg.png"]	
	palimg:  rejoin [tmpDir "palette.png"]
	rawimg:	 rejoin [tmpDir "rawimg.png"]
	tempimg: rejoin [tmpDir "celsius.pgm"]
	prog: copy rejoin [exifTool " -php -flir:all -q " to-local-file fileName " > " to-local-file exifFile]
	ret: call/shell/wait prog
	var: read/lines exifFile
	n: length? var
	i: 2
	write/lines exifFile2 "Red ["
	write/lines/append exifFile2 "]"
	while [i < n] [
		str: trim/with var/:i ","
		ss: split str " => "
		s: trim ss/1
		s: trim/with s #"^""
		v: set to-word s ss/2 
		vs: rejoin [s ": " ss/2]
		write/lines/append exifFile2 vs
		i: i + 1
	]
	extracted?: false
	do load exifFile2
]

;--OK
rcvGetVisibleImage: function [
"Get embedded visible RGB image"
	fileName	[string!]
	return:		[image!]
][
	binstr: copy #{}
	prog: copy rejoin [exifTool " -EmbeddedImage -b " to-local-file fileName]
	ret: call/wait/output prog binstr
	;print ["Get visible image: " ret]
	switch EmbeddedImageType [ 
		"PNG"  [write/binary to-file rgbpng binstr]
		"JPG"  [write/binary to-file rgbjpg binstr]			
		"DAT"  [imgsize: as-pair EmbeddedImageWidth EmbeddedImageHeight
				img: make image! reduce [imgsize binstr]
				save to-file rgbjpg img]
	]
	;--returned image
	switch EmbeddedImageType [ 
		"PNG"	[load to-file rgbpng]
		"JPG"	[load to-file rgbjpg]
		"DAT"	[load to-file rgbjpg]
	]
]

;--OK
rcvGetFlirPalette: function [
"Extract color table, swap Cb Cr and expand pal color table from [16,235] to [0,255]"
	fileName	[string!]
	return:		[image!]
][
	img: make image! reduce [224x1 gray]
	size: form img/size
	prog:  rejoin [
		exifTool  " " to-local-file fileName " -b -Palette" 
		" | " convertTool " -size " size 
		" -depth 8 YCbCr:- -separate -swap 1,2"
		" -set colorspace YCbCr -combine -colorspace RGB -auto-level " 
		to-local-file palimg
	]
	ret: call/shell/wait prog 
	;print ["Palette extraction: " ret]
	load to-red-file palimg
]

rcvMakeRedPalette: function [
"Export Flir palette values as a block"
	return:		[block!]
][
	;--make scale image for Red
	pimg: load to-file palimg
	clear flirPal	
	repeat i PaletteColors [append flirPal pimg/:i]
	flirPal		
]

;--OK
rcvGetFlirRawData: function [
"Get Flir RAW thermal data"
	fileName	[string!]
	return:		[image!]
][
	if RawThermalImageType = "TIFF" [
		prog: copy rejoin [
			exifTool " -RawThermalImage " to-local-file fileName 
			" | " convertTool " " to-local-file rawimg
		]
	]
	;16-bit PNG JPG OR DAT format: change byte order
	if RawThermalImageType <> "TIFF" [
		size: rejoin [form RawThermalImageWidth "x" form RawThermalImageHeight]
		prog: copy rejoin [
				exifTool " -b -RawThermalImage " to-local-file fileName 
				" | " convertTool " - gray:- | " 
				convertTool " -depth 16 -endian MSB -size " size " gray:- " 
				to-local-file rawimg
			]
	]
	ret: call/shell/wait prog
	;print ["Raw data reading: " ret]
	extracted?: true
	load to-red-file rawimg
]
;--Red Files
rcvGetPlanckValues: func [
"All the values we need for temperature computation"
][
	str: 		copy ReflectedApparentTemperature
	tmpREF: 	to-float trim/with str " C"
	RAWmax: 	RawValueMedian + (RawValueRange / 2)
	RAWmin: 	RAWmax - RawValueRange
	Kelvin: 	273.15
	;--calculate the amount of radiance of reflected objects ( Emissivity < 1 )	
	;--formula decomposition for easier arguments 
	v0: PlanckB / (tmpREF + Kelvin)
	v1: exp v0
	v1: v1 - PlanckF 
	v2: (PlanckR2 * v1) 
	RAWrefl: (PlanckR1 / v2) - PlanckO
	;--raw object min/max temperatures
	em: 1.0 - Emissivity
	RAWmaxobj: RAWmax - (em * RAWrefl) / Emissivity
	RAWminobj: RAWmin - (em * RAWrefl) / Emissivity	
	;--min and max ° values as float
	v0: log-e (PlanckR1 / (PlanckR2 * (RAWminobj + PlanckO))+ PlanckF)
	imgMinTemp: (PlanckB / v0) - Kelvin
	v0: log-e (PlanckR1 / (PlanckR2 * (RAWmaxobj + PlanckO))+ PlanckF)
	imgMaxTemp: (PlanckB / v0) - Kelvin
]


rcvGetImageTemperatures: function [
"Get a grayscale image of temperatures"
	fileName	[string!]
	return:		[image!]
][
	rcvGetFlirRawData fileName		;--we need raw data
	rcvGetPlanckValues				;--and constants
	
	;convert every rawimg-16-Bit pixel with Planck law to a temperature grayscale value
	;--Planck Law
	sMax: PlanckB / log-e (PlanckR1 / (PlanckR2 * (RAWmax + PlanckO)) + PlanckF)
	sMin: PlanckB / log-e (PlanckR1 / (PlanckR2 * (RAWmin + PlanckO)) + PlanckF)
	sDelta: sMax - sMin
	;--string form for creating mathExp as argument for convert
	R1: form PlanckR1 R2: form PlanckR2 B: form PlanckB O: form PlanckO F: form PlanckF
	ssMin: form sMin ssDelta: form sDelta
	mathExp: rejoin ["("B"/ln("R1"/("R2"*(65535*u+"O"))+"F")-"ssMin")/"ssDelta]
	;#"^"" for inserting " in convert argument
	prog: rejoin [convertTool " " to-local-file rawimg " -fx " #"^"" mathExp #"^"" " " to-local-file irimg]
	ret: call/shell/wait prog
	;--convert linear gray IR image to pgm format for temperature reading
	prog: rejoin [convertTool " " to-local-file irimg " -compress none " to-local-file tempimg]
	ret: call/shell/wait prog
	;print ["Image temperatures: " ret]
	load to-red-file irimg
]

_getTemperatures: routine [
	img				[block!] ;--a pgm image 
	minTemp			[float!]
	delta			[float!]
	return:			[block!]
	/local
	headImg tailImg	[red-value!]
	blk				[red-block!]
	n   			[integer!]
	int	cMax 		[red-integer!]
	f celsius		[float!] 
	colorMax 		[float!]
	ff				[red-float!]
][
	headImg: block/rs-head img
	tailImg: block/rs-tail img
	n: block/rs-length? img
	blk: as red-block! stack/push*
	block/make-at blk n - 4
	headImg: headImg + 3
	cMax: as red-integer! headImg	;--65535 for 16-bit 255 for 8-bit
	colorMax: as  float! cMax/value
	headImg: headImg + 4
	while [headImg < tailImg][
		int: as red-integer! headImg
		f: as float! int/value		
		celsius: f / colorMax * delta + minTemp	 
		ff: float/box celsius
		block/rs-append blk as red-value! ff
		headImg: headImg + 1
	]
	as red-block! stack/set-last as cell! blk
]

rcvGetTemperatureAsBlock: function [
"Export temperatures as float values in a block"
	fileName	[string!]
	return:		[block!]
][
	unless extracted? [rcvGetFlirRawData fileName]		;--we need raw data
	rcvGetPlanckValues									;--and constants
	delta: imgMaxTemp - imgMinTemp
	img: load to-red-file tempimg						;--a pgm image which is just a block 
	_getTemperatures img imgMinTemp delta
]



rcvCleanThermal: does [
	if exists? to-red-file rgbjpg 		[delete to-file rgbjpg]
	if exists? to-red-file rgbpng 		[delete to-file rgbpng]
	if exists? to-red-file irimg  		[delete to-file irimg]
	if exists? to-red-file palimg 		[delete to-file palimg]
	if exists? to-red-file rawimg 		[delete to-file rawimg]
	if exists? to-red-file tempimg 		[delete to-file tempimg]
	if exists? to-red-file exifFile 	[delete to-file exifFile]
	if exists? to-red-file exifFile2 	[delete to-file exifFile2]
	if exists? to-red-file tmpDir 		[delete to-file tmpDir]
]
