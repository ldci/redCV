Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %reccam.red
	Needs:	 View
]

#include %../../libs/redcv.red ; for redCV functions

clevel: -1 ; default compression
camSize: 0x0 
res: ["160x120" "320x240"]
iSize: to-pair res/2
x: iSize/x + 15
xx: iSize/x 
y: iSize/y + 50
margins: 10x10
img: rcvCreateImage iSize
cam: none ; for camera
canvas: none
imgSize: 0
nImages: 0

t1: t2: now/time/precise
elapsed: t2 - t1
fn: %video.rvf
fTemp: %video.rvf.tmp
d: 0.0
fps: 0
zComp: 0
isCreated: true
isRecording: false

getResolution: does [
	cam/selected: camList/selected
	img: to-image cam
	cSize/text: form img/size
	res: copy []
	append res to-string img/size / 8
	append res to-string img/size / 4
	append res to-string img/size / 2
	append res to-string img/size
	resList/data: res
	resList/selected: 3
	iSize: to-pair res/3
	cam/selected: none	
]

upDateWin: does [
	canvas/size: iSize
	x: iSize/x + 20
	xx: iSize/x 
	y: canvas/offset/y + iSize/y
	cb/offset/x: x
	btnCreate/offset/x: x
	l1/offset/x: x
	btnSave/offset/x: x
	btnQuit/offset/x: x
	cpx/offset/x: x + 5
	onoff/offset/x: x
	resList/offset/x: x
	camList/offset/x: x
	win/size/x: canvas/size/x + 200
	win/size/y: btnQuit/offset/y + 50
	if y > btnQuit/offset/y  [win/size/y: y + 30]
]


createVideo: does [
	;fn: request-file/save/filter ["Red Video Files" "*.rvf"] 
	;gets problems with FileSave Mode /save
	fn: request-file
		if not none? fn [
			ff: copy to-string fn
			append ff ".tmp"
			fTemp: to-file ff
			print [type? fn]
			win/text: to-string fn
			write/binary fn "RCAM"					;Four CC Red signature
			write/binary fTemp "DATA"				;end of header
			isCreated: true
			nImages: 0
			t1: t2: now/time/precise
			elapsed: t2 - t1
		]
]

updateFile: does[
	write/binary/append fn to-binary nImages		;Number of images
	write/binary/append fn to-binary img/size/x		;Image x size
	write/binary/append fn to-binary img/size/y		;Image y size
	write/binary/append fn to-binary d				;duration in sec
	write/binary/append fn to-binary fps			;FPS
	write/binary/append fn to-binary zComp		 	;compressed data (1) or not (0)
	f: read/binary fTemp
	write/binary/append fn f
]


; to-image seems to work only for rgb and not for argb

processCam: does [
	nImages: nImages + 1
	ct/text: form nImages
	et/text: form now/time/precise - t1
	canvas/image: to-image cam 	; orginal image
	img: to-image canvas		; reduced size image
	either zComp = 0 [vdata: img/rgb] [vdata: rcvCompressRGB img/rgb clevel]
	n1: length? vdata
	n2: length? img/rgb
	compression: 100 - (100 * n1 / n2)
	if isCreated [
		write/binary/append fTemp to-binary n1	 		; compressed image size
		write/binary/append fTemp to-binary n2			; uncompressed image size
		write/binary/append fTemp vdata					;binary! #{FFOOFF...}	
	]
	cpx/text: rejoin [" Compression: " form compression]
	append cpx/text " %"
]

title: "Red Camera recording: "


view win: layout [
		title title
		origin margins space margins
		cam: camera 1x1
		b1: base margins black
		cSize: field 80
		ct: field 100
		et: field 110
		return
		canvas: base iSize img rate 0:0:1 on-time [processCam]
		at as-pair x 40 btnCreate: button 160 "Create Video" [createVideo]
		at as-pair x 70 camList: drop-list 160 
		on-create [face/data: cam/data append title cam/data/1]
		on-change [getResolution upDateWin
				i: face/selected
				win/text: copy "Red Camera recording: "
			    append win/text face/data/:i
		]
		
		at as-pair x 100 l1: text 160 "Camera resolution" center
		
		
		
		at as-pair x 130 resList: drop-list 160 
		on-create [getResolution upDateWin]
		on-change [ 
			i: face/selected
			iSize: to-pair face/data/:i
			upDateWin
		]
		
		at as-pair x 160 cb: check 160 "Compressed video" [either face/data [zComp: 1] [zComp: 0]]
		at as-pair x 190 onoff: button 160 "Start/Stop" on-click [
				either cam/selected [
					t2: now/time/precise
					elapsed: elapsed + t2 - t1
					b1/color: black
					d: to-float elapsed
					fps: to-integer round nImages / d
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					isRecording: false
				][
					cam/selected: camList/selected
					img: to-image cam
					camSize: (img/size/x * img/size/y) * 3 
					cSize/text: form img/size
					imgSize: iSize/x * iSize/y * 3
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
					b1/color: green
					isRecording: true
					t1: now/time/precise
				]
		]
		at as-pair x 220 btnSave: button 160 "Save" [if isCreated and not isRecording [updateFile]]
		at as-pair x + 5 250 cpx: field 150
		at as-pair x 280 btnQuit: button 160 "Quit" on-click [delete fTemp quit]
		do [camList/selected: 1 canvas/rate: none cam/visible?: false]
]