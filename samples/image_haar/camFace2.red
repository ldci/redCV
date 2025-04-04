Red [
	Title:   "Test camera Red VID "
	Author:  "ldci"
	File: 	 %camFace2.red
	Needs:	 View
]

{similar to camFace1, but add grayscale transform}
;-- must be adapted to your OS and your paths
OS: system/platform
if any [OS = 'macOS OS = 'Linux] [home: select list-env "HOME"] 
if any [OS = 'MSDOS OS = 'Windows][home: select list-env "USERPROFILE"]
appDir: to-red-file rejoin [home "/Programmation/Red/RedCV/samples/image_haar"]
change-dir appDir
#include %../../libs/core/rcvCore.red
#include %../../libs/objdetect/rcvHaarCascade.red ;--for Haar cascade

;--default classifier
classifierFile: %../../libs/objdetect/cascades/face/face1.txt
;--default values for classifier
nStages: 0
totalNodes: 0
ws: 0x0
scale: 1.0	
nParameters: 23
sThreshold: 1.8
scaleFactor: 1.6
step: 2
minNeighbors: 3
startPos: 0x0
maxCandidates: 64
grouping: true
flag: 0

camSize: 1280x720			;--default cam size for macOS
camRSize2: camSize / 2		;--for canvas
camRSize4: camSize / 4		;--divide size by 4 for faster processing

cam: none 					;--for camera object
src0: make image! camSize	;--original image
src1: make image! camSize	;--original grayscale image
src2: make image! camRSize4	;--src0 reduced
src3: make image! camRSize4	;--src1 reduced

cBlk: []					;--for classifier
margins: 5x10

plot: compose [line-width 2 pen yellow box 0x0 5x5]

loadClassifier: does [
	cBlk: rcvReadTextClassifier classifierFile nParameters
	nStages: cBlk/1
	totalNodes: cBlk/2
	ws: cBlk/3
	rcvCreateHaarCascade nStages totalNodes scale ws
]

getFaces: does [
	rcvCopyImage src0  src1			;--a copy of source image
	rcv2Gray/average src0 src1		;--transformed to grayscale
	;--reduce original image size
	rcvNearestNeighbor src1 src2	;--reduced  gray image
	rcvNearestNeighbor src0 src3	;--reduced  RGB image
	
	t1: now/time/precise
	;--ATTENTION rcvDetectObjects inhibits and restores Red garbage collector
	;--not yet stable
	faces: rcvDetectObjects 
		src2 startPos scaleFactor 				;--use grayscale image
		step sThreshold 
		maxCandidates minNeighbors grouping		;--group candidates 
		flag
	t2: now/time/precise
	elapsed: round/to third (t2 - t1) 0.02 
	elapsed: to-integer (1000 * elapsed)
	sb/text: rejoin [form elapsed " ms"]
	;--draw rectangles
	if (length? faces) > 0 [
		minArea: 0 ct: big: 1
		foreach r faces [
			area: r/3 * r/4
			if area > minArea [minArea: area big: ct]
			ct: ct + 1
			plot/4: yellow 
			plot/6: as-pair r/1 r/2					;--top-left
			plot/7: as-pair (r/1 + r/3) (r/2 + r/4)	;--bottom-right
		]	
		if cb1/data [
			r: faces/:big
			plot/4: green
			plot/6: as-pair r/1 r/2					;--top-left
			plot/7: as-pair (r/1 + r/3) (r/2 + r/4)	;--bottom-right
		]
	]
	canvas/image: draw src3 plot
]

view win: layout [
		title "Red: Face Detection"
		origin margins space margins
		cam: camera 10x20;--non visible camera just to get back image 
		cam-list: drop-list 170 on-create [face/data: cam/data]
		cb1: check "One Face" true ;--1 or n faces
		cb2: check "Canny" false [either face/data [flag: 1] [flag: 0]]
		sb: field 100
		toggle 75 "Start" false [
				either cam/selected [
					face/text: "Start"
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					sb/text: mem/text: ""
				][
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
					src0: to-image cam
					cam/selected: cam-list/selected
					face/text: "Stop"
				]
		]
		
		btnQuit: button "Quit" on-click [quit]
		return
		canvas: base camRSize2 black on-time [
			src0: cam/image
			;--there is delay for the first frame
			unless none? src0 [getFaces]
			cam/image: none
			;mem/text: form stats/show
			mem/text: form stats/info
		]
		return
		mem: field 640
		do [cam-list/selected: 1 canvas/rate: none 
			cam/visible?: false loadClassifier]
]