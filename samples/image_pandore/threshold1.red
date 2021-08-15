#!/usr/local/bin/red
Red [
	Title:   "Pandore test"
	Author:  "Francois Jouen"
	File: 	 %threshold.red
	Needs:	 'View
]

status: ""
isFile: false
srcImg: none
f: ""

lowT: 50
highT: 200

; update according to you OS and directory
home: select list-env "HOME"
panhome: rejoin [home "/Programmation/Librairies/pandore_6.6.10/"]
sampleDir: rejoin [panhome "examples/"]
tmpDir: rejoin [sampleDir "tmp/"]
;panvisu: "bin/pvisu.app/Contents/MacOS/pvisu" ; for macOS users
panvisu: "bin/pvisu" ; for macOS ou  Unix users
change-dir to-file panhome

; is pandore installed?
prog: "bin/pversion"
call/output prog status


; Converts red loaded image to pandore image
red2pan: func [img [file!] return: [string!]] [
	sb2/text: "Converting to pan..."
	status: ""
	fName: ""
	fName: form second split-path img
	filename: copy/part fName (length? fName) - 4 ;removes .ext
	append filename ".pan"
	prog: rejoin  ["bin/pany2pan " to-string img " " tmpDir fileName]
	call/console prog
	call/output "bin/pstatus" status
	sb2/text: "Image conversion: " 
	filename ; returns filename
]

; Pandore thresholding
thresholdPan: func [fn [string!] t1 [integer!] t2 [integer!]] [
	prog: rejoin ["bin/pthresholding " form T1 " " form T2 " " 
			tmpDir fn  " " tmpDir "result.pan"
	]
 	call prog 
	prog: rejoin [panvisu " " tmpDir "result.pan"]
	call prog
	call/output "bin/pstatus" status 
	
	
]


; Removes all pandore images in /tmp/ directory
removePanImg: does [
	prog: rejoin ["rm " tmpDir "*.pan"]
	call prog
	sb2/text: "All pandore images removed"
]

; Loads red image
loadImage: does [
	isFile: false
	clear sb2/text
	srcImg: request-file
	if not none? srcImg [
		canvas/image: load srcImg
		isFile: true
		sb2/text: "Red Image loaded"
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Pandore Thresholding"
		button 60 "Load" 				[loadImage f: red2pan srcImg append sb2/text status]			
		button 150 "Show Result Image" 	[ sb2/text: "Shows filtered pan image: "
											  thresholdPan f lowT highT	
											  append sb2/text status
										]
		button 150 "Remove Pan Images"	[removePanImg]
		pad 40x0
		button 70 "Quit" 				[ Quit]
		return
		text 50 "Low" 
		sl1: slider 400x16 [lowT: to-integer face/data * 255 lowsb/text: form lowT] 
		lowsb: field 40 "100"
		return
		text 50 "High"
		sl2: slider 400x16 [highT: to-integer face/data * 255 highsb/text: form highT]  
		highsb: field 40 "255"
		return
		canvas: base 512x512 black
		return
		sb1: field 206
		sb2: field 294
		do [sb1/text: status sl1/data: lowT / 255.0 sl2/data: highT / 255.0]	
]

