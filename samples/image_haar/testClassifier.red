Red [
	Title:   "Haar Cascade "
	Author:  "Francois Jouen"
	File: 	 %testClassifier.red
	Needs:	 View
]

;-- must be adapted to your OS and your paths
home: select list-env "HOME"
appDir: to-file rejoin [home "/Programmation/Red/redCV/samples/image_haar"]
change-dir to-file appDir


#include %../../libs/objdetect/rcvHaarCascade.red		; for Haar cascade

;default
classifierFile: %../../libs/objdetect/cascades/face/face1.txt
screenx: system/view/screens/1/size/x
screeny: system/view/screens/1/size/y
margins: 10x10

; default values for classifier
nStages: 0
totalNodes: 0
ws: 0x0
scale: 1.0	
sizeX: 0
sizeY: 0

scaleFactor: 1.2
minNeighbors: 1
minSize: 20x20
startPos: 0x0
step: 1
sThreshold: 1.0
group: true
maxCandidates: 512
isFile: false
flagValue: 1

loadImage: does [
	;tmpF: request-file/file to-file rejoin [home "/Pictures/"] 
	tmpF: request-file
	if not none? tmpF [
		canvas1/image: none
		sb1/text: ""
		sb2/text: ""
		src: load tmpF
		clone: load tmpF
		sb1/text: rejoin [form src/size " pixels"]
		_sizex: src/size/x
		_sizey: src/size/y
		wscale: max 1 1 + max (2 * margins/x + _sizex) / screenx (4 * margins/y + 110 + _sizey) / screeny
		win/size/x: to-integer (2 * margins/x + max 640 src/size/x / to-integer wscale)
		win/size/y: to-integer (4 * margins/y + 120 + max 150 src/size/y / to-integer wscale)
		canvas1/size: src/size / to-integer wscale
		canvas1/offset/x: to-integer (win/size/x - canvas1/size/x / 2)
		sb1/offset/y: canvas1/size/y + 130
		sb2/offset/y: canvas1/size/y + 130
		sb2/size/x: to-integer win/size/x - 150
		b1/offset/x: to-integer win/size/x - 80
		b2/offset/x: to-integer win/size/x - 80
		canvas1/image: src
		isFile: true
	]
]

loadFile: does [
	f: request-file/file %../../libs/objdetect/cascades/ 
	if not none? f [
		classifierFile: f
		loadClassifier
		updateFields
		src: copy clone
		canvas1/image: src
		win/text: form f
		sb2/text: ""
	]
]

updateFields: does [
	f1/text: form nStages
	f2/text: form totalNodes
	f22/text: form ws
	f3/text: form startPos
	f4/text: form sThreshold
	f5/text: form scaleFactor
	f6/text: form step
	f7/text: form minNeighbors
	f1/enabled?: false
	f2/enabled?: false
	f22/enabled?: false
]

loadClassifier: does [
	b: rcvReadTextClassifier classifierFile 23
	nStages: b/1
	totalNodes: b/2
	ws: b/3
	rcvCreateHaarCascade nStages totalNodes scale ws
]

drawRect: func [
	rects	[block!]
] [
	plot: copy [line-width 2 pen green]
	foreach r rects [
		tl: as-pair r/1 r/2
		br: as-pair (r/1 + r/3) (r/2 + r/4)
		append plot reduce ['box (tl) (br)] ;' all rectangles
	]	
	canvas1/image: draw src plot
]


drawBiggestRect: func [
	rects	[block!]
] [
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
	plot: copy [line-width 2 pen green]
	append plot reduce ['box (tl) (br)] ;' biggest rectangle
	canvas1/image: draw src plot
]

searchFaces: func [
][
	if error? try [startPos: to-pair f3/text] [startPos: 0x0]
	if error? try [sThreshold: to-float f4/text] [sThreshold: 0.5] ; > 0.0
	if error? try [scaleFactor: to-float f5/text] [scaleFactor: 1.2] ; > 1.0
	if error? try [step: to-integer f6/text] [step: 1]
	if error? try [minNeighbors: to-integer f7/text] [minNeighbors: 1]

	sb2/text: "Face detection. Be patient..."
	src: copy clone
	canvas1/image: src
	do-events/no-wait
	;detect faces
	t1: now/time/precise
	faces: rcvDetectObjects 
			src startPos scaleFactor 
			step sThreshold
			maxCandidates minNeighbors group
			0 ;--no canny
	
	t2: now/time/precise
	n: length? faces
	;draw result
	if n > 0 [
		switch flagValue [
			1 [drawRect faces]
			2 [drawBiggestRect faces]
			3 [drawRect faces]
		]
	]
	
	elapsed: round/to third (t2 - t1) 0.02 
	elapsed: to-integer (1000 * elapsed)
	sb2/text: rejoin ["Identified: " n " in " elapsed " ms"]
]


view win: layout [
	title "redCV: Viola-Jones Haar Cascade"
	origin margins space margins
	button "Load" 		[loadImage]
	button "Classifier" [loadFile]
	text 50 "Stages"
	f1: field 50
	text 50 "Nodes"
	f2: field 50
	text "Window Size"
	f22: field 50
	pad 5x0
	b1: button 70 "Quit" [Quit]
	return
	text 60 "Start Pixel" 	f3: field 60  
	text 60 "Threshold" 	f4: field 40  
	text 35 "Scale" 		f5: field 40
	text 35 "Step"			f6: field 40	
	text 60 "Neighbor"		f7: field 40
	b2: button 70 "Detect"		[if isFile [searchFaces]]
	return
	text 100 "Method"
	drop-down 120 data ["Haar Scale" "Biggest Object" "All Candidates"] 
	    select 1  
	    on-change [
	    	flagValue: face/selected
	    	if flagValue < 3 [group: true] 
	    	if flagValue = 3 [group: false]
	    	if isFile [searchFaces]
	]
	
	return
	canvas1: base 640x480
	return
	sb1: field 120
	sb2: field 510
	do [loadClassifier updateFields]; automatic classifier reading
]