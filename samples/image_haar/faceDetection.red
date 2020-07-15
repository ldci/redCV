Red [
	Title:   "Haar Cascade "
	Author:  "Francois Jouen"
	File: 	 %faceDetection.red
	Needs:	 View
]

home: select list-env "HOME"
appDir: to-file rejoin [home "/Programmation/Red/redCV/samples/image_haar"]
change-dir to-file appDir

#include %../../libs/objdetect/rcvHaarCascade.red		; for Haar cascade

;default classifier
classifierFile: %../../libs/objdetect/cascades/face/face1.txt

screenx: system/view/screens/1/size/x
screeny: system/view/screens/1/size/y
margins: 10x10

; default values for classifier
nStages: 0
totalNodes: 0
ws: 0x0
scale: 1.0	

sThreshold: 0.2
scaleFactor: 1.3
step: 3
minNeighbors: 1
startPos: 0x0

maxCandidates: 512
grouping: true
flag: 0
isFile: false
viewFlag: 1
nParameters: 23

loadImage: does [
	tmpF: request-file
	if not none? tmpF [
		canvas1/image: none
		sb1/text: ""
		sb2/text: ""
		src: load tmpF
		clone: copy src
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
		sb2/size/x: win/size/x - 150
		b1/offset/x: win/size/x - 80
		b2/offset/x: win/size/x - 80
		canvas1/image: src
		isFile: true
		searchFaces
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
	;f1/enabled?: false
	;f2/enabled?: false
	;f22/enabled?: false
]

loadClassifier: does [
	;240 ms for reading, filling arrays, and updating cascade and pointers!
	b: rcvReadTextClassifier classifierFile nParameters
	nStages: b/1
	totalNodes: b/2
	ws: b/3
	rcvCreateHaarCascade nStages totalNodes scale ws
]

drawRects: func [
	rects	[block!]
] [
	plot: copy [line-width 2 pen green]
	;--first object
	if viewFlag = 1 [
		foreach r rects [
			tl: as-pair r/1 r/2
			br: as-pair (r/1 + r/3) (r/2 + r/4)
			append plot reduce ['box (tl) (br)]
			append plot reduce ['line-width 2 'pen green]
		]
	]
	;--biggest object
	if viewFlag = 2 [
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
		plot: copy [line-width 2 pen yellow]
		append plot reduce ['box (tl) (br)] ;' biggest rectangle
	]
	;--all objects
	if viewFlag = 3 [
		foreach r rects [
			tl: as-pair r/1 r/2
			br: as-pair (r/1 + r/3) (r/2 + r/4)
			append plot reduce ['box (tl) (br)]
			color: random white
			append plot reduce ['line-width 2 'pen (color)]
		]
	]	
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
			maxCandidates minNeighbors grouping 
			flag
		
	t2: now/time/precise
	n: length? faces
	;--draw result
	if n > 0 [drawRects faces]
	elapsed: round/to third (t2 - t1) 0.02 
	elapsed: to-integer (1000 * elapsed)
	sb2/text: rejoin ["Identified: " n " in " elapsed " ms"]
]

setParameters: func [
	param1			[float!]
	param2			[float!]
	param3			[integer!]
	param4			[integer!]	
][
	sThreshold: 	param1
	scaleFactor:	param2
	step:			param3
	minNeighbors:	param4
]


view win: layout [
	title "redCV: Haar Cascade Classifier"
	origin margins space margins
	button "Load" [loadImage]
	text 100 " Nb Stages"
	f1: field 50
	text 100 " Nb Nodes"
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
	
	text 70 "Classifier" 
	drop-down 150 data [
		"face 1 [default]"
		"face 2 [frontal]"
		"face 3 [frontal alt 1]"
		"face 4 [frontal alt 2]"
		"face 5 [frontal alt 3]"
		"face 6 [profile]"
		"eye 1 [default]"
		"eye 2 [big]"
		"eye 3 [small]"
		"eye 4 [left]"
		"eye 5 [right]"
		"eye 6 [left 2]"
		"eye 7 [right 2]"
		"mouth 1 [mcs]"
		"nose 1 [mcs]"  
		"ear 1 [right]"
		"ear 2 [left]"
	]
	select 1
	on-change [
		idx: face/selected
		case [
			idx = 1 [
				classifierFile: %../../libs/objdetect/cascades/face/face1.txt
				setParameters 0.2 1.3 3 1 ; for 1 face
				;setParameters 0.2 1.3 1 1 ; for N faces
				]
			idx = 2 [
				classifierFile: %../../libs/objdetect/cascades/face/face2.txt
				setParameters 0.4 1.6 2 1]
			idx = 3 [
				classifierFile: %../../libs/objdetect/cascades/face/face3.txt
				setParameters 1.0 1.2 3 1]	
			idx = 4 [
				classifierFile: %../../libs/objdetect/cascades/face/face4.txt
				setParameters 1.0 1.4 1 1]
			idx = 5 [
				classifierFile: %../../libs/objdetect/cascades/face/face5.txt
				setParameters 2.0 1.1 6 1]
			idx = 6 [
				classifierFile: %../../libs/objdetect/cascades/face/face6.txt
				setParameters 1.0 1.1 2 1]
			idx = 7 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye1.txt
				setParameters 1.0 1.1 1 1]
			idx = 8 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye2.txt
				setParameters 1.2 1.6 2 1]
			idx = 9 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye3.txt
				setParameters 2.3 1.5 1 2]
			idx = 10 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye4.txt
				setParameters 2.0 1.6 1 5]
			idx = 11 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye5.txt
				setParameters 1.8 1.5 1 1]
			idx = 12 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye6.txt
				setParameters 2.0 1.8 2 7]
			idx = 13 [
				classifierFile: %../../libs/objdetect/cascades/eye/eye7.txt
				setParameters 2.0 1.6 2 4]
			idx = 14 [
				classifierFile: %../../libs/objdetect/cascades/mouth/mouth1.txt
				setParameters 1.6 1.4 3 5]
			idx = 15 [
				classifierFile: %../../libs/objdetect/cascades/nose/nose1.txt
				setParameters 1.6 1.8 2 1]
			idx = 16 [
				classifierFile: %../../libs/objdetect/cascades/ear/ear1.txt
				setParameters 2.0 1.4 2 1]
			idx = 17 [
				classifierFile: %../../libs/objdetect/cascades/ear/ear2.txt
				setParameters 2.0 1.5 2 1]
		]
		loadClassifier
		updateFields
		if isFile [searchFaces]
	]
	
	text 50 "Method" 
	drop-down 120 data ["Haar Scale" "Canny Pruning"] 
	    select 1  
	    on-change [
	    	flag: face/selected - 1
	    	updateFields
	    	if isFile [searchFaces]
	]
	
	text 50 "View"
	drop-down 140 data [
		"Best Objects"
		"Biggest Object" 
		"All Candidates"
	]
	select 1
	on-change [
		viewFlag: face/selected
		if viewFlag <  2 [grouping: true]
		if viewFlag >= 2 [grouping: false]
		updateFields
		if isFile [searchFaces]
	]
	return
	canvas1: base 640x480
	return
	sb1: field 120
	sb2: field 510
	do [loadClassifier updateFields]; automatic classifier reading
]