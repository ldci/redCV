Red [
	Title:   "Haar Cascade "
	Author:  "ldci"
	File: 	 %faceDetection.red
	Needs:	 View
]
OS: system/platform
if any [OS = 'macOS OS = 'Linux] [home: select list-env "HOME"] 
if any [OS = 'MSDOS OS = 'Windows][home: select list-env "USERPROFILE"]
;-- must be adapted to your directories
appDir: to-red-file rejoin [home "/Programmation/Red/RedCV/samples/image_haar"]
change-dir appDir

;--include Haar cascade library
#include %../../libs/objdetect/rcvHaarCascade.red		
;--default classifier
classifierFile: %../../libs/objdetect/cascades/face/face1.txt

screenx: system/view/screens/1/size/x
screeny: system/view/screens/1/size/y
margins: 10x10

;--default values for the classifier
nStages: none		;--from classifier file
totalNodes: none	;--from classifier file
ws: none			;--from classifier file
scale: 1.0			;--default value	
sThreshold: 0.2		;--default value
scaleFactor: 1.3	;--default value
step: 3				;--default value
minNeighbors: 1		;--default value
startPos: 0x0		;--default value
maxCandidates: 512	;--default value	
grouping?: true		;--default value
flag: 0				;--default value
nParameters: 23		;--default value
;--Red
isFile?: false		;--not yet file
viewFlag: 1			;--Haar Scale method by default


loadImage: does [
	tmpF: request-file
	unless none? tmpF [
		canvas1/image: none
		sb1/text: ""
		sb2/text: ""
		src: load tmpF
		clone: copy src
		sb1/text: rejoin [form src/size " pixels"]
		;--canvas size update
		wscale: max 1 1 + max (2 * margins/x + src/size/x) / screenx (4 * margins/y + 110 + src/size/y) / screeny
		win/size/x: to-integer (2 * margins/x + max 640 src/size/x / to-integer wscale)
		win/size/y: to-integer (4 * margins/y + 120 + max 150 src/size/y / to-integer wscale)
		canvas1/size: src/size / to-integer wscale
		canvas1/offset/x: to-integer (win/size/x - canvas1/size/x / 2)
		sb1/offset/y: canvas1/size/y + 130
		sb2/offset/y: canvas1/size/y + 130
		;--adaptation for Red 0.6.5 with Point2D datatype. redCV libs use pair and not Point2D 
		w_size: to-pair win/size
		sb2/size/x: w_size/x - 150
		b1/offset/x: w_size/x - 80
		b2/offset/x: w_size/x - 80
		canvas1/image: src
		isFile?: true
		searchFaces
	]
]

updateFields: does [
	;--reading classifier default values
	f1/text: form nStages
	f2/text: form totalNodes
	f22/text: form ws
	f3/text: form startPos
	f4/text: form sThreshold
	f5/text: form scaleFactor
	f6/text: form step
	f7/text: form minNeighbors
]

loadClassifier: does [
	;--reading classifier file, filling arrays, and updating cascade and pointers!
	b: rcvReadTextClassifier classifierFile nParameters ;--23 parameters
	nStages: b/1
	totalNodes: b/2
	ws: b/3
	rcvCreateHaarCascade nStages totalNodes scale ws
]

drawRects: func [
	rects	[block!]
] [
	plot: copy [line-width 2 pen green]
	;--best objects
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
	;--all candidates
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
	if error? try [sThreshold: to-float f4/text] [sThreshold: 0.5] 		;--must be > 0.0
	if error? try [scaleFactor: to-float f5/text] [scaleFactor: 1.2]	;--must be > 1.0
	if error? try [step: to-integer f6/text] [step: 1]					;--must be >= 1
	if error? try [minNeighbors: to-integer f7/text] [minNeighbors: 1]	;--must be >= 1

	sb2/text: "Face detection. Be patient..."
	src: copy clone
	canvas1/image: src
	;do-events/no-wait
	;--detect faces
	t1: now/time/precise
	faces: rcvDetectObjects 
			src startPos scaleFactor 
			step sThreshold 
			maxCandidates minNeighbors grouping? 
			flag
	t2: now/time/precise
	elapsed: round/to third (t2 - t1) 0.02 
	elapsed: to-integer (1000 * elapsed)
	n: length? faces
	sb2/text: rejoin [" Face Identified: " n " in " elapsed " ms"]
	;--draw result
	if n > 0 [drawRects faces]
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
	button "Load Image" [loadImage]
	;--these informations come from the classifier files
	text 80 "Stages"
	f1: field 50 with [enabled?: false]
	text 80 " Nodes"
	f2: field 50 with [enabled?: false]
	text "Window Size"
	f22: field 50 with [enabled?: false]
	pad 5x0
	b1: button 65 "Quit" [Quit]
	return
	;--parameters
	text 60 "Start Pixel" 	f3: field 60 
	text 60 "Threshold" 	f4: field 40  
	text 35 "Scale" 		f5: field 40
	text 35 "Step"			f6: field 40	
	text 60 "Neighbor"		f7: field 40
	;--search for faces in image
	b2: button 65 "Detect"	[if isFile? [searchFaces]]
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
		;--classifier parameters can be changed
		case [
			idx = 1 [
				classifierFile: %../../libs/objdetect/cascades/face/face1.txt
				setParameters 0.2 1.3 3 1] 	
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
		if isFile? [searchFaces]
	]
	
	text 50 "Method" 
	drop-down 120 data ["Haar Scale" "Canny Pruning"] 
	    select 1  
	    on-change [
	    	flag: face/selected - 1
	    	updateFields
	    	if isFile? [searchFaces]
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
		either viewFlag = 1 [grouping?: true] [grouping?: false]
		updateFields
		if isFile? [searchFaces]
	]
	return
	canvas1: base 640x480
	return
	;--information fields
	sb1: field 120 with [enabled?: false]
	sb2: field 510 with [enabled?: false]
	do [loadClassifier updateFields]; automatic default classifier reading
]