Red [
	Title:   "Test camera Red VID "
	Author:  "Francois Jouen"
	File: 	 %camFace2.red
	Needs:	 'View
]

home: select list-env "HOME"
appDir: to-file rejoin [home "/Programmation/Red/redCV/samples/image_haar"]
change-dir to-file appDir

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
scaleFactor: 1.5
step: 2
minNeighbors: 3
startPos: 0x0
maxCandidates: 128
grouping: true
flag: 0


camSize: 1280x720		;--default cam size for macOS
camRSize: camSize / 4	;--divide size by 4 for faster processing

cam: none 				;--for camera object
src1: make image! camSize
src2: make image! camRSize
margins: 5x10
plot: copy []

loadClassifier: does [
	b: rcvReadTextClassifier classifierFile nParameters
	nStages: b/1
	totalNodes: b/2
	ws: b/3
	rcvCreateHaarCascade nStages totalNodes scale ws
]

drawRects: func [
	rects	[block!]
][
	plot: copy [line-width 2 pen green]
	foreach r rects [
		tl: as-pair r/1 r/2
		br: as-pair (r/1 + r/3) (r/2 + r/4)
		append plot reduce ['box (tl) (br)]
		append plot reduce ['line-width 2 'pen green]
	]
	if cb/data [
		minArea: 0
		ct: 1
		big: 1
		foreach r rects [
			area: r/3 * r/4
			if area > minArea [minArea: area big: ct]
			ct: ct + 1
		]	
		r: rects/:big
		tl: as-pair r/1 r/2
		br: as-pair (r/1 + r/3) (r/2 + r/4)
		plot: copy [line-width 3 pen green]
		append plot reduce ['box (tl) (br)]
	]
	canvas/image: draw src2 plot
]

getFaces: does [
	;--reduce image size
	rcvNearestNeighbor src1 src2
	t1: now/time/precise
	faces: rcvDetectObjects 
		src2 startPos scaleFactor 
		step sThreshold 
		maxCandidates minNeighbors grouping 
		flag
	t2: now/time/precise
	elapsed: round/to third (t2 - t1) 0.02 
	elapsed: to-integer (1000 * elapsed)
	sb/text: rejoin [form elapsed " ms"]
	n: length? faces
	if n > 0 [drawRects faces]
]


view win: layout [
		title "Face Detection Red Camera"
		origin margins space margins
		cam: camera 2x20;--non visible camera just to get back image 
		cam-list: drop-list 170 on-create [face/data: cam/data]
		onoff: button "Start/Stop" on-click [
				either cam/selected [
					cam/selected: none
					canvas/rate: none
					canvas/image: none
					sb/text: ""
				][
					src1: to-image cam
					cam/selected: cam-list/selected
					canvas/rate: 0:0:0.04;  max 1/25 fps in ms
				]
		]
		btnQuit: button "Quit" on-click [quit]
		return
		pad 12x0
		canvas: base camRSize black on-time [
			src1: cam/image
			;--there is delay for the first frame
			if not none? src1 [getFaces]
			cam/image: none
		]
		return
		pad 12x0 
		cb: check "One Face" true ;--1 or n faces
		cb2: check "Canny" false [either face/data [flag: 1] [flag: 0]]
		sb: field 150
		do [cam-list/selected: 1 canvas/rate: none 
			cam/visible?: false loadClassifier]
]