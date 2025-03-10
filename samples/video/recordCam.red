#!/usr/local/bin/red-view
Red [
	Title:   "Red camera and ffmpeg"
	Author:  "ldci"
	File: 	 %recordCam.red
	Needs:	 View
]

;--requires Ffmpeg. Works with video and audio devices!
;--redCV libs are not required

camSize: 1280x720 			;default Apple FaceTime Camera size
videoSize: form camSize 	;for Red visualization
iSize: camSize / 2 			;for Red camera GUI
cam: none 					;Red camera object 
fileName: "Untilted.mpg" 	;default file
vDevice: 0					;default video device
aDevice: 0					;default audio device
inputDevice: "avfoundation"	;macOS by default
frameRate: 25				;25 FPS
tg1: 	"film"				;for output target1
tg2:  	"dvd"				;for output target2
target: "film-dvd"			;for output target (tg1-tg2)
count: 0
t1: now/time
isFile: false
margins: 5x5

;--What OS is used. Then, set inputDevice
getPlatform: func [] [
	os: system/platform
	switch OS [
   		'macOS   	[inputDevice: "avfoundation"]
   	 	'Windows 	[inputDevice: "dshow"]
    	'Linux   	[inputDevice: "alsa"]
    	'FreeBSD	[inputDevice: "bktr"]
    	'Android 	[inputDevice: "android_camera"]
	]
	os
]

;Create video file
createVideo: does [
	tmp: request-file/filter/save [
		"Supported Video Files [mpg mp4 mkv avi wmv mov]" 
		"*.mpg";"*.mp4"; "*.mkv"; ".avi";".wmv";".mov"
	]
	if not none? tmp [
		fileName: form tmp 
		if exists? tmp [delete tmp] ; for ffmpeg
		win/text: fileName
		isFile: true
	]
]

;Get video properties
getVideoInfo: does [
	img: to-image cam
	cSize/text: copy form img/size
	img: none	
	frate/text: form frameRate
]

;Set output video target
setVideoOutput: does [
	target: copy ""
	append append append target tg1 "-" tg2
]

;Create ffmpeg command line
generateCommands: func [] [
	blk: rejoin [
		"ffmpeg" 								;location of ffmepg binary
		" -f " inputDevice						;OS input device
		" -framerate " frameRate				;FPS
		" -video_size " videoSize				;video size
		" -i " "'" vDevice "':'" aDevice "'"	;record video AND audio
		" -target " target						;output target 
		" '" fileName "'"						;output file name
	]
	form blk									;command line string
]

getVideoSize: func [] [
	attempt [
		round/to ((size? to-file fileName) / 1000000.0) 0.01
	]
]

;*************************** Main ******************************
view win: layout [
	title "Red camera recording with ffmpeg"
	origin margins space margins
	text 50 bold "Output" 
	drop-down 50 data ["film" "pal" "ntsc"]
		select 1
		on-change [tg1: face/data/(face/selected) setVideoOutput]
	
	drop-down 50 data ["dvd" "vcd" "svcd"]
		select 1
		on-change [tg2: face/data/(face/selected) setVideoOutput]
	
	drop-down 85 data ["1280x720" "640x480"]
		select 1
		on-change [videoSize: face/data/(face/selected)]
		
	sl: slider 100 [frameRate: 1 + to-integer sl/data * 29 
				ffps/text: form frameRate append ffps/text " fps"]
	ffps: field 45
	
	button "Create Video" on-click [createVideo]
	b1: button 50 "Start" on-click [
		unless isFile [alert "Create video first!"]
		if isFile [
			either cam/selected [
				call/wait "killall ffmpeg"
				cam/selected: none
				tF/rate: sF/rate: none
				count: 0
				b1/text: "Start"
				sF/text: form getVideoSize
				append sF/text " Mo"
				isFile: false
			][
				call generateCommands
				cam/selected: camList/selected
				if count = 0 [getVideoInfo]
				count: count + 1 
				b1/text: "Stop"
				t1: now/time
				tF/rate: sF/rate: 0:0:1 
			]
		]
	]
	
	button "Quit" 50 on-click [call/wait "killall ffmpeg" quit]
	return
	cam: camera iSize black 
	return
	camList: drop-list 230 
		on-create [face/data: cam/data]
		on-change [vDevice: camList/selected - 1  
					fDevice/text: form vdevice
					aDevice: 0]
	fDevice: field 30 
	text 40 bold "Size"
	cSize: field 70
	text 30 bold "FPS"
	frate: field 30 
	tF: field 60 on-time [face/text: form now/time - t1]	
	sF: field 110 right on-time [face/text: form getVideoSize
		append face/text " Mo" recycle ]
	do [getPlatform camList/selected: 1 vDevice: 0 aDevice: 0 fDevice/text: form vDevice 
	tF/rate: none sl/data: 80% ffps/text: form frameRate append ffps/text " fps"]
]