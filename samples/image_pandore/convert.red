#!/usr/local/bin/red-view
Red [
	Title:   "Pandore test"
	Author:  "ldci"
	File: 	 %convert.red
	Needs:	 'View
]
;'

status: ""
isFile: false
srcImg: none
f: ""

; update according to you OS and directory
OS: system/platform
if any [OS = 'macOS OS = 'Linux ] [home: select list-env "HOME"] 
if any [OS = 'MSDOS OS = 'Windows][home: select list-env "USERPROFILE"]

panhome: rejoin [home "/Programmation/pandore"]
sampleDir: rejoin [panhome "/examples/"]
tmpDir: rejoin [sampleDir "tmp/"]
if not exists? to-file tmpDir [make-dir to-file tmpDir]

;panvisu: "bin/pvisu.app/Contents/MacOS/pvisu" ; for macOS users with QT support
panvisu: "bin/pvisu" ; for macOS ou Unix users
;--for macOS compile pvisu/red
change-dir to-file panhome

;--is pandore installed?
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
	call/wait prog
	call/output "bin/pstatus" status
	sb2/text: "Image conversion: " 
	filename ; returns filename
]


;pthresholding 100 1e30 tangram.pan out.pan

; Call pandore pvisu.app to show pan image
showPan: func [fn [string!]] [
	prog: rejoin [panvisu " " tmpDir fn]
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
	unless none? srcImg [
		canvas/image: load srcImg
		isFile: true
		sb2/text: "Red Image loaded"
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Red and Pandore C++ Lib"
		button 60 "Load" 					[loadImage]			
		button 150 "Convert to Pan Image" 	[if isFile [
												f: red2pan srcImg 
												append sb2/text status]
											]
		button 150 "Show Pan Image" 		[either not empty? f [ 
													sb2/text: "Shows converted pan image: "
													showPan f append sb2/text status
												] [sb2/text: " No pan image to show"]
											]
		button 150 "Remove Pan Images" 		[removePanImg f: ""]
		button 70 "Quit" 					[Quit]
		return
		canvas: base 640x480 black
		return
		sb1: field 206
		sb2: field 424
		do [sb1/text: status]	
]
