#! /usr/local/bin/red
Red [
	Title:   "rcvFlir"
	Author:  "Francois Jouen"
	File: 	 %rcvFlir.red
	needs:   view
]


;--This module allows to process Flir thermal images
;--exiftool and magick convert are required
;--we need include %exif.red file in order to get default red words
;--this file is mandatory and is automatically updated for new images
#include %exif.red 				

;--redCV required libraries
#include %../core/rcvCore.red
#include %../imgproc/rcvConvolutionImg.red
#include %../imgproc/rcvImgEffect.red
#include %../imgproc/rcvGaussian.red

;--this must be adapted according your OS
exifTool: "/usr/local/bin/exiftool"
convertTool: "/usr/local/bin/convert"

exifFile:  	%tmp/exif.txt		;--for decoding Flir image
exifFile2: 	%tmp/exif.red		;--get Red words
flirPal: 	copy []				;--for color palette
rgbimg: 	"tmp/rgb.jpg"		;--Flir embedded visible image
irimg: 		"tmp/irimg.png"		;--Linear corrected Grayscale IR image
palimg: 	"tmp/palette.png"	;--Flir palette
rawimg:		"tmp/rawimg.png"	;--Corrected linear raw temperatures
tempimg:	"tmp/celsius.pgm"	;--For temperatures export 
extracted?: false
imgRatio: 0.0

rcvGetFlirMetaData: function [
"Get all Flir file metadata values as red words"
	fileName	[string!]
][
	prog: copy rejoin [exifTool " -php -flir:all -q " fileName " > " exifFile]
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

rcvGetVisibleImage: function [
"Get embedded visible RGB image"
	fileName	[string!]
	return:		[image!]
][
	binstr: copy #{}
	prog: rejoin [exifTool " -EmbeddedImage -b " fileName]
	ret: call/wait/output prog binstr
	switch EmbeddedImageType [ 
		"PNG"  [write/binary %tmp/rgb.png binstr rgbimg: form %tmp/rgb.png]
		"JPG"  [write/binary %tmp/rgb.jpg binstr rgbimg: form %tmp/rgb.jpg]
		"DAT"  [imgsize: as-pair EmbeddedImageWidth EmbeddedImageHeight
				img: make image! reduce [imgsize binstr]
				save %tmp/rgb.jpg img
				rgbimg: form %tmp/rgb.jpg]
	]
	;--returned image
	switch EmbeddedImageType [ 
		"PNG"	[load %tmp/rgb.png]
		"JPG"	[load %tmp/rgb.jpg]
		"DAT"	[load %tmp/rgb.jpg]
	]
]

rcvGetFlirPalette: function [
"Extract color table, swap Cb Cr and expand pal color table from [16,235] to [0,255]"
	fileName	[string!]
	return:		[image!]
][
	img: make image! reduce [224x1 gray]			
	if PaletteColors > 0 [
		size: rejoin [form PaletteColors "x1"]
		prog:  rejoin [
			exifTool  " " fileName " -b -Palette" 
			" | " convertTool " -size " size 
			" -depth 8 YCbCr:- -separate -swap 1,2"
			" -set colorspace YCbCr -combine -colorspace RGB -auto-level " 
			palimg
		]
		call/shell/wait prog 
		img: load to-file palimg
	]
	img
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

rcvGetFlirRawData: function [
"Get Flir RAW thermal data"
	fileName	[string!]
	return:		[image!]
][
	if RawThermalImageType = "TIFF" [
		prog: rejoin [
			exifTool " -RawThermalImage " fileName 
			" | " convertTool " " rawimg
		]
	]
	;16-bit PNG JPG OR DAT format: change byte order
	if RawThermalImageType <> "TIFF" [
		size: rejoin [form RawThermalImageWidth "x" form RawThermalImageHeight]
		prog: rejoin [
				exifTool " -b -RawThermalImage " fileName 
				" | " convertTool " - gray:- | " 
				convertTool " -depth 16 -endian msb -size " size " gray:- " 
				rawimg
			]
	]
	ret: call/shell/wait prog
	extracted?: true
	load to-file rawimg
]

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
	prog: rejoin [convertTool " " rawimg " -fx " #"^"" mathExp #"^"" " " irimg]
	ret: call/shell/wait prog
	;--convert linear gray IR image to pgm format for temperature reading
	prog: rejoin [convertTool " " irimg " -compress none " tempimg]
	ret: call/shell/wait prog
	load to-file irimg
]

_getTemperatures: routine [
	img				[block!]
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
	img: load to-file tempimg
	_getTemperatures img imgMinTemp delta
]


;--aligment
;--for most cameras
rcvAlignImages: func [
	fileName	[string!]
	return:		[image!]
][
	thermal: load to-file fileName								;--Original Flir Image
	visible: rcvGetVisibleImage fileName						;--Embbedded RGB Image	
	imgRatio: 1.0 - (1.0 / Real2IR)								;--Image ratio
	either imgRatio > 0.0 [
		cropXY: visible/size * imgRatio							;--ROI Size
		offSetXY: as-pair to-integer OffsetX to-integer OffsetY	;--Flir Offset as pair!
		imgOffset: cropXY / 2 + offSetXY						;--ROI Offset
		imgSize: cropXY +  thermal/size							;--ROI Size					
		img: rcvResizeImage visible imgSize						;--Resize destination image
		rcvCropImage visible img imgOffset						;--Crop ROI to destination
	][
		dec: visible/size % thermal/size
		factor: 0.85
		scale: max EmbeddedImageWidth / RawThermalImageWidth EmbeddedImageHeight / RawThermalImageHeight
		imgSize: visible/size * factor
		img: rcvResizeImage visible imgSize
		rcvCropImage visible img (dec * scale)
	]
	img
]


rcvGetPIPImage: func [
"Picture in Picture Mode"
	fileName	[string!]
	return:		[image!]
][
	thermal: load to-file fileName						;--Original Flir Image
	;--scale
	imgRatio: round/floor (EmbeddedImageWidth / RawThermalImageWidth / 4.0)
	;--pip mode is used if ratio > 1.0 otherwise returns the whole thermal image
	either imgRatio <= 1.0 [
		img: make image! as-pair RawThermalImageWidth RawThermalImageHeight
		rcvCropImage thermal img 0x0
	][
		imgSize: as-pair (PiPX1 + PiPX2) (PiPY1 + PiPY2)	;--PIP image Size 
		if odd? (PiPX1 + PiPX2) [imgSize: imgSize + 1]		;--0 or 1-based image computation
		img: make image! imgSize * imgRatio					;--correct scale	
		rcvCropImage thermal img as-pair PiPX1 + PiPX2 PiPY1 + PiPY2
	]
	img
]
