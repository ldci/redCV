#!/usr/local/bin/red
Red [
	Title:   "Pandore test"
	Author:  "ldci"
	File: 	 %threshold2.red
	Needs:	 'View
]
;'
#include %../../libs/pandore/panlibObj.red
File: false
srcImg: none
panFile: ""
pFile: none
panImg: none
lowT: 0
highT: 255
prog: make string! ""
status: ""
dSize: 256
gsize: as-pair dSize dSize
sldSize: as-pair ((dSize * 3) - 100) 16

;--update according to you OS and pandore directory
OS: system/platform
if any [OS = 'macOS OS = 'Linux ] [home: select list-env "HOME"] 
if any [OS = 'MSDOS OS = 'Windows][home: select list-env "USERPROFILE"]
panhome: rejoin [home "/Programmation/pandore/"]
sampleDir: rejoin [panhome "examples/"]
tmpDir: rejoin [sampleDir "tmp/"]
if not exists? to-file tmpDir [make-dir to-file tmpDir]
change-dir to-file panhome

;--is pandore installed?
call/output "bin/pversion" status

;--Converts red loaded image to pandore image
red2pan: func [img [file!] return: [string!]] [
	fName: ""
	fName: form second split-path img
	fileName: copy/part fName (length? fName) - 4 ;removes .ext
	append fileName ".pan"
	call/wait rejoin ["bin/pany2pan " to-string img " " tmpDir fileName]
	call/output "bin/pstatus " status
	fileName ; returns filename
]

;--Pandore thresholding
{pthresholding builds the output image  with the pixels of the input image 
that have a value greater or equal than low or lower or equal than high. Other values are set to 0}

thresholdPan: func [fn [string!] t1 [integer!] t2 [integer!]] [
	call/wait rejoin [
		"bin/pthresholding " form T1 " " form T2 " " 
		tmpDir fn  " " tmpDir "result.pan"
	]
	call/output "bin/pstatus" status 	
]

;--Converts to jpg
pan2JPG: does [
	call/wait rejoin ["bin/ppan2jpeg 1.0 " tmpDir "result.pan " tmpDir "result.jpg" ]
	call/output "bin/pstatus" status 
	sb2/text: rejoin ["Filtered pandore image: " status]
	if cb/data [
		pandore/pobject/split: true
		pandore/readPanImage  pFile
		panImg/rgb: pandore/pobject/data
		canvas2/image: panImg
	]
]

;--Removes all pandore images in tmp directory
removePanImg: does [
	call rejoin ["rm " tmpDir "*.pan"]
	sb3/text: "All pandore images removed"
]

;--Loads red image
loadImage: does [
	isFile: false
	clear sb2/text
	clear sb3/text
	canvas2/image: canvas3/image: none
	tmpFile: request-file
	unless none? tmpFile [
		srcImg: load tmpFile
		panImg:  make image! srcImg/size
		canvas1/image: srcImg
		isFile: true
		sb3/text: "Red Image loaded"
		pFile: to-file rejoin [tmpDir "result.pan"]
	]
]

;--Processes image
process: does [
	resImg: to-file rejoin [tmpDir "result.jpg"]
	thresholdPan panFile lowT highT	
	pan2JPG
	sb3/text: rejoin ["Filtered pandore image to jpg: " status]
	if exists? resImg [canvas3/image: load resImg]
]

; ***************** Test Program ****************************
view win: layout [
		title "Pandore Thresholding from Red"
		button 100 "Load Image" 			[loadImage panFile: red2pan tmpFile process]
		cb: check 100 "Show Pandore" false
		button 160 "Remove Pandore Images"	[removePanImg]	
		pad 310x0		
		button 70 "Quit" 					[Quit]
		return
		text 50 "Low" 
		sl1: slider sldSize [lowT: to-integer face/data * 255 
							lowsb/text: form lowT 
							if isFile [process]
		] 
		lowsb: field 40 "0"
		return
		text 50 "High"
		sl2: slider sldSize [highT: to-integer face/data * 255 
							highsb/text: form highT
							if isFile [process]
		]  
		highsb: field 40 "255"
		return
		text dSize "Source"
		text dSize "Pandore"
		text dSize "Result"
		return
		canvas1: base gsize black
		canvas2: base gsize black
		canvas3: base gsize black
		return
		sb1: field dSize
		sb2: field dSize
		sb3: field dSize
		do [sb1/text: status sl1/data: lowT / 255.0 sl2/data: highT / 255.0]	
]

